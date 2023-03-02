import 'dart:convert';

import 'package:example/app_config.dart';
import 'package:example/env/env.dart';
import 'package:example/localizations.dart';
import 'package:example/main.dart';
import 'package:example/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:toast/toast.dart';

import 'choose_user_page.dart';
import 'home_page.dart';

class AuthDetails {
  final String idToken;
  final String refreshToken;
  final String accessToken;
  final String streamToken;

  const AuthDetails({
    required this.idToken,
    required this.refreshToken,
    required this.accessToken,
    required this.streamToken
  });

  factory AuthDetails.fromJson(Map<String, dynamic> json) {
    return AuthDetails(
      idToken: json['id_token'],
      refreshToken: json['refresh_token'],
      accessToken: json['access_token'],
      streamToken: json['stream_token']
    );
  }
}

Future<AuthDetails> login(String userName, String password) async {
  final response = await http.post(
    Uri.parse(backendUrl + '/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': userName,
      'password': password
    }),
  );

  if (response.statusCode == 200) {
    return AuthDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception(jsonDecode(response.body));
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
      appBar: AppBar(
        backgroundColor: StreamChatTheme.of(context).colorTheme.barsBg,
        elevation: 1,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).login,
          style: StreamChatTheme.of(context).textTheme.headlineBold.copyWith(
              color: StreamChatTheme.of(context).colorTheme.textHighEmphasis),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              form(),
              SizedBox(height: 30),
              bottom(),
              SizedBox(height: 30),
              signUp()
            ],
          ),
        ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  Widget form() {
    return Container(
      width: 330,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.zero,
            child: TextField(
              controller: _usernameController,
              autocorrect: false,
              autofocus: false,
              style: TextStyle(
                fontSize: 20,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis,
              ),
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
                ),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                fillColor: StreamChatTheme.of(context).colorTheme.inputBg,
                filled: true,
                labelText: AppLocalizations.of(context).username,
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              autocorrect: false,
              autofocus: false,
              style: TextStyle(
                fontSize: 20,
                color: StreamChatTheme.of(context)
                    .colorTheme
                    .textHighEmphasis,
              ),
              decoration: InputDecoration(
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: StreamChatTheme.of(context).colorTheme.textLowEmphasis,
                ),
                border: UnderlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                fillColor: StreamChatTheme.of(context).colorTheme.inputBg,
                filled: true,
                labelText: AppLocalizations.of(context).password,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget bottom() {
    return ElevatedButton(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(330, 20)),
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).brightness == Brightness.light
                  ? StreamChatTheme.of(context)
                  .colorTheme
                  .accentPrimary
                  : Colors.white),
          elevation: MaterialStateProperty.all<double>(0),
          padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(vertical: 16)),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Text(
          AppLocalizations.of(context).login,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness != Brightness.light
                ? StreamChatTheme.of(context)
                .colorTheme
                .accentPrimary
                : Colors.white,
          ),
        ),
        onPressed: () async {
          if (loading) {
            return;
          }
          loading = true;
          showDialog(
            barrierDismissible: false,
            context: context,
            barrierColor:
            StreamChatTheme.of(context).colorTheme.overlay,
            builder: (context) => Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: StreamChatTheme.of(context)
                      .colorTheme
                      .barsBg,
                ),
                height: 100,
                width: 100,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
          try {
            AuthDetails? authDetails = await login(
                _usernameController.text, _passwordController.text
            );
            final apiKey = Env.streamChatApiKey;
            final username = _usernameController.text;
            final streamToken = authDetails.streamToken;
            final accessToken = authDetails.accessToken;
            final client = buildStreamChatClient(apiKey);

            try {
              await client.connectUser(
                User(id: username, extraData: {
                  'name': username,
                }),
                streamToken,
              );

              final secureStorage = FlutterSecureStorage();
              secureStorage.write(
                key: kStreamApiKey,
                value: apiKey,
              );
              secureStorage.write(
                key: kStreamUserId,
                value: username,
              );
              secureStorage.write(
                key: kStreamToken,
                value: streamToken,
              );
              secureStorage.write(
                key: kAccessToken,
                value: accessToken,
              );
            } catch (e) {
              print(e);
              var errorText =
                  AppLocalizations.of(context).errorConnecting;
              if (e is Map) {
                errorText = e['message'] ?? errorText;
              }
              Toast.show(
                  errorText, duration: Toast.lengthLong,
                  gravity: Toast.top, backgroundColor: Colors.red
              );
              Navigator.pop(context);
              loading = false;
              return;
            }
            loading = false;
            await Navigator.pushNamedAndRemoveUntil(
              context,
              Routes.HOME,
              ModalRoute.withName(Routes.HOME),
              arguments: HomePageArgs(client),
            );
          } catch(e) {
            var errorText = e.toString();
            if (e is Map) {
              errorText = e['message'] ?? errorText;
            }
            Toast.show(
                errorText.toString(), duration: Toast.lengthLong,
                gravity: Toast.top, backgroundColor: Colors.red
            );
            Navigator.pop(context);
            loading = false;
            return;
          }
        }
    );
  }

  Widget signUp() {
    return Container(
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Click here to ",
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).brightness != Brightness.light
                  ? Colors.white
                  : StreamChatTheme.of(context)
                  .colorTheme
                  .accentPrimary,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.SIGNUP_PAGE),
            child: Text(
              AppLocalizations.of(context).signUp,
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).brightness != Brightness.light
                      ? Colors.white
                      : StreamChatTheme.of(context)
                      .colorTheme
                      .accentPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
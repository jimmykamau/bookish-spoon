import 'dart:convert';

import 'package:example/app_config.dart';
import 'package:example/localizations.dart';
import 'package:example/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:toast/toast.dart';

Future<http.Response> signUp(String email, String username, String password) async {
  return await http.post(
    Uri.parse(backendUrl + '/signup'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
      'email': email
    }),
  );
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
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
          AppLocalizations.of(context).signUp,
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
              SizedBox(height: 50),
              signIn()
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
    _emailController.dispose();
  }

  Widget form() {
    return Container(
      width: 330,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: TextField(
              controller: _emailController,
              autocorrect: false,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
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
                labelText: AppLocalizations.of(context).emailAddress,
              ),
            ),
          ),
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
          AppLocalizations.of(context).signUp,
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

          http.Response? response = await signUp(
              _emailController.text,
              _usernameController.text,
              _passwordController.text
          );
          if (response.statusCode == 201) {
            final secureStorage = FlutterSecureStorage();
            secureStorage.write(
              key: kUsername,
              value: _usernameController.text,
            );
            Toast.show(
                "A confirmation email has been sent to " + _emailController.text,
                duration: Toast.lengthLong,
                gravity: Toast.top, backgroundColor: Colors.green
            );
            loading = false;
            await Navigator.pushNamed(context, Routes.CONFIRM_ACCOUNT_PAGE);
          } else {
            Toast.show(
                response.body.toString(),
                duration: Toast.lengthLong,
                gravity: Toast.top, backgroundColor: Colors.red
            );
            Navigator.pop(context);
            loading = false;
            return;
          }
        }
    );
  }

  Widget signIn() {
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
            onTap: () => Navigator.pushNamed(context, Routes.LOGIN_PAGE),
            child: Text(
              AppLocalizations.of(context).login,
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
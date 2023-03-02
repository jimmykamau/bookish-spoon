import 'dart:convert';

import 'package:example/app_config.dart';
import 'package:example/localizations.dart';
import 'package:example/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:toast/toast.dart';

Future<http.Response> confirmSignup(String confirmationCode) async {
  final secureStorage = FlutterSecureStorage();
  String? username = await secureStorage.read(key: kUsername);
  return await http.post(
    Uri.parse(backendUrl + '/signup/confirm'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username ?? kUsername,
      'confirmation_code': confirmationCode
    }),
  );
}

class ConfirmAccountPage extends StatefulWidget {
  @override
  _ConfirmAccountPageState createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  final _confirmationCodeController = TextEditingController();
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
            AppLocalizations.of(context).confirmAccount,
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
    _confirmationCodeController.dispose();
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
              controller: _confirmationCodeController,
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
                labelText: 'Confirmation Code',
              ),
            ),
          ),
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
          AppLocalizations.of(context).confirmAccount,
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

          http.Response? response = await confirmSignup(
              _confirmationCodeController.text
          );
          if (response.statusCode == 200) {
            Toast.show(
                "Account confirmed. Please log in",
                duration: Toast.lengthLong,
                gravity: Toast.top, backgroundColor: Colors.green
            );
            loading = false;
            await Navigator.pushNamed(context, Routes.LOGIN_PAGE);
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
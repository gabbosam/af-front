import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'main.dart';
import 'utils.dart';

class ChangePasswordPage extends StatelessWithDialogWidget {
  ChangePasswordPage(this.response);

  final Map<String, dynamic> response;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool validateStructure(String value) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  Future<Map> updatePassword(String jwt, String newpassword) async {
    var res = await http
        .post(
      "$SERVER_IP/update-me",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': APIKEY
      },
      body: jsonEncode({"newpassword": newpassword}),
    )
        .catchError((error) {
      print(error.toString());
    });
    var statusCode;
    try {
      statusCode = res.statusCode;
    } catch (er) {
      return null;
    }

    if (statusCode == 200) return json.decode(res.body);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text("Modifica password")]),
        ),
        floatingActionButton: Builder(builder: (BuildContext context) {
          return FloatingActionButton.extended(
            onPressed: () async {
              // Find the Scaffold in the widget tree and use
              // it to show a SnackBar.

              if (!validateStructure(_passwordController.text) ||
                  _passwordController.text.length < 8) {
                Scaffold.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 15),
                  content: Text(
                      'La password deve essere di almeno 8 caratteri:\n\n  - Almeno 1 carattere maiuscolo\n  - Almeno 1 carattere minuscolo\n  - Almeno 1 numero\n  - Almeno un carattere speciale ( ! @ # \$ & * ~ )'),
                ));
                // displayDialog(context, "Password non valida",
                //     "La passoword deve contenere:Almeno 1 carattere maiuscolo\Almeno 1 lcarattere minuscolo\nAlmeno 1 numero\nAlmeno un carattere speciale ( ! @ # \$ & * ~ )");
                // show dialog/snackbar to get user attention.
                return;
              } else if (_passwordController.text !=
                  _confirmPasswordController.text) {
                Scaffold.of(context)
                    .showSnackBar(failSnack('Le password non combaciano'));
              }

              var jwt = this.response["token"];
              var res = await updatePassword(jwt, _passwordController.text);

              var snack =
                  doneSnack('La password è stata modificata correttamente');
              if (res == null) {
                snack = failSnack(
                    'Errore nel salvataggio della nuova password, riprovare');
              }
              Scaffold.of(context).showSnackBar(snack);
              // Continue
            },
            label: Text('Salva password'),
            icon: Icon(Icons.save),
            backgroundColor: Colors.red,
          );
        }),
        body: ContainerBoxDecorationWithOpacity(
            imagePath: STATIC_ENDPOINT + '/scudetto_BN.png',
            child: Column(children: <Widget>[
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Conferma Password'),
              ),
            ])));
  }
}

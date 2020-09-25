import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'main.dart';
import 'utils.dart';

class PrivacyPage extends StatelessWithDialogWidget {
  PrivacyPage(this.response);

  final Map<String, dynamic> response;

  Future<Map> updatePrivacy(String jwt, int privacy) async {
    var res = await http
        .post(
      "$serverIp/update-me",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
      body: jsonEncode({"privacy": privacy}),
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
              children: [Text("Informativa privacy")]),
        ),
        body: ContainerBoxDecorationWithOpacity(
            imagePath: STATIC_ENDPOINT + '/scudetto_BN.png',
            child: Column(children: <Widget>[
              RichText(
                text: TextSpan(
                  text: 'Autorizzo ',
                  children: <TextSpan>[
                    TextSpan(
                        text: 'Atletico Fabriano ASD',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            '  al trattamento dei miei dati relativi allo stato di salute contenuti del modello di Autocertificazione ed alla sua conservazione ai sensi del Reg. Eu 2016/679 e della normativa nazionale vigente.'),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 300.0,
                height: 60.0,
                child: RaisedButton(
                    onPressed: () async {
                      var jwt = this.response["token"];
                      var res = await updatePrivacy(jwt, 1);
                      if (res != null) {
                        //Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MenuRoute(this.response)),
                        );
                      } else {
                        displayDialog(context, "Informativa privacy",
                            "Accettazione fallita, riprovare");
                      }
                    },
                    child: Text("ACCETTA E PROSEGUI",
                        style: TextStyle(fontSize: 20))),
              ),
            ])));
  }
}

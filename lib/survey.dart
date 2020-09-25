import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'const.dart';
import 'main.dart';
import 'utils.dart';

class SurveyPage extends StatefulWithDialogWidget {
  final Map<String, dynamic> response;

  SurveyPage(this.response);
  @override
  _SuveyPageState createState() => _SuveyPageState(this.response);
}

class _SuveyPageState extends State<SurveyPage> {
  _SuveyPageState(this.response);
  final Map<String, dynamic> response;
  final _formKey = GlobalKey<FormState>();

  bool febbre = false;
  bool tosse = false;
  bool stanchezza = false;
  bool gola = false;
  bool testa = false;
  bool muscoli = false;
  bool naso = false;
  bool nausea = false;
  bool vomito = false;
  bool gusto = false;
  bool congiuntivite = false;
  bool diarrea = false;
  bool covid = false;
  bool sospetti = false;
  bool familiari = false;
  bool conviventi = false;
  bool contatti = false;

  bool showBanner = true;

  Future<Map> addSurvey(String jwt) async {
    var res = await http
        .post(
      "$serverIp/add-survey",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
      body: jsonEncode({
        "febbre": febbre,
        "tosse": tosse,
        "stanchezza": stanchezza,
        "gola": gola,
        "testa": testa,
        "muscoli": muscoli,
        "naso": naso,
        "nausea": nausea,
        "vomito": vomito,
        "gusto": gusto,
        "congiuntivite": congiuntivite,
        "diarrea": diarrea,
        "covid": covid,
        "sospetti": sospetti,
        "familiari": familiari,
        "conviventi": conviventi,
        "contatti": contatti,
      }),
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
          automaticallyImplyLeading: false,
          title: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MenuRoute(this.response)));
              },
            ),
            Text("Autocertificazione")
          ]),
        ),
        floatingActionButton: Builder(builder: (BuildContext context) {
          return FloatingActionButton(
              child: Icon(Icons.save),
              onPressed: () async {
                var jwt = this.response["token"];
                Scaffold.of(context).showSnackBar(
                    doneSnack('Salvataggio in corso ...attendere'));
                var response = await addSurvey(jwt);
                if (response != null) {
                  // Scaffold.of(context).showSnackBar(
                  //     doneSnack('Autocertificazione salvata correttamente'));

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MenuRoute(response)));
                } else {
                  Scaffold.of(context).showSnackBar(failSnack(
                      "Errore nel salvataggio dell'autocertificazione"));
                }
              });
        }),
        body: ContainerBoxDecorationWithOpacity(
          imagePath: STATIC_ENDPOINT + '/scudetto_BN.png',
          child: Form(
              key: _formKey,
              child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5.0),
                  children: <Widget>[
                    if (showBanner)
                      MaterialBanner(
                          contentTextStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                          backgroundColor: Colors.amber[200],
                          forceActionsBelow: true,
                          actions: [
                            FlatButton(
                                onPressed: () {
                                  setState(() => showBanner = false);
                                },
                                child: Text("HO CAPITO"))
                          ],
                          content: Text(
                            "Se non hai riscontrato nessun sintomo non modificare nulla e salva l'autocertificazione",
                          )),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Row(children: [
                              Text("Sintomi riscontrati negli ultimi 14 giorni",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Row(children: [
                              Text("Febbre > 37.5°"),
                              Switch(
                                value: febbre,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    febbre = !febbre;
                                  });
                                },
                              )
                            ]),
                          ),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Row(children: [
                              Text("Tosse"),
                              Switch(
                                value: tosse,
                                onChanged: (bool newValue) {
                                  setState(() {
                                    tosse = !tosse;
                                  });
                                },
                              )
                            ]),
                          ),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Stanchezza"),
                                Switch(
                                  value: stanchezza,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      stanchezza = !stanchezza;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Mal di gola"),
                                Switch(
                                  value: gola,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      gola = !gola;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Mal di testa"),
                                Switch(
                                  value: testa,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      testa = !testa;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Dolori muscolari"),
                                Switch(
                                  value: muscoli,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      muscoli = !muscoli;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Congestione nasale"),
                                Switch(
                                  value: naso,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      naso = !naso;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Nausea"),
                                Switch(
                                  value: nausea,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      nausea = !nausea;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Vomito"),
                                Switch(
                                  value: vomito,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      vomito = !vomito;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Perdita di olfatto e gusto"),
                                Switch(
                                  value: gusto,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      gusto = !gusto;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Congiuntivite"),
                                Switch(
                                  value: congiuntivite,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      congiuntivite = !congiuntivite;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("Diarrea"),
                                Switch(
                                  value: diarrea,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      diarrea = !diarrea;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Row(children: [
                              Text("Eventuale esposizione al contagio",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                          ),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text(
                                    "CONTATTI con casi\nCOVID19 accertati\n(tampone positivo)"),
                                Switch(
                                  value: covid,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      covid = !covid;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text("CONTATTI con casi sospetti"),
                                Switch(
                                  value: sospetti,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      sospetti = !sospetti;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text(
                                    "CONTATTI con familiari\ndi casi sospetti"),
                                Switch(
                                  value: familiari,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      familiari = !familiari;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text(
                                    "CONVIVENTI con febbre\no sintomi influenzali\n(no tampone)"),
                                Switch(
                                  value: conviventi,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      conviventi = !conviventi;
                                    });
                                  },
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Row(children: [
                                Text(
                                    "CONTATTI con febbre\no sintomi influenzali\n(no tampone)"),
                                Switch(
                                  value: contatti,
                                  onChanged: (bool newValue) {
                                    setState(() {
                                      contatti = !contatti;
                                    });
                                  },
                                )
                              ])),
                        ])
                  ])),
        ));
  }
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:io';
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qrscan/qrscan.dart' as scanner;

import 'const.dart';
import 'user_profile.dart';
import 'change_password.dart';
import 'privacy_page.dart';
import 'survey.dart';
import 'utils.dart';

Map<String, dynamic> decodeJWTPayload(String jwt) {
  return json
      .decode(ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));
}

void main() {
  runApp(MyApp());
}

class ContainerBoxDecorationWithOpacity extends StatelessWidget {
  ContainerBoxDecorationWithOpacity({this.imagePath, this.child});
  final String imagePath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: this.child,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            image: DecorationImage(
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.95), BlendMode.screen),
          image: Image.network(this.imagePath).image,
          fit: BoxFit.cover,
        )));
  }
}

class StatelessWithDialogWidget extends StatelessWidget {
  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    throw UnimplementedError();
  }
}

class StatefulWithDialogWidget extends StatefulWidget {
  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  @override
  Widget build(BuildContext context) {
    // ignore: todo
    // TODO: implement build
    throw UnimplementedError();
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class LoginPage extends StatefulWithDialogWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberLogin = false;

  Future<Map> attemptLogIn(String username, String password) async {
    var res = await http
        .post("$SERVER_IP/login",
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              'x-api-key': APIKEY
            },
            body: jsonEncode(
                <String, String>{'username': username, 'password': password}))
        .catchError((error) {
      print(error.toString());
    });
    try {
      if (res.statusCode == 200) return json.decode(res.body);
    } catch (e) {
      //return <String, String>{"message": e.toString()
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Check@pp"),
        ),
        body: ContainerBoxDecorationWithOpacity(
          imagePath: STATIC_ENDPOINT + '/scudetto_BN.png',
          child: Column(
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Checkbox(
                        value: _rememberLogin,
                        onChanged: (bool newValue) {
                          var value = newValue ? "1" : "0";
                          window.localStorage["remember"] = value;
                          setState(() {
                            _rememberLogin = newValue;
                          });
                        }),
                  ),
                  Text("Mantieni l'accesso"),
                ],
              ),
              SizedBox(
                height: 50.0,
              ),
              SizedBox(
                width: 200.0,
                height: 60.0,
                child: RaisedButton(
                    padding: EdgeInsets.all(10.0),
                    onPressed: () async {
                      var username = _usernameController.text;
                      var password = _passwordController.text;
                      var response = await attemptLogIn(username, password);
                      if (response != null) {
                        window.localStorage["refreshToken"] =
                            response["refresh_token"];

                        var payload = decodeJWTPayload(response["token"]);
                        var privacy = payload["privacy"];
                        if (privacy == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PrivacyPage(response)),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuRoute(response)),
                          );
                        }
                      } else {
                        displayDialog(context, "Accesso negato",
                            "Username o password errate");
                      }
                    },
                    child: Text("ACCEDI", style: TextStyle(fontSize: 20))),
              )
            ],
          ),
        ));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map> get jwtOrEmpty async {
    if (window.localStorage.containsKey("remember") &&
        window.localStorage["remember"] == "1") {
      if (window.localStorage.containsKey("refreshToken")) {
        var response = await refreshToken(window.localStorage["refreshToken"]);
        if (response != null) {
          window.localStorage["refreshToken"] = response["refresh_token"];
          return response;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } else {
      window.localStorage["remember"] = "0";
      return null;
    }
  }

  Future<Map> refreshToken(String token) async {
    var res = await http
        .post("$SERVER_IP/refresh-token",
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.authorizationHeader: ' Bearer ' + token,
              'x-api-key': APIKEY
            },
            body: jsonEncode({}))
        .catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check@app',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: FutureBuilder(
          future: jwtOrEmpty,
          builder: (context, snapshot) {
            if (snapshot.data != "" && snapshot.hasData) {
              var payload = snapshot.data;

              if (payload == null) {
                return LoginPage();
              } else {
                var privacy = decodeJWTPayload(payload["token"])["privacy"];
                if (privacy == 0) {
                  return PrivacyPage(payload);
                }
                return MenuRoute(payload);
              }
            } else {
              return LoginPage();
            }
          }),
    );
  }
}

class MenuRoute extends StatelessWithDialogWidget {
  MenuRoute(this.response);
  final Map<String, dynamic> response;

  Future<Map> checkin(String jwt) async {
    var res = await http.post(
      "$SERVER_IP/check-in",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': APIKEY
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> checkout(String jwt) async {
    var res = await http.post(
      "$SERVER_IP/check-out",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': APIKEY
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> logout(String jwt) async {
    var res = await http.post(
      "$SERVER_IP/logout",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': APIKEY
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> me(String jwt) async {
    var res = await http.get(
      "$SERVER_IP/me",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': APIKEY
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> printSurvey(String jwt) async {
    var res = await http.get(
      "$SERVER_IP/pdf-gen",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': APIKEY
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future scanQRCode() async {
    try {
      String barcode = await scanner.scan();
      return barcode;
      //setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == scanner.CameraAccessDenied) {
        return "L'app non ha i permessi per utilizzare la fotocamera";
        // setState(() {
        //   this.barcode = 'No camera permission!';
        // });
      } else {
        return "Errore imprevisto: $e";
        //setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      return "Niente da catturare";
      // setState(() => this.barcode =
      // 'Nothing captured.');
    } catch (e) {
      return "Errore imprevisto: $e";
      //setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var userInfo = json.decode(ascii.decode(
        base64.decode(base64.normalize(this.response["token"].split(".")[1]))));

    var _needSurvey = needSurvey(userInfo["date_submit_survey"] ?? null);
    var _dayLeft = surveyDayLeft(userInfo["date_submit_survey"] ?? null);
    var _dayLeftMsg = _needSurvey
        ? (_dayLeft.isEmpty
            ? "Mai compilata"
            : "Compilata il " +
                userInfo["date_submit_survey"] +
                " - Scaduta da " +
                _dayLeft[2].abs().toString() +
                " giorni")
        : "Compilata il " +
            userInfo["date_submit_survey"] +
            " - Scade tra " +
            _dayLeft[2].abs().toString() +
            " giorni";

    var raisedButtonSize = {"width": 360.0, "height": 60.0};

    return Scaffold(
      appBar: AppBar(
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text("Atletico Fabriano ASD", style: TextStyle(fontSize: 16))
            ]),
        actions: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(userInfo["sub"], style: TextStyle(fontSize: 14.0)),
          ]),
          PopupMenuButton(
            onSelected: (value) async {
              //print the selected option
              switch (value) {
                case "logout":
                  var jwt = this.response["token"];
                  await logout(jwt);
                  window.localStorage.remove("hasCheckin");
                  window.localStorage.remove("refreshToken");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                  break;
                case "me":
                  if (!window.localStorage.containsKey("hasProfileData") ||
                      !this.response.containsKey("profile")) {
                    //print("GET PROFILE FROM API");
                    var jwt = this.response["token"];
                    var response = await me(jwt);
                    this.response["profile"] = response["profile"];
                  }
                  if (this.response["profile"] != null) {
                    window.localStorage["hasProfileData"] = "1";
                    //UserProfile(response).show();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserProfile(
                                this.response, this.response["profile"])));
                  } else {
                    displayDialog(context, "Errore",
                        "Impossibile recuperare le informazioni dell'utente");
                  }
                  break;
                case "changepwd":
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChangePasswordPage(this.response)));

                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: "me",
                  child: Text("Profilo"),
                ),
                PopupMenuItem(
                  value: "changepwd",
                  child: Text("Modifica password"),
                ),
                PopupMenuItem(
                  value: "logout",
                  child: Text("Esci"),
                )
              ];
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          //var qrcode = await scanQRCode();
          displayDialog(
              context, "Scansione codice", "Funzionalità ancora non attiva");
        },
        label: Text('Scansiona'),
        icon: Icon(Icons.qr_code_scanner_outlined),
        backgroundColor: Colors.red[100],
      ),
      body: Builder(builder: (BuildContext context) {
        return ContainerBoxDecorationWithOpacity(
            imagePath: STATIC_ENDPOINT + '/scudetto_BN.png',
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                    Widget>[
              Center(
                  child: Column(
                children: <Widget>[
                  SizedBox(
                      width: raisedButtonSize["width"],
                      height: raisedButtonSize["height"],
                      child: RaisedButton(
                          color: _needSurvey
                              ? Colors.red
                              : _dayLeft[2] <= 14
                                  ? Colors.orange
                                  : Colors.green,
                          onPressed: () async {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SurveyPage(
                                          this.response,
                                        )));
                          },
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(_needSurvey
                                          ? Icons.error_outline
                                          : Icons.done_outline),
                                      Text('AUTOCERTIFICAZIONE',
                                          style: TextStyle(fontSize: 20)),
                                    ]),
                                Text(_dayLeftMsg,
                                    style: TextStyle(fontSize: 12)),
                              ]))),
                  const SizedBox(height: 50),
                  SizedBox(
                      width: raisedButtonSize["width"],
                      height: raisedButtonSize["height"],
                      child: RaisedButton(
                          onPressed: () async {
                            if (!_needSurvey) {
                              var jwt = this.response["token"];
                              Scaffold.of(context).showSnackBar(doneSnack(
                                  "Richiesta di stampa... attendere"));
                              var response = await printSurvey(jwt);
                              if (response != null) {
                                js.context
                                    .callMethod("open", [response["url"]]);
                              }
                            }
                          },
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.print),
                                      Text('STAMPA AUTOCERTIFICAZIONE',
                                          style: TextStyle(fontSize: 18)),
                                    ]),
                              ]))),
                  const SizedBox(height: 50),
                  SizedBox(
                      width: raisedButtonSize["width"],
                      height: raisedButtonSize["height"],
                      child: RaisedButton(
                        onPressed: () async {
                          if (_needSurvey) {
                            displayDialog(context, "Ingresso",
                                "Per poter effettuare l'ingresso devi compilare l'autocertificazione");
                            return;
                          }
                          var jwt = this.response["token"];
                          var response = await checkin(jwt);
                          if (response != null) {
                            this.response["token"] = response["token"];
                            window.localStorage["hasCheckin"] = "1";
                            Scaffold.of(context).showSnackBar(doneSnack(
                                "L'ingresso è stato registrato correttamente"));
                            // displayDialog(context, "Check in effettuato",
                            //     "L'ingresso è stato registrato correttamente");
                          } else {
                            Scaffold.of(context).showSnackBar(failSnack(
                                "Registrazione accesso fallito, riprovare"));
                          }
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.meeting_room),
                              Text('INGRESSO', style: TextStyle(fontSize: 20))
                            ]),
                      )),
                  const SizedBox(height: 50),
                  SizedBox(
                      width: raisedButtonSize["width"],
                      height: raisedButtonSize["height"],
                      child: RaisedButton(
                        onPressed: () async {
                          if (window.localStorage.containsKey("hasCheckin")) {
                            var jwt = this.response["token"];
                            var response = await checkout(jwt);
                            if (response != null) {
                              this.response["token"] = response["token"];
                              Scaffold.of(context).showSnackBar(doneSnack(
                                  "L'uscita è stata registrata correttamente"));
                              // displayDialog(context, "Check out effettuato",
                              //     "L'uscita è stata registrata correttamente");
                            } else {
                              Scaffold.of(context).showSnackBar(failSnack(
                                  "Registrazione uscita fallita, riprovare"));
                            }
                          } else {
                            displayDialog(context, "Uscita",
                                "Prima devi effettuare l'ingresso premendo sul tasto INGRESSO");
                          }
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.exit_to_app),
                              Text('USCITA', style: TextStyle(fontSize: 20))
                            ]),
                      ))
                ],
              ))
            ]));
      }),
    );
  }
}

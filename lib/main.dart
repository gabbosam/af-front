// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:io';
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

Future main() async {
  await DotEnv().load('../.env');
  runApp(MyApp());
}

class ContainerBoxDecorationWithOpacity extends StatelessWidget {
  ContainerBoxDecorationWithOpacity({this.imagePath, this.child});
  final String imagePath;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(backgroundColor: Colors.transparent, body: this.child),
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

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberLogin = false;

  Future<Map> attemptLogIn(String username, String password) async {
    var res = await http
        .post("$serverIp/login",
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              'x-api-key': apiKey
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
                width: 250.0,
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
                          Navigator.pushReplacement(
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
                    child: Text("ENTRA",
                        overflow: TextOverflow.visible,
                        style: TextStyle(fontSize: 20))),
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
          window.localStorage["remember"] = "0";
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
        .post("$serverIp/refresh-token",
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.authorizationHeader: ' Bearer ' + token,
              'x-api-key': apiKey
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
        primarySwatch: environment == "dev" ? Colors.blue : Colors.red,
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

class MenuRoute extends StatefulWidget {
  MenuRoute(this.response);
  final Map<String, dynamic> response;
  @override
  _MenuRouteState createState() => _MenuRouteState(this.response);
}

class _MenuRouteState extends State<MenuRoute> {
  _MenuRouteState(this.response);
  final Map<String, dynamic> response;

  String checkInDate = "";
  String checkOutDate = "";

  Future<Map> checkin(String jwt) async {
    var res = await http.post(
      "$serverIp/check-in",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> checkout(String jwt) async {
    var res = await http.post(
      "$serverIp/check-out",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> logout(String jwt) async {
    var res = await http.post(
      "$serverIp/logout",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> me(String jwt) async {
    var res = await http.get(
      "$serverIp/me",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
    ).catchError((error) {
      print(error.toString());
    });
    if (res.statusCode == 200) return json.decode(res.body);
    return null;
  }

  Future<Map> printSurvey(String jwt) async {
    var res = await http.get(
      "$serverIp/pdf-print",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
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
    var userInfo = decodeJWTPayload(this.response["token"]);

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

    checkInDate = "Ultimo accesso: " + (userInfo["last_checkin"] ?? "...");
    checkOutDate = "Ultima uscita: " + (userInfo["last_checkout"] ?? "...");

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
                  window.localStorage.remove("hasProfileData");
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
                    Scaffold.of(context).showSnackBar(failSnack(
                        "Impossibile recuperare le informazioni dell'utente"));
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //var qrcode = await scanQRCode();
          displayDialog(
              context, "Scansione codice", "Funzionalità ancora non attiva");
          // Scaffold.of(context)
          //     .showSnackBar(failSnack("Funzionalità ancora non attiva"));
        },
        child: Icon(Icons.qr_code_scanner_outlined),
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
                              : _dayLeft[2] <= 5
                                  ? Colors.orange
                                  : Colors.green,
                          onPressed: () async {
                            Navigator.push(
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
                                if (response["url"] == "NULL") {
                                  Scaffold.of(context).showSnackBar(doneSnack(
                                      "Stampa non ancora disponibile... riprova"));
                                } else {
                                  js.context
                                      .callMethod("open", [response["url"]]);
                                }
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
                            var result =
                                decodeJWTPayload(this.response["token"]);
                            //print(result);
                            setState(() {
                              checkInDate = "Ultimo accesso: " +
                                  (result["last_checkin"] ?? "");
                            });

                            window.localStorage["hasCheckin"] =
                                result["access_hash"];
                            Scaffold.of(context).showSnackBar(doneSnack(
                                "L'ingresso è stato registrato correttamente"));
                            // displayDialog(context, "Check in effettuato",
                            //     "L'ingresso è stato registrato correttamente");
                          } else {
                            Scaffold.of(context).showSnackBar(failSnack(
                                "Registrazione accesso fallito, riprovare"));
                          }
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.meeting_room),
                                    Text('INGRESSO',
                                        style: TextStyle(fontSize: 20))
                                  ]),
                              if (checkInDate != "")
                                Text(checkInDate,
                                    style: TextStyle(fontSize: 12))
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
                              var result =
                                  decodeJWTPayload(this.response["token"]);
                              //print(result);
                              setState(() {
                                checkOutDate = "Ultima uscita: " +
                                    (result["last_checkout"] ?? "");
                              });
                              window.localStorage.remove("hasCheckin");
                              Scaffold.of(context).showSnackBar(doneSnack(
                                  "L'uscita è stata registrata correttamente"));
                              // displayDialog(context, "Check out effettuato",
                              //     "L'uscita è stata registrata correttamente");
                            } else {
                              Scaffold.of(context).showSnackBar(failSnack(
                                  "Registrazione uscita fallita, riprovare"));
                            }
                          } else {
                            Scaffold.of(context).showSnackBar(failSnack(
                                "Prima devi effettuare l'ingresso premendo sul tasto INGRESSO"));
                          }
                        },
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.exit_to_app),
                                    Text('USCITA',
                                        style: TextStyle(fontSize: 20))
                                  ]),
                              if (checkOutDate != "")
                                Text(checkOutDate,
                                    style: TextStyle(fontSize: 12))
                            ]),
                      ))
                ],
              ))
            ]));
      }),
    );
  }
}

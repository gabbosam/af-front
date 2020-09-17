// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qrscan/qrscan.dart' as scanner;

const SERVER_IP = 'https://n1lv4wjyc3.execute-api.eu-west-1.amazonaws.com/dev';
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

class LoginPage extends StatelessWithDialogWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<Map> attemptLogIn(String username, String password) async {
    var res = await http
        .post("$SERVER_IP/login",
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              'x-api-key': 'xddfuheeLr5ne39P10y4z8pUx6unUweP8xxKjOe5'
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
          imagePath:
              'http://af-static.s3-website-eu-west-1.amazonaws.com/scudetto_BN.png',
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
              RaisedButton(
                  onPressed: () async {
                    var username = _usernameController.text;
                    var password = _passwordController.text;
                    var response = await attemptLogIn(username, password);
                    if (response != null) {
                      window.localStorage["refreshToken"] =
                          response["refresh_token"];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuRoute(response)),
                      );
                    } else {
                      displayDialog(context, "An Error Occurred",
                          "No account was found matching that username and password");
                    }
                  },
                  child: Text("Log In")),
            ],
          ),
        ));
  }
}

class HomePage extends StatelessWidget {
  HomePage(this.jwt, this.payload);

  factory HomePage.fromBase64(String jwt) => HomePage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text("Secret Data Screen")),
        body: Center(child: Text(jwt)),
      );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<Map> get jwtOrEmpty async {
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
  }

  Future<Map> refreshToken(String token) async {
    var res = await http
        .post("$SERVER_IP/refresh-token",
            headers: <String, String>{
              HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
              HttpHeaders.authorizationHeader: ' Bearer ' + token,
              'x-api-key': 'xddfuheeLr5ne39P10y4z8pUx6unUweP8xxKjOe5'
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
        'x-api-key': 'xddfuheeLr5ne39P10y4z8pUx6unUweP8xxKjOe5'
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
        'x-api-key': 'xddfuheeLr5ne39P10y4z8pUx6unUweP8xxKjOe5'
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          var qrcode = await scanQRCode();
          displayDialog(context, "Scansione codice", qrcode);
        },
        label: Text('Scansiona'),
        icon: Icon(Icons.qr_code_scanner_outlined),
        backgroundColor: Colors.red,
      ),
      body: ContainerBoxDecorationWithOpacity(
          imagePath:
              'http://af-static.s3-website-eu-west-1.amazonaws.com/scudetto_BN.png',
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Column(
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () async {
                        var jwt = this.response["token"];
                        var response = await checkin(jwt);
                        if (response != null) {
                          this.response["token"] = response["token"];
                          displayDialog(context, "Checkin effettuato",
                              response["message"]);
                        } else {
                          displayDialog(
                              context, "An Error Occurred", "Checkin failed");
                        }
                      },
                      child: Text('CHECKIN'),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        var jwt = this.response["token"];
                        var response = await checkout(jwt);
                        if (response != null) {
                          this.response["token"] = response["token"];
                          displayDialog(context, "Checkout effettuato",
                              response["message"]);
                        } else {
                          displayDialog(
                              context, "An Error Occurred", "Checkout failed");
                        }
                      },
                      child: Text('CHECKOUT'),
                    ),
                  ],
                ))
              ])),
    );
  }
}

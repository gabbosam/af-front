import 'dart:convert';
import 'dart:html';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'const.dart';
import 'main.dart';
import 'utils.dart';

class UserProfile extends StatefulWidget {
  final Map<String, dynamic> response;
  final Map<String, dynamic> profile;

  UserProfile(this.response, this.profile);
  @override
  _UserProfileState createState() =>
      _UserProfileState(this.response, this.profile);
}

class _UserProfileState extends State<UserProfile> {
  _UserProfileState(this.response, this.profile);
  final Map<String, dynamic> response;
  final Map<String, dynamic> profile;
  final _formKey = GlobalKey<FormState>();

  bool editMode = false;
  TextEditingController email = TextEditingController();
  TextEditingController birth = TextEditingController();
  TextEditingController townOfBirth = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController parent = TextEditingController();
  TextEditingController parentBirth = TextEditingController();
  TextEditingController parentTownOfBirth = TextEditingController();
  TextEditingController parentAddress = TextEditingController();
  TextEditingController sportMedicalExam = TextEditingController();

  Future<Map> updateProfile(String jwt) async {
    var res = await http
        .post(
      "$serverIp/update-me",
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: 'Bearer ' + jwt,
        'x-api-key': apiKey
      },
      body: jsonEncode({
        "profile": {
          "birth": birth.text,
          "town_of_birth": townOfBirth.text,
          "address": address.text,
          "email": email.text,
          "parent": parent.text,
          "parent_birth_date": parentBirth.text,
          "parent_town_of_birth": parentTownOfBirth.text,
          "parent_address": parentAddress.text,
          "sport_medical_exam": sportMedicalExam.text
        }
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

  List<Widget> getFloatingButtons(BuildContext context) {
    var listWidget = [
      FloatingActionButton(
        mini: editMode,
        child: Icon(editMode ? Icons.edit_off : Icons.edit),
        heroTag: null,
        onPressed: () {
          setState(() {
            editMode = !editMode;
          });
        },
      ),
    ];

    if (editMode) {
      listWidget.insert(
        0,
        FloatingActionButton(
          child: Icon(Icons.save),
          heroTag: null,
          onPressed: () async {
            var jwt = this.response["token"];
            setState(() {
              this.profile.addAll({
                "birth": birth.text,
                "town_of_birth": townOfBirth.text,
                "address": address.text,
                "email": email.text,
                "parent": parent.text,
                "parent_birth_date": parentBirth.text,
                "parent_town_of_birth": parentTownOfBirth.text,
                "parent_address": parentAddress.text,
                "sport_medical_exam": sportMedicalExam.text
              });
            });
            var res = await updateProfile(jwt);
            if (res != null) {
              window.localStorage.remove("hasProfileData");
              Scaffold.of(context)
                  .showSnackBar(doneSnack('Profilo utente aggiornato'));
            } else {
              Scaffold.of(context).showSnackBar(
                  failSnack('Errore in aggiornamento del profilo utente'));
            }
          },
        ),
      );
    }
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    bool _isAdult = isAdult(this.profile["birth"]);

    return Scaffold(
        appBar: AppBar(
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [Text("Profilo utente")]),
        ),
        floatingActionButton: Builder(builder: (BuildContext context) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: getFloatingButtons(context));
        }),
        body: ContainerBoxDecorationWithOpacity(
          imagePath: STATIC_ENDPOINT + '/scudetto_BN.png',
          child: Form(
              key: _formKey,
              child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(10.0),
                  children: <Widget>[
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: TextFormField(
                                initialValue: this.profile["login"],
                                enabled: false,
                                style: TextStyle(fontSize: 16.0),
                                decoration: InputDecoration(
                                    labelText: "Utente",
                                    icon: Icon(Icons.not_interested))),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: TextFormField(
                                initialValue: this.profile["name"],
                                enabled: false,
                                style: TextStyle(fontSize: 16.0),
                                decoration: InputDecoration(
                                    labelText: "Nome",
                                    icon: Icon(Icons.not_interested))),
                          ),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  initialValue: this.profile["surname"],
                                  enabled: false,
                                  style: TextStyle(fontSize: 16.0),
                                  decoration: InputDecoration(
                                      labelText: "Cognome",
                                      icon: Icon(Icons.not_interested)))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  controller: birth
                                    ..text = this.profile["birth"],
                                  enabled: editMode,
                                  style: TextStyle(fontSize: 16.0),
                                  decoration: InputDecoration(
                                      labelText: "Data di nascita",
                                      hintText: "gg/mm/aaaa",
                                      icon: Icon(editMode
                                          ? Icons.edit
                                          : Icons.not_interested)))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  controller: townOfBirth
                                    ..text =
                                        this.profile["town_of_birth"] ?? "",
                                  enabled: editMode,
                                  style: TextStyle(fontSize: 16.0),
                                  decoration: InputDecoration(
                                      labelText: "Nato a",
                                      icon: Icon(editMode
                                          ? Icons.edit
                                          : Icons.not_interested)))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  controller: address
                                    ..text = this.profile["address"] ?? "",
                                  enabled: editMode,
                                  style: TextStyle(fontSize: 16.0),
                                  decoration: InputDecoration(
                                      labelText: "Residente in",
                                      icon: Icon(editMode
                                          ? Icons.edit
                                          : Icons.not_interested)))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  enabled: editMode,
                                  style: TextStyle(fontSize: 16.0),
                                  keyboardType: TextInputType.emailAddress,
                                  controller: email
                                    ..text = this.profile["email"] ?? "",
                                  decoration: InputDecoration(
                                      labelText: "Email",
                                      icon: Icon(editMode
                                          ? Icons.edit
                                          : Icons.not_interested)))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  enabled: editMode,
                                  style: TextStyle(fontSize: 16.0),
                                  controller: sportMedicalExam
                                    ..text =
                                        this.profile["sport_medical_exam"] ??
                                            "",
                                  decoration: InputDecoration(
                                      labelText: "Scadenza visita medica",
                                      hintText: "gg/mm/aaaa",
                                      icon: Icon(editMode
                                          ? Icons.edit
                                          : Icons.not_interested)))),
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: TextFormField(
                                  initialValue: this.profile["role"] ?? "",
                                  enabled: false,
                                  style: TextStyle(fontSize: 16.0),
                                  decoration: InputDecoration(
                                      labelText: "Ruolo",
                                      icon: Icon(Icons.not_interested)))),
                          if (!_isAdult)
                            const SizedBox(
                              height: 20.0,
                            ),
                          if (!_isAdult)
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Column(children: [
                                Text("Dati del genitore",
                                    style: TextStyle(fontSize: 20.0)),
                                Divider(
                                  thickness: 5.0,
                                  color: Colors.red,
                                ),
                              ]),
                            ),
                          if (!_isAdult)
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextFormField(
                                    enabled: editMode,
                                    controller: parent
                                      ..text = this.profile["parent"] ?? "",
                                    style: TextStyle(fontSize: 16.0),
                                    decoration: InputDecoration(
                                        labelText: "Nome e Cognome",
                                        icon: Icon(editMode
                                            ? Icons.edit
                                            : Icons.not_interested)))),
                          if (!_isAdult)
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextFormField(
                                    enabled: editMode,
                                    style: TextStyle(fontSize: 16.0),
                                    controller: parentBirth
                                      ..text =
                                          this.profile["parent_birth_date"] ??
                                              "",
                                    decoration: InputDecoration(
                                        labelText: "Data di nascita",
                                        hintText: "gg/mm/aaaa",
                                        icon: Icon(editMode
                                            ? Icons.edit
                                            : Icons.not_interested)))),
                          if (!_isAdult)
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextFormField(
                                    enabled: editMode,
                                    style: TextStyle(fontSize: 16.0),
                                    controller: parentTownOfBirth
                                      ..text = this.profile[
                                              "parent_town_of_birth"] ??
                                          "",
                                    decoration: InputDecoration(
                                        labelText: "Nato a",
                                        icon: Icon(editMode
                                            ? Icons.edit
                                            : Icons.not_interested)))),
                          if (!_isAdult)
                            Padding(
                                padding: EdgeInsets.all(10.0),
                                child: TextFormField(
                                    enabled: editMode,
                                    style: TextStyle(fontSize: 16.0),
                                    controller: parentAddress
                                      ..text =
                                          this.profile["parent_address"] ?? "",
                                    decoration: InputDecoration(
                                        labelText: "Residente in",
                                        icon: Icon(editMode
                                            ? Icons.edit
                                            : Icons.not_interested)))),
                        ])
                  ])),
        ));
  }
}

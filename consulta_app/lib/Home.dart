import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController txtcep = new TextEditingController();
  String resultado = '';

  _consultaCep() async {
    String cep = txtcep.text;
    String url = "https://viacep.com.br/ws/${cep}/json/";
    http.Response response;

    response = await http.get(Uri.parse(url));

    Map<String, dynamic> retorno = json.decode(response.body);

    String logradouro = retorno["logradouro"];
    String cidade = retorno["localidade"];
    String bairro = retorno["bairro"];

    setState(() {
      resultado = "${logradouro}, ${bairro}, ${cidade}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Consultado um CEP via API"),
          backgroundColor: Colors.blue,
        ),
        body: Container(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Digite o CEP ex: 18334000",
                  ),
                  style: TextStyle(fontSize: 15),
                  controller: txtcep,
                ),
                Text(
                  "Resultado: ${resultado}",
                  style: TextStyle(fontSize: 25),
                ),
                ElevatedButton(
                  child: Text(
                    "Consultar",
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: _consultaCep,
                )
              ],
            )));
  }
}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataAniController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  CollectionReference _pessoas =
      FirebaseFirestore.instance.collection('pessoas');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';

    if (documentSnapshot != null) {
      action = 'update';
      _nomeController.text = documentSnapshot['nome'];
      _dataAniController.text = documentSnapshot['dataAniversario'];
      _emailController.text = documentSnapshot['email'];
    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  TextField(
                    keyboardType: TextInputType.datetime,
                    controller: _dataAniController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Aniversário',
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    child: Text(action == 'create' ? 'Criar' : 'Atualizar'),
                    onPressed: () async {
                      final String nome = _nomeController.text;
                      final String data = _dataAniController.text;
                      final String email = _emailController.text;

                      if (nome != null && data != null && email != null) {
                        if (action == 'create') {
                          await _pessoas.add({
                            "nome": nome,
                            "dataAniversario": data,
                            "email": email
                          });
                        }

                        if (action == 'update') {
                          await _pessoas.doc(documentSnapshot?.id).update({
                            "nome": nome,
                            "dataAniversario": data,
                            "email": email
                          });
                        }

                        _nomeController.text = '';
                        _dataAniController.text = '';
                        _emailController.text = '';

                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
              ));
        });
  }

  Future<void> _deleteProduct(String pessoaId) async {
    await _pessoas.doc(pessoaId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pessoa excluída com sucesso!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Completo'),
      ),
      body: StreamBuilder(
          stream: _pessoas.snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['nome']),
                      subtitle: Text(documentSnapshot['email']),
                      trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _createOrUpdate(documentSnapshot)),
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteProduct(documentSnapshot.id))
                            ],
                          )),
                    ),
                  );
                },
              );
            }

            return Center(
              child: const CircularProgressIndicator(),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}

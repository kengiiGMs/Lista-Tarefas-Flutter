import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lista_tarefas/components/item_list_custom.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _toDoList = [];
  final _toDoController = TextEditingController();

  Map<String, dynamic>? _lastRemoved;
  int? _lastRemovedPos;

  /* Retorna os dados do arquivo ao iniciar o app */
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = jsonDecode(data);
      });
    });
  }

  /* Retorna arquivo que será salvo os dados  */
  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  /* Retorna os dados do arquivo */
  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return "Erro + $e";
    }
  }

  /* Salvar dados (substituição) no arquivo */
  Future<File> _saveData() async {
    String data = jsonEncode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  /* Adiciona dados na lista */
  void _addToDo() {
    setState(() {
      Map<String, dynamic> newToDo = {};
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add(newToDo);
      _saveData();
    });
  }

  /* Atualizar Lista e ordernar de acordo com o status */
  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _toDoList.sort((a, b) {
        if (a["ok"] && !b["ok"]) {
          return 1;
        } else if (!a["ok"] && b["ok"]) {
          return -1;
        } else {
          return 0;
        }
      });

      _saveData();
    });

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 5.0, 7.0, 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: _addToDo,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: EdgeInsets.only(top: 10.0),
                itemCount: _toDoList.length,
                itemBuilder:
                    (context, index) => buildItem(
                      context: context,
                      index: index,
                      toDoList: _toDoList,
                      setStateCallback: setState,
                      saveDataCallback: _saveData,
                      onRemove: (item, index) {
                        setState(() {
                          _lastRemoved = Map.from(item);
                          _lastRemovedPos = index;
                          _toDoList.removeAt(index);
                          _saveData();

                          final snack = SnackBar(
                            content: Text(
                              "Tarefa ${_lastRemoved?["title"]} removida!",
                            ),
                            action: SnackBarAction(
                              label: "Desfazer",
                              onPressed: () {
                                setState(() {
                                  _toDoList.insert(
                                    _lastRemovedPos!,
                                    _lastRemoved,
                                  );
                                  _saveData();
                                });
                              },
                            ),
                            duration: Duration(seconds: 2),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snack);
                        });
                      },
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

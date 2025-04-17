import 'package:flutter/material.dart';

Widget buildItem({
  required BuildContext context,
  required int index,
  required List toDoList,
  required Function setStateCallback,
  required Function saveDataCallback,
  required Function(Map<String, dynamic> item, int index) onRemove,
}) {
  final item = toDoList[index];
  return Dismissible(
    background: Container(
      color: Colors.red,
      child: Align(
        alignment: Alignment(-0.9, 0.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
    ),
    direction: DismissDirection.startToEnd,
    key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
    onDismissed: (direction) {
      onRemove(item, index);
    },
    child: CheckboxListTile(
      title: Text(item["title"]),
      value: item["ok"],
      onChanged:
          (check) => {
            setStateCallback(() {
              toDoList[index]["ok"] = check;
              saveDataCallback();
            }),
          },
      secondary: CircleAvatar(
        child: Icon(item["ok"] ? Icons.check : Icons.error),
      ),
    ),
  );
}

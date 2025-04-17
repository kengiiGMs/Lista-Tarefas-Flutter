import 'package:flutter/material.dart';

Widget buildItem({
  required BuildContext context,
  required int index,
  required List toDoList,
  required Function setStateCallback,
  required Function saveDataCallback,
}) {
  final item = toDoList[index];
  return CheckboxListTile(
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
  );
}

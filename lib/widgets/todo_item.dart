import 'package:flutter/material.dart';
import 'package:todo_list_flutter/constants/colors.dart';
import 'package:todo_list_flutter/model/todo.dart';

class TodoItem extends StatelessWidget {
  final ToDo todo;

  const TodoItem({Key? key, required this.todo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: ListTile(
            onTap: () {
              print('Clicked on Todo Item');
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            tileColor: Colors.white,
            leading: Icon(
              todo.isDone ? Icons.check_box : Icons.check_box_outline_blank, color: tdBlue),
            title: Text(todo.todoText!,
                style: TextStyle(
                    fontSize: 16,
                    color: tdBlack,
                    decoration:
                        todo.isDone ? TextDecoration.lineThrough : null)),
            trailing: Container(
              padding: EdgeInsets.all(0),
              margin: EdgeInsets.symmetric(vertical: 6),
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: tdRed,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: Colors.white,
                iconSize: 15,
                icon: Icon(Icons.delete),
                onPressed: () {
                  print('Clicked on Delete');
                },
              ),
            )));
  }
}

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';
import '../model/todo.dart';
import '../widgets/icon_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Asegúrate de importar esta librería
import '../constants/icons.dart'; // Asegúrate de importar esta librería

class Home extends StatefulWidget {
  Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isIconSelectorVisible = false;
  final todosList = ToDo.todoList();
  // declaro la variable iconProfile de donde de imagePaths tomo la primera del array
  String iconProfile = imagePaths[0];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  final _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadToDos();
    _loadProfileIcon();
    _foundToDo = todosList;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: tdBGColor,
          appBar: _buildAppBar(
            _toggleIconSelector,
            iconProfile: iconProfile,
          ),
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Column(
                  children: [
                    searchBox(),
                    Expanded(
                      child: ListView(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 50, bottom: 20),
                            child: Text(
                              'Lista de tareas',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_foundToDo.isEmpty)
                            Center(
                              child: Text(
                                'Sin tareas aún',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: tdGrey,
                                ),
                              ),
                            )
                          else
                            for (ToDo todoo in _foundToDo.reversed)
                              TodoItem(
                                todo: todoo,
                                onDeleteItem: _deleteToDoItem,
                                onToDoChanged: _handleToDoChange,
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin:
                              EdgeInsets.only(bottom: 20, right: 20, left: 20),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 0.0),
                                blurRadius: 10.0,
                                spreadRadius: 0.0,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _todoController,
                            decoration: InputDecoration(
                              hintText: 'Add a new todo item',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        margin: EdgeInsets.only(bottom: 20, right: 20),
                        padding: EdgeInsets.all(0),
                        child: ElevatedButton(
                          child: Image.asset('assets/images/plus.png'),
                          onPressed: () {
                            _addToDoItem(_todoController.text);
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(60, 60),
                            backgroundColor: tdBlue,
                            elevation: 10,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ),
        if (_isIconSelectorVisible) ...[
          ModalBarrier(
            dismissible: true,
            color: Colors.black.withOpacity(0.3),
            onDismiss: _toggleIconSelector,
          ),
          IconSelector(
              onPressed: _toggleIconSelector,
              icon: iconProfile,
              saveProfileIcon: _saveProfileIcon),
        ],
      ],
    );
  }

  void _handleToDoChange(ToDo todo) {
    setState(() {
      todo.isDone = !todo.isDone;
    });
    _saveToDos();
  }

  // funcion que guarda el profileIcon en la variable iconProfile en shared preferences
  void _saveProfileIcon(String icon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileIcon', icon);
    setState(() {
      iconProfile = icon;
    });
  }

  void _loadProfileIcon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String profileIcon = prefs.getString('profileIcon') ?? imagePaths[0];
    setState(() {
      iconProfile = profileIcon;
    });
  }

  void _deleteToDoItem(String id) {
    setState(() {
      todosList.removeWhere((item) => item.id == id);
    });
    _saveToDos();
  }

  void _addToDoItem(String toDo) {
    setState(() {
      // reviso si el texto del todo no está vacío
      if (toDo.isEmpty) {
        return;
      }
      todosList.add(ToDo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        todoText: toDo,
      ));
    });

    // actualizo el filtro
    _saveToDos();
    _foundToDo = todosList;

    _todoController.clear();
    _filterController.clear();
  }

  void _runFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todosList;
    } else {
      results = todosList
          .where((item) => item.todoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      _foundToDo = results;
    });
  }

  // quiero guardar la lista de todos en el shared preferences
  void _saveToDos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> todos =
        todosList.map((todo) => jsonEncode(todo.toJson())).toList();
    prefs.setStringList('todos', todos);
  }

  // quiero cargar la lista de todos del shared preferences
  void _loadToDos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? todos = prefs.getStringList('todos');
    if (todos != null) {
      todosList.clear();
      todosList.addAll(todos.map((todo) => ToDo.fromJson(jsonDecode(todo))));
      setState(() {
        _foundToDo = todosList;
      });
    }
  }

  void _toggleIconSelector() {
    setState(() {
      _isIconSelectorVisible = !_isIconSelectorVisible;
    });
  }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _runFilter(value),
        controller: _filterController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          prefixIcon: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.search, color: tdBlack, size: 20)),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Search',
          hintStyle: TextStyle(color: tdGrey),
        ),
      ),
    );
  }
}

AppBar _buildAppBar(_toggleIconSelector, {String? iconProfile}) {
  return AppBar(
    backgroundColor: tdBGColor,
    elevation: 0,
    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
          onTap: () {
            _toggleIconSelector();
          },
          child: Icon(Icons.menu, color: tdBlack, size: 30)),
      GestureDetector(
        onTap: () {
          _toggleIconSelector();
        },
        child: Container(
            height: 40,
            width: 40,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(iconProfile!))),
      )
    ]),
  );
}

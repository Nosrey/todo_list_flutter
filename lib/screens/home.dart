import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mi_lista_de_tareas/services/local_notification_service.dart';
import '../constants/colors.dart';
import '../widgets/todo_item.dart';
import '../model/todo.dart';
import '../widgets/icon_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Asegúrate de importar esta librería
import '../constants/icons.dart'; // Asegúrate de importar esta librería
// import 'package:awesome_notifications/awesome_notifications.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final LocalNotificationService service;

  bool _isIconSelectorVisible = false;
  final todosList = ToDo.todoList();
  // declaro la variable iconProfile de donde de imagePaths tomo la primera del array
  String iconProfile = imagePaths[0];
  List<ToDo> _foundToDo = [];
  final _todoController = TextEditingController();
  final _filterController = TextEditingController();


  Future<void> _requestPermissions() async {
    // Solicitar permiso para notificaciones
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Solicitar permiso para alarmas exactas en Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  @override
  void initState() {
    service = LocalNotificationService();
    _requestPermissions();
    service.initialize();
    super.initState();
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     // This is just an example. You can show a dialog or any other UI element to request permission.
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });

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
                margin: EdgeInsets.only(bottom: 80),
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
                              'Mis tareas',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w500,
                                // italic la letra
                                fontStyle: FontStyle.italic,
                                color: tdBlack,
                              ),
                            ),
                          ),
                          if (_foundToDo.isEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 50),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Sin tareas aún',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: tdGrey,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/arrow.png',
                                            height: 150,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                          onChanged: (value) => _todoTextFormatter(value),
                          decoration: InputDecoration(
                            hintText: 'Añadir nueva tarea',
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
                        onPressed: () async {
                          // scheduleNotification();
                          await service.showScheduledNotification(
                            id: 0,
                            title: 'Nueva tarea',
                            body: 'Se ha añadido una nueva tarea',
                            seconds: 5,
                          );
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
                ),
              ),
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

  // creo una funcion para que se ejecute usando flutter_local_notifications tambien
  // void scheduleNotification() async {
  //   print('Notification scheduled');
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: 10,
  //       channelKey: 'basic_channel',
  //       title: 'Nueva tarea 10',
  //       color: Colors.red,
  //       body: 'Se ha añadido una nueva tarea',
  //       notificationLayout: NotificationLayout.BigPicture,
  //       largeIcon: 'resource://drawable/res_app_icon',
  //       icon: 'resource://drawable/res_app_icon',
  //     ),
  //   );
  // }

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

  // hago una funcion para que al escribir en el _todoController la primera letra siempre será mayuscula y que se muestre en el teclado de telefono como que será mayuscula
  void _todoTextFormatter(String text) {
    if (text.length == 1) {
      _todoController.value = TextEditingValue(
        text: text.toUpperCase(),
        selection: TextSelection.collapsed(offset: 1),
      );
    }
  }

  void _filterFormatter(String text) {
    if (text.length == 1) {
      _filterController.value = TextEditingValue(
        text: text.toUpperCase(),
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    _runFilter(text);
  }

  // void triggerNotification() {
  //   AwesomeNotifications().createNotification(
  //     content: NotificationContent(
  //       id: 10,
  //       channelKey: 'basic_channel',
  //       title: 'Nueva tarea 6',
  //       color: Colors.red,
  //       body: 'Se ha añadido una nueva tarea',
  //       notificationLayout: NotificationLayout.BigPicture,
  //       largeIcon: 'resource://drawable/res_app_icon',
  //       icon: 'resource://drawable/res_app_icon',
  //     ),
  //   );
  // }

  Widget searchBox() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: TextField(
        onChanged: (value) => _filterFormatter(value),
        controller: _filterController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(10),
          prefixIcon: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.search, color: tdBlack, size: 20)),
          prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
          border: InputBorder.none,
          hintText: 'Buscar',
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

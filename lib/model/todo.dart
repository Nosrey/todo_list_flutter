class ToDo {
  String? id;
  String? todoText;
  bool isDone;

  ToDo({
    required this.id,
    required this.todoText,
    this.isDone = false,
  });

  static List<ToDo> todoList() {
    return [];
  }

  // añado un metodo toJson para esta funcion
  //   void _saveToDos() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String> todos = todosList.map((todo) => todo.toJson()).toList();
  //   prefs.setStringList('todos', todos);
  // }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todoText': todoText,
      'isDone': isDone,
    };
  }

  // ahora para esta funcion
  //   void _loadToDos() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String>? todos = prefs.getStringList('todos');
  //   if (todos != null) {
  //     todosList.clear();
  //     todosList.addAll(todos.map((todo) => ToDo.fromJson(jsonDecode(todo))));
  //   }
  // }
  // añado un metodo fromJson para esta funcion
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      todoText: json['todoText'],
      isDone: json['isDone'],
    );
  }
}

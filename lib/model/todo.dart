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
    return [
      ToDo(id: '01', todoText: 'Programar en Flutter', isDone: true),
      ToDo(id: '02', todoText: 'Hacer ejercicio', isDone: true),
      ToDo(id: '03', todoText: 'Leer un libro', isDone: false),
      // ToDo(id: '04', todoText: 'Aprender algo nuevo', isDone: false),
      // ToDo(id: '05', todoText: 'Ver una película', isDone: false),
    ];
  }
}
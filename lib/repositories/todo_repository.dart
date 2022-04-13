import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';

const todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getTodoList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
    // PEGOU O JSON DECODIFICADO, PEGOU CADA UM DOS ITENS DO JSON, CONVERTEU PARA O OBJETO PARA O TIPO TODO E TRANSFORMOU DE VOLTA NA LISTA
  }

  void saveTodoList(List<Todo> todos) {
    // PEGANDO A LISTA DE TAREFAS E CONVERTENDO PARA TEXTO NO PADRÃO JSON
      final jsonString = json.encode(todos);
      sharedPreferences.setString(todoListKey, jsonString);
  }
}

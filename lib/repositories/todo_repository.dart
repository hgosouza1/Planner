import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo.dart';

const todoListKey = 'todo_list';

class TodoRepository {
  late SharedPreferences prefs;

  void saveTodoList(List<Todo> todos) {
    // PEGANDO A LISTA DE TAREFAS E CONVERTENDO PARA TEXTO NO PADRÃO JSON
    final jsonString = json.encode(todos);
    prefs.setString(todoListKey, jsonString);
  }
}
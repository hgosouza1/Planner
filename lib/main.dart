import 'package:flutter/material.dart';
import 'package:todolist/pages/todo_list_page.dart';

void main() {

  runApp(const MyApp());
}

// DECLARANDO O APP
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}
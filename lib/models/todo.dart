import 'package:flutter/material.dart';

class Todo {
  Todo({required this.title, required this.date, required this.time});

  Todo.fromJson(Map<String, dynamic> json)
  // PEGA O JSON QUE RECEBE POR PARÂMETRO E CRIAR O NOVO OBJETIVO TODO
      : title = json['title'],
        date = DateTime.parse(json['datetime']),
        time = json['time'];
  // CONVERTENDO DE TEXTO PARA DATETIME

  String title;
  DateTime date;
  TimeOfDay time;

  // CRIADA UMA CLASSE QUE ARMAZENA O TÍTULO E O HORÁRIO

  Map<String, dynamic> toJson() {
    // ARMAZENANDO OS DADOS DA TAREFA EM JSON
    return {
      'title': title,
      'datetime': date.toIso8601String(),
      'time': time.toString(),
      // CONVERTER DATA EM TEXTO
    };
  }
}

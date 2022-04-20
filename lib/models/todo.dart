class Todo {
  Todo({required this.title, required this.dateTime});

  Todo.fromJson(Map<String, dynamic> json)
  // PEGA O JSON QUE RECEBE POR PARÂMETRO E CRIAR O NOVO OBJETIVO TODO
      : title = json['title'],
        dateTime = DateTime.parse(json['datetime']);
  // CONVERTENDO DE TEXTO PARA DATETIME

  String title;
  DateTime dateTime;

  // CRIADA UMA CLASSE QUE ARMAZENA O TÍTULO E O HORÁRIO

  Map<String, dynamic> toJson() {
    // ARMAZENANDO OS DADOS DA TAREFA EM JSON
    return {
      'title': title,
      'datetime': dateTime.toIso8601String(),
      // CONVERTER DATA EM TEXTO
    };
  }
}

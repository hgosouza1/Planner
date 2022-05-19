import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    Key? key,
    required this.todo,
    required this.onDelete,
  }) : super(key: key);
  // O WIDGET FILHO RECEBEU A FUNÇÃO onDelete POR PARÂMETRO

  final Todo todo;
  final Function(Todo) onDelete;
  get _date => DateFormat.yMd().format(todo.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      // ESPAÇAMENTO ENTRE AS TAREFAS DA LISTA
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Slidable(
          // BOTÃO DE CORRER
          child: Container(
            // CAIXAS DE TAREFAS
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              // BORDAS DAS CAIXAS DE TAREFAS
              color: const Color.fromRGBO(47, 64, 79, 1.0),
              // COR DAS CAIXAS DE TAREFAS
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // POSICIONA O TEXTO DA LISTA DE TARAFA NA ESQUERDA E PROPORCIONA A COLUNA DE ACORDO COM O ESPAÇO DE CORRER
              children: [
                Text(
                  todo.title,
                  // ACESSANDO O TÍTULO
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('$_date - ' + todo.time.format(context),
                    // ACESSANDO E FORMATANDO A DATA
                    style: const TextStyle(
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          actionExtentRatio: 0.25,
          // TAMANHO QUE A OPÇÃO DE DELETAR IRÁ OCUPAR. 0.25 DE 100.
          // TAMANHO DO ESPAÇO ENTRE O BOTÃO DE DELETE E O ITEM DA LISTA AO CORRER
          actionPane: const SlidableStrechActionPane()
          // TIPO DO BOTÃO DE CORRER
          ,
          secondaryActions: [
            // PARA EXIBIR BOTÕES AO CORRER PARA O LADO ESQUERDO, UTILIZA-SE secondaryActions
            IconSlideAction(
              // BOTÃO DE CORRER PARA DELETAR
              color: Colors.red,
              icon: Icons.delete,
              caption: 'Deletar',
              onTap: () {
                onDelete(todo);
                // CHAMADA DA FUNÇÃO onDelete
              },
            ),
          ],
          // PARA EXIBIR BOTÕES AO CORRER PARA O LADO DIREITO, UTILIZA-SE actions []
        ),
      ),
    );
  }
}

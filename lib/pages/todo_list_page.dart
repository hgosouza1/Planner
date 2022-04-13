import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/repositories/todo_repository.dart';
import 'package:todolist/widgets/todo_list_item.dart';
import '../preview/preview_page.dart';
import 'dart:io' as i;

// DECLARANDO A PÁGINA
class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

final TextEditingController todoController = TextEditingController();
final TodoRepository todoRepository = TodoRepository();

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  i.File? arquivo;
  XFile? archive;
  final picker = ImagePicker();

  Future getFileFromGallery() async {
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => archive = file);
      Get.back();
    }
  }

  showPreview(file) async {
    file = await Get.to(() => PreviewPage(
          file: file,
          key: file,
        ));

    if (file != null) {
      setState(() => arquivo = file);
      Get.back();
    }
  }

  // CONTROLADOR PARA CONSEGUIR PEGAR O TEXTO DO CAMPO DE TEXTO
  // CRIADA UMA LISTA COM A CLASSE TODO
  // CADA STRING É O TÍTULO DE UMA TAREFA
  // PARA CADA CAMPO DE TEXTO, TERÁ UM CONTROLLER E VICE-VERSA.

  List<Todo> todos = [];
  Todo? deletedTodo;

  // DELETAR TAREFA
  int? deletedTodoPos;

  // ARMAZENAR A POSIÇÃO DE ONDE A TAREFA FOI DELETADA
  String? errorText;

  get color => null;

  /// TODA VEZ QUE A PÁGINA FOR ABERTA, O INIT É LIDO E O REPOSITÓRIO DA LISTA É ABERTO
  @override
  void initState() {
    super.initState();
    todoRepository.getTodoList().then(
      (value) {
        setState(
          () {
            todos = value;
          },
        );
      },
    );
  }

  /// FUNÇÃO PARA DELETAR AS TAREFEAS DA LISTA
  void onDelete(Todo todo) {
    // CRIADA A FUNÇÃO onDelete NO WIDGTE PAI
    deletedTodo = todo;
    // ''SALVAR'' A TAREFA DELETADA
    deletedTodoPos = todos.indexOf(todo);
    // RETORNAR O ÍNDICE DA TAREFA REMOVIDA = SENDO: 0, 1, 2 E ETC...
    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);
    // SALVAR A EXCLUSÃO DO ITEM NO REPOSITÓRIO
    ScaffoldMessenger.of(context).clearSnackBars();
    // SUBIR A OPÇÃO DE DESFAZER A MEDIDA QUE FOR SENDO SELECIONADO
    ScaffoldMessenger.of(context).showSnackBar(
      // MENSAGEM APÓS AÇÃO DO USUÁRIO
      SnackBar(
        content: Text(
          'Tarefa ${todo.title} foi removida com sucesso!',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: Colors.grey,
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
              // INSERIR NA POSIÇÃO, O ITEM DELETADO
              // EXCLAMAÇÃO PARA INFORMAR QUE O PARÂMETRO SÓ SERÁ TRATADADO SE NÃO FOR NULO
            });
            todoRepository.saveTodoList(todos);
            // SALVAR A EXCLUSÃO DO ITEM NO REPOSITÓRIO
          },
        ),
        duration: const Duration(seconds: 5),
        // DURAÇÃO DA MENSAGEM DE DESFAZER
      ),
    );
  }

  /// DELETAR TODOS AS TAREFAS DA LISTA
  void deleteAllTodos() {
    // FUNÇÃO PARA LIMPAR TUDO
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
    // SALVAR A EXCLUSÃO DOS ITENS NO REPOSITÓRIO
  }

  /// FUNÇÃO CAIXA DE ALERTA PARA SELEÇÃO DO AVATAR
  void addAvatar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog();
      },
    );
  }

  /// FUNÇÃO DE POP-UP COM A CONFIRMAÇÃO DA EXCLUSÃO COM OPÇÃO DE DESFAZER
  void showDeleteTodosConfirmationDialog() {
    // FUNÇÃO PARA CRIAR UMA CAIXA DE ALERTA PARA LIMPAR TUDO
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar tudo?'),
        content:
            const Text('Você tem certeza que deseja apagar todas as tarefas?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // PARA FECHAR O DIÁLOGO
            },
            style: TextButton.styleFrom(primary: Colors.lightBlue),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
              // PARA FECHAR O DIÁLOGO E CHAMAR A FUNÇÃO DE LIMPAR TUDO
            },
            style: TextButton.styleFrom(primary: Colors.red),
            child: const Text('Limpar tudo'),
          ),
        ],
      ),
    );
  }

  /// MODAL PARA ADIÇÃO DE TAREFA
  void configurationModalBottomSheet(context) {
    // FUNÇÃO PARA RECURSOS DO BUTTON ADD
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      context: context,
      builder: (BuildContext bc) {
        return SizedBox(
          child: Column(
            children: <Widget>[
              SizedBox(
                child: TextField(
                  controller: todoController,
                  decoration: InputDecoration(
                    border: const UnderlineInputBorder(),
                    labelText: 'Adicione uma tarefa!',
                    // TÍTULO DO CAMPO
                    hintText: 'Ex: Estudar Inglês',
                    // TEXTO DE EXEMPLO
                    errorText: errorText,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    // DEFAULT VALUE
                  ),
                  onSubmitted: (String text) {
                    if (text.isEmpty) {
                      setState(() {
                        errorText = 'O título não pode ser vazio!';
                      });
                      return;
                    }
                    setState(() {
                      Todo newTodo = Todo(
                        title: text,
                        dateTime: DateTime.now(),
                      );
                      // CRIANDO UM OBJETO NEW TODO
                      todos.add(newTodo);
                      // ADICINAR O NEW TODO NA LISTA DE TAREFA
                    });
                    todoRepository.saveTodoList(todos);
                    // SET STATE PARA ATUALIZAR A TELA
                    todoController.clear();
                    // APÓS A ADIÇÃO, O TEXTO DIGITADO É EXCLUÍDO DO CAMPO DE TAREFA
                    Navigator.of(context).pop();
                    // PARA FECHAR A CAIXA DE TEXTO APÓS O SUBMITE (ENTER)
                  },
                ),
                width: 450.0,
                height: 70.0,
              ),
              SizedBox(
                child: TextButton.icon(
                  onPressed: () {
                    String text = todoController.text;
                    if (text.isEmpty) {
                      setState(() {
                        errorText = 'O título não pode ser vazio!';
                      });
                      return;
                    }
                    setState(() {
                      Todo newTodo = Todo(
                        title: text,
                        dateTime: DateTime.now(),
                      );
                      // CRIANDO UM OBJETO NEW TODO
                      todos.add(newTodo);
                      // ADICINAR O NEW TODO NA LISTA DE TAREFA
                    });
                    todoRepository.saveTodoList(todos);
                    // SET STATE PARA ATUALIZAR A TELA
                    todoController.clear();
                    // APÓS A ADIÇÃO, O TEXTO DIGITADO É EXCLUÍDO DO CAMPO DE TAREFA
                    Navigator.of(context).pop();
                    // PARA FECHAR A CAIXA DE TEXTO APÓS O SUBMITE (ENTER)
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar'),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          height: 120.0,
        );
      },
    );
  }

  /// ORDEM DE EXIBIÇÃO DOS WIDGETS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _appBar(),
          _body(),
          Positioned(
            top: 27,
            right: 25,
            height: 65,
            width: 65,
            child: _arquivo(context),
          ),
          _titleTop(),
        ],
      ),
    );
  }

  /// APPBAR
  Widget _appBar() {
    return AppBar(
      flexibleSpace: Container(
        height: 150,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(33, 73, 79, 1.0),
              Color.fromRGBO(58, 121, 130, 1.0),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  /// TÍTULO E SUBTÍTULO
  Widget _titleTop() {
    return Column(
      children: [
        Container(
          child: const Text(
            'Higor Oliveira',
            style: TextStyle(
              fontFamily: "Sagoe UI",
              fontSize: 17,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          padding: const EdgeInsets.only(top: 42, left: 32),
        ),
        Container(
          child: const Text(
            'Desenvolvedor | Mobile',
            style: TextStyle(
              fontFamily: "Sagoe UI",
              letterSpacing: 0.5,
              fontSize: 10,
              color: Colors.white,
            ),
          ),
          padding: const EdgeInsets.only(top: 5, left: 32),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      // ALINHAMENTO DA COLUNA
    );
  }

  /// CORPO COM A LISTA DO APP
  Widget _body() {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 120.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35.0),
            topRight: Radius.circular(35.0),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: ListView(
                    // LISTA COM BARRA DE ROLAGEM COM TODOS OS ITENS
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        // PARA CADA LISTA QUE ESTAVA NAS TAREFAS FOI CRIADO UM LISTITLE
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                          // PASSADA A REFERÊNCIA DA FUNÇÃO onDelete POR PARÂMETRO PARA O WIDGTE FILHO
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 2º ESPAÇAMENTO ENTRE LISTA E INFORMATIVO DO TOTAL
                Row(
                  // 2º LINHA COM O INFORMATIVO DE TOTAL DE TAREFAS E BOTÃO DE LIMPAR
                  children: [
                    if (todos.isEmpty)
                      (const Expanded(
                        child: Text(
                          'Você não possuí tarefas adicionadas',
                        ),
                      ))
                    else if (todos.length == 1)
                      (Expanded(
                        child: Text(
                          'Você possuí ${todos.length} tarefa pendente',
                        ),
                      ))
                    else
                      (Expanded(
                        child: Text(
                          'Você possuí ${todos.length} tarefas pendentes',
                        ),
                      )),
                    const SizedBox(width: 8),
                    // ESPAÇAMENTO ENTRE O INFORMATIVO DO TOTAL E O BOTÃO DE LIMPAR
                    if (todos.isNotEmpty)
                      ElevatedButton.icon(
                        // BOTÃO DE LIMPAR
                        icon: const Icon(
                          Icons.delete_sweep_rounded,
                        ),
                        onPressed: showDeleteTodosConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          primary: const Color(0xFF673AB7),
                          onPrimary: Colors.white,
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                        label: const Text(
                          'Limpar tudo',
                          style: TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        // style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          configurationModalBottomSheet(context);
        },
        child: Container(
          width: 60,
          height: 60,
          child: const Icon(
            Icons.add,
            size: 37,
          ),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(233, 189, 75, 1.0),
                Color.fromRGBO(202, 116, 30, 1.0),
              ],
            ),
          ),
        ),
        elevation: 60,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        //bottom navigation bar on scaffold
        shape: const AutomaticNotchedShape(RoundedRectangleBorder()),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40.0),
              topRight: Radius.circular(40.0),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(30, 68, 81, 1.0),
                Color.fromRGBO(48, 100, 107, 1.0),
              ],
            ),
          ),
          height: 50.0,
          child: Row(
            //children inside bottom appbar
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: const Icon(Icons.search, color: Colors.transparent),
                  onPressed: () {}),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  /// BOTÃO DO AVATAR
  Widget _arquivo(context) {
    if (arquivo != null) {
      return SizedBox(
        child: FloatingActionButton(
          child: Image.file(
            arquivo!,
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          elevation: 60,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context),
            );
          },
        ),
      );
    } else {
      return SizedBox(
        child: FloatingActionButton(
          child: const Icon(Icons.account_circle_sharp, color: Colors.white70, size: 63),
          backgroundColor: Colors.transparent,
          // shape: const StadiumBorder(
          //  side: BorderSide(color: Colors.blue, width: 4),),
          /// BORDAS NO ÍCONE DO AVATAR
          elevation: 60,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context),
            );
          },
        ),
      );
    }
  }

  /// CAIXA PARA SELEÇÃO DO AVATAR
  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 200),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      title: const Text('Selecione ou tire uma foto:'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () =>
                Get.to(() => CameraCamera(onFile: (file) => showPreview(file))),
            icon: const Icon(Icons.camera_alt),
            label: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Tirar uma foto'),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
          ),
          ElevatedButton.icon(
            onPressed: () => getFileFromGallery(),
            icon: const Icon(Icons.camera_alt),
            label: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Selecionar da Galeria'),
            ),
          ),
        ],
      ),
    );
  }
}

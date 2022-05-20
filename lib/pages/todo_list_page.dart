import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolist/models/todo.dart';
import 'package:todolist/repositories/todo_repository.dart';
import 'package:todolist/widgets/todo_list_item.dart';
import '../preview/preview_page.dart';
import 'dart:io' as i;

/// DECLARANDO A PÁGINA
class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

final TextEditingController todoController = TextEditingController();
final TodoRepository todoRepository = TodoRepository();

class _TodoListPageState extends State<TodoListPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  get newTime => time;

  /// FORMATANDO DATA SELECIONADA E O DIA ATUAL
  get _dateNow => DateFormat.yMd().format(_focusedDay);

  get _now => DateFormat.yMd().format(DateTime.now());

  /// FORMATANDO O NOME DO DIA DA SEMANA
  //RETIRANDO TRECHO DO DIA
  String get primaryText =>
      DateFormat.EEEE('pt_BR').format(_focusedDay).replaceAll("-feira", "");

  // ESPECIFICANDO A PRIMEIRA LETRA COMO MAÍUSCULA
  String get firstUppercase => primaryText.substring(0, 1).toUpperCase();

  // CAPTANDO O RETANTE DO TEXTO COM EXCESSÃO DA PRIMEIRA LETRA
  String get lastUppercase => primaryText.substring(1);

  TimeOfDay _time = TimeOfDay.now();
  late TimeOfDay picked;

  Future<void> selectTime(BuildContext context) async {
    picked = (await showTimePicker(
      context: context,
      initialTime: _time,
    ))!;
    setState(() {
      _time = picked;
      print(picked);
    });
  }

  i.File? arquivo;
  XFile? archive;
  final picker = ImagePicker();

  get kEvents => null;

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

  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;
  String? errorText;

  /// ORDEM DE EXIBIÇÃO DOS WIDGETS
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _body(),
          Positioned(
            top: 20.0,
            right: 23.0,
            height: 35.0,
            width: 35.0,
            child: _avatar(context),
          ),
          _titleTop(),
        ],
      ),
    );
  }

  /// TÍTULO E SUBTÍTULO
  Widget _titleTop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_dateNow == _now)
          Container(
            child: const Text(
              "Hoje",
              style: TextStyle(
                fontFamily: "lib/fonts/Roboto-Black.ttf",
                fontWeight: FontWeight.w700,
                fontSize: 26,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            padding: const EdgeInsets.only(top: 24.0),
          )
        else
          Container(
            child: Text(
              firstUppercase + lastUppercase,
              // UNINDO O RESULTADO DOS DOIS TEXTOS
              style: const TextStyle(
                fontFamily: "lib/fonts/Roboto-Black.ttf",
                fontWeight: FontWeight.w700,
                fontSize: 26,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
            padding: const EdgeInsets.only(top: 24.0),
          )
      ],
    );
  }

  /// CORPO COM A LISTA DO APP
  Widget _body() {
    return Scaffold(
        body: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 75.0),
                child: TableCalendar(
                  headerVisible: false,
                  locale: 'pt_BR',
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(
                      // DIAS DA SEMANA - ÚTEIS
                      fontFamily: "lib/fonts/Roboto-Medium.ttf",
                      fontWeight: FontWeight.w500,
                      fontSize: 17.0,
                      color: Color.fromRGBO(47, 64, 79, 1),
                    ),
                    weekendStyle: const TextStyle(
                        // DIAS DA SEMANA - FIM DE SEMANA
                        fontFamily: "lib/fonts/Roboto-Medium.ttf",
                        fontWeight: FontWeight.w600,
                        fontSize: 17.0,
                        color: Color.fromRGBO(47, 64, 79, 1.0)),
                    dowTextFormatter: (date, locale) =>
                        DateFormat.E(locale).format(date)[0].toUpperCase(),
                  ),
                  calendarStyle: const CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(85, 173, 181, 1),
                    ),
                    todayTextStyle: TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.white),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromRGBO(25, 32, 51, 1.0),
                    ),
                    defaultTextStyle: TextStyle(
                        // DIAS DOS MêS - ÚTEIS
                        fontFamily: "lib/fonts/Roboto-Light.ttf",
                        color: Colors.white),
                    weekendTextStyle: TextStyle(
                        // DIAS DOS MêS - FIM DE SEMANA
                        fontFamily: "lib/fonts/Roboto-Light.ttf",
                        color: Colors.white),
                  ),
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ListView(
                    // LISTA COM BARRA DE ROLAGEM COM TODOS OS ITENS
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        // PARA CADA LISTA QUE ESTAVA NAS TAREFAS FOI CRIADO UM LISTITLE
                        if (DateFormat('dd/MM/yyyy').format(todo.date) ==
                            DateFormat('dd/MM/yyyy').format(_selectedDay))
                          (TodoListItem(
                            todo: todo,
                            onDelete: onDelete,
                            // PASSADA A REFERÊNCIA DA FUNÇÃO onDelete POR PARÂMETRO PARA O WIDGTE FILHO
                          ))
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // ESPAÇAMENTO ENTRE O INFORMATIVO DO TOTAL E O BOTÃO DE LIMPAR
                children: [
                  if (todos.isEmpty)
                    Flexible(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const <Widget>[
                            Text(
                              'Você ainda não possuí tarefas adicionadas.',
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (todos.length == 1)
                    Container(
                      padding: const EdgeInsets.only(left: 20.0, top: 10, right: 10, bottom: 10),
                      child: Expanded(
                        child: Text(
                          'Você possuí ${todos.length} tarefa pendente',
                        ),
                      ),
                    )
                  else if (todos.length > 1)
                    Container(
                        padding: const EdgeInsets.only(left: 20.0, top: 10, right: 10, bottom: 10),
                        child: Expanded(
                          child: Text(
                            'Você possuí ${todos.length} tarefas pendentes',
                          ),
                        )),
                  if (todos.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: ElevatedButton.icon(
                        // BOTÃO DE LIMPAR
                        icon: const Icon(
                          Icons.delete_sweep_rounded,
                        ),
                        onPressed: showDeleteTodosConfirmationDialog,
                        style: ElevatedButton.styleFrom(
                          primary: Colors.transparent,
                          onPrimary: Colors.white,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                          ),
                          padding: const EdgeInsets.all(12.0),
                        ),
                        label: const Text(
                          'Limpar tudo',
                          style: TextStyle(
                            fontFamily: "lib/fonts/Roboto-Medium.ttf",
                            fontWeight: FontWeight.w600,
                            fontSize: 13.0,
                          ),
                        ),
                        // style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            hourModal(context);
          },
          child: Container(
            width: 60.0,
            height: 60.0,
            child: const Icon(
              Icons.add,
              size: 35.0,
              color: Colors.white,
            ),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromRGBO(85, 173, 181, 1),
              // Color.fromRGBO(116, 234, 206, 1.0),
            ),
          ),
          elevation: 60.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(35.0),
            topLeft: Radius.circular(35.0),
          ),
          child: BottomAppBar(
            color: const Color.fromRGBO(25, 32, 51, 1),
            notchMargin: 10.0,
            shape: const CircularNotchedRectangle(),
            elevation: 60.0,
            child: SizedBox(
              height: 60.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.home, color: Colors.transparent),
                      onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: const Color.fromRGBO(19, 27, 40, 1.0));
  }

  /// BOTÃO DA IMAGEM DE PERFIL
  Widget _avatar(context) {
    if (arquivo != null) {
      return SizedBox(
        child: FloatingActionButton(
          child: Image.file(
            arquivo!,
            fit: BoxFit.cover,
          ),
          backgroundColor: Colors.transparent,
          elevation: 60.0,
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
          child: Icon(Icons.account_circle_sharp,
              color: Colors.grey[900], size: 35.0),
          backgroundColor: Colors.white,
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

  /// POP-UP PARA SELEÇÃO DA IMAGEM DE PERFIL
  Widget _buildPopupDialog(BuildContext context) {
    return AlertDialog(
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 200.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Foto de Perfil',
            style: TextStyle(
                fontFamily: "lib/fonts/Segoe UI Bold.ttf",
                fontWeight: FontWeight.w600,
                fontSize: 26.0,
                letterSpacing: 1.0,
                color: Colors.white),
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 30.0),
          ),
          SizedBox(
            width: 220.0,
            height: 50.0,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromRGBO(85, 173, 181, 1),
                ),
              ),
              onPressed: () => Get.to(
                  () => CameraCamera(onFile: (file) => showPreview(file))),
              icon: const Icon(Icons.camera_alt),
              label: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Tirar uma foto'),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10.0),
          ),
          SizedBox(
            width: 220.0,
            height: 50.0,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromRGBO(85, 173, 181, 1),
                ),
              ),
              onPressed: () => getFileFromGallery(),
              icon: const Icon(Icons.image),
              label: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text('Selecionar da Galeria'),
              ),
            ),
          ),
        ],
      ),
    );
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

  /// MODAL PARA ADICIONAR A TAREFA
  void hourModal(BuildContext context) {
    // FUNÇÃO PARA CRIAR A CAIXA DE ALERTA PARA ADIÇÃO DE TAREFA
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        title: const Text(
          'Adicionar Tarefa',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontFamily: "lib/fonts/Roboto-Bold.ttf",
              fontSize: 26.0,
              color: Colors.white),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 100.0, vertical: 180.0),
        content: Flexible(
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            initialDateTime: _selectedDay,
            onDateTimeChanged: (DateTime newTime) {
              setState(() => time = newTime as TimeOfDay);
            },
          ),
        ),
        actions: [
          Column(
            children: [
              Center(
                child: SizedBox(
                  width: 250.0,
                  child: TextField(
                    controller: todoController,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.only(left: 5.0, right: 5.0),
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      border: const UnderlineInputBorder(),
                      errorText: errorText,
                      labelText: 'Ex: Estudar Inglês',
                      // DESCRIÇÃO DO CAMPO
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.cyan,
                          width: 2.0,
                        ),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                    ),
                    onSubmitted: (String text) {
                      if (text.isEmpty) {
                        setState(() {
                          errorText = 'O título não pode ser vazio!';
                        });
                        return;
                      }
                      todoController.clear();
                      // APÓS A ADIÇÃO, O TEXTO DIGITADO É EXCLUÍDO DO CAMPO DE TAREFA
                      Navigator.of(context).pop();
                      // PARA FECHAR A CAIXA DE TEXTO APÓS O SUBMITE (ENTER)
                      setState(() {
                        Todo newTodo = Todo(
                          title: text,
                          date: _selectedDay,
                          time: newTime,
                        );
                        // CRIANDO UM OBJETO NEW TODO
                        todos.add(newTodo);
                        // ADICINAR O NEW TODO NA LISTA DE TAREFA
                      });
                      todoRepository.saveTodoList(todos);
                      // SET STATE PARA ATUALIZAR A TELA
                    },
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 10.0)),
              SizedBox(
                child: TextButton.icon(
                  icon: const Icon(
                    Icons.add,
                    size: 18.0,
                    color: Colors.cyan,
                  ),
                  label: const Text('Adicionar',
                      style: TextStyle(color: Colors.cyan)),
                  onPressed: () {
                    String text = todoController.text;
                    if (text.isEmpty) {
                      setState(() {
                        errorText = 'O título não pode ser vazio!';
                      });
                      return;
                    }
                    todoController.clear();
                    // APÓS A ADIÇÃO, O TEXTO DIGITADO É EXCLUÍDO DO CAMPO DE TAREFA
                    Navigator.of(context).pop();
                    // PARA FECHAR A CAIXA DE TEXTO APÓS O SUBMITE (ENTER)
                    setState(() {
                      Todo newTodo = Todo(
                        title: text,
                        date: _selectedDay,
                        time: newTime,
                      );
                      // CRIANDO UM OBJETO NEW TODO
                      todos.add(newTodo);
                      // ADICINAR O NEW TODO NA LISTA DE TAREFA
                    });
                    todoRepository.saveTodoList(todos);
                    // SET STATE PARA ATUALIZAR A TELA
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// FUNÇÃO PARA DELETAR TAREFAS ESPECÍFICAS DA LISTA
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
}

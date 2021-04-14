

import 'package:flutter/material.dart';
import 'package:network_app/notifiers/todo_list_notifier.dart';
import 'package:provider/provider.dart';

import 'models/todo_model.dart';

import 'dart:async';

import 'package:path/path.dart' as pth;
import 'package:sqflite/sqflite.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {




  @override
  void initState() {
    super.initState();
    getDataFromDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Todo List"),
      ),
      body: Consumer<TodoListNotifier>(
          builder: (context, todoListNotifier, child) {
            return ListView(
                children: todoListNotifier.todos.map(
                        (todo) => TodoInstance(t: todo,)
                ).toList()
            );
          }
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: openAddPage,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
      )
    );
  }

  openAddPage() {

    showDialog(
        context: context,
      builder: (BuildContext ctx)=> AddTodoDialog()
    );
  }



  void getDataFromDatabase() async {

    final Future<Database> database = openDatabase(
      pth.join(await getDatabasesPath(), 'todos.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE todo(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INTEGER);",
        );
      },
      version: 1,
    );

    final Database db = await database;
    
    final List<Map<String, dynamic>> list = await db.query('todo');

    List<Todo> receivdList = list.map(
            (e) => Todo(
            id: e["id"],
            title: e["title"],
            description: e["description"],
            isDone: e["isDone"]==0 ?false : true
        )
    ).toList();

    Provider
        .of<TodoListNotifier>(context, listen: false)
        .setNewList(receivdList);


  }


}

class TodoInstance extends StatefulWidget {
  @override
  _TodoInstanceState createState() => _TodoInstanceState(t: t);
  Todo t;
  TodoInstance({this.t});
}

class _TodoInstanceState extends State<TodoInstance> {


  Todo t;
  _TodoInstanceState({this.t});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: UniqueKey(),
        child: FlatButton(
            padding: EdgeInsets.all(0),
            onPressed: (){
              setState(() {
                t.isDone = t.isDone ?false : true;
              });
              updateTodo(t);
            },
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(t.title),
                      subtitle: Text(t.description),
                    ),
                  ),
                  t.isDone
                      ?Icon(Icons.check_circle, color: Colors.green,)
                      :Icon(Icons.radio_button_unchecked, color: Colors.grey,)
                ],
              ),
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 5,
                        blurRadius: 5,
                        color: Colors.black12
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
            )
        ),
        onDismissed: (DismissDirection direction)=> deleteTodo(t.id)
    );
  }

  deleteTodo(int id)async{

    final Future<Database> database = openDatabase(
        pth.join(await getDatabasesPath(), 'todos.db'),
        onCreate: (db, version) async {
    await db.execute(
    "CREATE TABLE todo(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INTEGER);",
    );
    },
    version: 1,
    );

    final db = await database;

    db.delete(
        'todo',
      where: "id = ?",
      whereArgs: [id],
    );

  }


  updateTodo(Todo t) async {

    final Future<Database> database = openDatabase(
        pth.join(await getDatabasesPath(), 'todos.db'),
        onCreate: (db, version) async {
    await db.execute(
    "CREATE TABLE todo(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INTEGER);",
    );
    },
    version: 1,
    );

    final db = await database;

    await db.update(
        'todo',
        t.toMap(),
        where: "id = ?",
        whereArgs: [t.id]
    );

  }
}

class AddTodoDialog extends StatelessWidget {

  final formKey = GlobalKey<FormState>();
  Todo newTodo = Todo();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      child: Container(
        padding: EdgeInsets.all(10),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: TextFormField(
                    decoration: InputDecoration(
                        labelText: "Title",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(0)
                    ),
                    onSaved: (v){
                      newTodo.title = v;
                    },
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white
                  ),
                ),
                Container(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: TextFormField(
                    maxLines: 5,
                    decoration: InputDecoration(
                        labelText: "Description",
                        border: InputBorder.none,

                        isDense: true,
                        contentPadding: EdgeInsets.all(0)
                    ),
                    onSaved: (v){
                      newTodo.description = v;
                    },
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Colors.white
                  ),
                ),

                Container(
                  height: 10,
                ),

                RaisedButton(
                    child: Text("Add"),
                    onPressed: ()=>addTodo(newTodo, context)
                )
              ],
            ),
          ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(20))

        ),
      ),
    );
  }
  addTodo(Todo t, BuildContext c) {
    t.isDone = false;
    formKey.currentState.save();

    Provider
        .of<TodoListNotifier>(c , listen: false)
        .addToList(t);

    Navigator.pop(c);
    addDataToDatabase(t);
  }

  void addDataToDatabase(Todo t) async{

    final Future<Database> database = openDatabase(
      pth.join(await getDatabasesPath(), 'todos.db'),
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE todo(id INTEGER PRIMARY KEY, title TEXT, description TEXT, isDone INTEGER);",
        );
      },
      version: 1,
    );

    final Database db = await database;

    await db.insert(
        'todo',
        t.toMap()
    );

  }
}

//get
//add
//todo: update
//todo: delete
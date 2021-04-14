

import 'package:flutter/material.dart';
import 'package:network_app/models/todo_model.dart';

class TodoListNotifier extends ChangeNotifier{

  List<Todo> todos = [];

  TodoListNotifier({this.todos= const []});

  setNewList(List<Todo> newList){
    todos = newList;
    notifyListeners();
  }

  addToList(Todo t){
    todos.add(t);
    notifyListeners();
  }


}
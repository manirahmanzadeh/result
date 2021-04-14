
import 'package:flutter/material.dart';
import 'package:network_app/notifiers/todo_list_notifier.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';



void main(){
  runApp(
      ChangeNotifierProvider(
          create: (context)=> TodoListNotifier(),
        child: MyApp(),
      )
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF9474cc)
      ),
    );
  }
}

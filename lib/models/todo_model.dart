
class Todo{
  int id;
  String title;
  String description;
  bool isDone;
  Todo({this.title, this.description, this.isDone, this.id});

  toMap()=>{
    'title' : title,
    'description' : description,
    'isDone' : isDone ? 1 : 0
  };

}
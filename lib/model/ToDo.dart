import 'package:objectbox/objectbox.dart';

@Entity()
class ToDo {
  int id = 0;
  String todo;
  bool check = false;

  ToDo({
    required this.todo,
    required this.check,
  });
}

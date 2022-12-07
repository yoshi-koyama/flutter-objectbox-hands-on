import 'package:flutter/material.dart';
import 'package:flutter_objectbox_hands_on/objectbox.g.dart';

import '../model/ToDo.dart';
import 'ShoppingMemoPage.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({Key? key}) : super(key: key);

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  // ObjectBoxの利用にstoreが必要
  Store? store;
  Box<ToDo>? toDoBox;
  List<ToDo> toDoList = [];

  // 投稿後の内容を削除するためのもの
  final controller = TextEditingController();

  Future<void> initialize() async {
    // storeの作成にopenStore()という非同期関数の実行が必要
    store = await openStore();
    toDoBox = store?.box<ToDo>();
    fetchToDoList();
  }

  // この関数の中の処理は初回に一度だけ実行される
  @override
  void initState() {
    super.initState();
    initialize();
  }

  // BoxからToDo一覧を取得
  void fetchToDoList() {
    toDoList = toDoBox?.getAll() ?? [];
    setState(() {});
  }

  // controllerを使う時はdisposeが必要
  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: Text(
          "ToDoリスト",
          style: TextStyle(fontSize: 32, color: Colors.amber[300]),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, size: 28),
            onPressed: () {
              store?.close();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ShoppingMemoPage()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: toDoList.length,
              itemBuilder: (context, index) {
                final toDo = toDoList[index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // チェックボックスの表示
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                          activeColor: Colors.blue,
                          value: toDo.check,
                          onChanged: (bool? checkBoxState) {
                            toDo.check = checkBoxState!;
                            toDoBox?.put(toDo);
                            fetchToDoList();
                          },
                        ),
                      ),
                      // ToDoリストの内容を表示
                      Expanded(
                        child: Text(
                          toDo.todo,
                          style: TextStyle(
                              fontSize: 28,
                              color: toDo.check ? Colors.grey : Colors.black),
                        ),
                      ),
                      // ToDoリストの削除
                      IconButton(
                        onPressed: () {
                          toDoBox?.remove(toDo.id);
                          fetchToDoList();
                        },
                        icon: const Icon(Icons.delete, size: 28),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'ToDoリスト追加',
                fillColor: Colors.blue[500],
                filled: true,
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.deepPurpleAccent,
                    width: 1,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
              ),
              onFieldSubmitted: (text) {
                if (text != "") {
                  final newToDo = ToDo(todo: text, check: false);
                  toDoBox?.put(newToDo);
                  fetchToDoList();
                }
                controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:todo_app_project/Screens/add_page.dart';
import 'package:todo_app_project/Services/todo_service.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    // TODO: implement initState
    fetchTodo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: const Center(
              child: Text('No Todo Item'),
            ),
            child: ListView.builder(
                itemCount: items.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(onSelected: (value) {
                        if (value == 'edit') {
                          //open edit page
                          navigateToEditPage(item);
                        } else if (value == 'delete') {
                          //delete and remove the item
                          deleteById(id);
                        }
                      }, itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: Text('Edit'),
                            value: 'edit',
                          ),
                          const PopupMenuItem(
                            child: Text('Delete'),
                            value: 'delete',
                          ),
                        ];
                      }),
                    ),
                  );
                }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage,
        label: const Text('Add Todo'),
      ),
    );
  }

  Future<void> navigateToEditPage(Map item) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => AddTodoPage(todo: item)));
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigateToAddPage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const AddTodoPage()));
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteById(id) async {
    // Delete the item

    final isSuccess = await TodoService.deleteById(id);
    if (isSuccess) {
      // Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      // show the error
      showErrorMessage('Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    final response = await TodoService.fetchToDos();

    if (response != null) {
      setState(() {
        items = response;
      });
    } else {
      showErrorMessage('Something Went wrong');
    }

    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

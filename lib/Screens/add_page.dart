import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodoPage extends StatefulWidget {
  final Map? todo;
  const AddTodoPage({
    super.key,
    this.todo,
  });

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titlecontroller.text = title;
      descriptioncontroller.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add Todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          TextField(
            controller: titlecontroller,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptioncontroller,
            decoration: const InputDecoration(
              hintText: 'Description',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: isEdit ? updateData : SubmitData,
              child: Text(isEdit ? 'Update' : 'Submit')),
        ],
      ),
    );
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("you cannot call updated without todo data");
      return;
    }
    final id = todo['_id'];
    // final iscompleted = todo['is_completed'];
    final title = titlecontroller.text;
    final description = descriptioncontroller.text;

    // Get data from form

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // submit the updated data to the server

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      showSuccessMessage('Updation Success');
    } else {
      showErrorMessage('Updation Failed');
    }
  }

  Future<void> SubmitData() async {
// to reset the form after success submission

    final title = titlecontroller.text;
    final description = descriptioncontroller.text;

    // Get data from form

    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    // submit data to the server

    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    // show success or fail message based on status

    if (response.statusCode == 201) {
      titlecontroller.text = '';
      descriptioncontroller.text = '';
      showSuccessMessage('Creation Success');
    } else {
      showErrorMessage('Creation Failed');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.green),
        ));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.red),
        ));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/pages/add_page.dart';
import 'package:http/http.dart' as http;

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
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final id = item['id'];
              return ListTile(
                leading: CircleAvatar(child: Text('${item['id']}')),
                title: Text(item['title']),
                subtitle: Text(item['description']),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Handle edit action
                    } else if (value == 'delete') {
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ];
                  },
                ),
              );
            },
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigationToAddPage,
        label: Text('Add Todo'),
      ),
    );
  }

  void navigationToAddPage() {
    final route = MaterialPageRoute(builder: (context) => const AddTodoPage());
    Navigator.push(context, route);
  }

  Future<void> deleteById(int id) async {
    final url = 'http://10.0.2.2:8000/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 204) {
      final filtered = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtered;
      });
    }
  }

  Future<void> fetchTodo() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = 'http://10.0.2.2:8000/todos?page=1&limit=10';
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        setState(() {
          items = result;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

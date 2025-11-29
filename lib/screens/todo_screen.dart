import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Buat simpan data
import 'dart:convert'; // Buat terjemahin JSON

// --- CLASS TODO (MODEL) DIMASUKIN SINI BIAR GAK ERROR IMPORT ---
class Todo {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
// ---------------------------------------------------------

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  // Variabel penampung data
  List<Todo> todos = [];
  String filterStatus = 'Semua'; // Pilihan: Semua, Selesai, Belum

  @override
  void initState() {
    super.initState();
    loadTodos(); // Panggil fungsi baca data pas aplikasi dibuka
  }

  // --- LOGIC SIMPAN & BACA (SharedPreferences) ---

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = todos.map((todo) => todo.toJson()).toList();
    String todosString = jsonEncode(jsonList);
    await prefs.setString('todos_revo', todosString);
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    String? todosString = prefs.getString('todos_revo');

    if (todosString != null) {
      List<dynamic> jsonList = jsonDecode(todosString);
      setState(() {
        todos = jsonList.map((json) => Todo.fromJson(json)).toList();
      });
    }
  }

  // --- LOGIC CRUD (Tambah, Edit, Hapus) ---

  void addTodo(String title) {
    setState(() {
      todos.add(Todo(
        id: DateTime.now().toString(),
        title: title,
        createdAt: DateTime.now(),
        isCompleted: false,
      ));
    });
    saveTodos();
  }

  void toggleTodoStatus(Todo todo, bool? value) {
    setState(() {
      todo.isCompleted = value ?? false;
    });
    saveTodos();
  }

  void deleteTodo(String id) {
    setState(() {
      todos.removeWhere((item) => item.id == id);
    });
    saveTodos();
  }

  List<Todo> getFilteredTodos() {
    if (filterStatus == 'Selesai') {
      return todos.where((todo) => todo.isCompleted).toList();
    } else if (filterStatus == 'Belum') {
      return todos.where((todo) => !todo.isCompleted).toList();
    }
    return todos;
  }

  // --- TAMPILAN (UI) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas 1: Todo List'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          DropdownButton<String>(
            value: filterStatus,
            dropdownColor: Colors.white,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            underline: Container(),
            style: const TextStyle(color: Colors.black),
            items: ['Semua', 'Selesai', 'Belum'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                filterStatus = newValue!;
              });
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: getFilteredTodos().isEmpty
          ? Center(child: Text('Kosong nih di filter "$filterStatus"'))
          : ListView.builder(
        itemCount: getFilteredTodos().length,
        itemBuilder: (context, index) {
          final todo = getFilteredTodos()[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (val) => toggleTodoStatus(todo, val),
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: todo.isCompleted ? Colors.grey : Colors.black,
                ),
              ),
              subtitle: Text("Dibuat: ${todo.createdAt.toString().substring(0, 16)}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteTodo(todo.id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddDialog,
      ),
    );
  }

  void _showAddDialog() {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Tugas Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Contoh: Beli pulsa"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                addTodo(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
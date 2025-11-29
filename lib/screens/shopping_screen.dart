import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/shopping_model.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<ShoppingItem> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  // --- LOGIC SIMPAN & BACA (PERSISTENT) ---

  Future<void> saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString('shopping_revo', jsonEncode(jsonList));
  }

  Future<void> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('shopping_revo');
    if (data != null) {
      List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        items = jsonList.map((json) => ShoppingItem.fromJson(json)).toList();
      });
    }
  }

  // --- CRUD OPERASI ---

  void addItem(String name, String amount, String category) {
    setState(() {
      items.add(ShoppingItem(
        id: DateTime.now().toString(),
        name: name,
        amount: amount,
        category: category,
      ));
    });
    saveItems();
  }

  void deleteItem(String id) {
    setState(() {
      items.removeWhere((item) => item.id == id);
    });
    saveItems();
  }

  void toggleStatus(int index, bool? val) {
    setState(() {
      items[index].isBought = val ?? false;
    });
    saveItems();
  }

  // --- TAMPILAN (UI) ---

  @override
  Widget build(BuildContext context) {
    // Hitung total item yang sudah & belum dibeli [cite: 492]
    int totalBought = items.where((i) => i.isBought).length;
    int totalPending = items.length - totalBought;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas 2: Daftar Belanja'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Dashboard Info Total
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoCard("Total Item", "${items.length}", Colors.blue),
                _buildInfoCard("Sudah Dibeli", "$totalBought", Colors.green),
                _buildInfoCard("Belum", "$totalPending", Colors.orange),
              ],
            ),
          ),
          // List Belanja
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text("Belum ada belanjaan"))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.isBought,
                      activeColor: Colors.green,
                      onChanged: (val) => toggleStatus(index, val),
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.isBought
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text("${item.amount} | ${item.category}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteItem(item.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showAddDialog,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Dialog Tambah Belanjaan dengan Dropdown Kategori
  void _showAddDialog() {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = 'Makanan'; // Default kategori
    final List<String> categories = ['Makanan', 'Minuman', 'Elektronik', 'Lainnya'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Biar Dropdown bisa berubah state-nya di dalam dialog
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah Belanjaan'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nama Barang'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Jumlah (cth: 2 kg)'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (val) {
                      setStateDialog(() => selectedCategory = val!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      addItem(nameController.text, amountController.text, selectedCategory);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
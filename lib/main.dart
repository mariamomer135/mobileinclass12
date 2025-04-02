import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: kIsWeb
          ? const FirebaseOptions(
              apiKey: "AIzaSyAwAVoQrdnJCOckpBjLY63f6VFTILfLAKU",
              authDomain: "in-class-12-54f59.firebaseapp.com",
              projectId: "in-class-12-54f59",
              storageBucket: "in-class-12-54f59.firebasestorage.app",
              messagingSenderId: "10360596061",
              appId: "1:10360596061:web:d5387b9a47e910cc280fb4",
            )
          : null, // Mobile initializes using google-services.json
    );
  }

  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Manager',
      theme: ThemeData(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.green.shade50,
        colorScheme: ColorScheme.light(
          primary: Colors.green,
          secondary: Colors.pinkAccent,
        ),
      ),
      home: const InventoryHomePage(title: 'Inventory Dashboard'),
    );
  }
}

class InventoryHomePage extends StatefulWidget {
  final String title;
  const InventoryHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  final CollectionReference inventoryCollection =
      FirebaseFirestore.instance.collection('inventory');
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool isEditing = false;
  String? currentItemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: inventoryCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No items found", style: TextStyle(fontSize: 16)));
                }

                var items = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.green.shade200),
                  itemBuilder: (context, index) {
                    var item = items[index];
                    return ListTile(
                      title: Text(
                        item['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                      subtitle: Text("Quantity: ${item['quantity']}",
                          style: TextStyle(color: Colors.pink.shade700)),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueGrey),
                            onPressed: () => _editItem(item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteItem(item),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInputForm(),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                onPressed: isEditing ? _updateItem : _addNewItem,
                child: Text(isEditing ? 'Update Item' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearForm() {
    _nameController.clear();
    _quantityController.clear();
    setState(() {
      isEditing = false;
    });
  }

  void _addNewItem() {
    final String name = _nameController.text.trim();
    final String quantityStr = _quantityController.text.trim();

    if (name.isEmpty || quantityStr.isEmpty) return;

    final int quantity = int.tryParse(quantityStr) ?? 0;
    if (quantity <= 0) return;

    inventoryCollection.add({'name': name, 'quantity': quantity});
    _clearForm();
  }

  void _editItem(DocumentSnapshot item) {
    setState(() {
      isEditing = true;
      currentItemId = item.id;
      _nameController.text = item['name'];
      _quantityController.text = item['quantity'].toString();
    });
  }

  void _updateItem() {
    final String name = _nameController.text.trim();
    final String quantityStr = _quantityController.text.trim();

    if (name.isEmpty || quantityStr.isEmpty) return;

    final int quantity = int.tryParse(quantityStr) ?? 0;
    if (quantity <= 0) return;

    inventoryCollection.doc(currentItemId).update({'name': name, 'quantity': quantity});
    _clearForm();
  }

  void _deleteItem(DocumentSnapshot item) {
    item.reference.delete();
  }
}

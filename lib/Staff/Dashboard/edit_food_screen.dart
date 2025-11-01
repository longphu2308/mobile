// lib/staff/screens/edit_food_screen.dart
import 'package:flutter/material.dart';

class EditFoodScreen extends StatefulWidget {
  final Map<String, dynamic>? food;
  const EditFoodScreen({super.key, this.food});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtl;
  late TextEditingController _priceCtl;
  late TextEditingController _descCtl;
  bool _available = true;

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _nameCtl = TextEditingController(text: f != null ? f['name'] : '');
    _priceCtl = TextEditingController(text: f != null ? f['price'].toString() : '');
    _descCtl = TextEditingController(text: f != null ? (f['desc'] ?? '') : '');
    _available = f != null ? (f['available'] ?? true) : true;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final res = {
      'id': widget.food != null ? widget.food!['id'] : 'F${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameCtl.text.trim(),
      'price': int.tryParse(_priceCtl.text.trim()) ?? 0,
      'desc': _descCtl.text.trim(),
      'available': _available,
    };
    Navigator.pop(context, res);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.food != null ? 'Edit food' : 'Add food', style: const TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // image placeholder
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.camera_alt_outlined, size: 36, color: Colors.grey),
                    SizedBox(height: 6),
                    Text('Add image (placeholder)', style: TextStyle(color: Colors.black54)),
                  ],
                )),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameCtl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter name' : null,
                decoration: const InputDecoration(labelText: 'Food name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter price' : null,
                decoration: const InputDecoration(labelText: 'Price (VNĐ)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available'),
                value: _available,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _available = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: Text(widget.food != null ? 'Save changes' : 'Add food', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

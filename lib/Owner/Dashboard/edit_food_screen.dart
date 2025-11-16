import 'package:flutter/material.dart';

class EditFoodScreen extends StatefulWidget {
  final Map<String, dynamic>? food;
  const EditFoodScreen({super.key, this.food});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color primaryColor = const Color(0xFFFF6B1D);

  late TextEditingController _nameCtl;
  late TextEditingController _priceCtl;
  late TextEditingController _descCtl;
  late TextEditingController _imageCtl;
  String _category = 'Món chính';
  bool _available = true;

  // Tuỳ chọn món
  Map<String, String> _options = {'Size': 'Vừa', 'Topping': 'Không'};

  final List<String> _categories = ['Món chính', 'Đồ uống', 'Combo'];

  @override
  void initState() {
    super.initState();
    final f = widget.food;
    _nameCtl = TextEditingController(text: f?['name'] ?? '');
    _priceCtl = TextEditingController(text: f?['price']?.toString() ?? '');
    _descCtl = TextEditingController(text: f?['desc'] ?? '');
    _imageCtl = TextEditingController(text: f?['image'] ?? '');
    _category = f?['category'] ?? 'Món chính';
    _available = f?['available'] ?? true;
    _options = Map<String, String>.from(f?['options'] ?? _options);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final res = {
      'id': widget.food != null
          ? widget.food!['id']
          : 'F${DateTime.now().millisecondsSinceEpoch}',
      'name': _nameCtl.text.trim(),
      'price': int.tryParse(_priceCtl.text.trim()) ?? 0,
      'desc': _descCtl.text.trim(),
      'available': _available,
      'category': _category,
      'image': _imageCtl.text.trim(),
      'options': _options,
    };
    Navigator.pop(context, res);
  }

  Widget _buildOptionRow(String key, String value) {
    return Row(
      children: [
        Expanded(child: Text(key)),
        Expanded(
          flex: 2,
          child: TextFormField(
            initialValue: value,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => _options[key] = v,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _options.remove(key)),
          icon: const Icon(Icons.delete, color: Colors.redAccent),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.food != null ? 'Chỉnh sửa món' : 'Thêm món',
            style: const TextStyle(color: Colors.black)),
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Ảnh món
              TextFormField(
                controller: _imageCtl,
                decoration: const InputDecoration(
                  labelText: 'Ảnh (URL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nhập tên món' : null,
                decoration: const InputDecoration(
                    labelText: 'Tên món', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceCtl,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nhập giá' : null,
                decoration: const InputDecoration(
                    labelText: 'Giá (VNĐ)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                    labelText: 'Mô tả món', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Còn hàng'),
                value: _available,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _available = v),
              ),
              const SizedBox(height: 20),

              // Tuỳ chọn món
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tùy chọn món',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _options['Tùy chọn mới'] = '';
                      });
                    },
                  )
                ],
              ),
              const SizedBox(height: 8),
              ..._options.entries
                  .map((e) => _buildOptionRow(e.key, e.value))
                  .toList(),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(widget.food != null ? 'Lưu thay đổi' : 'Thêm món',
                      style: const TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

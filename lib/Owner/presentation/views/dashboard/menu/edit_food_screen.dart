import 'package:flutter/material.dart';
import 'package:mobile/Owner/presentation/controllers/edit_food_controller.dart';
import 'package:mobile/User/utils/utils.dart';

class EditFoodScreen extends StatefulWidget {
  final Map<String, dynamic>? food;
  const EditFoodScreen({super.key, this.food});

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  late EditFoodController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditFoodController(widget.food);
  }

  void _save() {
    final res = _controller.save(widget.food);
    if (res.isNotEmpty) {
      Navigator.pop(context, res);
    }
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
            onChanged: (v) => _controller.options[key] = v,
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _controller.removeOption(key)),
          icon: const Icon(Icons.delete, color: Colors.redAccent),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        title: Text(
          widget.food != null ? 'Chỉnh sửa món' : 'Thêm món',
          style: const TextStyle(color: blackColor),
        ),
        leading: const BackButton(color: blackColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(horizontalPadding),
        child: Form(
          key: _controller.formKey,
          child: Column(
            children: [
              // Ảnh món
              TextFormField(
                controller: _controller.imageCtl,
                decoration: const InputDecoration(
                  labelText: 'Ảnh (URL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.nameCtl,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nhập tên món' : null,
                decoration: const InputDecoration(
                  labelText: 'Tên món',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.priceCtl,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nhập giá' : null,
                decoration: const InputDecoration(
                  labelText: 'Giá (VNĐ)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _controller.category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: _controller.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(
                  () => _controller.category = v ?? _controller.category,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _controller.descCtl,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Mô tả món',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Còn hàng'),
                value: _controller.available,
                activeColor: primaryColor,
                onChanged: (v) => setState(() => _controller.available = v),
              ),
              const SizedBox(height: 20),

              // Tuỳ chọn món
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tùy chọn món',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _controller.addOption('Tùy chọn mới', '');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._controller.options.entries
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
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    widget.food != null ? 'Lưu thay đổi' : 'Thêm món',
                    style: const TextStyle(color: whiteColor, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

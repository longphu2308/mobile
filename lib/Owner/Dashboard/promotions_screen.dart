import 'package:flutter/material.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final List<Map<String, dynamic>> _promos = [
    {
      'code': 'WELCOME10',
      'type': 'Giảm %',
      'value': 10,
      'maxDiscount': 10000,
      'active': true,
      'used': 25,
    },
    {
      'code': 'FREESHIP',
      'type': 'Miễn phí vận chuyển',
      'value': 0,
      'maxDiscount': 0,
      'active': true,
      'used': 40,
    },
    {
      'code': 'FLASHSALE',
      'type': 'Chiến dịch',
      'value': 20,
      'maxDiscount': 15000,
      'active': false,
      'used': 12,
    },
  ];

  void _toggleActive(int idx) => setState(() {
        _promos[idx]['active'] = !_promos[idx]['active'];
      });

  void _createPromo() {
    showDialog(
      context: context,
      builder: (context) {
        final codeCtrl = TextEditingController();
        final valueCtrl = TextEditingController();
        final maxCtrl = TextEditingController();

        String selectedType = 'Giảm %';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Tạo chương trình mới'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã khuyến mãi'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Loại khuyến mãi'),
                  items: const [
                    DropdownMenuItem(value: 'Giảm %', child: Text('Giảm %')),
                    DropdownMenuItem(value: 'Miễn phí vận chuyển', child: Text('Miễn phí vận chuyển')),
                    DropdownMenuItem(value: 'Chiến dịch', child: Text('Chiến dịch đặc biệt')),
                  ],
                  onChanged: (val) => selectedType = val ?? 'Giảm %',
                ),
                TextField(
                  controller: valueCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giá trị giảm (%)'),
                ),
                TextField(
                  controller: maxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Giảm tối đa (VND)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Tạo'),
              onPressed: () {
                setState(() {
                  _promos.add({
                    'code': codeCtrl.text.isNotEmpty ? codeCtrl.text : 'NEW${_promos.length + 1}',
                    'type': selectedType,
                    'value': int.tryParse(valueCtrl.text) ?? 5,
                    'maxDiscount': int.tryParse(maxCtrl.text) ?? 10000,
                    'active': true,
                    'used': 0,
                  });
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _deletePromo(int idx) {
    setState(() => _promos.removeAt(idx));
  }

  void _showDetail(Map<String, dynamic> promo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chi tiết chương trình",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Mã: ${promo['code']}"),
            Text("Loại: ${promo['type']}"),
            if (promo['type'] != 'Miễn phí vận chuyển')
              Text("Giá trị giảm: ${promo['value']}%"),
            if (promo['maxDiscount'] > 0)
              Text("Giảm tối đa: ₫${promo['maxDiscount']}"),
            const SizedBox(height: 10),
            Text("Đã sử dụng: ${promo['used']} lượt"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.insights),
              label: const Text('Xem báo cáo hiệu quả'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Chương trình khuyến mãi',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: BackButton(color: Colors.black),
        actions: [
          IconButton(
              onPressed: _createPromo,
              icon: const Icon(Icons.add, color: primaryColor)),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _promos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, idx) {
          final promo = _promos[idx];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_offer_outlined, color: primaryColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${promo['code']} • ${promo['type']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    Switch(
                        value: promo['active'],
                        onChanged: (_) => _toggleActive(idx),
                        activeColor: primaryColor),
                    IconButton(
                        onPressed: () => _deletePromo(idx),
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (promo['type'] != 'Miễn phí vận chuyển')
                      Text("Giảm ${promo['value']}% (tối đa ₫${promo['maxDiscount']})",
                          style: const TextStyle(fontSize: 13)),
                    Text("Đã dùng: ${promo['used']}",
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    TextButton(
                      onPressed: () => _showDetail(promo),
                      child: const Text('Chi tiết'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

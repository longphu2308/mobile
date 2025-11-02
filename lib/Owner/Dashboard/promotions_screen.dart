// lib/staff/screens/promotions_screen.dart
import 'package:flutter/material.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final List<Map<String, dynamic>> _promos = [
    {'code': 'WELCOME10', 'type': 'Percent', 'value': 10, 'active': true},
    {'code': 'FREESHIP', 'type': 'Shipping', 'value': 0, 'active': true},
  ];

  void _toggleActive(int idx) => setState(() => _promos[idx]['active'] = !_promos[idx]['active']);

  void _createPromo() {
    setState(() {
      _promos.add({'code': 'NEW${_promos.length+1}', 'type': 'Percent', 'value': 5, 'active': true});
    });
  }

  void _deletePromo(int idx) {
    setState(() => _promos.removeAt(idx));
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Promotions', style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
        actions: [IconButton(onPressed: _createPromo, icon: const Icon(Icons.add, color: primaryColor))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: _promos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, idx) {
            final p = _promos[idx];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0,2))]),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined, color: primaryColor),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${p['code']} • ${p['type']} ${p['value']}${p['type']=='Percent' ? '%' : ''}')),
                  Switch(value: p['active'], onChanged: (_) => _toggleActive(idx), activeColor: primaryColor),
                  IconButton(onPressed: () => _deletePromo(idx), icon: const Icon(Icons.delete, color: Colors.redAccent)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

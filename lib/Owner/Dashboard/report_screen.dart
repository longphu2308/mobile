// lib/staff/screens/report_screen.dart
import 'package:flutter/material.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFFF6B1D);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Reports', style: TextStyle(color: Colors.black)),
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Total Revenue', style: TextStyle(color: Colors.black54)),
              SizedBox(height: 8),
              Text('₫ 120,000,000', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Orders by day', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  // Placeholder for chart
                  Expanded(child: Center(child: Text('Chart placeholder', style: TextStyle(color: Colors.black45)))),
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}

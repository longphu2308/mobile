import 'package:flutter/material.dart';
import 'package:mobile/User/utils/utils.dart';

class EarningsPage extends StatelessWidget {
  static const routeName = '/shipper/earnings';
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // mock data
    final total = 1250000;
    final items = [
      {'date': '2025-11-07', 'amount': 150000},
      {'date': '2025-11-08', 'amount': 230000},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          const Text(
                            'Tổng doanh thu',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$total VND',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: const [
                          Text(
                            'Số đơn',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '24',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Doanh thu (7 ngày)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // simple bar chart mock
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Colors.orange,
                        child: SizedBox(height: 20),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Colors.orange,
                        child: SizedBox(height: 40),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Colors.orange,
                        child: SizedBox(height: 60),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Colors.orange,
                        child: SizedBox(height: 80),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ColoredBox(
                        color: Colors.orange,
                        child: SizedBox(height: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lịch sử giao dịch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(items[i]['date'].toString()),
                  trailing: Text('${items[i]['amount']} VND'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

void main() {
  runApp(const TradeTookApp());
}

class TradeTookApp extends StatelessWidget {
  const TradeTookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TradeTook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TradeTookScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TradeTookScreen extends StatelessWidget {
  const TradeTookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TradeTook for Shoonya'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Symbol + Price
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Flexible(
                      child: Text(
                        'NIFTY12JUN2525500CE [44888]',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '₹24.9',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            /// Order Details
            _buildSectionCard(
              title: 'Order Details',
              child: const Text(
                '[Buy Order Details]\n[SL Order Details]\n[Target Order Details]',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

            /// Exchange & Type Chips
            _buildSectionCard(
              title: 'Exchange & Type',
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildChip('MCX'),
                  _buildChip('NFO', selected: true),
                  _buildChip('NSE'),
                  _buildChip('MKT', selected: true),
                  _buildChip('CUSTOM'),
                ],
              ),
            ),

            /// Toggle Buttons
            _buildSectionCard(
              title: 'Execution Mode',
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fixed', label: Text('Fixed High')),
                  ButtonSegment(value: 'market', label: Text('Market Aligned')),
                ],
                selected: const {'market'},
                onSelectionChanged: (_) {},
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.grey.shade100),
                ),
              ),
            ),

            /// Input Fields
            _buildSectionCard(
              title: 'Set Parameters',
              child: Row(
                children: [
                  _buildInputField('0.0'),
                  const SizedBox(width: 10),
                  _buildInputField('-0.0'),
                  const SizedBox(width: 10),
                  _buildInputField('1867.50', prefixText: '₹'),
                ],
              ),
            ),

            /// Action Buttons
            _buildSectionCard(
              title: 'Trade Actions',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildActionButton('SLNEW', Colors.green),
                  _buildActionButton('SLC2C', Colors.black),
                  _buildActionButton('-M10P', Colors.orange),
                  _buildActionButton('-M50P', Colors.black),
                  _buildActionButton('SL.10+', Colors.green),
                  _buildActionButton('SL.50+', Colors.green),
                  _buildActionButton('SL₹1+', Colors.green),
                  _buildActionButton('SL₹2+', Colors.green),
                  _buildActionButton('SL.10-', Colors.red),
                  _buildActionButton('SL.50-', Colors.red),
                ],
              ),
            ),

            /// Exit and Add Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.close),
                      label: const Text('Exit Trade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton.small(
                    onPressed: () {},
                    backgroundColor: Colors.blueGrey,
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            /// Disclaimer
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                '**Petuk Ji Pvt. Ltd. Disclaimer: We suggest trading with minimum quantity and price points for educational practical purposes only. The information provided is for educational use. Trading involves substantial risk. Please trade responsibly.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, {bool selected = false}) {
    return Chip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black)),
      backgroundColor: selected ? Colors.blueGrey : Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _buildInputField(String hint, {String? prefixText}) {
    return Expanded(
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefixText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

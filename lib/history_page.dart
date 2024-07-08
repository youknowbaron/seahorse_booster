import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.history});

  final List<String> history;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử giao đấu'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemBuilder: (context, index) => ListTile(
            title: Text(history[index]),
          ),
          itemCount: history.length,
        ),
      ),
    );
  }
}

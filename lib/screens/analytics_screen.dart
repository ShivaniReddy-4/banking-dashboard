import '../models/txn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bank_provider.dart';
import '../utils/format.dart';
import '../widgets/charts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    final theme = Theme.of(context);
    final entries = bank.spendByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<double>(0, (s, e) => s + e.value);
    final savings = bank.monthIncome - bank.monthExpense;

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Analytics')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('This month by category', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 210,
                        height: 210,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CustomPaint(
                                painter: DonutPainter(
                                  values: entries.map((e) => e.value).toList(),
                                  colors: entries.map((e) => e.key.color).toList(),
                                  emptyColor: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total spent', style: TextStyle(fontSize: 12)),
                                Text(money(total),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (entries.isEmpty) const Text('No spending recorded this month.'),
                      ...entries.map((e) {
                        final pct = total == 0 ? 0 : e.value / total * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(e.key.label)),
                              Text(money(e.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                              SizedBox(
                                width: 56,
                                child: Text('${pct.toStringAsFixed(0)}%', textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _InfoCard(label: 'Income', value: money(bank.monthIncome))),
                  const SizedBox(width: 12),
                  Expanded(child: _InfoCard(label: 'Expenses', value: money(bank.monthExpense))),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(savings >= 0 ? Icons.savings : Icons.warning_amber,
                      color: savings >= 0 ? Colors.green : Colors.orange),
                  title: Text(savings >= 0 ? 'Saved this month' : 'Overspent this month'),
                  trailing: Text(money(savings.abs()), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              if (entries.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(entries.first.key.icon, color: entries.first.key.color),
                    title: const Text('Biggest spending category'),
                    subtitle: Text(entries.first.key.label),
                    trailing: Text(money(entries.first.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

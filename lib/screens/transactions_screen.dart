import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/txn.dart';
import '../providers/bank_provider.dart';
import '../utils/format.dart';
import '../widgets/txn_tile.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _filter = 0; // 0 All, 1 Income, 2 Expense
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();

    final list = bank.txns.where((t) {
      final okType = _filter == 0 || (_filter == 1 && t.income) || (_filter == 2 && !t.income);
      final q = _query.toLowerCase();
      final okQuery = q.isEmpty || t.title.toLowerCase().contains(q) || t.category.label.toLowerCase().contains(q);
      return okType && okQuery;
    }).toList();

    // headers + items
    final items = <Object>[];
    String? last;
    for (final t in list) {
      final label = dayLabel(t.date);
      if (label != last) {
        items.add(label);
        last = label;
      }
      items.add(t);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search by name or category',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  children: [
                    for (final (i, label) in ['All', 'Income', 'Expense'].indexed)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == i,
                          onSelected: (_) => setState(() => _filter = i),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No transactions found'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          if (item is String) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 14, bottom: 4),
                              child: Text(item,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                            );
                          }
                          return TxnTile(txn: item as Txn);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

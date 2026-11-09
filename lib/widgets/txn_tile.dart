import 'package:flutter/material.dart';

import '../models/txn.dart';
import '../utils/format.dart';

class TxnTile extends StatelessWidget {
  final Txn txn;
  const TxnTile({super.key, required this.txn});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () => showTxnDetails(context, txn),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: CircleAvatar(
        backgroundColor: txn.category.color.withAlpha(45),
        child: Icon(txn.category.icon, color: txn.category.color, size: 22),
      ),
      title: Text(txn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${txn.category.label} \u2022 ${dayLabel(txn.date)}'),
      trailing: Text(
        '${txn.income ? '+' : '-'}${money(txn.amount)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: txn.income ? Colors.green.shade600 : null,
        ),
      ),
    );
  }
}

void showTxnDetails(BuildContext context, Txn t) {
  Widget row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: Colors.grey)),
            Flexible(child: Text(v, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: t.category.color.withAlpha(45),
              child: Icon(t.category.icon, color: t.category.color, size: 28),
            ),
            const SizedBox(height: 12),
            Text('${t.income ? '+' : '-'}${money(t.amount)}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(t.title),
            const SizedBox(height: 16),
            row('Type', t.income ? 'Credit' : 'Debit'),
            row('Category', t.category.label),
            row('Date', fmtDate(t.date)),
            row('Time', TimeOfDay.fromDateTime(t.date).format(context)),
            if (t.note.isNotEmpty) row('Note', t.note),
            row('Status', 'Completed'),
          ],
        ),
      ),
    ),
  );
}

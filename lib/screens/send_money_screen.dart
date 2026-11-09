import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/payee.dart';
import '../models/txn.dart';
import '../providers/bank_provider.dart';
import '../utils/format.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  Payee? _payee;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final bank = context.read<BankProvider>();
    final amt = double.tryParse(_amount.text.replaceAll(',', '').trim());

    String? err;
    if (_payee == null) {
      err = 'Please choose who to send money to';
    } else if (amt == null || amt <= 0) {
      err = 'Enter a valid amount';
    } else if (amt > bank.balance) {
      err = 'Insufficient balance';
    }
    setState(() => _error = err);
    if (err != null) return;

    final payee = _payee!;
    final value = amt!;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm transfer'),
        content: Text('Send ${money(value)} to ${payee.name} (${payee.bank})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Send')),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    bank.addTxn(
      title: 'Sent to ${payee.name}',
      category: Category.transfer,
      amount: value,
      income: false,
      note: _note.text.trim(),
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Transfer successful'),
        content: Text('${money(value)} sent to ${payee.name}.', textAlign: TextAlign.center),
        actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Send to', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              SizedBox(
                height: 104,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: payees.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    final p = payees[i];
                    final selected = _payee == p;
                    return InkWell(
                      onTap: () => setState(() => _payee = p),
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 78,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: selected ? cs.primary : Colors.transparent, width: 3),
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: selected ? cs.primary : cs.secondaryContainer,
                                child: Text(
                                  p.initials,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: selected ? cs.onPrimary : cs.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(p.name.split(' ').first, style: const TextStyle(fontSize: 12), maxLines: 1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_payee != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${_payee!.name} \u2022 ${_payee!.bank}', style: theme.textTheme.bodySmall),
                ),
              const SizedBox(height: 20),
              TextField(
                controller: _amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: '\u20B9 ',
                  labelText: 'Amount',
                  helperText: 'Available balance: ${money(bank.balance)}',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [500, 1000, 2000, 5000]
                    .map((v) => ActionChip(
                          label: Text('\u20B9$v'),
                          onPressed: () => setState(() => _amount.text = v.toString()),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: cs.error, fontWeight: FontWeight.w600)),
                ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Money'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

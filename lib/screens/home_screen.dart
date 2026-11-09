import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/txn.dart';
import '../providers/bank_provider.dart';
import '../utils/format.dart';
import '../widgets/charts.dart';
import '../widgets/txn_tile.dart';
import 'send_money_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onSeeAll;
  const HomeScreen({super.key, required this.onSeeAll});

  Future<void> _topUp(BuildContext context) async {
    final bank = context.read<BankProvider>();
    final c = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add money'),
          content: TextField(
            controller: c,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(prefixText: '\u20B9 ', labelText: 'Amount', errorText: error),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(c.text.trim());
                if (v == null || v <= 0) {
                  setS(() => error = 'Enter a valid amount');
                  return;
                }
                bank.addTxn(title: 'Wallet top-up', category: Category.transfer, amount: v, income: true);
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payBill(BuildContext context) async {
    final bank = context.read<BankProvider>();
    const bills = ['Electricity', 'Water', 'Mobile Recharge', 'Broadband', 'DTH'];
    String bill = bills.first;
    final c = TextEditingController();
    String? error;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Pay bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: bill,
                items: bills.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (v) => setS(() => bill = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(prefixText: '\u20B9 ', labelText: 'Amount', errorText: error),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                final v = double.tryParse(c.text.trim());
                if (v == null || v <= 0) {
                  setS(() => error = 'Enter a valid amount');
                  return;
                }
                if (v > bank.balance) {
                  setS(() => error = 'Insufficient balance');
                  return;
                }
                bank.addTxn(title: '$bill bill', category: Category.bills, amount: v, income: false);
                Navigator.pop(ctx);
              },
              child: const Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bank = context.watch<BankProvider>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final labels = List.generate(7, (i) => weekdayShort[now.subtract(Duration(days: 6 - i)).weekday - 1]);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.account_balance),
            SizedBox(width: 8),
            Text('NovaBank', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') bank.reset();
            },
            itemBuilder: (_) => const [PopupMenuItem(value: 'reset', child: Text('Reset demo data'))],
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text('Welcome back,', style: theme.textTheme.bodyMedium),
              Text('Shivani', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // ---- balance card ----
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)],
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Available Balance', style: TextStyle(color: Colors.white70)),
                        const Spacer(),
                        IconButton(
                          tooltip: bank.hideBalance ? 'Show balance' : 'Hide balance',
                          onPressed: bank.toggleHide,
                          icon: Icon(bank.hideBalance ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                        ),
                      ],
                    ),
                    Text(
                      bank.hideBalance ? '\u20B9 \u2022\u2022\u2022\u2022\u2022\u2022' : money(bank.balance),
                      style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      '\u2022\u2022\u2022\u2022   \u2022\u2022\u2022\u2022   \u2022\u2022\u2022\u2022   4821',
                      style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(child: Text('SHIVANI', style: TextStyle(color: Colors.white70, fontSize: 12))),
                        Text('VALID THRU 08/29', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- quick actions ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickAction(
                    icon: Icons.send,
                    label: 'Send',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendMoneyScreen())),
                  ),
                  _QuickAction(icon: Icons.add_card, label: 'Add money', onTap: () => _topUp(context)),
                  _QuickAction(icon: Icons.receipt_long, label: 'Pay bills', onTap: () => _payBill(context)),
                ],
              ),
              const SizedBox(height: 20),

              // ---- month summary ----
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Income (this month)',
                      value: money(bank.monthIncome),
                      icon: Icons.arrow_downward,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Spent (this month)',
                      value: money(bank.monthExpense),
                      icon: Icons.arrow_upward,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ---- weekly chart ----
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Last 7 days spending', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: WeekBarsPainter(
                            values: bank.last7Days,
                            labels: labels,
                            barColor: cs.primary.withAlpha(120),
                            todayColor: cs.primary,
                            textColor: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ---- recent transactions ----
              Row(
                children: [
                  Text('Recent transactions', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  TextButton(onPressed: onSeeAll, child: const Text('See all')),
                ],
              ),
              ...bank.txns.take(5).map((t) => TxnTile(txn: t)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primaryContainer,
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: color.withAlpha(40), child: Icon(icon, size: 14, color: color)),
                const SizedBox(width: 8),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 11), maxLines: 2)),
              ],
            ),
            const SizedBox(height: 8),
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

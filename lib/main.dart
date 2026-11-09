import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/bank_provider.dart';
import 'screens/analytics_screen.dart';
import 'screens/home_screen.dart';
import 'screens/transactions_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BankProvider(),
      child: const NovaBankApp(),
    ),
  );
}

class NovaBankApp extends StatelessWidget {
  const NovaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaBank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF3949AB), useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF3949AB),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final loaded = context.select<BankProvider, bool>((b) => b.loaded);
    if (!loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSeeAll: () => setState(() => _index = 1)),
          const TransactionsScreen(),
          const AnalyticsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), selectedIcon: Icon(Icons.pie_chart), label: 'Analytics'),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class HomeTab extends StatefulWidget {
  final String userName;
  final String userId;
  const HomeTab({super.key, required this.userName, required this.userId});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  double _balance = 0;
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<dynamic> _recentTransactions = [];

  static const Map<String, IconData> _catIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_bus,
    'Medicine': Icons.medical_services,
    'Groceries': Icons.shopping_cart,
    'Rent': Icons.home,
    'Gifts': Icons.card_giftcard,
    'Savings': Icons.savings,
    'Entertainment': Icons.movie,
    'More': Icons.add_circle_outline,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final r = await ApiService.getTransactions(widget.userId);
      if (r['success'] == true) {
        setState(() {
          _totalIncome = (r['totalIncome'] as num).toDouble();
          _totalExpense = (r['totalExpense'] as num).toDouble();
          _balance = (r['balance'] as num).toDouble();
          final all = r['transactions'] as List;
          _recentTransactions = all.take(5).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F2D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09C),
        automaticallyImplyLeading: false,
        title: const Text(
          'Splitwise',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF00D09C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Banner ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D09C), Color(0xFF00B386)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.userName}! 👋',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome to Splitwise',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Balance Row ──
              Row(
                children: [
                  _balanceCard(
                    'Balance',
                    '\$${_balance.toStringAsFixed(2)}',
                    const Color(0xFF00D09C),
                  ),
                  const SizedBox(width: 12),
                  _balanceCard(
                    'Income',
                    '\$${_totalIncome.toStringAsFixed(2)}',
                    const Color(0xFF4A90D9),
                  ),
                  const SizedBox(width: 12),
                  _balanceCard(
                    'Expense',
                    '\$${_totalExpense.toStringAsFixed(2)}',
                    Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Quick Actions ──
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _actionCard(
                    Icons.group_add,
                    'Create\nGroup',
                    const Color(0xFF00D09C),
                    () {},
                  ),
                  const SizedBox(width: 14),
                  _actionCard(
                    Icons.receipt_long,
                    'Add\nExpense',
                    const Color(0xFF00B386),
                    () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddTransactionScreen(userId: widget.userId),
                        ),
                      );
                      _loadData();
                    },
                  ),
                  const SizedBox(width: 14),
                  _actionCard(
                    Icons.payment,
                    'Settle\nUp',
                    const Color(0xFF009E73),
                    () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Recent Activity ──
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              if (_recentTransactions.isEmpty)
                _emptyTile()
              else
                ..._recentTransactions.map((t) {
                  final cat = t['category'] ?? 'More';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _activityTile(
                      icon: _catIcons[cat] ?? Icons.receipt,
                      title: t['title'] ?? cat,
                      subtitle: cat,
                      amount: t['type'] == 'income'
                          ? '+\$${(t['amount'] as num).toStringAsFixed(2)}'
                          : '-\$${(t['amount'] as num).toStringAsFixed(2)}',
                      isIncome: t['type'] == 'income',
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionScreen(userId: widget.userId),
            ),
          );
          _loadData();
        },
        backgroundColor: const Color(0xFF00D09C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Expense',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _balanceCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyTile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00D09C).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart, color: Color(0xFF00D09C)),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No expenses yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add your first expense to get started!',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF00D09C).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF00D09C), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? const Color(0xFF00D09C) : Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

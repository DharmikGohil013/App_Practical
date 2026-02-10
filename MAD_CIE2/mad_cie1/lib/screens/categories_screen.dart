import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'add_transaction_screen.dart';

class CategoriesScreen extends StatefulWidget {
  final String userId;
  const CategoriesScreen({super.key, required this.userId});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  double _totalIncome = 0;
  double _totalExpense = 0;
  double _balance = 0;
  final Map<String, double> _categoryExpenses = {};
  bool _isLoading = true;

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Color(0xFF4A90D9)},
    {
      'name': 'Transport',
      'icon': Icons.directions_bus,
      'color': Color(0xFF5B7FFF),
    },
    {
      'name': 'Medicine',
      'icon': Icons.medical_services,
      'color': Color(0xFF00BCD4),
    },
    {
      'name': 'Groceries',
      'icon': Icons.shopping_cart,
      'color': Color(0xFF00D09C),
    },
    {'name': 'Rent', 'icon': Icons.home, 'color': Color(0xFFFF7043)},
    {'name': 'Gifts', 'icon': Icons.card_giftcard, 'color': Color(0xFFAB47BC)},
    {'name': 'Savings', 'icon': Icons.savings, 'color': Color(0xFFFFCA28)},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Color(0xFFEF5350)},
    {
      'name': 'More',
      'icon': Icons.add_circle_outline,
      'color': Color(0xFF78909C),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final result = await ApiService.getTransactions(widget.userId);
      if (result['success'] == true) {
        final transactions = result['transactions'] as List;
        double income = 0, expense = 0;
        final Map<String, double> catExp = {};

        for (final t in transactions) {
          final amount = (t['amount'] as num).toDouble();
          if (t['type'] == 'income') {
            income += amount;
          } else {
            expense += amount;
            final cat = t['category'] as String;
            catExp[cat] = (catExp[cat] ?? 0) + amount;
          }
        }

        setState(() {
          _totalIncome = income;
          _totalExpense = expense;
          _balance = income - expense;
          _categoryExpenses.clear();
          _categoryExpenses.addAll(catExp);
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  double get _budgetLimit => 20000;
  double get _usagePercent =>
      _budgetLimit > 0 ? (_totalExpense / _budgetLimit).clamp(0, 1) : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F2D),
      body: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF00D09C), Color(0xFF00B386)],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {},
                      ),
                      const Expanded(
                        child: Text(
                          'Categories',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00D09C),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: const Color(0xFF00D09C),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // ── Balance & Expense Cards ──
                            Row(
                              children: [
                                _summaryCard(
                                  icon: Icons.account_balance_wallet,
                                  iconColor: const Color(0xFF00D09C),
                                  label: 'Total Balance',
                                  value: '\$${_balance.toStringAsFixed(2)}',
                                  valueColor: const Color(0xFF0D1F2D),
                                ),
                                const SizedBox(width: 12),
                                _summaryCard(
                                  icon: Icons.trending_down,
                                  iconColor: Colors.redAccent,
                                  label: 'Total Expense',
                                  value:
                                      '-\$${_totalExpense.toStringAsFixed(2)}',
                                  valueColor: Colors.redAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // ── Progress Bar ──
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF00D09C),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${(_usagePercent * 100).toInt()}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '\$${_budgetLimit.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _usagePercent,
                                      minHeight: 10,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF00D09C),
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Color(0xFF00D09C),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${(_usagePercent * 100).toInt()}% Of Your Expenses, Looks Good.',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // ── Category Grid ──
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final cat = categories[index];
                                final catName = cat['name'] as String;
                                final catColor = cat['color'] as Color;
                                final spent = _categoryExpenses[catName] ?? 0;

                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddTransactionScreen(
                                          userId: widget.userId,
                                          preselectedCategory: catName,
                                        ),
                                      ),
                                    );
                                    _loadData();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: catColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: catColor.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: catColor.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: Icon(
                                            cat['icon'] as IconData,
                                            color: catColor,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          catName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        if (spent > 0) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '\$${spent.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: catColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

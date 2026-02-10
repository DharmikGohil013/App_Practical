import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final String userId;

  const TransactionsScreen({super.key, required this.userId});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isLoading = true;
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<dynamic> _transactions = [];
  bool _isHeaderExpanded = true;
  String _filterType = 'all'; // 'all', 'income', 'expense'

  final Map<String, IconData> _categoryIcons = {
    'Salary': Icons.attach_money,
    'Groceries': Icons.shopping_bag,
    'Rent': Icons.home,
    'Transport': Icons.directions_bus,
    'Food': Icons.restaurant,
    'Entertainment': Icons.movie,
    'Health': Icons.local_hospital,
    'Shopping': Icons.shopping_cart,
    'Others': Icons.more_horiz,
  };

  final Map<String, Color> _categoryColors = {
    'Salary': Colors.blue,
    'Groceries': Colors.blue,
    'Rent': Colors.blue,
    'Transport': Colors.blue,
    'Food': Colors.orange,
    'Entertainment': Colors.purple,
    'Health': Colors.red,
    'Shopping': Colors.pink,
    'Others': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getTransactions(widget.userId);
      if (mounted) {
        setState(() {
          _transactions = data['transactions'] ?? [];
          _totalIncome = (data['totalIncome'] ?? 0).toDouble();
          _totalExpense = (data['totalExpense'] ?? 0).toDouble();
          _totalBalance = _totalIncome - _totalExpense;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  List<dynamic> get _filteredTransactions {
    if (_filterType == 'all') {
      return _transactions;
    } else if (_filterType == 'income') {
      return _transactions.where((t) => t['type'] == 'income').toList();
    } else {
      return _transactions.where((t) => t['type'] == 'expense').toList();
    }
  }

  double get _filteredTotal {
    if (_filterType == 'income') {
      return _totalIncome;
    } else if (_filterType == 'expense') {
      return _totalExpense;
    }
    return _totalBalance;
  }

  Map<String, List<dynamic>> _groupTransactionsByMonth() {
    final Map<String, List<dynamic>> grouped = {};
    for (var transaction in _filteredTransactions) {
      final date = DateTime.parse(transaction['date']);
      final monthYear = DateFormat('MMMM').format(date);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(transaction);
    }
    return grouped;
  }

  double get _budgetLimit => 20000;
  double get _expensePercentage =>
      _budgetLimit > 0 ? (_totalExpense / _budgetLimit) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09C),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {},
                  ),
                  const Text(
                    'Transaction',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Expandable Header Cards Section
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Total Balance Card
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _filterType = 'all';
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: _filterType == 'all'
                            ? Border.all(
                                color: const Color(0xFF00D09C),
                                width: 2,
                              )
                            : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _filterType == 'all'
                                ? 'Total Balance'
                                : _filterType == 'income'
                                ? 'Total Income'
                                : 'Total Expense',
                            style: const TextStyle(
                              color: Color(0xFF0D1F2D),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_filteredTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: _filterType == 'expense'
                                  ? Colors.red
                                  : (_filterType == 'income'
                                        ? const Color(0xFF00D09C)
                                        : (_filteredTotal < 0
                                              ? Colors.red
                                              : const Color(0xFF00D09C))),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_isHeaderExpanded) ...[
                    const SizedBox(height: 12),
                    // Income and Expense Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _filterType = _filterType == 'income'
                                    ? 'all'
                                    : 'income';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: _filterType == 'income'
                                    ? Border.all(
                                        color: const Color(0xFF00D09C),
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Income',
                                    style: TextStyle(
                                      color: Color(0xFF0D1F2D),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${_totalIncome.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _filterType = _filterType == 'expense'
                                    ? 'all'
                                    : 'expense';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: _filterType == 'expense'
                                    ? Border.all(
                                        color: const Color(0xFF00D09C),
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Expense',
                                    style: TextStyle(
                                      color: Color(0xFF0D1F2D),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${_totalExpense.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Budget Progress Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_expensePercentage.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Total Expense',
                                    style: TextStyle(
                                      color: Color(0xFF0D1F2D),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.attach_money,
                                    color: Color(0xFF0D1F2D),
                                    size: 16,
                                  ),
                                  Text(
                                    'Total Budget',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${_totalExpense.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF0D1F2D),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${_budgetLimit.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _expensePercentage / 100,
                              backgroundColor: Colors.grey[300],
                              color: Colors.red,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(100 - _expensePercentage).toStringAsFixed(0)}% Of Your Expenses, Looks Good.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  // Toggle Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isHeaderExpanded = !_isHeaderExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Icon(
                        _isHeaderExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Transaction List
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5F1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _filterType == 'income'
                                  ? 'No income transactions'
                                  : _filterType == 'expense'
                                  ? 'No expense transactions'
                                  : 'No transactions yet',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [..._buildTransactionList()],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionList() {
    final grouped = _groupTransactionsByMonth();
    final List<Widget> widgets = [];

    grouped.forEach((month, transactions) {
      // Month Header
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Text(
                month,
                style: const TextStyle(
                  color: Color(0xFF0D1F2D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09C),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      );

      // Transactions for this month
      for (var transaction in transactions) {
        widgets.add(_buildTransactionItem(transaction));
      }
    });

    return widgets;
  }

  Widget _buildTransactionItem(dynamic transaction) {
    final category = transaction['category'] ?? 'Others';
    final title = transaction['title'] ?? 'Transaction';
    final amount = (transaction['amount'] ?? 0).toDouble();
    final type = transaction['type'] ?? 'expense';
    final date = DateTime.parse(transaction['date']);
    final note = transaction['note'] ?? '';

    final isExpense = type == 'expense';
    final amountColor = isExpense ? Colors.red : Colors.green;
    final amountPrefix = isExpense ? '-' : '+';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_categoryColors[category] ?? Colors.grey).withOpacity(
                0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _categoryIcons[category] ?? Icons.help_outline,
              color: _categoryColors[category] ?? Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0D1F2D),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('HH:mm').format(date)} - ${DateFormat('MMMM dd').format(date)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          // Amount and Category
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix\$${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note.isNotEmpty ? note : category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

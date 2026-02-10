import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String userId;
  final String preselectedCategory;

  const AddTransactionScreen({
    super.key,
    required this.userId,
    this.preselectedCategory = 'Food',
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  late String _selectedCategory;
  String _type = 'expense';
  bool _isLoading = false;

  static const List<String> categoryNames = [
    'Food',
    'Transport',
    'Medicine',
    'Groceries',
    'Rent',
    'Gifts',
    'Savings',
    'Entertainment',
    'More',
  ];

  static const Map<String, IconData> categoryIcons = {
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
    _selectedCategory = widget.preselectedCategory;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      _showSnackBar('Please fill in title and amount');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('Enter a valid amount');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.addTransaction(
        userId: widget.userId,
        category: _selectedCategory,
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        note: _noteController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSnackBar('Transaction added!');
        Navigator.pop(context, true);
      } else {
        _showSnackBar(result['message'] ?? 'Failed');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Connection error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF00D09C)),
    );
  }

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Add Transaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // ── Form ──
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Type Toggle ──
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5F1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _typeButton(
                            'expense',
                            'Expense',
                            Icons.trending_down,
                          ),
                          const SizedBox(width: 4),
                          _typeButton('income', 'Income', Icons.trending_up),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Category Selector ──
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 46,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryNames.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final name = categoryNames[i];
                          final isSelected = _selectedCategory == name;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF00D09C)
                                    : const Color(0xFFE8F5F1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    categoryIcons[name],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF00D09C),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 22),

                    // ── Title ──
                    _label('Title'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _titleController,
                      hint: 'e.g. Grocery shopping',
                      icon: Icons.title,
                    ),
                    const SizedBox(height: 18),

                    // ── Amount ──
                    _label('Amount'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _amountController,
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    // ── Note ──
                    _label('Note (optional)'),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _noteController,
                      hint: 'Add a note...',
                      icon: Icons.note_alt_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // ── Submit ──
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _isLoading ? 'Saving...' : 'Add Transaction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeButton(String type, String label, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00D09C) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: const Color(0xFF00D09C), size: 20),
        filled: true,
        fillColor: const Color(0xFFE8F5F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

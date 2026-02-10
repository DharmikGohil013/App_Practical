import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userId;

  const MainNavScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userId,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTab(userName: widget.userName),
      const _PlaceholderTab(
        icon: Icons.insert_chart_outlined,
        label: 'Analytics',
      ),
      const _PlaceholderTab(icon: Icons.compare_arrows, label: 'Transfers'),
      const _PlaceholderTab(icon: Icons.layers_outlined, label: 'Groups'),
      ProfileScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        userId: widget.userId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D1F2D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _navItem(
                  Icons.insert_chart_outlined,
                  Icons.insert_chart,
                  'Analytics',
                  1,
                ),
                _navItem(
                  Icons.compare_arrows,
                  Icons.compare_arrows,
                  'Transfers',
                  2,
                ),
                _navItem(Icons.layers_outlined, Icons.layers, 'Groups', 3),
                _navItem(Icons.person_outline, Icons.person, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00D09C).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? const Color(0xFF00D09C) : Colors.grey.shade500,
          size: 28,
        ),
      ),
    );
  }
}

// Placeholder for tabs not yet built
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F2D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: const Color(0xFF00D09C).withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

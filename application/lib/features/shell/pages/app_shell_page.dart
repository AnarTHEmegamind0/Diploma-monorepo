import 'package:core/core/app_theme.dart';
import 'package:core/features/audit/pages/customer_page.dart';
import 'package:core/features/history/pages/history_page.dart';
import 'package:core/features/home/pages/home_page.dart';
import 'package:core/features/profile/pages/profile_page.dart';
import 'package:core/features/shell/service/navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key});

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  final Map<int, Widget> _pageCache = <int, Widget>{0: const HomePage()};

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const CustomerPage();
      case 2:
        return const HistoryPage();
      case 3:
        return const ProfilePage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.select(
      (NavigationController controller) => controller.index,
    );
    _pageCache.putIfAbsent(selectedIndex, () => _buildPage(selectedIndex));

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: List<Widget>.generate(
          4,
          (index) => _pageCache[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.darkNavy, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: context.read<NavigationController>().setIndex,
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.orange,
          unselectedItemColor: AppColors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Нүүр',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Аудит',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history),
              label: 'Түүх',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Профайл',
            ),
          ],
        ),
      ),
    );
  }
}

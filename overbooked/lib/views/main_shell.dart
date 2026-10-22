import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/bookshelf_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import 'bookshelf/bookshelf_view.dart';
import 'discover/discover_view.dart';
import 'profile/profile_view.dart';
import 'stats/stats_view.dart';

/// Root scaffold with a bottom navigation bar and 4 tab views.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    BookshelfView(),
    StatsView(),
    DiscoverView(),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize providers after the first frame so context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().user!.uid;
      context.read<BookshelfProvider>().init(userId);
      context.read<StatsProvider>().init(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories_outlined),
            activeIcon: Icon(Icons.auto_stories),
            label: 'Estantes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Dados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Descoberta',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

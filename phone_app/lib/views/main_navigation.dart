import 'package:flutter/material.dart';
import 'catalog/catalog_screen.dart';
import 'watchlist/watchlist_screen.dart';
import 'tv_remote/tv_remote_screen.dart';
import 'wearable/wearable_screen.dart';
import 'profile/profile_screen.dart';

const Color kPurple = Color(0xFF8A2BE2);
const Color kNeonGreen = Color(0xFF39FF14);
const Color kDarkBg = Color(0xFF141414);
const Color kCardBg = Color(0xFF1E1E1E);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CatalogScreen(),
    WatchlistScreen(),
    TvRemoteScreen(),
    WearableScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDarkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kCardBg,
          border: Border(
            top: BorderSide(color: Colors.grey[850]!, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: kPurple.withValues(alpha: 0.35),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: kNeonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                );
              }
              return const TextStyle(color: Colors.grey, fontSize: 11);
            }),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: kCardBg,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.explore_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.explore, color: kNeonGreen),
                label: 'Catálogo',
              ),
              NavigationDestination(
                icon: Icon(Icons.bookmarks_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.bookmarks, color: kNeonGreen),
                label: 'Mi Lista',
              ),
              NavigationDestination(
                icon: Icon(Icons.tv_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.tv, color: kNeonGreen),
                label: 'Control TV',
              ),
              NavigationDestination(
                icon: Icon(Icons.watch_outlined, color: Colors.grey),
                selectedIcon: Icon(Icons.watch, color: kNeonGreen),
                label: 'Wearable',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline, color: Colors.grey),
                selectedIcon: Icon(Icons.person, color: kNeonGreen),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

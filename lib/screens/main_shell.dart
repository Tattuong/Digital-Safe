import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../providers/shop_provider.dart';
import 'documents/add_document_screen.dart';
import 'documents/documents_list_screen.dart';
import 'home/home_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openAddDocument() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDocumentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shop = context.watch<ShopProvider>();
    final preset = shop.activeTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? preset.darkBackground : preset.background,
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          RecentScreen(),
          FavoritesScreen(),
          SettingsScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTabChanged: (i) => setState(() => _index = i),
        onAdd: _openAddDocument,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAdd;

  const _BottomNav({
    required this.index,
    required this.onTabChanged,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkNavBar : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 10, 8, bottom > 0 ? bottom : 14),
        child: Row(
          children: [
            Expanded(child: _NavItem(label: AppStrings.t(context, 'tabHome'), active: index == 0, icon: Icons.home_rounded, onTap: () => onTabChanged(0))),
            Expanded(child: _NavItem(label: AppStrings.t(context, 'tabRecent'), active: index == 1, icon: Icons.history_rounded, onTap: () => onTabChanged(1))),
            Expanded(child: _AddNavItem(onTap: onAdd)),
            Expanded(child: _NavItem(label: AppStrings.t(context, 'tabFavorites'), active: index == 2, icon: Icons.star_rounded, onTap: () => onTabChanged(2))),
            Expanded(child: _NavItem(label: AppStrings.t(context, 'tabSettings'), active: index == 3, icon: Icons.settings_rounded, onTap: () => onTabChanged(3))),
          ],
        ),
      ),
    );
  }
}

class _AddNavItem extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.white54 : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.t(context, 'tabAdd'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.active,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeColor = AppColors.neonBlue;
    final inactiveColor = isDark ? Colors.white54 : AppColors.textMuted;
    final color = active ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

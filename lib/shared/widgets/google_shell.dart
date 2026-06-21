import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';

class GoogleShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const GoogleShell({
    super.key,
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 980;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (isDesktop)
            _SideBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            )
          else
            _CompactRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
          Expanded(
            child: Column(
              children: [
                const GoogleTopBar(),
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                    ),
                    child: ColoredBox(
                      color: AppColors.background,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SideBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _SideBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(22, 28, 18, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandMark(),
          const SizedBox(height: 42),
          const _SectionLabel('MY DESK'),
          _NavTile(
            index: 0,
            selectedIndex: selectedIndex,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: onDestinationSelected,
          ),
          _NavTile(
            index: 7,
            selectedIndex: selectedIndex,
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month_rounded,
            label: 'My schedule',
            onTap: onDestinationSelected,
          ),
          const SizedBox(height: 24),
          const _SectionLabel('MENU'),
          _NavTile(
            index: 1,
            selectedIndex: selectedIndex,
            icon: Icons.menu_book_outlined,
            selectedIcon: Icons.menu_book_rounded,
            label: 'Classroom',
            onTap: onDestinationSelected,
          ),
          _NavTile(
            index: 8,
            selectedIndex: selectedIndex,
            icon: Icons.groups_outlined,
            selectedIcon: Icons.groups_rounded,
            label: 'Independent class',
            onTap: onDestinationSelected,
          ),
          _NavTile(
            index: 3,
            selectedIndex: selectedIndex,
            icon: Icons.style_outlined,
            selectedIcon: Icons.style_rounded,
            label: 'Flashcards',
            onTap: onDestinationSelected,
          ),
          _NavTile(
            index: 4,
            selectedIndex: selectedIndex,
            icon: Icons.quiz_outlined,
            selectedIcon: Icons.quiz_rounded,
            label: 'Exams',
            onTap: onDestinationSelected,
          ),
          _NavTile(
            index: 5,
            selectedIndex: selectedIndex,
            icon: Icons.insert_chart_outlined_rounded,
            selectedIcon: Icons.insert_chart_rounded,
            label: 'Report',
            onTap: onDestinationSelected,
          ),
          _NavTile(
            index: 2,
            selectedIndex: selectedIndex,
            icon: Icons.description_outlined,
            selectedIcon: Icons.description_rounded,
            label: 'Materials',
            onTap: onDestinationSelected,
          ),
          const Spacer(),
          const _SectionLabel('SETTINGS'),
          _NavTile(
            index: 6,
            selectedIndex: selectedIndex,
            icon: Icons.tune_outlined,
            selectedIcon: Icons.tune_rounded,
            label: 'Analytics',
            onTap: onDestinationSelected,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.school_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keep learning every day',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _CompactRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.none,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: _LogoGlyph(),
      ),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: Text('Dashboard')),
        NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: Text('Subjects')),
        NavigationRailDestination(icon: Icon(Icons.description_outlined), selectedIcon: Icon(Icons.description_rounded), label: Text('Materials')),
        NavigationRailDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style_rounded), label: Text('Flashcards')),
        NavigationRailDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz_rounded), label: Text('Exams')),
        NavigationRailDestination(icon: Icon(Icons.insert_chart_outlined_rounded), selectedIcon: Icon(Icons.insert_chart_rounded), label: Text('Results')),
        NavigationRailDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: Text('Analytics')),
        NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded), label: Text('Planner')),
        NavigationRailDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: Text('Batches')),
      ],
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _LogoGlyph(),
        const SizedBox(width: 14),
        Text(
          'ReviewHub',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}

class _LogoGlyph extends StatelessWidget {
  const _LogoGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        children: [
          _LogoBlock(left: 0, top: 0, color: AppColors.primary),
          _LogoBlock(left: 17, top: 0, color: AppColors.secondary),
          _LogoBlock(left: 0, top: 17, color: AppColors.primaryDark),
          _LogoBlock(left: 17, top: 17, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  final double left;
  final double top;
  final Color color;

  const _LogoBlock({
    required this.left,
    required this.top,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavTile({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: selected ? AppColors.mutedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                color: selected ? AppColors.text : AppColors.text,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: AppColors.text,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GoogleTopBar extends StatelessWidget {
  const GoogleTopBar({super.key});

  Future<void> _handleMenuAction(BuildContext context, String value) async {
    if (value != 'logout') return;

    await AuthService.signOut();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search classes, exams, reports...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _TopPill(
            icon: Icons.calendar_today_outlined,
            label: '01 Aug',
            onTap: () {},
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryDark,
              child: Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopPill({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.border),
        backgroundColor: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

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
    final showSidebar = MediaQuery.of(context).size.width > 980;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          if (showSidebar)
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
                  child: ColoredBox(
                    color: AppColors.background,
                    child: child,
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

class _NavItem {
  final int index;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem(this.index, this.icon, this.selectedIcon, this.label);
}

const _myDeskItems = [
  _NavItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
  _NavItem(7, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Study Planner'),
];

const _learningItems = [
  _NavItem(1, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Subjects'),
  _NavItem(2, Icons.description_outlined, Icons.description_rounded, 'Materials'),
  _NavItem(3, Icons.style_outlined, Icons.style_rounded, 'Flashcards'),
  _NavItem(4, Icons.quiz_outlined, Icons.quiz_rounded, 'Exams'),
];

const _insightItems = [
  _NavItem(5, Icons.assessment_outlined, Icons.assessment_rounded, 'Results'),
  _NavItem(6, Icons.analytics_outlined, Icons.analytics_rounded, 'Analytics'),
];

const _managementItems = [
  _NavItem(8, Icons.groups_outlined, Icons.groups_rounded, 'Batches'),
];

const _allItems = [
  _NavItem(0, Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
  _NavItem(1, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Subjects'),
  _NavItem(2, Icons.description_outlined, Icons.description_rounded, 'Materials'),
  _NavItem(3, Icons.style_outlined, Icons.style_rounded, 'Flashcards'),
  _NavItem(4, Icons.quiz_outlined, Icons.quiz_rounded, 'Exams'),
  _NavItem(5, Icons.assessment_outlined, Icons.assessment_rounded, 'Results'),
  _NavItem(6, Icons.analytics_outlined, Icons.analytics_rounded, 'Analytics'),
  _NavItem(7, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Study Planner'),
  _NavItem(8, Icons.groups_outlined, Icons.groups_rounded, 'Batches'),
];

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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 20, 18),
              child: _BrandMark(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NavSection(
                      title: 'MY DESK',
                      items: _myDeskItems,
                      selectedIndex: selectedIndex,
                      onTap: onDestinationSelected,
                    ),
                    _NavSection(
                      title: 'LEARNING',
                      items: _learningItems,
                      selectedIndex: selectedIndex,
                      onTap: onDestinationSelected,
                    ),
                    _NavSection(
                      title: 'INSIGHTS',
                      items: _insightItems,
                      selectedIndex: selectedIndex,
                      onTap: onDestinationSelected,
                    ),
                    _NavSection(
                      title: 'MANAGEMENT',
                      items: _managementItems,
                      selectedIndex: selectedIndex,
                      onTap: onDestinationSelected,
                    ),
                    const SizedBox(height: 16),
                    const _SidebarNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavSection extends StatelessWidget {
  final String title;
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NavSection({
    required this.title,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
            ),
          ),
          for (final item in items)
            _NavTile(
              item: item,
              selectedIndex: selectedIndex,
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _NavTile({
    required this.item,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = item.index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap(item.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: selected ? AppColors.mutedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(selected ? item.selectedIcon : item.icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        color: AppColors.text,
                      ),
                ),
              ),
            ],
          ),
        ),
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
      destinations: [
        for (final item in _allItems)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          ),
      ],
    );
  }
}

class _SidebarNote extends StatelessWidget {
  const _SidebarNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.school_rounded, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Keep learning every day',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
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
        Expanded(
          child: Text(
            'ReviewHub',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                ),
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
        children: const [
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

class GoogleTopBar extends StatelessWidget {
  const GoogleTopBar({super.key});

  Future<void> _handleMenuAction(BuildContext context, String value) async {
    if (value != 'signout') return;

    await AuthService.signOut();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;

        return Container(
          height: 88,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          color: AppColors.background,
          child: Row(
            children: [
              if (!compact)
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
                )
              else
                const Spacer(),
              const SizedBox(width: 16),
              if (!compact)
                _TopPill(
                  icon: Icons.calendar_today_outlined,
                  label: '01 Aug',
                  onTap: () {},
                ),
              if (!compact) const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(context, value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'profile', child: Text('Profile')),
                  PopupMenuItem(value: 'signout', child: Text('Sign out')),
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
      },
    );
  }
}

class _TopPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopPill({required this.icon, required this.label, required this.onTap});

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

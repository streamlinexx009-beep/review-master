import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/profile_service.dart';

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
    final isDesktop = MediaQuery.of(context).size.width > 1000;
    final sidebarWidth = isDesktop ? 292.0 : 96.0;

    return FutureBuilder<String?>(
      future: ProfileService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data;
        final isTeacher = role == 'instructor' || role == 'admin';

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          body: Row(
            children: [
              Container(
                width: sidebarWidth,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE6EAF0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F111827),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: _Sidebar(
                  expanded: isDesktop,
                  selectedIndex: selectedIndex,
                  isTeacher: isTeacher,
                  onDestinationSelected: onDestinationSelected,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                  child: Column(
                    children: [
                      GoogleTopBar(isTeacher: isTeacher),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: ColoredBox(
                            color: const Color(0xFFF6F8FB),
                            child: child,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  final bool expanded;
  final bool isTeacher;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _Sidebar({
    required this.expanded,
    required this.isTeacher,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  void _go(BuildContext context, int index) {
    if (!isTeacher && index == 2) {
      context.go('/results');
      return;
    }
    onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: expanded ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
                  ),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white),
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ReviewHub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isTeacher ? 'Teacher workspace' : 'Student workspace',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          if (expanded) const _SidebarSectionLabel('Workspace'),
          _NavTile(
            expanded: expanded,
            selected: selectedIndex == 0,
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            onTap: () => _go(context, 0),
          ),
          _NavTile(
            expanded: expanded,
            selected: selectedIndex == 1,
            icon: Icons.menu_book_rounded,
            label: isTeacher ? 'Subjects' : 'My Classes',
            badge: 'Core',
            onTap: () => _go(context, 1),
          ),
          const SizedBox(height: 14),
          if (expanded) _SidebarSectionLabel(isTeacher ? 'Teaching' : 'Learning'),
          _NavTile(
            expanded: expanded,
            selected: selectedIndex == 2,
            icon: isTeacher ? Icons.insights_rounded : Icons.assessment_rounded,
            label: isTeacher ? 'Student Performance' : 'My Results',
            onTap: () => _go(context, 2),
          ),
          _NavTile(
            expanded: expanded,
            selected: selectedIndex == 3,
            icon: Icons.event_note_rounded,
            label: 'Study Planner',
            onTap: () => _go(context, 3),
          ),
          if (isTeacher) ...[
            const SizedBox(height: 14),
            if (expanded) const _SidebarSectionLabel('Management'),
            _NavTile(
              expanded: expanded,
              selected: selectedIndex == 4,
              icon: Icons.groups_rounded,
              label: 'Batches',
              onTap: () => _go(context, 4),
            ),
          ],
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(expanded ? 16 : 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF0F766E)),
                      const SizedBox(height: 10),
                      const Text(
                        'Tip',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTeacher
                            ? 'Teachers can create class content, AI drafts, exams, batches, and monitor student progress.'
                            : 'Students can open classes, study materials, take tests, and view their own results.',
                        style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                      ),
                    ],
                  )
                : const Icon(Icons.tips_and_updates_rounded, color: Color(0xFF0F766E)),
          ),
        ],
      ),
    );
  }
}

class _SidebarSectionLabel extends StatelessWidget {
  final String label;

  const _SidebarSectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8, top: 4),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final bool expanded;
  final bool selected;
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.expanded,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: expanded ? 14 : 0),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0F766E) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? Colors.white : const Color(0xFF475569),
            size: 22,
          ),
          if (expanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF0F172A),
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withOpacity(0.18) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF0369A1),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Tooltip(
        message: expanded ? '' : label,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}

class GoogleTopBar extends StatelessWidget {
  final bool isTeacher;

  const GoogleTopBar({super.key, required this.isTeacher});

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
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A111827),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                decoration: InputDecoration(
                  hintText: isTeacher ? 'Search classes, students, exams, reports...' : 'Search classes, materials, exams, results...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Container(
                    margin: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune_rounded, size: 18),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          _TopBarButton(icon: Icons.calendar_today_rounded, label: 'Today', onTap: () {}),
          const SizedBox(width: 10),
          _CircleIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
          const SizedBox(width: 10),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopBarButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EAF0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF0F172A)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2FE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: const Color(0xFF0369A1)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SidebarLayout
    extends StatelessWidget {

  final Widget child;

  const SidebarLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(
                  Icons.dashboard,
                ),
                label: Text(
                  'Dashboard',
                ),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.book,
                ),
                label: Text(
                  'Subjects',
                ),
              ),
            ],
            selectedIndex: 0,
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
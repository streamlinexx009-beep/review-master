import 'package:flutter/material.dart';

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
    final isDesktop =
        MediaQuery.of(context).size.width >
            1000;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isDesktop,
            selectedIndex: selectedIndex,
            onDestinationSelected:
                onDestinationSelected,

            leading: const Padding(
              padding:
                  EdgeInsets.all(16),
              child: CircleAvatar(
                radius: 24,
                child: Icon(
                  Icons.school,
                ),
              ),
            ),

            destinations: const [
              NavigationRailDestination(
                icon: Icon(
                  Icons.dashboard_outlined,
                ),
                selectedIcon:
                    Icon(Icons.dashboard),
                label: Text(
                  'Dashboard',
                ),
              ),

              NavigationRailDestination(
                icon: Icon(
                  Icons.book_outlined,
                ),
                selectedIcon:
                    Icon(Icons.book),
                label: Text(
                  'Subjects',
                ),
              ),

              NavigationRailDestination(
                icon: Icon(
                  Icons.description_outlined,
                ),
                selectedIcon:
                    Icon(Icons.description,
                ),
                label: Text(
                  'Materials',
                ),
              ),


              NavigationRailDestination(
                icon: Icon(
                  Icons.style_outlined,
                ),
                selectedIcon:
                    Icon(Icons.style),
                label: Text(
                  'Flashcards',
                ),
              ),

              NavigationRailDestination(
                icon: Icon(
                  Icons.quiz_outlined,
                ),
                selectedIcon:
                    Icon(Icons.quiz),
                label: Text(
                  'Exams',
                ),
              ),

              NavigationRailDestination(
                icon: Icon(
                  Icons.assessment_outlined,
                ),
                selectedIcon: Icon(
                  Icons.assessment,
                ),
                label: Text(
                  'Results',
                ),
              ),


              NavigationRailDestination(
                icon: Icon(
                  Icons.analytics_outlined,
                ),
                selectedIcon:
                    Icon(Icons.analytics),
                label: Text(
                  'Analytics',
                ),
              ),

              NavigationRailDestination(
                icon: Icon(
                  Icons.event_note_outlined,
                ),
                selectedIcon:
                    Icon(Icons.event_note),
                label: Text(
                  'Study Planner',
                ),
              ),

              NavigationRailDestination(
                icon: Icon(
                  Icons.groups_outlined,
                ),
                selectedIcon: Icon(
                  Icons.groups,
                ),
                label: Text(
                  'Batches',
                ),
              ),
            ],
          ),

          const VerticalDivider(
            width: 1,
          ),

          Expanded(
            child: Column(
              children: [
                const GoogleTopBar(),

                Expanded(
                  child: child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GoogleTopBar extends StatelessWidget {
  const GoogleTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      decoration: BoxDecoration(
        color:
            Theme.of(context)
                .colorScheme
                .surface,

        border: Border(
          bottom: BorderSide(
            color:
                Colors.grey.shade300,
          ),
        ),
      ),

      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: TextField(
                decoration:
                    InputDecoration(
                  hintText:
                      'Search materials, flashcards, exams...',

                  prefixIcon:
                      const Icon(
                    Icons.search,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value ==
                  'logout') {
                // TODO:
                // Connect AuthService.logout()
              }
            },
            itemBuilder:
                (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Text(
                  'Profile',
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text(
                  'Logout',
                ),
              ),
            ],
            child:
                const CircleAvatar(
              child: Icon(
                Icons.person,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GoogleTopBar extends StatelessWidget {
  const GoogleTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          SizedBox(width: 16),

          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),

          CircleAvatar(
            child: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
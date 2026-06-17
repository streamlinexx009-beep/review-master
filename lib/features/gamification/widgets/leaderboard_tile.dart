import 'package:flutter/material.dart';

class LeaderboardTile
    extends StatelessWidget {

  final String name;

  final int points;

  final int rank;

  const LeaderboardTile({
    super.key,
    required this.name,
    required this.points,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading:
          CircleAvatar(
        child:
            Text(
          rank.toString(),
        ),
      ),
      title: Text(name),
      trailing:
          Text(
        '$points pts',
      ),
    );
  }
}
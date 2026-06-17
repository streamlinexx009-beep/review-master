import 'package:flutter/material.dart';

class FavoriteButton
    extends StatelessWidget {

  final bool isFavorite;

  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isFavorite
            ? Icons.favorite
            : Icons.favorite_border,
      ),
    );
  }
}
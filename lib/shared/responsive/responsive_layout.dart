import 'package:flutter/material.dart';

import 'breakpoints.dart';

class ResponsiveLayout
    extends StatelessWidget {

  final Widget mobile;

  final Widget tablet;

  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final width =
        MediaQuery.of(
      context,
    ).size.width;

    if (width <
        Breakpoints.mobile) {
      return mobile;
    }

    if (width <
        Breakpoints.tablet) {
      return tablet;
    }

    return desktop;
  }
}
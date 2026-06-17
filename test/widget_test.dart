import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:review_master/main.dart';

void main() {
  testWidgets(
    'ReviewHub loads successfully',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ReviewHubApp(),
        ),
      );

      expect(
        find.byType(ReviewHubApp),
        findsOneWidget,
      );
    },
  );
}
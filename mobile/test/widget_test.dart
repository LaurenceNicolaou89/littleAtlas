import 'package:flutter_test/flutter_test.dart';

import 'package:little_atlas/app.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const LittleAtlasApp());
  });
}

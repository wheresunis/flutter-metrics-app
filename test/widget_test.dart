import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_diary/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('App builds without Firebase', (tester) async {
  await tester.pumpWidget(const AppRoot(enableFirebase: false));
  await tester.pumpAndSettle();
  expect(find.byType(WelcomeScreen), findsOneWidget);
});
}


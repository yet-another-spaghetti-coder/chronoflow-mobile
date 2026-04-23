import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MainDrawer Widget Tests', () {
    late bool signOutCalled;
    late Color testColor;

    setUp(() {
      signOutCalled = false;
      testColor = Colors.blue;
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: MainDrawer(
            color: testColor,
            signOut: () {
              signOutCalled = true;
            },
          ),
        ),
        routes: {
          Constants.eventScreen: (context) => const Scaffold(
            body: Center(child: Text('Event Screen')),
          ),
        },
      );
    }

    testWidgets('renders drawer with correct background color', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.backgroundColor, equals(testColor));
    });

    testWidgets('displays drawer header with logo and title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FlutterLogo), findsOneWidget);
      expect(find.text(Constants.sidebarTitle), findsOneWidget);

      final logo = tester.widget<FlutterLogo>(find.byType(FlutterLogo));
      expect(logo.size, equals(100));
    });

    testWidgets('displays HOME list tile with correct icon and text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('HOME'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('displays LOGOUT list tile with correct icon and text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('LOGOUT'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('navigates to event screen when HOME is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('HOME'));
      await tester.pumpAndSettle();

      expect(find.text('Event Screen'), findsOneWidget);
    });

    testWidgets('calls signOut callback when LOGOUT is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(signOutCalled, isFalse);

      await tester.tap(find.text('LOGOUT'));
      await tester.pump();

      expect(signOutCalled, isTrue);
    });

    testWidgets('drawer header has white background', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final drawerHeader = tester.widget<DrawerHeader>(find.byType(DrawerHeader));
      final decoration = drawerHeader.decoration! as BoxDecoration;
      expect(decoration.color, equals(Colors.white));
    });

    testWidgets('drawer has correct shape and elevation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.shape, isA<RoundedRectangleBorder>());
      expect(drawer.elevation, equals(2));
    });

    testWidgets('list tiles have hover color set to white', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      for (final listTile in listTiles) {
        expect(listTile.hoverColor, equals(Colors.white));
      }
    });

    testWidgets('finds exactly 2 list tiles', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListTile), findsNWidgets(2));
    });
  });
}

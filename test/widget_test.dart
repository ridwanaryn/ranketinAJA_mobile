import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:raketinaja/main.dart';
import 'package:raketinaja/features/court/presentation/providers/app_provider.dart';

// Mock HttpOverrides to prevent NetworkImage exceptions when loading images in widget tests.
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient implements HttpClient {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl || invocation.memberName == #openUrl) {
      return Future.value(MockHttpClientRequest());
    }
    return null;
  }
}

class MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(MockHttpClientResponse());
    }
    if (invocation.memberName == #headers) {
      return MockHttpHeaders();
    }
    return null;
  }
}

class MockHttpHeaders implements HttpHeaders {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockHttpClientResponse implements HttpClientResponse {
  static final List<int> _imageData = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==');

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #statusCode) {
      return 200;
    }
    if (invocation.memberName == #contentLength) {
      return _imageData.length;
    }
    if (invocation.memberName == #compressionState) {
      return HttpClientResponseCompressionState.notCompressed;
    }
    return null;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_imageData]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('raketinAJA Smoke and Widget Tests', () {
    testWidgets('Login page renders successfully', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that the login page title "Welcome Back" is displayed.
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Synchronize your session to continue.'), findsOneWidget);
      expect(find.text('LOGIN ROLE'), findsOneWidget);

      // Verify presence of input fields (Email and Password labels or hints)
      expect(find.text('IDENTITY (EMAIL)'), findsOneWidget);
      expect(find.text('ACCESS KEY'), findsOneWidget);

      // Verify action button
      expect(find.text('Enter raketinAJA'), findsOneWidget);
    });

    testWidgets('Role selection updates provider userRole on login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MyApp(),
        ),
      );

      // Enter valid email and password
      await tester.enterText(find.byType(TextFormField).first, 'owner@raketinaja.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap on the Owner role selection
      await tester.tap(find.text('Owner'));
      await tester.pumpAndSettle();

      // Tap Enter raketinAJA
      await tester.tap(find.text('Enter raketinAJA'));
      await tester.pumpAndSettle();

      // Check provider state after login
      final BuildContext context = tester.element(find.byType(MyApp));
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      expect(appProvider.userRole, equals('owner'));
      expect(appProvider.isAuthenticated, isTrue);
    });
  });
}

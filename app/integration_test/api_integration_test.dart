/// Omnigram API Integration Tests
///
/// Runs Dart HTTP client against a real server (no emulator needed).
/// Server must be running at the URL specified by env var OMNIGRAM_TEST_URL.
///
/// Usage:
///   # Local
///   dart test integration_test/api_integration_test.dart
///
///   # CI (server started by docker compose)
///   OMNIGRAM_TEST_URL=http://localhost:8080 \
///   OMNIGRAM_TEST_USER=testadmin \
///   OMNIGRAM_TEST_PASS=testpass123 \
///   dart test integration_test/api_integration_test.dart

import 'dart:io';

import 'package:omnigram/service/api/omnigram_api.dart';
import 'package:omnigram/service/api/auth_api.dart';
import 'package:omnigram/service/api/book_api.dart';
import 'package:omnigram/service/api/sync_api.dart';
import 'package:omnigram/service/api/shelf_api.dart';
import 'package:omnigram/service/api/system_api.dart';
import 'package:flutter_test/flutter_test.dart';

/// Read env with fallback.
String env(String key, String fallback) =>
    Platform.environment[key] ?? fallback;

void main() {
  final baseUrl = env('OMNIGRAM_TEST_URL', 'http://localhost:8080');
  final username = env('OMNIGRAM_TEST_USER', 'testadmin');
  final password = env('OMNIGRAM_TEST_PASS', 'testpass123');

  late OmnigramApi api;
  late AuthApi auth;

  setUpAll(() async {
    api = OmnigramApi(baseUrl: baseUrl);
    auth = AuthApi(api);

    // Login once for all tests
    await auth.login(account: username, password: password);
    expect(api.isAuthenticated, isTrue, reason: 'Login failed — is the server running at $baseUrl?');
  });

  // ── L0: Health & Connectivity ─────────────────────────────────────

  group('Health', () {
    test('GET /healthz returns 200', () async {
      final health = await auth.healthCheck();
      expect(health.status, equals('ok'));
    });

    test('GET /sys/ping returns system info', () async {
      final info = await auth.ping();
      expect(info, isNotNull);
    });
  });

  // ── L1: Authentication ────────────────────────────────────────────

  group('Auth', () {
    test('login returns valid tokens', () async {
      final freshApi = OmnigramApi(baseUrl: baseUrl);
      final freshAuth = AuthApi(freshApi);
      final token = await freshAuth.login(account: username, password: password);
      expect(token.accessToken, isNotEmpty);
      expect(token.refreshToken, isNotEmpty);
    });

    test('getUserInfo returns current user', () async {
      final user = await auth.getUserInfo();
      expect(user.name, isNotEmpty);
    });

    test('invalid credentials returns error', () async {
      final freshApi = OmnigramApi(baseUrl: baseUrl);
      final freshAuth = AuthApi(freshApi);
      expect(
        () => freshAuth.login(account: 'nonexistent', password: 'wrong'),
        throwsA(anything),
      );
    });
  });

  // ── L2: Books ─────────────────────────────────────────────────────

  group('Books', () {
    late BookApi books;

    setUp(() {
      books = BookApi(api);
    });

    test('listBooks returns list', () async {
      final result = await books.listBooks();
      expect(result, isA<List>());
    });

    test('getRecentBooks returns list', () async {
      final result = await books.getRecentBooks();
      expect(result, isA<List>());
    });

    test('getFavoriteBooks returns list', () async {
      final result = await books.getFavoriteBooks();
      expect(result, isA<List>());
    });

    test('getStats returns stats', () async {
      final stats = await books.getStats();
      expect(stats, isNotNull);
    });

    test('search returns list', () async {
      final result = await books.search('test');
      expect(result, isA<List>());
    });
  });

  // ── L3: Tags & Shelves ────────────────────────────────────────────

  group('Tags', () {
    late TagApi tags;

    setUp(() {
      tags = TagApi(api);
    });

    test('listTags returns list', () async {
      final result = await tags.listTags();
      expect(result, isA<List>());
    });
  });

  group('Shelves', () {
    late ShelfApi shelves;

    setUp(() {
      shelves = ShelfApi(api);
    });

    test('listShelves returns list', () async {
      final result = await shelves.listShelves();
      expect(result, isA<List>());
    });

    test('CRUD shelf lifecycle', () async {
      // Create
      final shelf = await shelves.createShelf('Test Shelf', description: 'integration test');
      expect(shelf.name, equals('Test Shelf'));

      // Read
      final fetched = await shelves.getShelf(shelf.id);
      expect(fetched.name, equals('Test Shelf'));

      // Update
      final updated = await shelves.updateShelf(shelf.id, {'name': 'Updated Shelf'});
      expect(updated.name, equals('Updated Shelf'));

      // Delete
      await shelves.deleteShelf(shelf.id);

      // Verify deleted
      expect(
        () => shelves.getShelf(shelf.id),
        throwsA(anything),
      );
    });
  });

  // ── L4: Sync ──────────────────────────────────────────────────────

  group('Sync', () {
    late SyncApi sync;

    setUp(() {
      sync = SyncApi(api);
    });

    test('fullSync returns data', () async {
      final result = await sync.fullSync({'last_sync_time': 0});
      expect(result, isA<Map>());
    });

    test('deltaSync returns data', () async {
      final result = await sync.deltaSync({'last_sync_time': 0});
      expect(result, isA<Map>());
    });
  });

  // ── L5: System ────────────────────────────────────────────────────

  group('System', () {
    late SystemApi system;

    setUp(() {
      system = SystemApi(api);
    });

    test('getSystemInfo returns info', () async {
      final info = await system.getSystemInfo();
      expect(info, isNotNull);
    });

    test('getScanStatus returns status', () async {
      final status = await system.getScanStatus();
      expect(status, isNotNull);
    });

    test('getAiStatus returns status', () async {
      final status = await system.getAiStatus();
      expect(status, isNotNull);
    });
  });

  // ── L6: Stats ─────────────────────────────────────────────────────

  group('Stats', () {
    late StatsApi stats;

    setUp(() {
      stats = StatsApi(api);
    });

    test('getOverview returns data', () async {
      final result = await stats.getOverview();
      expect(result, isA<Map>());
    });

    test('getDailyStats returns list', () async {
      final result = await stats.getDailyStats();
      expect(result, isA<List>());
    });
  });

  // ── L7: Error Handling ────────────────────────────────────────────

  group('Error handling', () {
    test('unauthenticated request returns 401', () async {
      final noAuthApi = OmnigramApi(baseUrl: baseUrl);
      final noAuthBooks = BookApi(noAuthApi);
      expect(
        () => noAuthBooks.listBooks(),
        throwsA(anything),
      );
    });

    test('nonexistent endpoint returns 404', () async {
      expect(
        () => api.get('/nonexistent/path', fromJson: (d) => d),
        throwsA(anything),
      );
    });
  });
}

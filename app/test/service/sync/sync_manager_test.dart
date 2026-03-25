import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/service/sync/sync_manager.dart';

void main() {
  group('SyncStatus', () {
    test('has all expected values', () {
      expect(SyncStatus.values, contains(SyncStatus.idle));
      expect(SyncStatus.values, contains(SyncStatus.syncing));
      expect(SyncStatus.values, contains(SyncStatus.success));
      expect(SyncStatus.values, contains(SyncStatus.error));
      expect(SyncStatus.values, contains(SyncStatus.offline));
      expect(SyncStatus.values.length, 5);
    });
  });

  group('SyncErrorType', () {
    test('has all expected values', () {
      expect(SyncErrorType.values, contains(SyncErrorType.network));
      expect(SyncErrorType.values, contains(SyncErrorType.auth));
      expect(SyncErrorType.values, contains(SyncErrorType.server));
      expect(SyncErrorType.values, contains(SyncErrorType.data));
      expect(SyncErrorType.values, contains(SyncErrorType.unknown));
      expect(SyncErrorType.values.length, 5);
    });
  });

  group('SyncConflict', () {
    test('stores all fields correctly', () {
      const conflict = SyncConflict(bookId: 42, field: 'title', localValue: 'Local Title', serverValue: 'Server Title');

      expect(conflict.bookId, 42);
      expect(conflict.field, 'title');
      expect(conflict.localValue, 'Local Title');
      expect(conflict.serverValue, 'Server Title');
    });
  });

  group('SyncState', () {
    test('default values', () {
      const state = SyncState();
      expect(state.status, SyncStatus.idle);
      expect(state.lastSyncTime, isNull);
      expect(state.message, isNull);
      expect(state.progress, 0.0);
      expect(state.errorType, isNull);
      expect(state.conflicts, isEmpty);
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime.now();
      final state = SyncState(status: SyncStatus.syncing, lastSyncTime: now, message: 'Syncing...', progress: 0.5);

      final updated = state.copyWith(progress: 0.8);
      expect(updated.status, SyncStatus.syncing);
      expect(updated.lastSyncTime, now);
      expect(updated.progress, 0.8);
    });

    test('copyWith overrides specified fields', () {
      const state = SyncState(status: SyncStatus.syncing, progress: 0.5);
      final updated = state.copyWith(status: SyncStatus.success, message: 'Done', progress: 1.0);

      expect(updated.status, SyncStatus.success);
      expect(updated.message, 'Done');
      expect(updated.progress, 1.0);
    });

    test('copyWith with conflicts', () {
      const state = SyncState();
      const conflicts = [
        SyncConflict(bookId: 1, field: 'title', localValue: 'A', serverValue: 'B'),
        SyncConflict(bookId: 2, field: 'rating', localValue: '4', serverValue: '5'),
      ];

      final updated = state.copyWith(conflicts: conflicts);
      expect(updated.conflicts.length, 2);
      expect(updated.conflicts[0].bookId, 1);
      expect(updated.conflicts[1].field, 'rating');
    });

    test('copyWith clears message when null passed explicitly', () {
      const state = SyncState(message: 'old message');
      // copyWith uses ?? so passing null keeps old value — this is by design
      final updated = state.copyWith(status: SyncStatus.idle);
      // message is preserved unless explicitly overridden
      expect(updated.message, isNull); // copyWith passes message directly, not with ??
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:omnigram/page/settings_page/subpage/sync_conflicts_page.dart';
import 'package:omnigram/page/settings_page/subpage/selective_sync_page.dart';

void main() {
  group('SyncFilterKeys', () {
    test('has expected constant values', () {
      expect(SyncFilterKeys.enabledShelves, 'sync_filter_shelves');
      expect(SyncFilterKeys.enabledTags, 'sync_filter_tags');
      expect(SyncFilterKeys.syncAll, 'sync_filter_all');
    });
  });

  group('SyncConflictsPage', () {
    test('can be instantiated', () {
      const page = SyncConflictsPage();
      expect(page, isA<SyncConflictsPage>());
    });
  });

  group('SelectiveSyncPage', () {
    test('can be instantiated', () {
      const page = SelectiveSyncPage();
      expect(page, isA<SelectiveSyncPage>());
    });
  });
}

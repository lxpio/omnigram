// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_status.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanStatusHash() => r'4c8548266ca03f5000c073f9e8ba6e0b497b0cc5';

/// See also [scanStatus].
@ProviderFor(scanStatus)
final scanStatusProvider = AutoDisposeStreamProvider<ScanStatsDto>.internal(
  scanStatus,
  name: r'scanStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scanStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScanStatusRef = AutoDisposeStreamProviderRef<ScanStatsDto>;
String _$scanServiceHash() => r'5a9c1772a87f2869199be7bc4e57181ebfd44950';

/// See also [ScanService].
@ProviderFor(ScanService)
final scanServiceProvider =
    AutoDisposeNotifierProvider<ScanService, bool>.internal(
  ScanService.new,
  name: r'scanServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scanServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScanService = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

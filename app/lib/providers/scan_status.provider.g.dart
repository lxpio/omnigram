// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_status.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanStatusHash() => r'fd67e70a7b009025261422153012b3f59c083b31';

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
String _$scanServiceHash() => r'5c070ef1b1c481463b5197b02d8cb6a2409f8f10';

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

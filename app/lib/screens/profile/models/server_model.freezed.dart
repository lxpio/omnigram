// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScanStatusModel _$ScanStatusModelFromJson(Map<String, dynamic> json) {
  return _ScanStatusModel.fromJson(json);
}

/// @nodoc
mixin _$ScanStatusModel {
  int get total => throw _privateConstructorUsedError;
  bool get running => throw _privateConstructorUsedError;
  @JsonKey(name: 'scan_count')
  int get scanCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'disk_usage')
  int get diskUsage => throw _privateConstructorUsedError;
  @JsonKey(name: 'epub_count')
  int get epubCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'pdf_count')
  int get pdfCount => throw _privateConstructorUsedError;
  List<String>? get errs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScanStatusModelCopyWith<ScanStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanStatusModelCopyWith<$Res> {
  factory $ScanStatusModelCopyWith(
          ScanStatusModel value, $Res Function(ScanStatusModel) then) =
      _$ScanStatusModelCopyWithImpl<$Res, ScanStatusModel>;
  @useResult
  $Res call(
      {int total,
      bool running,
      @JsonKey(name: 'scan_count') int scanCount,
      @JsonKey(name: 'disk_usage') int diskUsage,
      @JsonKey(name: 'epub_count') int epubCount,
      @JsonKey(name: 'pdf_count') int pdfCount,
      List<String>? errs});
}

/// @nodoc
class _$ScanStatusModelCopyWithImpl<$Res, $Val extends ScanStatusModel>
    implements $ScanStatusModelCopyWith<$Res> {
  _$ScanStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? running = null,
    Object? scanCount = null,
    Object? diskUsage = null,
    Object? epubCount = null,
    Object? pdfCount = null,
    Object? errs = freezed,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      running: null == running
          ? _value.running
          : running // ignore: cast_nullable_to_non_nullable
              as bool,
      scanCount: null == scanCount
          ? _value.scanCount
          : scanCount // ignore: cast_nullable_to_non_nullable
              as int,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as int,
      epubCount: null == epubCount
          ? _value.epubCount
          : epubCount // ignore: cast_nullable_to_non_nullable
              as int,
      pdfCount: null == pdfCount
          ? _value.pdfCount
          : pdfCount // ignore: cast_nullable_to_non_nullable
              as int,
      errs: freezed == errs
          ? _value.errs
          : errs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScanStatusModelImplCopyWith<$Res>
    implements $ScanStatusModelCopyWith<$Res> {
  factory _$$ScanStatusModelImplCopyWith(_$ScanStatusModelImpl value,
          $Res Function(_$ScanStatusModelImpl) then) =
      __$$ScanStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      bool running,
      @JsonKey(name: 'scan_count') int scanCount,
      @JsonKey(name: 'disk_usage') int diskUsage,
      @JsonKey(name: 'epub_count') int epubCount,
      @JsonKey(name: 'pdf_count') int pdfCount,
      List<String>? errs});
}

/// @nodoc
class __$$ScanStatusModelImplCopyWithImpl<$Res>
    extends _$ScanStatusModelCopyWithImpl<$Res, _$ScanStatusModelImpl>
    implements _$$ScanStatusModelImplCopyWith<$Res> {
  __$$ScanStatusModelImplCopyWithImpl(
      _$ScanStatusModelImpl _value, $Res Function(_$ScanStatusModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? running = null,
    Object? scanCount = null,
    Object? diskUsage = null,
    Object? epubCount = null,
    Object? pdfCount = null,
    Object? errs = freezed,
  }) {
    return _then(_$ScanStatusModelImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      running: null == running
          ? _value.running
          : running // ignore: cast_nullable_to_non_nullable
              as bool,
      scanCount: null == scanCount
          ? _value.scanCount
          : scanCount // ignore: cast_nullable_to_non_nullable
              as int,
      diskUsage: null == diskUsage
          ? _value.diskUsage
          : diskUsage // ignore: cast_nullable_to_non_nullable
              as int,
      epubCount: null == epubCount
          ? _value.epubCount
          : epubCount // ignore: cast_nullable_to_non_nullable
              as int,
      pdfCount: null == pdfCount
          ? _value.pdfCount
          : pdfCount // ignore: cast_nullable_to_non_nullable
              as int,
      errs: freezed == errs
          ? _value._errs
          : errs // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScanStatusModelImpl implements _ScanStatusModel {
  const _$ScanStatusModelImpl(
      {this.total = 0,
      this.running = false,
      @JsonKey(name: 'scan_count') this.scanCount = 0,
      @JsonKey(name: 'disk_usage') this.diskUsage = 0,
      @JsonKey(name: 'epub_count') this.epubCount = 0,
      @JsonKey(name: 'pdf_count') this.pdfCount = 0,
      final List<String>? errs})
      : _errs = errs;

  factory _$ScanStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScanStatusModelImplFromJson(json);

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final bool running;
  @override
  @JsonKey(name: 'scan_count')
  final int scanCount;
  @override
  @JsonKey(name: 'disk_usage')
  final int diskUsage;
  @override
  @JsonKey(name: 'epub_count')
  final int epubCount;
  @override
  @JsonKey(name: 'pdf_count')
  final int pdfCount;
  final List<String>? _errs;
  @override
  List<String>? get errs {
    final value = _errs;
    if (value == null) return null;
    if (_errs is EqualUnmodifiableListView) return _errs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ScanStatusModel(total: $total, running: $running, scanCount: $scanCount, diskUsage: $diskUsage, epubCount: $epubCount, pdfCount: $pdfCount, errs: $errs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScanStatusModelImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.running, running) || other.running == running) &&
            (identical(other.scanCount, scanCount) ||
                other.scanCount == scanCount) &&
            (identical(other.diskUsage, diskUsage) ||
                other.diskUsage == diskUsage) &&
            (identical(other.epubCount, epubCount) ||
                other.epubCount == epubCount) &&
            (identical(other.pdfCount, pdfCount) ||
                other.pdfCount == pdfCount) &&
            const DeepCollectionEquality().equals(other._errs, _errs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      total,
      running,
      scanCount,
      diskUsage,
      epubCount,
      pdfCount,
      const DeepCollectionEquality().hash(_errs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScanStatusModelImplCopyWith<_$ScanStatusModelImpl> get copyWith =>
      __$$ScanStatusModelImplCopyWithImpl<_$ScanStatusModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScanStatusModelImplToJson(
      this,
    );
  }
}

abstract class _ScanStatusModel implements ScanStatusModel {
  const factory _ScanStatusModel(
      {final int total,
      final bool running,
      @JsonKey(name: 'scan_count') final int scanCount,
      @JsonKey(name: 'disk_usage') final int diskUsage,
      @JsonKey(name: 'epub_count') final int epubCount,
      @JsonKey(name: 'pdf_count') final int pdfCount,
      final List<String>? errs}) = _$ScanStatusModelImpl;

  factory _ScanStatusModel.fromJson(Map<String, dynamic> json) =
      _$ScanStatusModelImpl.fromJson;

  @override
  int get total;
  @override
  bool get running;
  @override
  @JsonKey(name: 'scan_count')
  int get scanCount;
  @override
  @JsonKey(name: 'disk_usage')
  int get diskUsage;
  @override
  @JsonKey(name: 'epub_count')
  int get epubCount;
  @override
  @JsonKey(name: 'pdf_count')
  int get pdfCount;
  @override
  List<String>? get errs;
  @override
  @JsonKey(ignore: true)
  _$$ScanStatusModelImplCopyWith<_$ScanStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

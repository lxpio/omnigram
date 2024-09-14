// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_accounts_get200_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminAccountsGet200Response extends AdminAccountsGet200Response {
  @override
  final int total;
  @override
  final BuiltList<UserDto> items;
  @override
  final int? pageNum;
  @override
  final int? pageSize;

  factory _$AdminAccountsGet200Response(
          [void Function(AdminAccountsGet200ResponseBuilder)? updates]) =>
      (new AdminAccountsGet200ResponseBuilder()..update(updates))._build();

  _$AdminAccountsGet200Response._(
      {required this.total, required this.items, this.pageNum, this.pageSize})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        total, r'AdminAccountsGet200Response', 'total');
    BuiltValueNullFieldError.checkNotNull(
        items, r'AdminAccountsGet200Response', 'items');
  }

  @override
  AdminAccountsGet200Response rebuild(
          void Function(AdminAccountsGet200ResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminAccountsGet200ResponseBuilder toBuilder() =>
      new AdminAccountsGet200ResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminAccountsGet200Response &&
        total == other.total &&
        items == other.items &&
        pageNum == other.pageNum &&
        pageSize == other.pageSize;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, pageNum.hashCode);
    _$hash = $jc(_$hash, pageSize.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminAccountsGet200Response')
          ..add('total', total)
          ..add('items', items)
          ..add('pageNum', pageNum)
          ..add('pageSize', pageSize))
        .toString();
  }
}

class AdminAccountsGet200ResponseBuilder
    implements
        Builder<AdminAccountsGet200Response,
            AdminAccountsGet200ResponseBuilder> {
  _$AdminAccountsGet200Response? _$v;

  int? _total;
  int? get total => _$this._total;
  set total(int? total) => _$this._total = total;

  ListBuilder<UserDto>? _items;
  ListBuilder<UserDto> get items =>
      _$this._items ??= new ListBuilder<UserDto>();
  set items(ListBuilder<UserDto>? items) => _$this._items = items;

  int? _pageNum;
  int? get pageNum => _$this._pageNum;
  set pageNum(int? pageNum) => _$this._pageNum = pageNum;

  int? _pageSize;
  int? get pageSize => _$this._pageSize;
  set pageSize(int? pageSize) => _$this._pageSize = pageSize;

  AdminAccountsGet200ResponseBuilder() {
    AdminAccountsGet200Response._defaults(this);
  }

  AdminAccountsGet200ResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _total = $v.total;
      _items = $v.items.toBuilder();
      _pageNum = $v.pageNum;
      _pageSize = $v.pageSize;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminAccountsGet200Response other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AdminAccountsGet200Response;
  }

  @override
  void update(void Function(AdminAccountsGet200ResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminAccountsGet200Response build() => _build();

  _$AdminAccountsGet200Response _build() {
    _$AdminAccountsGet200Response _$result;
    try {
      _$result = _$v ??
          new _$AdminAccountsGet200Response._(
              total: BuiltValueNullFieldError.checkNotNull(
                  total, r'AdminAccountsGet200Response', 'total'),
              items: items.build(),
              pageNum: pageNum,
              pageSize: pageSize);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'AdminAccountsGet200Response', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

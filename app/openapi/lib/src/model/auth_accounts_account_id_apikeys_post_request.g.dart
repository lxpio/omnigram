// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_accounts_account_id_apikeys_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthAccountsAccountIdApikeysPostRequest
    extends AuthAccountsAccountIdApikeysPostRequest {
  @override
  final String name;

  factory _$AuthAccountsAccountIdApikeysPostRequest(
          [void Function(AuthAccountsAccountIdApikeysPostRequestBuilder)?
              updates]) =>
      (new AuthAccountsAccountIdApikeysPostRequestBuilder()..update(updates))
          ._build();

  _$AuthAccountsAccountIdApikeysPostRequest._({required this.name})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        name, r'AuthAccountsAccountIdApikeysPostRequest', 'name');
  }

  @override
  AuthAccountsAccountIdApikeysPostRequest rebuild(
          void Function(AuthAccountsAccountIdApikeysPostRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthAccountsAccountIdApikeysPostRequestBuilder toBuilder() =>
      new AuthAccountsAccountIdApikeysPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthAccountsAccountIdApikeysPostRequest &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AuthAccountsAccountIdApikeysPostRequest')
          ..add('name', name))
        .toString();
  }
}

class AuthAccountsAccountIdApikeysPostRequestBuilder
    implements
        Builder<AuthAccountsAccountIdApikeysPostRequest,
            AuthAccountsAccountIdApikeysPostRequestBuilder> {
  _$AuthAccountsAccountIdApikeysPostRequest? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  AuthAccountsAccountIdApikeysPostRequestBuilder() {
    AuthAccountsAccountIdApikeysPostRequest._defaults(this);
  }

  AuthAccountsAccountIdApikeysPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthAccountsAccountIdApikeysPostRequest other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$AuthAccountsAccountIdApikeysPostRequest;
  }

  @override
  void update(
      void Function(AuthAccountsAccountIdApikeysPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthAccountsAccountIdApikeysPostRequest build() => _build();

  _$AuthAccountsAccountIdApikeysPostRequest _build() {
    final _$result = _$v ??
        new _$AuthAccountsAccountIdApikeysPostRequest._(
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'AuthAccountsAccountIdApikeysPostRequest', 'name'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

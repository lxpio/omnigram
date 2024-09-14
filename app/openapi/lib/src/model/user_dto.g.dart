// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserDto extends UserDto {
  @override
  final int id;
  @override
  final String? email;
  @override
  final String? mobile;
  @override
  final String name;
  @override
  final int roleId;
  @override
  final String? nickName;
  @override
  final String? avatarUrl;
  @override
  final bool locked;
  @override
  final int mfaSwitch;
  @override
  final int ctime;
  @override
  final int utime;

  factory _$UserDto([void Function(UserDtoBuilder)? updates]) =>
      (new UserDtoBuilder()..update(updates))._build();

  _$UserDto._(
      {required this.id,
      this.email,
      this.mobile,
      required this.name,
      required this.roleId,
      this.nickName,
      this.avatarUrl,
      required this.locked,
      required this.mfaSwitch,
      required this.ctime,
      required this.utime})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(id, r'UserDto', 'id');
    BuiltValueNullFieldError.checkNotNull(name, r'UserDto', 'name');
    BuiltValueNullFieldError.checkNotNull(roleId, r'UserDto', 'roleId');
    BuiltValueNullFieldError.checkNotNull(locked, r'UserDto', 'locked');
    BuiltValueNullFieldError.checkNotNull(mfaSwitch, r'UserDto', 'mfaSwitch');
    BuiltValueNullFieldError.checkNotNull(ctime, r'UserDto', 'ctime');
    BuiltValueNullFieldError.checkNotNull(utime, r'UserDto', 'utime');
  }

  @override
  UserDto rebuild(void Function(UserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserDtoBuilder toBuilder() => new UserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserDto &&
        id == other.id &&
        email == other.email &&
        mobile == other.mobile &&
        name == other.name &&
        roleId == other.roleId &&
        nickName == other.nickName &&
        avatarUrl == other.avatarUrl &&
        locked == other.locked &&
        mfaSwitch == other.mfaSwitch &&
        ctime == other.ctime &&
        utime == other.utime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, mobile.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, roleId.hashCode);
    _$hash = $jc(_$hash, nickName.hashCode);
    _$hash = $jc(_$hash, avatarUrl.hashCode);
    _$hash = $jc(_$hash, locked.hashCode);
    _$hash = $jc(_$hash, mfaSwitch.hashCode);
    _$hash = $jc(_$hash, ctime.hashCode);
    _$hash = $jc(_$hash, utime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserDto')
          ..add('id', id)
          ..add('email', email)
          ..add('mobile', mobile)
          ..add('name', name)
          ..add('roleId', roleId)
          ..add('nickName', nickName)
          ..add('avatarUrl', avatarUrl)
          ..add('locked', locked)
          ..add('mfaSwitch', mfaSwitch)
          ..add('ctime', ctime)
          ..add('utime', utime))
        .toString();
  }
}

class UserDtoBuilder implements Builder<UserDto, UserDtoBuilder> {
  _$UserDto? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _mobile;
  String? get mobile => _$this._mobile;
  set mobile(String? mobile) => _$this._mobile = mobile;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _roleId;
  int? get roleId => _$this._roleId;
  set roleId(int? roleId) => _$this._roleId = roleId;

  String? _nickName;
  String? get nickName => _$this._nickName;
  set nickName(String? nickName) => _$this._nickName = nickName;

  String? _avatarUrl;
  String? get avatarUrl => _$this._avatarUrl;
  set avatarUrl(String? avatarUrl) => _$this._avatarUrl = avatarUrl;

  bool? _locked;
  bool? get locked => _$this._locked;
  set locked(bool? locked) => _$this._locked = locked;

  int? _mfaSwitch;
  int? get mfaSwitch => _$this._mfaSwitch;
  set mfaSwitch(int? mfaSwitch) => _$this._mfaSwitch = mfaSwitch;

  int? _ctime;
  int? get ctime => _$this._ctime;
  set ctime(int? ctime) => _$this._ctime = ctime;

  int? _utime;
  int? get utime => _$this._utime;
  set utime(int? utime) => _$this._utime = utime;

  UserDtoBuilder() {
    UserDto._defaults(this);
  }

  UserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _mobile = $v.mobile;
      _name = $v.name;
      _roleId = $v.roleId;
      _nickName = $v.nickName;
      _avatarUrl = $v.avatarUrl;
      _locked = $v.locked;
      _mfaSwitch = $v.mfaSwitch;
      _ctime = $v.ctime;
      _utime = $v.utime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserDto other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$UserDto;
  }

  @override
  void update(void Function(UserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserDto build() => _build();

  _$UserDto _build() {
    final _$result = _$v ??
        new _$UserDto._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'UserDto', 'id'),
            email: email,
            mobile: mobile,
            name:
                BuiltValueNullFieldError.checkNotNull(name, r'UserDto', 'name'),
            roleId: BuiltValueNullFieldError.checkNotNull(
                roleId, r'UserDto', 'roleId'),
            nickName: nickName,
            avatarUrl: avatarUrl,
            locked: BuiltValueNullFieldError.checkNotNull(
                locked, r'UserDto', 'locked'),
            mfaSwitch: BuiltValueNullFieldError.checkNotNull(
                mfaSwitch, r'UserDto', 'mfaSwitch'),
            ctime: BuiltValueNullFieldError.checkNotNull(
                ctime, r'UserDto', 'ctime'),
            utime: BuiltValueNullFieldError.checkNotNull(
                utime, r'UserDto', 'utime'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint

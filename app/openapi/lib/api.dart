//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/default_api.dart';

part 'model/admin_accounts_get200_response.dart';
part 'model/apikey_dto.dart';
part 'model/auth_accounts_account_id_apikeys_post_request.dart';
part 'model/auth_login_post_request.dart';
part 'model/change_password_dto.dart';
part 'model/create_user_dto.dart';
part 'model/ebook_dto.dart';
part 'model/ebook_index_dto.dart';
part 'model/ebook_list_dto.dart';
part 'model/enable_scan_dto.dart';
part 'model/login_credential_dto.dart';
part 'model/m4t_tts_stream_post_request.dart';
part 'model/reader_books_book_id_put_request.dart';
part 'model/reader_stats_dto.dart';
part 'model/resp_dto.dart';
part 'model/scan_stats_dto.dart';
part 'model/speaker_dto.dart';
part 'model/speaker_list_dto.dart';
part 'model/sys_info_dto.dart';
part 'model/user_dto.dart';


/// An [ApiClient] instance that uses the default values obtained from
/// the OpenAPI specification file.
var defaultApiClient = ApiClient();

const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
const _deepEquality = DeepCollectionEquality();
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

bool _isEpochMarker(String? pattern) => pattern == _dateEpochMarker || pattern == '/$_dateEpochMarker/';

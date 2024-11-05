//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:openapi/src/date_serializer.dart';
import 'package:openapi/src/model/date.dart';

import 'package:openapi/src/model/access_token_dto.dart';
import 'package:openapi/src/model/admin_accounts_get200_response.dart';
import 'package:openapi/src/model/apikey_dto.dart';
import 'package:openapi/src/model/auth_accounts_account_id_apikeys_post_request.dart';
import 'package:openapi/src/model/change_password_dto.dart';
import 'package:openapi/src/model/create_user_dto.dart';
import 'package:openapi/src/model/delta_sync_dto.dart';
import 'package:openapi/src/model/delta_sync_resp_dto.dart';
import 'package:openapi/src/model/ebook_dto.dart';
import 'package:openapi/src/model/ebook_index_dto.dart';
import 'package:openapi/src/model/ebook_resp_dto.dart';
import 'package:openapi/src/model/enable_scan_dto.dart';
import 'package:openapi/src/model/full_sync_dto.dart';
import 'package:openapi/src/model/login_credential_dto.dart';
import 'package:openapi/src/model/m4t_tts_stream_post_request.dart';
import 'package:openapi/src/model/read_progress_dto.dart';
import 'package:openapi/src/model/reader_books_book_id_progress_put_request.dart';
import 'package:openapi/src/model/reader_books_book_id_put_request.dart';
import 'package:openapi/src/model/reader_stats_dto.dart';
import 'package:openapi/src/model/refresh_token_dto.dart';
import 'package:openapi/src/model/resp_dto.dart';
import 'package:openapi/src/model/scan_stats_dto.dart';
import 'package:openapi/src/model/speaker_dto.dart';
import 'package:openapi/src/model/speaker_list_dto.dart';
import 'package:openapi/src/model/sys_info_dto.dart';
import 'package:openapi/src/model/sys_ping_get200_response.dart';
import 'package:openapi/src/model/user_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  AccessTokenDto,
  AdminAccountsGet200Response,
  ApikeyDto,
  AuthAccountsAccountIdApikeysPostRequest,
  ChangePasswordDto,
  CreateUserDto,
  DeltaSyncDto,
  DeltaSyncRespDto,
  EbookDto,
  EbookIndexDto,
  EbookRespDto,
  EnableScanDto,
  FullSyncDto,
  LoginCredentialDto,
  M4tTtsStreamPostRequest,
  ReadProgressDto,
  ReaderBooksBookIdProgressPutRequest,
  ReaderBooksBookIdPutRequest,
  ReaderStatsDto,
  RefreshTokenDto,
  RespDto,
  ScanStatsDto,
  SpeakerDto,
  SpeakerListDto,
  SysInfoDto,
  SysPingGet200Response,
  UserDto,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(EbookDto)]),
        () => ListBuilder<EbookDto>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ApikeyDto)]),
        () => ListBuilder<ApikeyDto>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

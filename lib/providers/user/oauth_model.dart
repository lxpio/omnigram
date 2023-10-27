
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:omnigram/providers/service/api_service.dart';

part 'oauth_model.freezed.dart';
part 'oauth_model.g.dart';

@freezed
class OauthModel with _$OauthModel {
  const factory OauthModel({
    @Default('') @JsonKey(name: 'token_type') String tokenType,
    @Default('') @JsonKey(name: 'refresh_token') String refreshToken,
    @Default('') @JsonKey(name: 'access_token') String accessToken,
    @Default(3600) int expired_in,
  }) = _OauthModel;

  factory OauthModel.fromJson(Map<String, dynamic> json) =>
      _$OauthModelFromJson(json);
}

Future<OauthModel> getOauthToken(
  String baseUrl,
  String username,
  String password,
) async {
  final remote = APIService(baseUrl: baseUrl);

  final resp = await remote.request<OauthModel>('POST', '/user/oauth2/token',
      body: {"username": username, "password": password},
      fromJsonT: OauthModel.fromJson);

  if (resp.code != 200) {
    throw Exception(resp.message);
  }

  return resp.data!;
}

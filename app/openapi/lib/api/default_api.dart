//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// 删除账号
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  Future<Response> adminAccountsAccountIdDeleteWithHttpInfo(String accountId,) async {
    // ignore: prefer_const_declarations
    final path = r'/admin/accounts/{account_id}'
      .replaceAll('{account_id}', accountId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 删除账号
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  Future<RespDto?> adminAccountsAccountIdDelete(String accountId,) async {
    final response = await adminAccountsAccountIdDeleteWithHttpInfo(accountId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RespDto',) as RespDto;
    
    }
    return null;
  }

  /// 获取用户列表
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索
  ///
  /// * [String] email:
  ///   邮箱
  ///
  /// * [String] name:
  ///   用户名
  ///
  /// * [int] pageNum:
  ///   页码
  ///
  /// * [int] pageSize:
  ///   每页大小
  Future<Response> adminAccountsGetWithHttpInfo({ String? search, String? email, String? name, int? pageNum, int? pageSize, }) async {
    // ignore: prefer_const_declarations
    final path = r'/admin/accounts';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
    }
    if (email != null) {
      queryParams.addAll(_queryParams('', 'email', email));
    }
    if (name != null) {
      queryParams.addAll(_queryParams('', 'name', name));
    }
    if (pageNum != null) {
      queryParams.addAll(_queryParams('', 'page_num', pageNum));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'page_size', pageSize));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取用户列表
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索
  ///
  /// * [String] email:
  ///   邮箱
  ///
  /// * [String] name:
  ///   用户名
  ///
  /// * [int] pageNum:
  ///   页码
  ///
  /// * [int] pageSize:
  ///   每页大小
  Future<AdminAccountsGet200Response?> adminAccountsGet({ String? search, String? email, String? name, int? pageNum, int? pageSize, }) async {
    final response = await adminAccountsGetWithHttpInfo( search: search, email: email, name: name, pageNum: pageNum, pageSize: pageSize, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AdminAccountsGet200Response',) as AdminAccountsGet200Response;
    
    }
    return null;
  }

  /// 创建账号
  ///
  /// 创建普通用户
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [CreateUserDto] createUserDto:
  Future<Response> adminAccountsPostWithHttpInfo({ CreateUserDto? createUserDto, }) async {
    // ignore: prefer_const_declarations
    final path = r'/admin/accounts';

    // ignore: prefer_final_locals
    Object? postBody = createUserDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 创建账号
  ///
  /// 创建普通用户
  ///
  /// Parameters:
  ///
  /// * [CreateUserDto] createUserDto:
  Future<UserDto?> adminAccountsPost({ CreateUserDto? createUserDto, }) async {
    final response = await adminAccountsPostWithHttpInfo( createUserDto: createUserDto, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserDto',) as UserDto;
    
    }
    return null;
  }

  /// 获取用户信息
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   
  ///
  /// * [Object] body:
  Future<Response> adminAccountsUserIdGetWithHttpInfo(String userId, { Object? body, }) async {
    // ignore: prefer_const_declarations
    final path = r'/admin/accounts/{user_id}'
      .replaceAll('{user_id}', userId);

    // ignore: prefer_final_locals
    Object? postBody = body;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取用户信息
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] userId (required):
  ///   
  ///
  /// * [Object] body:
  Future<UserDto?> adminAccountsUserIdGet(String userId, { Object? body, }) async {
    final response = await adminAccountsUserIdGetWithHttpInfo(userId,  body: body, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserDto',) as UserDto;
    
    }
    return null;
  }

  /// 获取API Key列表
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  Future<Response> authAccountsAccountIdApikeysGetWithHttpInfo(String accountId,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/accounts/{account_id}/apikeys'
      .replaceAll('{account_id}', accountId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取API Key列表
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  Future<List<ApikeyDto>?> authAccountsAccountIdApikeysGet(String accountId,) async {
    final response = await authAccountsAccountIdApikeysGetWithHttpInfo(accountId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      final responseBody = await _decodeBodyBytes(response);
      return (await apiClient.deserializeAsync(responseBody, 'List<ApikeyDto>') as List)
        .cast<ApikeyDto>()
        .toList(growable: false);

    }
    return null;
  }

  /// 删除API Key
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  ///
  /// * [String] keyId (required):
  ///   
  Future<Response> authAccountsAccountIdApikeysKeyIdDeleteWithHttpInfo(String accountId, String keyId,) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/accounts/{account_id}/apikeys/{key_id}'
      .replaceAll('{account_id}', accountId)
      .replaceAll('{key_id}', keyId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 删除API Key
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  ///
  /// * [String] keyId (required):
  ///   
  Future<RespDto?> authAccountsAccountIdApikeysKeyIdDelete(String accountId, String keyId,) async {
    final response = await authAccountsAccountIdApikeysKeyIdDeleteWithHttpInfo(accountId, keyId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RespDto',) as RespDto;
    
    }
    return null;
  }

  /// 创建API Key
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  ///
  /// * [AuthAccountsAccountIdApikeysPostRequest] authAccountsAccountIdApikeysPostRequest:
  Future<Response> authAccountsAccountIdApikeysPostWithHttpInfo(String accountId, { AuthAccountsAccountIdApikeysPostRequest? authAccountsAccountIdApikeysPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/accounts/{account_id}/apikeys'
      .replaceAll('{account_id}', accountId);

    // ignore: prefer_final_locals
    Object? postBody = authAccountsAccountIdApikeysPostRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 创建API Key
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  ///
  /// * [AuthAccountsAccountIdApikeysPostRequest] authAccountsAccountIdApikeysPostRequest:
  Future<ApikeyDto?> authAccountsAccountIdApikeysPost(String accountId, { AuthAccountsAccountIdApikeysPostRequest? authAccountsAccountIdApikeysPostRequest, }) async {
    final response = await authAccountsAccountIdApikeysPostWithHttpInfo(accountId,  authAccountsAccountIdApikeysPostRequest: authAccountsAccountIdApikeysPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ApikeyDto',) as ApikeyDto;
    
    }
    return null;
  }

  /// 重置账号密码
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  ///
  /// * [ChangePasswordDto] changePasswordDto:
  Future<Response> authAccountsAccountIdResetPostWithHttpInfo(String accountId, { ChangePasswordDto? changePasswordDto, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/accounts/{account_id}/reset'
      .replaceAll('{account_id}', accountId);

    // ignore: prefer_final_locals
    Object? postBody = changePasswordDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 重置账号密码
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] accountId (required):
  ///   
  ///
  /// * [ChangePasswordDto] changePasswordDto:
  Future<RespDto?> authAccountsAccountIdResetPost(String accountId, { ChangePasswordDto? changePasswordDto, }) async {
    final response = await authAccountsAccountIdResetPostWithHttpInfo(accountId,  changePasswordDto: changePasswordDto, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RespDto',) as RespDto;
    
    }
    return null;
  }

  /// 用户登录
  ///
  /// 用户登录接口，认证成功以后返回200 ok ，并set-cookie 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LoginCredentialDto] loginCredentialDto:
  Future<Response> authLoginPostWithHttpInfo({ LoginCredentialDto? loginCredentialDto, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/login';

    // ignore: prefer_final_locals
    Object? postBody = loginCredentialDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 用户登录
  ///
  /// 用户登录接口，认证成功以后返回200 ok ，并set-cookie 
  ///
  /// Parameters:
  ///
  /// * [LoginCredentialDto] loginCredentialDto:
  Future<RespDto?> authLoginPost({ LoginCredentialDto? loginCredentialDto, }) async {
    final response = await authLoginPostWithHttpInfo( loginCredentialDto: loginCredentialDto, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RespDto',) as RespDto;
    
    }
    return null;
  }

  /// 用户登出
  ///
  /// 用户登出接口，将清理 cookie
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> authLogoutPostWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/auth/logout';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 用户登出
  ///
  /// 用户登出接口，将清理 cookie
  Future<RespDto?> authLogoutPost() async {
    final response = await authLogoutPostWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'RespDto',) as RespDto;
    
    }
    return null;
  }

  /// 获取访问token
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [LoginCredentialDto] loginCredentialDto:
  Future<Response> authTokenPostWithHttpInfo({ LoginCredentialDto? loginCredentialDto, }) async {
    // ignore: prefer_const_declarations
    final path = r'/auth/token';

    // ignore: prefer_final_locals
    Object? postBody = loginCredentialDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取访问token
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [LoginCredentialDto] loginCredentialDto:
  Future<AccessTokenDto?> authTokenPost({ LoginCredentialDto? loginCredentialDto, }) async {
    final response = await authTokenPostWithHttpInfo( loginCredentialDto: loginCredentialDto, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'AccessTokenDto',) as AccessTokenDto;
    
    }
    return null;
  }

  /// 获取书籍封面图片
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  Future<Response> imgReaderCoversBookIdGetWithHttpInfo(String bookId,) async {
    // ignore: prefer_const_declarations
    final path = r'/img/reader/covers/{book_id}'
      .replaceAll('{book_id}', bookId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取书籍封面图片
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  Future<Object?> imgReaderCoversBookIdGet(String bookId,) async {
    final response = await imgReaderCoversBookIdGetWithHttpInfo(bookId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// 文字转语音
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [M4tTtsStreamPostRequest] m4tTtsStreamPostRequest:
  Future<Response> m4tTtsSimplePostWithHttpInfo({ M4tTtsStreamPostRequest? m4tTtsStreamPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/m4t/tts/simple';

    // ignore: prefer_final_locals
    Object? postBody = m4tTtsStreamPostRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 文字转语音
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [M4tTtsStreamPostRequest] m4tTtsStreamPostRequest:
  Future<Object?> m4tTtsSimplePost({ M4tTtsStreamPostRequest? m4tTtsStreamPostRequest, }) async {
    final response = await m4tTtsSimplePostWithHttpInfo( m4tTtsStreamPostRequest: m4tTtsStreamPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// 获取声音列表
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> m4tTtsSpeakersGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/m4t/tts/speakers';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取声音列表
  ///
  /// 
  Future<SpeakerListDto?> m4tTtsSpeakersGet() async {
    final response = await m4tTtsSpeakersGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SpeakerListDto',) as SpeakerListDto;
    
    }
    return null;
  }

  /// 上传声音
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   名称
  ///
  /// * [MultipartFile] wav:
  ///   原始声音
  Future<Response> m4tTtsSpeakersPostWithHttpInfo({ String? name, MultipartFile? wav, }) async {
    // ignore: prefer_const_declarations
    final path = r'/m4t/tts/speakers';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['multipart/form-data'];

    bool hasFields = false;
    final mp = MultipartRequest('POST', Uri.parse(path));
    if (name != null) {
      hasFields = true;
      mp.fields[r'name'] = parameterToString(name);
    }
    if (wav != null) {
      hasFields = true;
      mp.fields[r'wav'] = wav.field;
      mp.files.add(wav);
    }
    if (hasFields) {
      postBody = mp;
    }

    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 上传声音
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   名称
  ///
  /// * [MultipartFile] wav:
  ///   原始声音
  Future<SpeakerDto?> m4tTtsSpeakersPost({ String? name, MultipartFile? wav, }) async {
    final response = await m4tTtsSpeakersPostWithHttpInfo( name: name, wav: wav, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SpeakerDto',) as SpeakerDto;
    
    }
    return null;
  }

  /// 文字转语音接口
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [M4tTtsStreamPostRequest] m4tTtsStreamPostRequest:
  Future<Response> m4tTtsStreamPostWithHttpInfo({ M4tTtsStreamPostRequest? m4tTtsStreamPostRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/m4t/tts/stream';

    // ignore: prefer_final_locals
    Object? postBody = m4tTtsStreamPostRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 文字转语音接口
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [M4tTtsStreamPostRequest] m4tTtsStreamPostRequest:
  Future<Object?> m4tTtsStreamPost({ M4tTtsStreamPostRequest? m4tTtsStreamPostRequest, }) async {
    final response = await m4tTtsStreamPostWithHttpInfo( m4tTtsStreamPostRequest: m4tTtsStreamPostRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// 书籍详情
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  Future<Response> readerBooksBookIdGetWithHttpInfo(String bookId,) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/books/{book_id}'
      .replaceAll('{book_id}', bookId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 书籍详情
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  Future<EbookDto?> readerBooksBookIdGet(String bookId,) async {
    final response = await readerBooksBookIdGetWithHttpInfo(bookId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookDto',) as EbookDto;
    
    }
    return null;
  }

  /// 修改书籍介绍信息
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  ///
  /// * [ReaderBooksBookIdPutRequest] readerBooksBookIdPutRequest:
  Future<Response> readerBooksBookIdPutWithHttpInfo(String bookId, { ReaderBooksBookIdPutRequest? readerBooksBookIdPutRequest, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/books/{book_id}'
      .replaceAll('{book_id}', bookId);

    // ignore: prefer_final_locals
    Object? postBody = readerBooksBookIdPutRequest;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 修改书籍介绍信息
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  ///
  /// * [ReaderBooksBookIdPutRequest] readerBooksBookIdPutRequest:
  Future<EbookDto?> readerBooksBookIdPut(String bookId, { ReaderBooksBookIdPutRequest? readerBooksBookIdPutRequest, }) async {
    final response = await readerBooksBookIdPutWithHttpInfo(bookId,  readerBooksBookIdPutRequest: readerBooksBookIdPutRequest, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookDto',) as EbookDto;
    
    }
    return null;
  }

  /// 获取书籍列表
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索字段
  ///
  /// * [int] pageSize:
  ///   页数
  ///
  /// * [int] pageNum:
  ///   页数大小
  ///
  /// * [String] category:
  ///   分类
  ///
  /// * [String] author:
  ///   作者
  Future<Response> readerBooksGetWithHttpInfo({ String? search, int? pageSize, int? pageNum, String? category, String? author, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/books';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'page_size', pageSize));
    }
    if (pageNum != null) {
      queryParams.addAll(_queryParams('', 'page_num', pageNum));
    }
    if (category != null) {
      queryParams.addAll(_queryParams('', 'category', category));
    }
    if (author != null) {
      queryParams.addAll(_queryParams('', 'author', author));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取书籍列表
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索字段
  ///
  /// * [int] pageSize:
  ///   页数
  ///
  /// * [int] pageNum:
  ///   页数大小
  ///
  /// * [String] category:
  ///   分类
  ///
  /// * [String] author:
  ///   作者
  Future<EbookListDto?> readerBooksGet({ String? search, int? pageSize, int? pageNum, String? category, String? author, }) async {
    final response = await readerBooksGetWithHttpInfo( search: search, pageSize: pageSize, pageNum: pageNum, category: category, author: author, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookListDto',) as EbookListDto;
    
    }
    return null;
  }

  /// 下载书籍
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  Future<Response> readerDownloadBooksBookIdGetWithHttpInfo(String bookId,) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/download/books/{book_id}'
      .replaceAll('{book_id}', bookId);

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 下载书籍
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] bookId (required):
  ///   
  Future<Object?> readerDownloadBooksBookIdGet(String bookId,) async {
    final response = await readerDownloadBooksBookIdGetWithHttpInfo(bookId,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'Object',) as Object;
    
    }
    return null;
  }

  /// 喜欢的书
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索字段
  ///
  /// * [num] pageSize:
  ///   页数
  ///
  /// * [num] pageNum:
  ///   页数大小
  ///
  /// * [String] category:
  ///   分类
  ///
  /// * [String] author:
  ///   作者
  Future<Response> readerFavGetWithHttpInfo({ String? search, num? pageSize, num? pageNum, String? category, String? author, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/fav';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'page_size', pageSize));
    }
    if (pageNum != null) {
      queryParams.addAll(_queryParams('', 'page_num', pageNum));
    }
    if (category != null) {
      queryParams.addAll(_queryParams('', 'category', category));
    }
    if (author != null) {
      queryParams.addAll(_queryParams('', 'author', author));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 喜欢的书
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索字段
  ///
  /// * [num] pageSize:
  ///   页数
  ///
  /// * [num] pageNum:
  ///   页数大小
  ///
  /// * [String] category:
  ///   分类
  ///
  /// * [String] author:
  ///   作者
  Future<EbookListDto?> readerFavGet({ String? search, num? pageSize, num? pageNum, String? category, String? author, }) async {
    final response = await readerFavGetWithHttpInfo( search: search, pageSize: pageSize, pageNum: pageNum, category: category, author: author, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookListDto',) as EbookListDto;
    
    }
    return null;
  }

  /// 获取阅读索引页
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [num] random:
  ///   随机书籍数量
  ///
  /// * [num] recent:
  ///   最近阅读数量
  Future<Response> readerIndexGetWithHttpInfo({ num? random, num? recent, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/index';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (random != null) {
      queryParams.addAll(_queryParams('', 'random', random));
    }
    if (recent != null) {
      queryParams.addAll(_queryParams('', 'recent', recent));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取阅读索引页
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [num] random:
  ///   随机书籍数量
  ///
  /// * [num] recent:
  ///   最近阅读数量
  Future<EbookIndexDto?> readerIndexGet({ num? random, num? recent, }) async {
    final response = await readerIndexGetWithHttpInfo( random: random, recent: recent, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookIndexDto',) as EbookIndexDto;
    
    }
    return null;
  }

  /// 最近阅读
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索字段
  ///
  /// * [num] pageSize:
  ///   页数
  ///
  /// * [num] pageNum:
  ///   页数大小
  ///
  /// * [String] category:
  ///   分类
  ///
  /// * [String] author:
  ///   作者
  Future<Response> readerRecentGetWithHttpInfo({ String? search, num? pageSize, num? pageNum, String? category, String? author, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/recent';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (search != null) {
      queryParams.addAll(_queryParams('', 'search', search));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'page_size', pageSize));
    }
    if (pageNum != null) {
      queryParams.addAll(_queryParams('', 'page_num', pageNum));
    }
    if (category != null) {
      queryParams.addAll(_queryParams('', 'category', category));
    }
    if (author != null) {
      queryParams.addAll(_queryParams('', 'author', author));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 最近阅读
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [String] search:
  ///   模糊搜索字段
  ///
  /// * [num] pageSize:
  ///   页数
  ///
  /// * [num] pageNum:
  ///   页数大小
  ///
  /// * [String] category:
  ///   分类
  ///
  /// * [String] author:
  ///   作者
  Future<EbookListDto?> readerRecentGet({ String? search, num? pageSize, num? pageNum, String? category, String? author, }) async {
    final response = await readerRecentGetWithHttpInfo( search: search, pageSize: pageSize, pageNum: pageNum, category: category, author: author, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookListDto',) as EbookListDto;
    
    }
    return null;
  }

  /// 获取阅读统计数据
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> readerStatsGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/reader/stats';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取阅读统计数据
  ///
  /// 
  Future<ReaderStatsDto?> readerStatsGet() async {
    final response = await readerStatsGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ReaderStatsDto',) as ReaderStatsDto;
    
    }
    return null;
  }

  /// 上传书籍
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] body:
  Future<Response> readerUploadPostWithHttpInfo({ MultipartFile? body, }) async {
    // ignore: prefer_const_declarations
    final path = r'/reader/upload';

    // ignore: prefer_final_locals
    Object? postBody = body;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/octet-stream'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 上传书籍
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [MultipartFile] body:
  Future<EbookDto?> readerUploadPost({ MultipartFile? body, }) async {
    final response = await readerUploadPostWithHttpInfo( body: body, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'EbookDto',) as EbookDto;
    
    }
    return null;
  }

  /// 获取系统信息
  ///
  /// 获取当前系统后台信息（管理员权限）
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> sysInfoGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/sys/info';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取系统信息
  ///
  /// 获取当前系统后台信息（管理员权限）
  Future<SysInfoDto?> sysInfoGet() async {
    final response = await sysInfoGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SysInfoDto',) as SysInfoDto;
    
    }
    return null;
  }

  /// 修改系统信息
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [SysInfoDto] sysInfoDto:
  Future<Response> sysInfoPutWithHttpInfo({ SysInfoDto? sysInfoDto, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sys/info';

    // ignore: prefer_final_locals
    Object? postBody = sysInfoDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 修改系统信息
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [SysInfoDto] sysInfoDto:
  Future<SysInfoDto?> sysInfoPut({ SysInfoDto? sysInfoDto, }) async {
    final response = await sysInfoPutWithHttpInfo( sysInfoDto: sysInfoDto, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SysInfoDto',) as SysInfoDto;
    
    }
    return null;
  }

  /// 系统心跳
  ///
  /// 获取当前系统后台信息（管理员权限）
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> sysPingGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/sys/ping';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 系统心跳
  ///
  /// 获取当前系统后台信息（管理员权限）
  Future<SysPingGet200Response?> sysPingGet() async {
    final response = await sysPingGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SysPingGet200Response',) as SysPingGet200Response;
    
    }
    return null;
  }

  /// 启动扫描
  ///
  /// 启动扫描目录（管理员权限）
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [EnableScanDto] enableScanDto:
  Future<Response> sysScanRunPostWithHttpInfo({ EnableScanDto? enableScanDto, }) async {
    // ignore: prefer_const_declarations
    final path = r'/sys/scan/run';

    // ignore: prefer_final_locals
    Object? postBody = enableScanDto;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 启动扫描
  ///
  /// 启动扫描目录（管理员权限）
  ///
  /// Parameters:
  ///
  /// * [EnableScanDto] enableScanDto:
  Future<ScanStatsDto?> sysScanRunPost({ EnableScanDto? enableScanDto, }) async {
    final response = await sysScanRunPostWithHttpInfo( enableScanDto: enableScanDto, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ScanStatsDto',) as ScanStatsDto;
    
    }
    return null;
  }

  /// 获取当前扫描状态
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> sysScanStatusGetWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/sys/scan/status';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取当前扫描状态
  ///
  /// 
  Future<ScanStatsDto?> sysScanStatusGet() async {
    final response = await sysScanStatusGetWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ScanStatsDto',) as ScanStatsDto;
    
    }
    return null;
  }

  /// 停止扫描
  ///
  /// 停止扫描目录（管理员权限）
  ///
  /// Note: This method returns the HTTP [Response].
  Future<Response> sysScanStopPostWithHttpInfo() async {
    // ignore: prefer_const_declarations
    final path = r'/sys/scan/stop';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 停止扫描
  ///
  /// 停止扫描目录（管理员权限）
  Future<ScanStatsDto?> sysScanStopPost() async {
    final response = await sysScanStopPostWithHttpInfo();
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ScanStatsDto',) as ScanStatsDto;
    
    }
    return null;
  }

  /// 当前用户信息
  ///
  /// 
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Object] body:
  Future<Response> userUserinfoGetWithHttpInfo({ Object? body, }) async {
    // ignore: prefer_const_declarations
    final path = r'/user/userinfo';

    // ignore: prefer_final_locals
    Object? postBody = body;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 当前用户信息
  ///
  /// 
  ///
  /// Parameters:
  ///
  /// * [Object] body:
  Future<UserDto?> userUserinfoGet({ Object? body, }) async {
    final response = await userUserinfoGetWithHttpInfo( body: body, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'UserDto',) as UserDto;
    
    }
    return null;
  }
}

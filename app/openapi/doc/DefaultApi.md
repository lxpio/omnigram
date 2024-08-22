# openapi.api.DefaultApi

## Load the API package
```dart
import 'package:openapi/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**adminAccountsAccountIdDelete**](DefaultApi.md#adminaccountsaccountiddelete) | **DELETE** /admin/accounts/{account_id} | 删除账号
[**adminAccountsGet**](DefaultApi.md#adminaccountsget) | **GET** /admin/accounts | 获取用户列表
[**adminAccountsPost**](DefaultApi.md#adminaccountspost) | **POST** /admin/accounts | 创建账号
[**adminAccountsUserIdGet**](DefaultApi.md#adminaccountsuseridget) | **GET** /admin/accounts/{user_id} | 获取用户信息
[**authAccountsAccountIdApikeysGet**](DefaultApi.md#authaccountsaccountidapikeysget) | **GET** /auth/accounts/{account_id}/apikeys | 获取API Key列表
[**authAccountsAccountIdApikeysKeyIdDelete**](DefaultApi.md#authaccountsaccountidapikeyskeyiddelete) | **DELETE** /auth/accounts/{account_id}/apikeys/{key_id} | 删除API Key
[**authAccountsAccountIdApikeysPost**](DefaultApi.md#authaccountsaccountidapikeyspost) | **POST** /auth/accounts/{account_id}/apikeys | 创建API Key
[**authAccountsAccountIdResetPost**](DefaultApi.md#authaccountsaccountidresetpost) | **POST** /auth/accounts/{account_id}/reset | 重置账号密码
[**authLoginPost**](DefaultApi.md#authloginpost) | **POST** /auth/login | 用户登录
[**authLogoutPost**](DefaultApi.md#authlogoutpost) | **POST** /auth/logout | 用户登出
[**authTokenPost**](DefaultApi.md#authtokenpost) | **POST** /auth/token | 获取访问token
[**imgReaderCoversBookIdGet**](DefaultApi.md#imgreadercoversbookidget) | **GET** /img/reader/covers/{book_id} | 获取书籍封面图片
[**m4tTtsSimplePost**](DefaultApi.md#m4tttssimplepost) | **POST** /m4t/tts/simple | 文字转语音
[**m4tTtsSpeakersGet**](DefaultApi.md#m4tttsspeakersget) | **GET** /m4t/tts/speakers | 获取声音列表
[**m4tTtsSpeakersPost**](DefaultApi.md#m4tttsspeakerspost) | **POST** /m4t/tts/speakers | 上传声音
[**m4tTtsStreamPost**](DefaultApi.md#m4tttsstreampost) | **POST** /m4t/tts/stream | 文字转语音接口
[**readerBooksBookIdGet**](DefaultApi.md#readerbooksbookidget) | **GET** /reader/books/{book_id} | 书籍详情
[**readerBooksBookIdPut**](DefaultApi.md#readerbooksbookidput) | **PUT** /reader/books/{book_id} | 修改书籍介绍信息
[**readerBooksGet**](DefaultApi.md#readerbooksget) | **GET** /reader/books | 获取书籍列表
[**readerDownloadBooksBookIdGet**](DefaultApi.md#readerdownloadbooksbookidget) | **GET** /reader/download/books/{book_id} | 下载书籍
[**readerFavGet**](DefaultApi.md#readerfavget) | **GET** /reader/fav | 喜欢的书
[**readerIndexGet**](DefaultApi.md#readerindexget) | **GET** /reader/index | 获取阅读索引页
[**readerRecentGet**](DefaultApi.md#readerrecentget) | **GET** /reader/recent | 最近阅读
[**readerStatsGet**](DefaultApi.md#readerstatsget) | **GET** /reader/stats | 获取阅读统计数据
[**readerUploadPost**](DefaultApi.md#readeruploadpost) | **POST** /reader/upload | 上传书籍
[**sysInfoGet**](DefaultApi.md#sysinfoget) | **GET** /sys/info | 获取系统信息
[**sysInfoPut**](DefaultApi.md#sysinfoput) | **PUT** /sys/info | 修改系统信息
[**sysPingGet**](DefaultApi.md#syspingget) | **GET** /sys/ping | 系统心跳
[**sysScanRunPost**](DefaultApi.md#sysscanrunpost) | **POST** /sys/scan/run | 启动扫描
[**sysScanStatusGet**](DefaultApi.md#sysscanstatusget) | **GET** /sys/scan/status | 获取当前扫描状态
[**sysScanStopPost**](DefaultApi.md#sysscanstoppost) | **POST** /sys/scan/stop | 停止扫描
[**userUserinfoGet**](DefaultApi.md#useruserinfoget) | **GET** /user/userinfo | 当前用户信息


# **adminAccountsAccountIdDelete**
> RespDto adminAccountsAccountIdDelete(accountId)

删除账号



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final accountId = accountId_example; // String | 

try {
    final result = api_instance.adminAccountsAccountIdDelete(accountId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminAccountsAccountIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 

### Return type

[**RespDto**](RespDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminAccountsGet**
> AdminAccountsGet200Response adminAccountsGet(search, email, name, pageNum, pageSize)

获取用户列表



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final search = ; // String | 模糊搜索
final email = ; // String | 邮箱
final name = user1; // String | 用户名
final pageNum = 56; // int | 页码
final pageSize = 56; // int | 每页大小

try {
    final result = api_instance.adminAccountsGet(search, email, name, pageNum, pageSize);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminAccountsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| 模糊搜索 | [optional] 
 **email** | **String**| 邮箱 | [optional] 
 **name** | **String**| 用户名 | [optional] 
 **pageNum** | **int**| 页码 | [optional] 
 **pageSize** | **int**| 每页大小 | [optional] 

### Return type

[**AdminAccountsGet200Response**](AdminAccountsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminAccountsPost**
> UserDto adminAccountsPost(createUserDto)

创建账号

创建普通用户

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final createUserDto = CreateUserDto(); // CreateUserDto | 

try {
    final result = api_instance.adminAccountsPost(createUserDto);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminAccountsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **createUserDto** | [**CreateUserDto**](CreateUserDto.md)|  | [optional] 

### Return type

[**UserDto**](UserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **adminAccountsUserIdGet**
> UserDto adminAccountsUserIdGet(userId, body)

获取用户信息



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final userId = userId_example; // String | 
final body = Object(); // Object | 

try {
    final result = api_instance.adminAccountsUserIdGet(userId, body);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->adminAccountsUserIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userId** | **String**|  | 
 **body** | **Object**|  | [optional] 

### Return type

[**UserDto**](UserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAccountsAccountIdApikeysGet**
> List<ApikeyDto> authAccountsAccountIdApikeysGet(accountId)

获取API Key列表



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final accountId = accountId_example; // String | 

try {
    final result = api_instance.authAccountsAccountIdApikeysGet(accountId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authAccountsAccountIdApikeysGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 

### Return type

[**List<ApikeyDto>**](ApikeyDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAccountsAccountIdApikeysKeyIdDelete**
> RespDto authAccountsAccountIdApikeysKeyIdDelete(accountId, keyId)

删除API Key



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final accountId = accountId_example; // String | 
final keyId = keyId_example; // String | 

try {
    final result = api_instance.authAccountsAccountIdApikeysKeyIdDelete(accountId, keyId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authAccountsAccountIdApikeysKeyIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 
 **keyId** | **String**|  | 

### Return type

[**RespDto**](RespDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAccountsAccountIdApikeysPost**
> ApikeyDto authAccountsAccountIdApikeysPost(accountId, authAccountsAccountIdApikeysPostRequest)

创建API Key



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final accountId = accountId_example; // String | 
final authAccountsAccountIdApikeysPostRequest = AuthAccountsAccountIdApikeysPostRequest(); // AuthAccountsAccountIdApikeysPostRequest | 

try {
    final result = api_instance.authAccountsAccountIdApikeysPost(accountId, authAccountsAccountIdApikeysPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authAccountsAccountIdApikeysPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 
 **authAccountsAccountIdApikeysPostRequest** | [**AuthAccountsAccountIdApikeysPostRequest**](AuthAccountsAccountIdApikeysPostRequest.md)|  | [optional] 

### Return type

[**ApikeyDto**](ApikeyDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authAccountsAccountIdResetPost**
> RespDto authAccountsAccountIdResetPost(accountId, changePasswordDto)

重置账号密码



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final accountId = accountId_example; // String | 
final changePasswordDto = ChangePasswordDto(); // ChangePasswordDto | 

try {
    final result = api_instance.authAccountsAccountIdResetPost(accountId, changePasswordDto);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authAccountsAccountIdResetPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **accountId** | **String**|  | 
 **changePasswordDto** | [**ChangePasswordDto**](ChangePasswordDto.md)|  | [optional] 

### Return type

[**RespDto**](RespDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLoginPost**
> RespDto authLoginPost(loginCredentialDto)

用户登录

用户登录接口，认证成功以后返回200 ok ，并set-cookie 

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final loginCredentialDto = LoginCredentialDto(); // LoginCredentialDto | 

try {
    final result = api_instance.authLoginPost(loginCredentialDto);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authLoginPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginCredentialDto** | [**LoginCredentialDto**](LoginCredentialDto.md)|  | [optional] 

### Return type

[**RespDto**](RespDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authLogoutPost**
> RespDto authLogoutPost()

用户登出

用户登出接口，将清理 cookie

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.authLogoutPost();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authLogoutPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**RespDto**](RespDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authTokenPost**
> AccessTokenDto authTokenPost(loginCredentialDto)

获取访问token



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final loginCredentialDto = LoginCredentialDto(); // LoginCredentialDto | 

try {
    final result = api_instance.authTokenPost(loginCredentialDto);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->authTokenPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginCredentialDto** | [**LoginCredentialDto**](LoginCredentialDto.md)|  | [optional] 

### Return type

[**AccessTokenDto**](AccessTokenDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **imgReaderCoversBookIdGet**
> Object imgReaderCoversBookIdGet(bookId)

获取书籍封面图片



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final bookId = bookId_example; // String | 

try {
    final result = api_instance.imgReaderCoversBookIdGet(bookId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->imgReaderCoversBookIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bookId** | **String**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **m4tTtsSimplePost**
> Object m4tTtsSimplePost(m4tTtsStreamPostRequest)

文字转语音



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final m4tTtsStreamPostRequest = M4tTtsStreamPostRequest(); // M4tTtsStreamPostRequest | 

try {
    final result = api_instance.m4tTtsSimplePost(m4tTtsStreamPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->m4tTtsSimplePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **m4tTtsStreamPostRequest** | [**M4tTtsStreamPostRequest**](M4tTtsStreamPostRequest.md)|  | [optional] 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: audio/basic

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **m4tTtsSpeakersGet**
> SpeakerListDto m4tTtsSpeakersGet()

获取声音列表



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.m4tTtsSpeakersGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->m4tTtsSpeakersGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SpeakerListDto**](SpeakerListDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **m4tTtsSpeakersPost**
> SpeakerDto m4tTtsSpeakersPost(name, wav)

上传声音



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final name = name_example; // String | 名称
final wav = BINARY_DATA_HERE; // MultipartFile | 原始声音

try {
    final result = api_instance.m4tTtsSpeakersPost(name, wav);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->m4tTtsSpeakersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **name** | **String**| 名称 | [optional] 
 **wav** | **MultipartFile**| 原始声音 | [optional] 

### Return type

[**SpeakerDto**](SpeakerDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **m4tTtsStreamPost**
> Object m4tTtsStreamPost(m4tTtsStreamPostRequest)

文字转语音接口



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final m4tTtsStreamPostRequest = M4tTtsStreamPostRequest(); // M4tTtsStreamPostRequest | 

try {
    final result = api_instance.m4tTtsStreamPost(m4tTtsStreamPostRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->m4tTtsStreamPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **m4tTtsStreamPostRequest** | [**M4tTtsStreamPostRequest**](M4tTtsStreamPostRequest.md)|  | [optional] 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: text/event-stream

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerBooksBookIdGet**
> EbookDto readerBooksBookIdGet(bookId)

书籍详情



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final bookId = bookId_example; // String | 

try {
    final result = api_instance.readerBooksBookIdGet(bookId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerBooksBookIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bookId** | **String**|  | 

### Return type

[**EbookDto**](EbookDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerBooksBookIdPut**
> EbookDto readerBooksBookIdPut(bookId, readerBooksBookIdPutRequest)

修改书籍介绍信息



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final bookId = bookId_example; // String | 
final readerBooksBookIdPutRequest = ReaderBooksBookIdPutRequest(); // ReaderBooksBookIdPutRequest | 

try {
    final result = api_instance.readerBooksBookIdPut(bookId, readerBooksBookIdPutRequest);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerBooksBookIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bookId** | **String**|  | 
 **readerBooksBookIdPutRequest** | [**ReaderBooksBookIdPutRequest**](ReaderBooksBookIdPutRequest.md)|  | [optional] 

### Return type

[**EbookDto**](EbookDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerBooksGet**
> EbookListDto readerBooksGet(search, pageSize, pageNum, category, author)

获取书籍列表



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final search = ; // String | 模糊搜索字段
final pageSize = 56; // int | 页数
final pageNum = 56; // int | 页数大小
final category = category_example; // String | 分类
final author = author_example; // String | 作者

try {
    final result = api_instance.readerBooksGet(search, pageSize, pageNum, category, author);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerBooksGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| 模糊搜索字段 | [optional] 
 **pageSize** | **int**| 页数 | [optional] 
 **pageNum** | **int**| 页数大小 | [optional] 
 **category** | **String**| 分类 | [optional] 
 **author** | **String**| 作者 | [optional] 

### Return type

[**EbookListDto**](EbookListDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerDownloadBooksBookIdGet**
> Object readerDownloadBooksBookIdGet(bookId)

下载书籍



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final bookId = bookId_example; // String | 

try {
    final result = api_instance.readerDownloadBooksBookIdGet(bookId);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerDownloadBooksBookIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bookId** | **String**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerFavGet**
> EbookListDto readerFavGet(search, pageSize, pageNum, category, author)

喜欢的书



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final search = ; // String | 模糊搜索字段
final pageSize = 8.14; // num | 页数
final pageNum = 8.14; // num | 页数大小
final category = category_example; // String | 分类
final author = author_example; // String | 作者

try {
    final result = api_instance.readerFavGet(search, pageSize, pageNum, category, author);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerFavGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| 模糊搜索字段 | [optional] 
 **pageSize** | **num**| 页数 | [optional] 
 **pageNum** | **num**| 页数大小 | [optional] 
 **category** | **String**| 分类 | [optional] 
 **author** | **String**| 作者 | [optional] 

### Return type

[**EbookListDto**](EbookListDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerIndexGet**
> EbookIndexDto readerIndexGet(random, recent)

获取阅读索引页



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final random = 10; // num | 随机书籍数量
final recent = 12; // num | 最近阅读数量

try {
    final result = api_instance.readerIndexGet(random, recent);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerIndexGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **random** | **num**| 随机书籍数量 | [optional] 
 **recent** | **num**| 最近阅读数量 | [optional] 

### Return type

[**EbookIndexDto**](EbookIndexDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerRecentGet**
> EbookListDto readerRecentGet(search, pageSize, pageNum, category, author)

最近阅读



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final search = ; // String | 模糊搜索字段
final pageSize = 8.14; // num | 页数
final pageNum = 8.14; // num | 页数大小
final category = category_example; // String | 分类
final author = author_example; // String | 作者

try {
    final result = api_instance.readerRecentGet(search, pageSize, pageNum, category, author);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerRecentGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **search** | **String**| 模糊搜索字段 | [optional] 
 **pageSize** | **num**| 页数 | [optional] 
 **pageNum** | **num**| 页数大小 | [optional] 
 **category** | **String**| 分类 | [optional] 
 **author** | **String**| 作者 | [optional] 

### Return type

[**EbookListDto**](EbookListDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerStatsGet**
> ReaderStatsDto readerStatsGet()

获取阅读统计数据



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.readerStatsGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerStatsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ReaderStatsDto**](ReaderStatsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **readerUploadPost**
> EbookDto readerUploadPost(body)

上传书籍



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final body = MultipartFile(); // MultipartFile | 

try {
    final result = api_instance.readerUploadPost(body);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->readerUploadPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | **MultipartFile**|  | [optional] 

### Return type

[**EbookDto**](EbookDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/octet-stream
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sysInfoGet**
> SysInfoDto sysInfoGet()

获取系统信息

获取当前系统后台信息（管理员权限）

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.sysInfoGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sysInfoGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SysInfoDto**](SysInfoDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sysInfoPut**
> SysInfoDto sysInfoPut(sysInfoDto)

修改系统信息



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final sysInfoDto = SysInfoDto(); // SysInfoDto | 

try {
    final result = api_instance.sysInfoPut(sysInfoDto);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sysInfoPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sysInfoDto** | [**SysInfoDto**](SysInfoDto.md)|  | [optional] 

### Return type

[**SysInfoDto**](SysInfoDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sysPingGet**
> SysPingGet200Response sysPingGet()

系统心跳

获取当前系统后台信息（管理员权限）

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.sysPingGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sysPingGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**SysPingGet200Response**](SysPingGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sysScanRunPost**
> ScanStatsDto sysScanRunPost(enableScanDto)

启动扫描

启动扫描目录（管理员权限）

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final enableScanDto = EnableScanDto(); // EnableScanDto | 

try {
    final result = api_instance.sysScanRunPost(enableScanDto);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sysScanRunPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **enableScanDto** | [**EnableScanDto**](EnableScanDto.md)|  | [optional] 

### Return type

[**ScanStatsDto**](ScanStatsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sysScanStatusGet**
> ScanStatsDto sysScanStatusGet()

获取当前扫描状态



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.sysScanStatusGet();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sysScanStatusGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ScanStatsDto**](ScanStatsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sysScanStopPost**
> ScanStatsDto sysScanStopPost()

停止扫描

停止扫描目录（管理员权限）

### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();

try {
    final result = api_instance.sysScanStopPost();
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->sysScanStopPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ScanStatsDto**](ScanStatsDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **userUserinfoGet**
> UserDto userUserinfoGet(body)

当前用户信息



### Example
```dart
import 'package:openapi/api.dart';

final api_instance = DefaultApi();
final body = Object(); // Object | 

try {
    final result = api_instance.userUserinfoGet(body);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->userUserinfoGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **body** | **Object**|  | [optional] 

### Return type

[**UserDto**](UserDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

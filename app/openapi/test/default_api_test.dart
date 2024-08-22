//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:openapi/api.dart';
import 'package:test/test.dart';


/// tests for DefaultApi
void main() {
  // final instance = DefaultApi();

  group('tests for DefaultApi', () {
    // 删除账号
    //
    // 
    //
    //Future<RespDto> adminAccountsAccountIdDelete(String accountId) async
    test('test adminAccountsAccountIdDelete', () async {
      // TODO
    });

    // 获取用户列表
    //
    // 
    //
    //Future<AdminAccountsGet200Response> adminAccountsGet({ String search, String email, String name, int pageNum, int pageSize }) async
    test('test adminAccountsGet', () async {
      // TODO
    });

    // 创建账号
    //
    // 创建普通用户
    //
    //Future<UserDto> adminAccountsPost({ CreateUserDto createUserDto }) async
    test('test adminAccountsPost', () async {
      // TODO
    });

    // 获取用户信息
    //
    // 
    //
    //Future<UserDto> adminAccountsUserIdGet(String userId, { Object body }) async
    test('test adminAccountsUserIdGet', () async {
      // TODO
    });

    // 获取API Key列表
    //
    // 
    //
    //Future<List<ApikeyDto>> authAccountsAccountIdApikeysGet(String accountId) async
    test('test authAccountsAccountIdApikeysGet', () async {
      // TODO
    });

    // 删除API Key
    //
    // 
    //
    //Future<RespDto> authAccountsAccountIdApikeysKeyIdDelete(String accountId, String keyId) async
    test('test authAccountsAccountIdApikeysKeyIdDelete', () async {
      // TODO
    });

    // 创建API Key
    //
    // 
    //
    //Future<ApikeyDto> authAccountsAccountIdApikeysPost(String accountId, { AuthAccountsAccountIdApikeysPostRequest authAccountsAccountIdApikeysPostRequest }) async
    test('test authAccountsAccountIdApikeysPost', () async {
      // TODO
    });

    // 重置账号密码
    //
    // 
    //
    //Future<RespDto> authAccountsAccountIdResetPost(String accountId, { ChangePasswordDto changePasswordDto }) async
    test('test authAccountsAccountIdResetPost', () async {
      // TODO
    });

    // 用户登录
    //
    // 用户登录接口，认证成功以后返回200 ok ，并set-cookie 
    //
    //Future<RespDto> authLoginPost({ LoginCredentialDto loginCredentialDto }) async
    test('test authLoginPost', () async {
      // TODO
    });

    // 用户登出
    //
    // 用户登出接口，将清理 cookie
    //
    //Future<RespDto> authLogoutPost() async
    test('test authLogoutPost', () async {
      // TODO
    });

    // 获取访问token
    //
    // 
    //
    //Future<AccessTokenDto> authTokenPost({ LoginCredentialDto loginCredentialDto }) async
    test('test authTokenPost', () async {
      // TODO
    });

    // 获取书籍封面图片
    //
    // 
    //
    //Future<Object> imgReaderCoversBookIdGet(String bookId) async
    test('test imgReaderCoversBookIdGet', () async {
      // TODO
    });

    // 文字转语音
    //
    // 
    //
    //Future<Object> m4tTtsSimplePost({ M4tTtsStreamPostRequest m4tTtsStreamPostRequest }) async
    test('test m4tTtsSimplePost', () async {
      // TODO
    });

    // 获取声音列表
    //
    // 
    //
    //Future<SpeakerListDto> m4tTtsSpeakersGet() async
    test('test m4tTtsSpeakersGet', () async {
      // TODO
    });

    // 上传声音
    //
    // 
    //
    //Future<SpeakerDto> m4tTtsSpeakersPost({ String name, MultipartFile wav }) async
    test('test m4tTtsSpeakersPost', () async {
      // TODO
    });

    // 文字转语音接口
    //
    // 
    //
    //Future<Object> m4tTtsStreamPost({ M4tTtsStreamPostRequest m4tTtsStreamPostRequest }) async
    test('test m4tTtsStreamPost', () async {
      // TODO
    });

    // 书籍详情
    //
    // 
    //
    //Future<EbookDto> readerBooksBookIdGet(String bookId) async
    test('test readerBooksBookIdGet', () async {
      // TODO
    });

    // 修改书籍介绍信息
    //
    // 
    //
    //Future<EbookDto> readerBooksBookIdPut(String bookId, { ReaderBooksBookIdPutRequest readerBooksBookIdPutRequest }) async
    test('test readerBooksBookIdPut', () async {
      // TODO
    });

    // 获取书籍列表
    //
    // 
    //
    //Future<EbookListDto> readerBooksGet({ String search, int pageSize, int pageNum, String category, String author }) async
    test('test readerBooksGet', () async {
      // TODO
    });

    // 下载书籍
    //
    // 
    //
    //Future<Object> readerDownloadBooksBookIdGet(String bookId) async
    test('test readerDownloadBooksBookIdGet', () async {
      // TODO
    });

    // 喜欢的书
    //
    // 
    //
    //Future<EbookListDto> readerFavGet({ String search, num pageSize, num pageNum, String category, String author }) async
    test('test readerFavGet', () async {
      // TODO
    });

    // 获取阅读索引页
    //
    // 
    //
    //Future<EbookIndexDto> readerIndexGet({ num random, num recent }) async
    test('test readerIndexGet', () async {
      // TODO
    });

    // 最近阅读
    //
    // 
    //
    //Future<EbookListDto> readerRecentGet({ String search, num pageSize, num pageNum, String category, String author }) async
    test('test readerRecentGet', () async {
      // TODO
    });

    // 获取阅读统计数据
    //
    // 
    //
    //Future<ReaderStatsDto> readerStatsGet() async
    test('test readerStatsGet', () async {
      // TODO
    });

    // 上传书籍
    //
    // 
    //
    //Future<EbookDto> readerUploadPost({ MultipartFile body }) async
    test('test readerUploadPost', () async {
      // TODO
    });

    // 获取系统信息
    //
    // 获取当前系统后台信息（管理员权限）
    //
    //Future<SysInfoDto> sysInfoGet() async
    test('test sysInfoGet', () async {
      // TODO
    });

    // 修改系统信息
    //
    // 
    //
    //Future<SysInfoDto> sysInfoPut({ SysInfoDto sysInfoDto }) async
    test('test sysInfoPut', () async {
      // TODO
    });

    // 系统心跳
    //
    // 获取当前系统后台信息（管理员权限）
    //
    //Future<SysPingGet200Response> sysPingGet() async
    test('test sysPingGet', () async {
      // TODO
    });

    // 启动扫描
    //
    // 启动扫描目录（管理员权限）
    //
    //Future<ScanStatsDto> sysScanRunPost({ EnableScanDto enableScanDto }) async
    test('test sysScanRunPost', () async {
      // TODO
    });

    // 获取当前扫描状态
    //
    // 
    //
    //Future<ScanStatsDto> sysScanStatusGet() async
    test('test sysScanStatusGet', () async {
      // TODO
    });

    // 停止扫描
    //
    // 停止扫描目录（管理员权限）
    //
    //Future<ScanStatsDto> sysScanStopPost() async
    test('test sysScanStopPost', () async {
      // TODO
    });

    // 当前用户信息
    //
    // 
    //
    //Future<UserDto> userUserinfoGet({ Object body }) async
    test('test userUserinfoGet', () async {
      // TODO
    });

  });
}

import 'package:test/test.dart';
import 'package:openapi/openapi.dart';


/// tests for DefaultApi
void main() {
  final instance = Openapi().getDefaultApi();

  group(DefaultApi, () {
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
    //Future<UserDto> adminAccountsUserIdGet(String userId, { JsonObject body }) async
    test('test adminAccountsUserIdGet', () async {
      // TODO
    });

    // 获取API Key列表
    //
    // 
    //
    //Future<BuiltList<ApikeyDto>> authAccountsAccountIdApikeysGet(String accountId) async
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

    // 刷新accesstoken
    //
    // 
    //
    //Future<AccessTokenDto> authTokenRefreshPost({ RefreshTokenDto refreshTokenDto }) async
    test('test authTokenRefreshPost', () async {
      // TODO
    });

    // 获取书籍封面图片
    //
    // 
    //
    //Future<JsonObject> imgCoversCoverIdGet(String coverId, { String size }) async
    test('test imgCoversCoverIdGet', () async {
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
    //Future<JsonObject> m4tTtsStreamPost({ M4tTtsStreamPostRequest m4tTtsStreamPostRequest }) async
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

    // 查看书籍阅读进度
    //
    // 
    //
    //Future<ReadProgressDto> readerBooksBookIdProgressGet(String bookId) async
    test('test readerBooksBookIdProgressGet', () async {
      // TODO
    });

    // 更新书籍阅读进度
    //
    // 
    //
    //Future<ReadProgressDto> readerBooksBookIdProgressPut(String bookId, { ReaderBooksBookIdProgressPutRequest readerBooksBookIdProgressPutRequest }) async
    test('test readerBooksBookIdProgressPut', () async {
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
    //Future<EbookRespDto> readerBooksGet({ String search, int pageSize, int pageNum, String category, String author }) async
    test('test readerBooksGet', () async {
      // TODO
    });

    // 下载书籍
    //
    // 
    //
    //Future<JsonObject> readerDownloadBooksBookIdGet(String bookId) async
    test('test readerDownloadBooksBookIdGet', () async {
      // TODO
    });

    // 喜欢的书
    //
    // 
    //
    //Future<EbookRespDto> readerFavGet({ String search, num pageSize, num pageNum, String category, String author }) async
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
    //Future<EbookRespDto> readerRecentGet({ String search, num pageSize, num pageNum, String category, String author }) async
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

    // 增量同步
    //
    // 全量同步数据（文档）
    //
    //Future<DeltaSyncRespDto> syncDeltaPost({ FullSyncDto fullSyncDto }) async
    test('test syncDeltaPost', () async {
      // TODO
    });

    // 全量同步
    //
    // 
    //
    //Future<BuiltList<EbookDto>> syncFullPost({ FullSyncDto fullSyncDto }) async
    test('test syncFullPost', () async {
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
    //Future<UserDto> userUserinfoGet({ JsonObject body }) async
    test('test userUserinfoGet', () async {
      // TODO
    });

    // 文字转语音
    //
    // fish-speech api server
    //
    //Future<JsonObject> v1TtsPost({ TtsReqDto ttsReqDto }) async
    test('test v1TtsPost', () async {
      // TODO
    });

  });
}
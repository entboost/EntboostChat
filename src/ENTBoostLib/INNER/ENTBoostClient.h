//
//  EntBoostClient.h
//  ENTBoostKit
//
//  Created by zhong zf on 13-11-17.
//
//

#import "SOTP_defines.h"
#import "LogonCenter.h"
#import "UserManager.h"
#import "ChatManager.h"
#import "AVManager.h"
#import "EBCache.h"
#import "ENTBoostClientOuterDelegate.h"

@class EBMsgInfo;
@class EBMessage;
@class EBTalk;
@class EBCallInfo;
@class EBVCard;
@class EBGroupInfo;
@class EBMemberInfo;
@class EBNotification;
@class EBChat;

@class TBTalk;
@class TBCall;
@class TBMessage;
@class TBChatDot;
@class TBLogonProperty;
@class TBCacheVersion;
@class TBGroupInfo;
@class TBMemberInfo;
@class TBContactInfo;
@class TBNotification;
@class TBEmotion;
@class EBEmotionInner;

#pragma mark - ENTBoostClientInnerDelegate
@protocol ENTBoostClientInnerDelegate
@optional

/**
 * @param accountInfo 账号相关信息
 */
- (void)onOauthSuccess:(EBAccountInfo*) accountInfo;

///**提醒需要重登事件
// * @param appName 应用名
// * @param cid 调用标识
// * @param fromServerAddress 来源服务地址
// */
//- (void)needRelogon:(NSString *)appName cid:(uint32_t)cid fromServerAddress:(NSString *)fromServerAddress;

/**接收到聊天消息
 * @param msgInfo 原始的消息实例
 * @param message 包装后消息实例
 * @param callId 会话编号
 */
- (void)onRecevieMsg:(EBMsgInfo*)msgInfo message:(EBMessage*)message callId:(uint64_t)callId;

@end


#pragma mark - ENTBoostClient
///恩布业务基本接口类
@interface ENTBoostClient : NSObject <AbstractManagerDelegate, AVManagerDelegate>
{
    //LC服务器部署唯一编号
    uint64_t _deployId;
    
    //应用编号
    NSString* _appId;
    //应用密钥
    NSString* _appKey;
    //应用动态令牌
    NSString* _appOnlineKey;
    
    //账号前缀
    NSString* _accountPrefix;
    //开放注册情况
    uint16_t _openRegister;
    //是否开放游客
    BOOL _isOpenVisitor;
    //重置密码链接
    NSString* _forgetPasswordUrl;
    //注册新用户链接
    NSString* _registerUrl;
    //企业LOGO链接
    NSString* _entLogoUrl;
    //是否发送注册验证邮件
    BOOL _isSendRegMail;
    //保存聊天记录配置
    uint16_t _saveConversations;
    //漫游消息URL
    NSString* _conversationsUrl;
    //恩布管理中心URL(当前用户是企业管理者才有值)
    NSString* _entManagerUrl;
    //自动打开订购APP应用ID
    uint16_t _autoOpenSubId;
    //服务端是否拥有授权许可
    BOOL _isLicenseUser;
    //已授权服务端名称
    NSString* _productName;
    //用户登录密码验证模式
    int _passwordAuthMode;
    //应用导航缓存，数据结构：{key=subId, entity=NSArray}
    NSMutableDictionary* _funcNavigationsCache;
    //地区数据字典缓存，数据结构：{key=aId, entity=NSDictionary}
    NSMutableDictionary* _areasCache;
    
    //    __weak id _delegate; //回调代理
    //LogonCenter *_lc;
    
    //    enum UserStatus _userStatus; //用户登录状态(非在线状态)
    //    enum EB_USER_LINE_STATE _lineState; //在线状态
    int _accountType; //账号类型
    EBServerInfo *_appServerInfo; //应用中心服务信息
    EBServerInfo *_umServerInfo; //当前用户主UM服务信息
    NSString* _umOnlineKey; //主UM访问令牌
    NSString* _acmKey; //账号验证动态令牌，用于网络掉线、电脑休眠后重新登录时暂替代密码用途;时效短，用户offline后失效
    
//    //需要加密后存入磁盘，以后再实现
//    NSMutableDictionary* _oauthKeys; //自动登录验证令牌，客户端主动创建，可长时间有效
    
    //终端识别码
    NSString* _usId; //待定
    
    //全局并发队列
    dispatch_queue_t _globalDispatchQueue;
    
    //UM服务连接池
    NSMutableDictionary* _umPool;
    //userManager连接池的单线程操作队列
    dispatch_queue_t _umPoolOperationQueue;
    //userManager连接池操作队列关联的自定义数据key
    void *_isOnUMPoolQueueOrTargetQueueKey;
    
//    //定期清理过期数据开关
//    BOOL _isClearingUMPool;
    
    //CM服务连接池
    NSMutableDictionary* _cmPool;
    //chatManager连接池的单线程操作队列
    dispatch_queue_t _cmPoolOperationQueue;
    //chatManager连接池操作队列关联的自定义数据key
    void *_isOnCMPoolQueueOrTargetQueueKey;
    
    
    //AVM服务连接池
    NSMutableDictionary* _avmPool;
    //AVManager连接池的单线程操作队列
    dispatch_queue_t _avmPoolOperationQueue;
    //AVManager连接池操作队列关联的自定义数据key
    void *_isOnAVMPoolQueueOrTargetQueueKey;
    
//    //成员信息缓存；注意该缓存不包括全部成员，只是用于加载多少缓存多少
//    //{key=depCode, value=NSArray}, NSArray中的实例是EBMemberInfo类
//    NSMutableDictionary* _memberInfoCache;
//    //_memberInfoCache的单线程操作队列
//    dispatch_queue_t _memberInfoCacheOperationQueue;
//    //_memberInfoCache连接池操作队列关联的自定义数据key
//    void *_isOnMemberInfoCacheQueueOrTargetQueueKey;
    
//    //本地保存数据操作队列
//    dispatch_queue_t _persistenceOperationQueue;
//    void* _isOnPersistenceQueueOrTargetQueueKey;
    
    //企业信息
    EBEnterpriseInfo* _enterpriseInfo;
    
    //推送证书编号
    uint64_t _sslId;
    //设置编号
    NSString* _deviceToken;
}

//上一次应用初始化时间
@property(strong, nonatomic) NSDate* lastInitENVTime;

//LC服务器部署唯一编号
@property(nonatomic, readonly) uint64_t deployId;
//服务端是否已授权
@property(nonatomic, readonly) BOOL isLicenseUser;
//已授权服务端名称
@property(strong ,nonatomic, readonly) NSString* productName;

@property(atomic) BOOL isLogin; //目前是否已登录状态

///当前用户信息
@property(strong, atomic) EBAccountInfo* accountInfo;

///当前用户在线key
@property(strong, nonatomic, readonly) NSString* umOnlineKey;

///当前用户所属企业编号
@property(atomic) uint64_t myEntCode;
///企业LOGO链接
@property(strong, nonatomic, readonly) NSString* entLogoUrl;
///重置密码连接
@property(strong, nonatomic, readonly) NSString* forgetPasswordUrl;

///回调代理
@property(weak, nonatomic) id delegate;

/**设置LC服务地址
 * @param lCAddress
 */
+ (void)setLCAddress:(NSString*)lCAddress;

//获取LC服务地址
+ (NSString*)lCAddress;

///获取全局单例
+ (ENTBoostClient*)sharedClient;

/**关闭本Client实例
 * @param acceptPush 是否接收推送消息
 */
- (void)closeWithAcceptPush:(BOOL)acceptPush;

//获取LC服务实例
- (LogonCenter*)logonCenter;

/////资源(表情、头像等)描述信息
//@property(strong, nonatomic) NSDictionary* resourceDescriptions;

///联系人分组
@property(strong, nonatomic) NSDictionary* contactGroups;
/////联系人信息
//@property(strong, nonatomic) NSDictionary* contactInfos;
/////联系人信息是否加载完毕
//@property(nonatomic) BOOL isContactInfoLoaded;
///联系人模式，YES=好友模式(需验证)，NO=普通模式(免验证)
@property(nonatomic) BOOL contactNeedVerification;
///邀请进入群组是否需要对方验证通过
@property(nonatomic) BOOL inviteAdd2GroupNeedVerification;

///应用功能列表
@property(nonatomic, strong) NSDictionary* subscribeFuncInfos;
///应用访问入口
@property(nonatomic, strong) NSString* funcUrl;
///我的消息应用订购ID
@property(nonatomic) uint64_t groupMsgSubId;
///邀请好友应用订购ID
@property(nonatomic) uint64_t findAppSubId;

/////CoreData相关
//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

///关闭数据库
- (void)closeDataBase;

///数据库保存变更
- (void)saveDataBaseContext;

@end

#pragma mark - LogonCenterExt 登录中心
///恩布业务登录中心(LC)接口类
@interface ENTBoostClient(LogonCenterExt) <LogonCenterDelegate>

/**初始化应用参数
 * @param appId 应用ID
 * @param appKey 应用key(密钥)
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)initENVWithAppId:(NSString *)appId appKey:(NSString *)appKey success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**使用内存中已存在的参数再次初始化应用参数
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)reInitENVOnSuccess:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**匿名登录
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)logonVisitor:(void (^)(EBAccountInfo* accountInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**登录验证
 * @param uid 用户编号
 * @param password 用户密码
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)logonWithUid:(uint64_t)uid password:(NSString *)password success:(void (^)(EBAccountInfo* accountInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**第三方登录验证
 * @param uid 用户编号
 * @param success 验证成功后的回调函数
 * @param forward 验证不通过后的回调函数，返回第三方验证的URL
 * @param failure 调用失败后的回调函数
 */
- (void)oauthWithUid:(uint64_t)uid success:(void (^)(EBAccountInfo* accountInfo))successBlock forward:(void(^)(NSString *oauthUrl))forwardBlock failure:(void(^)(NSError* error))failureBlock;

/**重新登录(用于掉线或休眠恢复后)
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)reLogon:(void (^)(EBAccountInfo* accountInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**自动登录(曾经在当前客户端成功登录过，自动登录都有可能成功)；游客模式无效
 * @param uid 用户编号
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)autoLogonWithUid:(uint64_t)uid success:(void (^)(EBAccountInfo* accountInfo))successBlock failure:(void(^)(NSError* error))failureBlock;


/**查询普通用户在线信息，用于实现用户呼叫
 * @param virtualAccount 对方账号或用户编号(uid)、手机号码
 * @param callKey 呼叫来源Key，实现企业呼叫来源限制
 * @param requestType 请求类型
    EB_REQUEST_TYPE_REG 注册请求，subType=0普通查询，subType=1注册查询
    EB_REQUEST_TYPE_LOGON 登录请求，subType填登录类型logonType
    EB_REQUEST_TYPE_INVITE 呼叫请求，subType=1返回用户默认名片信息，subType=0不返回用户默认名片信息
 * @param subType 子类型
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)queryUser:(NSString*)virtualAccount callKey:(NSString*)callKey requestType:(EB_REQUEST_TYPE)requestType subType:(int)subType success:(void(^)(uint64_t uid, NSString* account, uint64_t memberCode, uint64_t depCode, NSString* umKey/*, enum EB_STATE_CODE userState*/, EBServerInfo* umServerInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

///**查询部门(可跨部门)或同群组中成员的在线信息，用于实现用户呼叫
// * @param memberCode 成员编号(部门成员或群组成员)
// * @param callKey 呼叫来源Key，实现企业呼叫来源限制
// * @param success 成功后的回调函数
// * @param failure 失败后的回调函数
// */
//- (void)queryMember:(uint64_t)memberCode callKey:(NSString*)callKey success:(void(^)(uint64_t uid, NSString* account, uint64_t memberCode, uint64_t depCode, NSString* umKey, enum EB_STATE_CODE userState, EBServerInfo* umServerInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**查询部门(可跨部门)或群组的在线信息，用于实现用户呼叫
 * @param depCode 部门或群组编号
 * @param callKey 呼叫来源Key，实现企业呼叫来源限制
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)queryGroup:(uint64_t)depCode callKey:(NSString*)callKey success:(void(^)(NSString* umKey, EBServerInfo* umServerInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

@end


#pragma mark - UserManagerExt 用户管理

//缓存版本-默认编号
#define CACHE_VERSION_SPECIAL_CODE 0
//缓存版本-表情、头像编号
#define CACHE_VERSION_EMOTION_CODE 1

///恩布业务用户管理(UM)接口类
@interface ENTBoostClient (UserManagerExt) <UserManagerDelegate>

///漫游消息URL
- (NSString*)conversationsUrl;

/**获取访问应用功能的验证key
 * @param subId 功能订购ID
 * @return 应用功能访问验证key
 */
- (NSString*)funcKeyWithSubId:(uint64_t)subId;

///头像和表情资源是否加载完毕
- (BOOL)isEmotionLoaded;

///表情资源
- (NSArray*)expressions;
///头像资源
- (NSArray*)headPhotos;

/////企业信息
//@property(strong, nonatomic, readonly) EBEnterpriseInfo* enterpriseInfo;
/////部门信息
//@property(strong, nonatomic, readonly) NSDictionary* entGroupInfos;
/////个人群组信息
//@property(strong, nonatomic, readonly) NSDictionary* personalGroupInfos;
/////成员信息
//@property(strong, nonatomic) NSDictionary* memberInfos;

////启动清理闲置UM连接任务定时器
//- (void)startClearIdleUserManagerTask;
////关闭清理闲置UM连接任务定时器
//- (void)stopClearIdleUserManagerTask;

/**获取UM连接
 * @param address 连接地址，如192.168.0.1:18012
 */
//- (UserManager*)userManagerWithAddress:(NSString*)address;

/**设置APNS参数
 * @param sslId 在恩布平台登记推送证书的编号
 * @param deviceToken 设备令牌
 */
- (void)setAPNSWithSSLId:(uint64_t)sslId andDeviceToken:(NSString*)deviceToken;

/**上线并设置在线状态
 * @param state 在线状态
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)onlineWithState:(enum EB_USER_LINE_STATE)state success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**下线
 * @param acceptPush 是否接收推送消息
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)offlineWithAcceptPush:(BOOL)acceptPush success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

///**加载资源
// * @param entSuccessBlock 组织架构加载完成后的回调函数
// * @param emotionSuccessBlock 表情资源加载完成后的回调函数
// * @param failure 失败后的回调函数
// */
//- (void)loadResourceInfoWithSuccess:(void(^)(EBEnterpriseInfo* enterpriseInfo, NSDictionary* entGroupInfos, NSDictionary* personalGroupInfos/*, NSDictionary* memberInfos*/))entSuccessBlock emotionSucess:(void(^)(NSArray* expressions, NSArray* headPhotos))emotionSuccessBlock failure:(void(^)(NSError* error))failureBlock;

#pragma mark 使用缓存或从读取服务器数据
/**加载企业自身信息 - 使用缓存
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)cacheLoadEnterpriseInfoWithSuccess:(void(^)(EBEnterpriseInfo* enterpriseInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载部门信息(不包括成员) - 使用缓存
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)cacheLoadEntGroupInfosWithSuccess:(void(^)(NSDictionary* groupInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载个人群组信息(不包括成员) - 使用缓存
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)cacheLoadPersonalGroupInfosWithSuccess:(void(^)(NSDictionary* groupInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**判断本地缓存版本并从远程同步加载
 * @param type 本地缓存资料版本类型
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)checkVersionAndLoadGroupInfosWithType:(EB_CACHE_VERSION_INFO_TYPE)type success:(void(^)(NSDictionary* groupInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载一个成员信息 - 使用缓存
 * @param empCode 成员编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadMemberInfoWithEmpCode:(uint64_t)empCode success:(void (^)(EBMemberInfo * memberInfo))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载多个成员信息 - 使用缓存
 * @param empCodes 成员编号列表
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadMemberInfosWithEmpCodes:(NSArray*)empCodes success:(void (^)(NSDictionary* memberInfos))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载一个成员信息 - 使用缓存
 * @param uid 用户编号
 * @param depCode 部门或群组编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadMemberInfoWithUid:(uint64_t)uid depCode:(uint64_t)depCode success:(void (^)(EBMemberInfo * memberInfo))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载某部门或群组下成员信息 - 使用缓存
 * @param depCode 部门或群组编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadMemberInfosWithDepCode:(uint64_t)depCode success:(void(^)(NSDictionary* memberInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载联系人分组信息 - 使用缓存
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadContactGroupsOnSuccess:(void (^)(NSDictionary* contactGroups))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载一个联系人信息 - 使用缓存
 * @param contactId 联系人编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadContactInfoWithId:(uint64_t)contactId success:(void (^)(EBContactInfo * contactInfo))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载一个联系人信息 - 使用缓存
 * @param contactUid 联系人用户编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadContactInfoWithContactUid:(uint64_t)contactUid success:(void (^)(EBContactInfo * contactInfo))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载某分组下联系人信息 - 使用缓存
 * @param groupId 联系人分组编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadContactInfosWithGroupId:(uint64_t)groupId success:(void(^)(NSDictionary* contactInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载全部联系人信息 - 使用缓存
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadContactInfosOnSuccess:(void(^)(NSDictionary* contactInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**获取某订购应用导航数据 - 使用缓存
 * @param subId 订购编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadFuncNavigationsWithSubId:(uint64_t)subId success:(void(^)(NSArray* funcNavigations))successBlock failure:(void(^)(NSError* error))failureBlock;

/**获取某地区的下级地区数据 - 使用缓存
 * @param parentId 上级地区编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadAreaDictionaryWithParentId:(uint64_t)parentId successBlock:(void(^)(NSDictionary* areas))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载表情和头像资源 - 使用缓存
 * @param beginBlock 加载开始时的回调函数
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)cacheLoadEmotionsOnBegin:(void(^)(NSArray* expressions, NSArray* headPhotos))beginBlock OnCompletion:(void(^)(NSArray* expressions, NSArray* headPhotos))completionBlock failure:(void(^)(NSError* error))failureBlock;

/**获取一个指定部门或群组信息 - 使用缓存
 * @param depCode 部门或群组编号
 */
- (EBGroupInfo*)groupInfoWithDepCode:(uint64_t)depCode;

#pragma mark 直接访问服务器读取数据
/**加载企业自身信息 - 直接访问服务器
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadEnterpriseInfoWithSuccess:(void(^)(EBEnterpriseInfo* enterpriseInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载部门信息(不包括成员) - 直接访问服务器
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadEntGroupInfosWithSuccess:(void(^)(NSDictionary* entGroupInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载个人群组信息(不包括成员) - 直接访问服务器
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadPersonalGroupInfosWithSuccess:(void(^)(NSDictionary* personalGroupInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**获取一个指定部门或群组信息 - 直接访问服务器
 * @param depCode 部门或群组编号
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadGroupInfoWithDepCode:(uint64_t)depCode success:(void(^)(EBGroupInfo* groupInfo, uint64_t groupInfoVer))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载一个成员信息 - 服务器直接读取
 * @param empCode 部门或群组的成员编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfoWithEmpCode:(uint64_t)empCode success:(void (^)(EBMemberInfo * memberInfo, uint64_t groupVer))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载一个成员信息 - 服务器直接读取
 * @param uid 用户编号
 * @param depCode 部门或群组编号
 * @param successBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfoWithUid:(uint64_t)uid depCode:(uint64_t)depCode success:(void (^)(EBMemberInfo * memberInfo, uint64_t groupVer))successBlock failure:(void (^)(NSError *error))failureBlock;

/**搜索部门或群组成员 服务器直接读取
 * @param searchKey 搜索条件：名称、账号、手机号、用户编号(uid)
 * @param successBlock 加载完成后的回调函数
        参数：memberInfos = { key=depCode, value=NSDictionary{key=empCode, value=EBMemberInfo实例} }
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfosWithSearchKey:(NSString*)searchKey success:(void(^)(NSDictionary* memberInfos))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载动态数据(离线信息、用户通知、应用订购关系、部门版本号、个人群组版本号、群组成员在线状态)
 * @param isLoadMsg 是否加载离线信息、用户通知
 * @param isLoadSubFunc 是否加载订购应用关系
 * @param isLoadGroupVersion 是否加载企业部门和个人群组版本号
 * @param memberOnlineStateDepCode 加载群组成员在线状态时使用的群组编号
 * @param isLoadContactOnlineState 是否加载联系人在线状态
 * @param userOnlineStateUids 加载指定用户在线状态时使用的Uid(支持多个)
 * @param isLoadEntGroupOnlineStateCount 是否加载企业部门/项目组的在线人数
 * @param isLoadMyGroupOnlineStateCount 是否加载个人群组/讨论组的在线人数
 * @param groupOnlineStateCountDepCodes 加载部门和群组在线人数时指定的部门(群组)编号列表，结构：@[depCode的NSNumbers对象实例, ...]
 * @param successBlock API本身调用返回正确状态后回调函数(不用等待后续数据加载完成才触发)
 * @param subFuncloadedBlock 应用订购关系加载完成后回调函数
 * @param groupVersionInfosLoadedBlock 部门和群组版本号加载完成后回调函数
 * @param memberOnlineStateLoadedBlock 群组在线状态加载完成回调函数
 * @param contactOnlineStateLoadedBlock 联系人在线状态加载完成回调函数
 * @param userOnlineStateLoadedBlock 用户在线状态加载完成回调函数
 * @param groupOnlineStateCountLoadedBlock 加载部门或群组在线成员数量完成时回调函数
 * @param failure 失败后回调函数
 */
- (void)loadInfo:(BOOL)isLoadMsg isLoadSubFunc:(BOOL)isLoadSubFunc isLoadGroupVersion:(BOOL)isLoadGroupVersion memberOnlineStateDepCode:(uint64_t)memberOnlineStateDepCode isLoadContactOnlineState:(BOOL)isLoadContactOnlineState userOnlineStateUids:(NSArray*)userOnlineStateUids isLoadEntGroupOnlineStateCount:(BOOL)isLoadEntGroupOnlineStateCount isLoadMyGroupOnlineStateCount:(BOOL)isLoadMyGroupOnlineStateCount groupOnlineStateCountDepCodes:(NSArray*)groupOnlineStateCountDepCodes success:(void(^)(void))successBlock subFuncloadedBlock:(void(^)(void))subFuncloadedBlock groupVersionInfosLoadedBlock:(void(^)(void))groupVersionInfosLoadedBlock memberOnlineStateLoadedBlock:(void(^)(NSDictionary* memberStates, uint64_t depCode))memberOnlineStateLoadedBlock contactOnlineStateLoadedBlock:(void(^)(NSDictionary* contactStates))contactOnlineStateLoadedBlock userOnlineStateLoadedBlock:(void(^)(NSDictionary* userStates))userOnlineStateLoadedBlock groupOnlineStateCountLoadedBlock:(void(^)(NSDictionary* countsOfGroupOnlineState))groupOnlineStateCountLoadedBlock failure:(void(^)(NSError* error))failureBlock;

/**加载应用导航
 * @param subId 应用订购编号
 * @param successBlock API本身调用返回正确状态后回调函数(不用等待后续数据加载完成才触发)
 * @param failure 失败后回调函数
 */
- (void)loadFuncNavigationsWithSubId:(uint64_t)subId success:(void(^)(NSArray* funcNavigations))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载字典数据
 * @param type 类型
 * @param value 查询条件
 * @param areaLoadedBlock 地区字典加载完成时回调函数
 * @param failure 失败后回调函数
 */
- (void)loadDictionaryWithType:(int)type value:(uint64_t)value areaLoadedBlock:(void(^)(NSDictionary* areas, uint64_t version))areaLoadedBlock failure:(void(^)(NSError* error))failureBlock;

/**查询用户默认信息
 * @param virtualAccount 虚拟账号(账号、手机号、用户编号)
 * @param successBlock 成功后的回调函数
 * @param failure 失败后回调函数
 */
- (void)queryUserInfoWithVirtualAccount:(NSString*)virtualAccount success:(void (^)(uint64_t uid, NSString* account, EBVCard* vCard))successBlock failure:(void (^)(NSError *error))failureBlock;

/**加载联系人分组
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadContactGroupsWithSuccess:(void(^)(NSDictionary* contactGroups))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载联系人信息
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadContactInfosWithSuccess:(void(^)(NSDictionary* contactInfos))successBlock failure:(void(^)(NSError* error))failureBlock;

/**加载一个联系人信息
    contactId与contactUid至少一个不等于0
 * @param contactId 联系人编号，0=忽略
 * @param contactUid 联系人的用户编号，0=忽略
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)loadContactInfoWithId:(uint64_t)contactId orContactUid:(uint64_t)contactUid success:(void(^)(EBContactInfo* contactInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

#pragma mark 管理

/**注册新用户
 * @param umServerInfo UM资源
 * @param virtualAccount 电子邮箱格式、手机号码、用户编号、带保留字符前缀的英文数字组合(例如@abc123)
 * @param userName 名称
 * @param userExt 用户扩展信息，一般填空
 * @param gender 性别
 * @param birthday 生日
 * @param address 联系地址
 * @param entName 所属企业名称；首次注册企业时使用(注册管理员)，填空注册为普通用户
 * @param isResendRegEmail 是否重发激活验证邮件；NO=普通用户注册功能，YES=重发注册验证邮件(非注册一个新用户)
 * @param isNoNeedRegEmail 是否不需要邮件激活验证；YES=不需要验证激活(自动激活)，NO=需要验证激活(自动发送验证邮件)
 * @param pwd 登录密码
 * @param isEncodePwd 上传的密码是否已经加密；YES=已经加密，服务端将直接保存；NO=密码未加密，服务端将执行加密再保存
 * @param successBlock 成功后回调函数
        参数：uid 用户编号
             regCode 注册验证码
 * @param failureBlock 失败后回调函数
 */
- (void)registUserWithUmServerInfo:(EBServerInfo*)umServerInfo virtualAcount:(NSString*)virtualAccount userName:(NSString*)userName userExt:(NSString*)userExt gender:(EB_GENDER_TYPE)gender birthday:(NSDate*)birthday address:(NSString*)address entName:(NSString*)entName isResendRegEmail:(BOOL)isResendRegEmail isNoNeedRegEmail:(BOOL)isNoNeedRegMail pwd:(NSString*)pwd isEncodePwd:(BOOL)isEncodePwd success:(void(^)(uint64_t uid, int regCode))successBlock failure:(SOTPFailureBlock)failureBlock;

/**编辑当前用户资料
 * @param newAccountInfo 当前用户资料
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserInfoWithAccountInfo:(EBAccountInfo*)newAccountInfo success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**编辑当前用户聊天设置
 * @param setting 当前用户聊天设置
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserSetting:(int)setting success:(void(^)(int savedSetting))successBlock failure:(SOTPFailureBlock)failureBlock;

/**设置当前用户默认电子名片
 * @param defaultEmp 默认电子名片(默认部门或群组编号)
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserDefaultEmp:(uint64_t)defaultEmp success:(void(^)(uint64_t savedDefaultEmp))successBlock failure:(SOTPFailureBlock)failureBlock;

/**修改当前用户密码
 * @param newPassword 新密码
 * @param oldPassword 旧密码
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)changePassword:(NSString*)newPassword oldPassword:(NSString*)oldPassword success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**设置用户在部门或群组的头像
 * @param depCode 部门或群组编号
 * @param resId 头像资源编号，必要大于0
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserHeadPhotoWithDepCode:(uint64_t)depCode resId:(uint64_t)resId success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**上传头像资源文件
 * @param data 头像资源文件数据
 * @param depCode 部门或群组编号
 * @param extendName 资源文件扩展名
 * @param md5 md5校验码
 * @param requestBlock 发起请求上传资源文件请求成功后的回调函数
 * @param beginBlock 开始发送回调函数
 * @param processingBlock 处理中回调函数
 * @param successBlock 成功后回调函数
 * @param resourceExistsBlock 资源文件已存在的回调函数
 * @param cancelBlock 取消发送文件
 * @param failureBlock 失败后回调函数
 */
- (void)uploadHeadPhotoWithData:(NSData*)data depCode:(uint64_t)depCode extendName:(NSString*)extendName md5:(NSString*)md5 request:(void(^)(uint64_t msgId, uint64_t resId))requestBlock begin:(void(^)(uint64_t msgId, uint64_t resId))beginBlock processing:(EB_PROCESSING_BLOCK2)processingBlock resourceExists:(void(^)(uint64_t msgId, uint64_t resId))resourceExistsBlock cancel:(void(^)(uint64_t msgId, uint64_t resId, BOOL initiative))cancelBlock success:(void(^)(uint64_t msgId, uint64_t resId))successBlock failure:(SOTPFailureBlock)failureBlock;

/**新建或编辑联系人分组
 * @param groupId 分组编号；0=新建，其它=编辑
 * @param groupName 分组名称
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)createOrEditContactGroupWithGroupId:(uint64_t)groupId groupName:(NSString*)groupName success:(void(^)(uint64_t groupId))successBlock failure:(void(^)(NSError* error))failureBlock;

/**删除联系人分组
 * @param groupId 分组编号，不可以等于0
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)delContactGroupWithId:(uint64_t)groupId success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**验证联系人
    uid与account至少一个不等于0或nil
 * @param uid 联系人的用户编号
 * @param account 联系人的用户账号
 * @param description 备注信息
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)verifyContactInfoWithUid:(uint64_t)uid orAccount:(NSString*)account description:(NSString*)description success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**新建或编辑联系人信息
 * @param contactInfo 联系人信息；contactInfo.contactId等于0表示新建，不等于0表示编辑
 * @param verificationSentBlock 邀请已发出后的回调函数
 * @param success 添加或编辑成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)createOrEditContactInfo:(EBContactInfo*)contactInfo success:(void(^)(EBContactInfo* contactInfo))successBlock verificationSent:(void(^)(void))verificationSentBlock failure:(void(^)(NSError* error))failureBlock;

/**删除联系人信息
 * @discussion contactId与contactUid至少一个不可以等于0
 * @param contactId 联系人编号
 * @param contactUid 联系人的用户编号
 * @param deleteAnother 同时也删除对方列表中的联系人
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)delContactInfoWithId:(uint64_t)contactId orContactUid:(uint64_t)contactUid deleteAnother:(BOOL)deleteAnother success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**变更联系人所属分组
 * @discussion contactId与contactUid至少一个不可以等于0
 * @param contactId 联系人编号
 * @param contactUid 联系人的用户编号
 * @param groupId 分组编号，等于0表示设置到默认分组
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)changeContactInfoWithId:(uint64_t)contactId orContactUid:(uint64_t)contactUid groupId:(uint64_t)groupId success:(void(^)(EBContactInfo* contactInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**创建或修改部门(或群组)
 * @param groupInfo 部门(或项目组)信息
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)createOrEditGroup:(EBGroupInfo*)groupInfo success:(void(^)(EBGroupInfo* groupInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

/**删除群组(或部门)
 * @param depCode 群组(或部门)编号
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)deleteGroupWithDepCode:(uint64_t)depCode success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**1、新增或修改群组(部门)成员信息；2、邀请成员进入群组
 * @param memberInfo 成员信息
 * @param success 成功后回调函数
         参数：  empCode 成员编号
                empUid 成员的用户编号
                userLineState 员工的在线状态
 @param inviteSentBlock 邀请已发送的回调函数
 * @param failure 失败后回调函数
 */
- (void)createOrEditMember:(EBMemberInfo*)memberInfo success:(void(^)(uint64_t empCode, uint64_t empUid, EB_USER_LINE_STATE userLineState))successBlock inviteSent:(void(^)(void))inviteSentBlock failure:(void(^)(NSError* error))failureBlock;

/**删除群组(部门)成员
 * @param empCode 成员编号
 * @param depCode 群组(或部门)编号
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)deleteMember:(uint64_t)empCode depCode:(uint64_t)depCode success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**响应业务信息
 * @param msgId 成员编号
 * @param ackType 响应消息：1 接受、2 拒绝、3 删除信息
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)umMackWithMsgId:(uint64_t)msgId ackType:(int)ackType success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

#pragma mark 呼叫CALL相关

/**发起呼叫请求(一对一会话)
 * toUid和toAccount至少一个不能等于0或nil
 * @param toUid 对方用户编号
 * @param toAccount 对方用户账号
 * @param existCallId 已存在的会话编号
 * @param umAddress 被邀请用户所在UM连接地址信息
 * @param umKey 进入会话密钥
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)callUser:(uint64_t)toUid toAccount:(NSString*)toAccount existCallId:(uint64_t)existCallId usingAddress:(NSString*)umAddress umKey:(NSString*)umKey success:(void(^)(uint64_t callId))successBlock failure:(void(^)(NSError* error))failureBlock;

/**发起呼叫请求(部门或群组会话)
 * @param depCode 部门或群组编号
 * @param existCallId 已存在的会话编号
 * @param toUid 指定某一个成员,0=不指定
 * @param umAddress 被邀请用户所在UM连接地址信息
 * @param umKey 进入会话密钥
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)callGroup:(uint64_t)depCode existCallId:(uint64_t)existCallId toUid:(uint64_t)toUid usingAddress:(NSString*)umAddress umKey:(NSString*)umKey success:(void(^)(uint64_t callId))successBlock failure:(void(^)(NSError* error))failureBlock;

/**一对一会话转换为讨论组
 * @param toUid 对方用户编号
 * @param existCallId 已存在的会话编号
 * @param umAddress 被邀请用户所在UM连接地址信息
 * @param umKey 进入会话密钥
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)call2TempGroupToUid:(uint64_t)toUid existCallId:(uint64_t)existCallId usingAddress:(NSString*)umAddress umKey:(NSString*)umKey success:(void(^)(uint64_t newCallId))successBlock failure:(void(^)(NSError* error))failureBlock;

/**响应呼叫请求
 * @param callId 会话编号
 * @param accept 是否接受: 1=接受,2=拒绝
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)ackTheCall:(uint64_t)callId accept:(BOOL)accept success:(void(^)(EBServerInfo *umServerInfo, NSString *umKey))successBlock failure:(void(^)(NSError* error))failureBlock;

/**进入会话状况
 * @param callId 会话编号
 * @param depCode 部门或群组编号
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)enterTheCall:(uint64_t)callId depCode:(uint64_t)depCode success:(void(^)(EBServerInfo* cmServerInfo, NSString* cmKey, uint64_t chatId))successBlock failure:(void(^)(NSError* error))failureBlock;

/**退出会话
 * @param callId 会话编号
 * @param hangup 部门或群组编号
 * @Param acceptPush 是否接收推送信息
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)hangupTheCall:(uint64_t)callId hangup:(BOOL)hangup acceptPush:(BOOL)acceptPush success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

///获取所有会话信息
- (NSDictionary*)callInfos;

///获取会话信息
- (EBCallInfo*)callInfoWithCallId:(uint64_t)callId;

/**获取会话信息
 * @param uid 用户编号, 0=不作为查询条件
 * @param account 用户账号, nil=不作为查询条件
 * @param depCode 群组编号, 0=寻找一对一会话, 大于0寻找群组会话
 */
- (EBCallInfo*)callInfoWithUid:(uint64_t)uid Account:(NSString*)account depCode:(uint64_t)depCode;

//清空所有会话信息
- (void)removeAllCallInfo;

/**删除会话信息
 * @param 会话编号
 */
- (void)removeCallInfoWithCallId:(uint64_t)callId;

/**普通会话呼叫流程
 * @param depCode 群组编号
 * @param toUid 被邀请方用户编号，群组会话中可不填(0)
 * @param existCallId 已存在的会话编号
 * @param callKey 呼叫来源Key,用于实现企业呼叫来源限制
 * @param failure 失败后的回调函数
 */
- (void)callFlowWithDepCode:(uint64_t)depCode toUid:(uint64_t)toUid existCallId:(uint64_t)existCallId callKey:(NSString*)callKey failure:(void(^)(NSError *error))failureBlock;;

/**一对一会话转临时讨论组呼叫流程
 * @param toUid 被邀请方用户编号
 * @param existCallId 已存在的会话编号
 * @param callKey 呼叫来源Key,用于实现企业呼叫来源限制
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)callFlow2TempGroupToUid:(uint64_t)toUid existCallId:(uint64_t)existCallId callKey:(NSString*)callKey success:(void(^)(uint64_t newCallId))successBlock failure:(void(^)(NSError *error))failureBlock;


#pragma mark 音视频服务相关
/*!
 @function 请求视频通话
 @discussion 发起视频通话的请求。一对一会话，对方接收到请求并响应接受后，双方再同时上视频；群组会话，申请成功后，不需要等待其他人接受，可以立即上视频。
 @param callId 会话编号
 @param includeVideo 是否包括视频；NO=只有音频，YES=音视频
 @param successBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avRequestWithCallId:(uint64_t)callId includeVideo:(BOOL)includeVideo success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/*!
 @function 响应视频通话的邀请
 @discussion 一对一会话，响应是否接受音视频请求；群组会话，响应是否接收某一成员的视频
 @param callId 会话编号
 @param toUid 响应接收方，一对一会话时可填0
 @param ackType 响应结果
 @param successBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avAckWithCallId:(uint64_t)callId toUid:(uint64_t)toUid ackType:(int)ackType success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/*!
 @function 结束视频通话
 @discussion 一对一会话，视频会话结束；群组会话，当前用户退出视频会话，其他人可继续进行视频会话
 @param callId 会话编号
 @param successBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avEndWithCallId:(uint64_t)callId success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

@end

#pragma mark - UserManagerExt2 用户管理2
///恩布业务用户管理(UM)接口类
@interface ENTBoostClient (UserManagerExt2) <UserManagerDelegate>

#pragma mark 内部方法

//获取资料的旧总版本号并且更新至最新版本号
- (uint64_t)fetchOldInfoVerAndSavingNewInfoVer:(uint64_t)newInfoVer type:(EB_CACHE_VERSION_INFO_TYPE)type;

//EB_MSG_ADD_2_GROUP  有人加入群(部门)-事件处理方法
- (void)msgAdd2GroupHandler:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString *)msgName msgContent:(NSString *)msgContent depCode:(uint64_t)depCode vCard:(EBVCard *)vCard fromServerAddress:(NSString *)fromServerAddress;

//EB_MSG_REMOVE_GROUP  被移出群(部门)-事件处理方法
//EB_MSG_EXIT_GROUP 主动退出群(部门)-事件处理方法
- (void)msgExitGroupHandler:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString *)msgName msgContent:(NSString *)msgContent depCode:(uint64_t)depCode vCard:(EBVCard *)vCard fromServerAddress:(NSString *)fromServerAddress;

//EB_MSG_CALL_2_GRPUP 一对一会话转临时讨论组-事件处理方法
- (void)msgCall2TempGroupHandler:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString *)msgName msgContent:(NSString *)msgContent depCode:(uint64_t)depCode vCard:(EBVCard *)vCard fromServerAddress:(NSString *)fromServerAddress;

//EB_MSG_UPDATE_GROUP  //新增群(部门)或修改群(部门)资料-事件处理方法
- (void)msgUpdateGroupHandler:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString *)msgName msgContent:(NSString *)msgContent depCode:(uint64_t)depCode vCard:(EBVCard *)vCard fromServerAddress:(NSString *)fromServerAddress;

//EB_MSG_DELETE_GROUP  //解散群(部门)-事件处理方法
- (void)msgDeleteGroupHandler:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString *)msgName msgContent:(NSString *)msgContent depCode:(uint64_t)depCode vCard:(EBVCard *)vCard fromServerAddress:(NSString *)fromServerAddress;

/**增加一个“我的消息”的应用消息通知
 * @param msgId 消息编号，如没有填0
 * @param content 内容，如没有填nil
 */
- (void)addNotificationOfMyMessageAppWithMsgId:(uint64_t)msgId content:(NSString*)content;

/**增加一个“广播消息”的应用消息通知
 * @param msgId 消息编号，如没有填0
 * @param msgName 标题
 * @param msgContent 内容
 * @param subType 自定义类型(保留字段)
 */
- (void)addNotificationOfBroadcastMessageAppWithMsgId:(uint64_t)msgId msgName:(NSString*)msgName msgContent:(NSString*)msgContent subType:(int)subType;

/**增加一个“系统通知”
 * @param msgId 消息编号，如没有填0
 * @param content 内容，如没有填nil
 */
- (void)addNotificationOfSysNoticeWithMsgId:(uint64_t)msgId content:(NSString *)content;

//处理删除联系人信息
- (void)handleContactInfoDeleted:(uint64_t)contactId newContactInfoVer:(uint64_t)newContactInfoVer isDeleted:(BOOL)isDeleted success:(void(^)(EBContactInfo* contactInfo))successBlock;

//处理变更联系人信息
- (void)handleContactInfoUpdated:(uint64_t)contactId orContactUid:(uint64_t)contactUid newContactInfoVer:(uint64_t)newContactInfoVer success:(void(^)(EBContactInfo* contactInfo))successBlock failure:(void(^)(NSError* error))failureBlock;

@end

#pragma mark - ChatManagerExt 会话管理
///恩布业务聊天管理(CM)接口类
@interface ENTBoostClient (ChatManagerExt) <ChatManagerDelegate>

/**删除CM连接
 * @param address 连接地址，如192.168.0.1:18012
 */
- (void)removeChatManagerInCMPoolWithAddress:(NSString*)address;

/**进入聊天会话
 * @param callId 会话编号
 * @param chatId 聊天编号
 * @param chatKey 聊天会话KEY
 * @param offUid 被邀请方用户编号(离线时才需要使用)
 * @param depCode 部门或群组代码
 * @param cmAddress CM连接地址信息
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cmEnterWithCallId:(uint64_t)callId chatId:(uint64_t)chatId chatKey:(NSString*)chatKey offUid:(uint64_t)offUid depCode:(uint64_t)depCode usingAddress:(NSString*)cmAddress success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**退出聊天会话
 * @param chatId 聊天编号
 * @param chatKey 聊天会话KEY
 * @param exitSession 是否退出会话, TRUE=退出会话，用于挂断一对一会话,FALSE=离线状况(非挂断会话)
 * @parma acceptPush 是否接收推送信息
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cmExitWithChatId:(uint64_t)chatId chatKey:(NSString*)chatKey exitSession:(BOOL)exitSession acceptPush:(BOOL)acceptPush success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

/**发送富文本信息
 * @param richEntities EBRichEntity实例数组
 * @param richSubType 富文本信息子类型(EB_RICH_SUB_TYPE_JPG =图片模式,EB_RICH_SUB_TYPE_AUDIO=语音模式),图片和语音不可以同一条聊天信息中混发
 * @param callId 会话编号
 * @param toUid 接收方用户编号(如发送至群中所有人时，填0)
 * @param isPrivate 是否私聊(用于群组聊天时)
 * @param begin 开始发送回调函数
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)sendRichInfo:(NSArray*)richEntities richSubType:(EB_RICH_SUB_TYPE)richSubType forCallId:(uint64_t)callId toUid:(uint64_t)toUid isPrivate:(BOOL)isPrivate begin:(void(^)(uint64_t msgId))beginBlock success:(void(^)(uint64_t msgId))successBlock failure:(void(^)(NSError* error))failureBlock;

/**发送文件
 * @param path 文件路径
 * @param fileName 文件名
 * @param callId 会话编号
 * @param toUid 接收方用户编号(如发送至群中所有人时，填0)
 * @param isPrivate 是否私聊(用于群组聊天时)
 * @param offChat 是否传离线文件
 * @param byteSize 文件容量大小(字节)
 * @param md5 md5校验码
 * @param requestBlock 发起发文件请求成功后的回调函数
 * @param beginBlock 开始发送回调函数
 * @param processingBlock 处理中回调函数
 * @param successBlock 成功后回调函数
 * @param offFileExistsBlock 离线文件已存在的回调函数
 * @param cancelBlock 取消发送文件
 * @param failureBlock 失败后回调函数
 */
- (void)sendFileAtPath:(NSString*)path usingFileName:(NSString*)fileName forCallId:(uint64_t)callId toUid:(uint64_t)toUid isPrivate:(BOOL)isPrivate offChat:(BOOL)offChat byteSize:(uint64_t)byteSize md5:(NSString*)md5 request:(void(^)(uint64_t msgId))requestBlock begin:(void(^)(uint64_t msgId))beginBlock processing:(EB_PROCESSING_BLOCK)processingBlock success:(void(^)(uint64_t msgId))successBlock offFileExists:(void(^)(uint64_t msgId))offFileExistsBlock cancel:(void(^)(uint64_t msgId, BOOL initiative))cancelBlock failure:(void(^)(NSError* error))failureBlock;

/**上传资源(文件)
 * @param resId 资源编号
 * @param data 数据对象；(可选)与filePath只能其中一个非nil，不可两个参数同时等于nil
 * @param filePath 数据文件路径；(可选)与data只能其中一个非nil，不可两个参数同时等于nil
 * @param fileByteSize 数据文件大小(字节数)；(可选)与filePath配合使用
 * @param fileName 文件名(可选)
 * @param cmServer CM服务连接信息
 * @param md5 md5校验码(可选)
 * @param requestBlock 发起发文件请求成功后的回调函数
 * @param beginBlock 开始发送回调函数
 * @param processingBlock 处理中回调函数
 * @param successBlock 成功后回调函数
 * @param offFileExistsBlock 离线文件已存在的回调函数
 * @param cancelBlock 取消发送文件
 * @param failureBlock 失败后回调函数
 */
- (void)uploadResource:(uint64_t)resId data:(NSData*)data orFilePath:(NSString*)filePath fileByteSize:(uint64_t)fileByteSize fileName:(NSString*)fileName md5:(NSString*)md5 usingServer:(EBServerInfo*)cmServer request:(void(^)(uint64_t msgId))requestBlock begin:(void(^)(uint64_t msgId))beginBlock processing:(EB_PROCESSING_BLOCK)processingBlock success:(void(^)(uint64_t msgId))successBlock offFileExists:(void(^)(uint64_t msgId))offFileExistsBlock cancel:(void(^)(uint64_t msgId, BOOL initiative))cancelBlock failure:(void(^)(NSError* error))failureBlock;

/**取消发送文件
 * @param msgId 消息编号
 * @param callId 会话编号
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cancelSendingFileWithMsgId:(uint64_t)msgId forCallId:(uint64_t)callId success:(void(^)(void))successBlock failure:(void(^)(NSError* error))failureBlock;

///接收表情资源(内部使用)
- (void)receiveEmotions:(NSDictionary*)emotions cid:(uint32_t)cid onBegin:(void(^)(NSArray* expressions, NSArray* headPhotos))beginBlock onCompletion:(void(^)(NSArray* expressions, NSArray* headPhotos))comletionBlock;

/**下载一个资源文件
 * @param resId 资源编号
 * @param cmAddress cm服务器地址
 * @param confirmMD5 md5验证码
 * @param successBlock 成功后回调函数
        参数：filePaths 资源加载完毕后保存在本地的文件绝对路径
 * @param failureBlock 失败后回调函数
 */
- (void)receiveResourceWithResId:(uint64_t)resId cmAddress:(NSString*)cmAddress confirmMD5:(NSString*)confirmMD5 success:(void(^)(NSString* filePath))successBlock failure:(void(^)(NSError* error))failureBlock;

/**下载多个资源文件
 * @param resourceParams 请求加载资源列表 {key=cmAddress, entity=NSDictionary}
    entity结构：resId 资源编号，cmAddress cm服务器地址，md5 md5验证码
 * @param successBlock 成功后回调函数
        参数：filePaths 资源加载完毕后保存在本地的文件绝对路径，{key=resId[NSNumber], entity=filePath[NSString]}
 * @param failureBlock 失败后回调函数
 */
- (void)receiveResourcesWithResourceParams:(NSDictionary*)resourceParams success:(void(^)(NSDictionary* filePaths))successBlock failure:(void(^)(NSError* error))failureBlock;

@end

#pragma mark - AVManagerExt 音视频服务
@interface ENTBoostClient (AVManagerExt)

/*！开始进行音视频通话
 @function 
 @discussion 开始音视频通话
 @param callId 会话编号
 */
- (void)audioVideoOnlineWithCallId:(uint64_t)callId;

/*! 挂断音视频通话
 @function
 @discussion
 @param callId 会话编号
 @param offline 是否执行用户注销下线。当offline=NO，只取消与会话相关的订阅；当offline=YES，除了取消与会话相关的订阅之外，还执行用户注销下线。
 */
- (void)audioVideoHandOffWithCallId:(uint64_t)callId offline:(BOOL)offline;

/*! 取消对指定用户的订阅
 @function
 @discussion
 @param targetUid 目标用户的编号
 @param callId 会话编号
 */
- (void)audioVideoCancelSinkMember:(uint64_t)targetUid forCallId:(uint64_t)callId;

/*！
 @function
 @discussion 发送音频数据
 @param data 数据内容
 @param callId 会话编号
 @param samplingTime 数据采集时间偏移量
 */
- (void)audioSendData:(NSData*)data samplingTime:(uint32_t)samplingTime forCallId:(uint64_t)callId;


/*! 获取一个接收到的音频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @return 音频数据帧
 */
- (EBRTPFrame*)rtpAudioFrameInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId;

/*! 获取一个接收到的视频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @return 视频数据帧
 */
- (EBRTPFrame*)rtpVideoFrameInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId;

/*! 获取多个接收到的音频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @param limit 返回的最大数量限制
 @return 音频数据帧列表
 */
- (NSArray*)rtpAudioFramesInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId limit:(NSUInteger)limit;

/*! 获取多个接收到的视频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @param limit 返回的最大数量限制
 @return 视频数据帧列表
 */
- (NSArray*)rtpVideoFramesInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId limit:(NSUInteger)limit;

@end

#pragma mark - PersistenceExt 数据库持久化
///数据本地保存功能
@interface ENTBoostClient (PersistenceExt)

///获取一个关于聊天记录的自增长数字
- (uint64_t)sequenceOfTBMessage;

///获取一个关于通知记录的自增长数字
- (uint64_t)sequenceOfTBNotification;

///检测并校正错误数据
- (void)checkAndValidateDBData;

///获取属于当前用户的所有对话归类
- (NSArray*)tbTalks;

/**查询获取tbTalk
 * @param type talk类型
 * @return TBTalk列表
 */
- (NSArray*)tbTalksWithType:(EB_TALK_TYPE)type;

/**查询获取tbTalk
 * @param type talk类型
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBTalk*)tbTalkOfLastWithType:(EB_TALK_TYPE)type createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询获取对话归类
 * @param talkId 对话归类编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBTalk*)tbTalkWithTalkId:(NSString*)talkId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询获取对话归类，depCode、otherUid和otherAccount不可同时等于0或nil；otherUid与otherAccount是or关系
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param otherAccount 对方用户账号(用于一对一会话)
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBTalk*)tbTalkWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid otherAccount:(NSString*)otherAccount createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询获取多个TBTalk会话，depCode、otherUid不可同时等于0
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 */
- (NSArray*)tbTalksWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid;

/**删除对话归类
 * @param talkId 对话归类编号
 */
- (void)deleteTBTalkWithTalkId:(NSString*)talkId;

/**更新对话归类时间字段
 * @param updatedTime 时间
 * @param talkId 对话归类编号
 */
- (void)updateTBTalkWithUpdatedTime:(NSDate*)updatedTime forTalkId:(NSString*)talkId;

/**更新对话归类头像图标文件路径
 * @param iconFile 头像图标文件路径
 * @param talkId 对话归类编号
 */
- (void)updateTBTalkWithIconFile:(NSString*)iconFile forTalkId:(NSString*)talkId;

/**新增或更新对话归类
 * @param callInfo 会话实例
 */
- (void)saveOrUpdateTBTalkWithCallInfo:(EBCallInfo*)callInfo;

/**新增或更新对话归类
 * depCode与otherUid不可同时等于0
 * @param depCode 部门或群组编号
 * @param depName 部门或群组名称
 * @param otherUid 对方用户编号
 * @param otherAccount 对方账号
 * @param otherUserName 对方名称
 * @parma otherEmpCode 对方成员编号
 * @param callId 会话编号
 */
- (TBTalk*)saveOrUpdateTBTalkWithDepCode:(uint64_t)depCode depName:(NSString*)depName otherUid:(uint64_t)otherUid otherAccount:(NSString*)otherAccount otherUserName:(NSString*)otherUserName otherEmpCode:(uint64_t)otherEmpCode callId:(uint64_t)callId;

/**新增或更新对话归类，depCode、otherUid和otherAccount不可同时等于0或nil
    用于聊天对话的talk
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param otherAccount 对方用户账号(用于一对一会话)
 * @param otherUserName 对方用户名(用于一对一会话)
 * @param otherEmpCode 对方成员编号(用于一对一会话)
 * @param successBlock 成功时调用的block
 * @param failureBlock 失败时调用的block
 */
- (void)insertOrUpdateTBTalkWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid otherAccount:(NSString*)otherAccount otherUserName:(NSString*)otherUserName otherEmpCode:(uint64_t)otherEmpCode success:(void(^)(TBTalk* tbTalk))successBlock failure:(void(^)(NSError* error))failureBlock;

/**新增或更新对话归类
    用于非聊天对话的talk
 * @param type talk类型
 * @param talkName talk名称
 * @return TBTalk实例
 */
- (TBTalk*)insertOrUpdateTBTalkWithType:(EB_TALK_TYPE)type talkName:(NSString*)talkName;

#pragma mark - TBNotification

/**获取通知信息
 * @param notiId 通知编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return 通知信息实例
 */
- (TBNotification*)tbNotificationWithNotiId:(uint64_t)notiId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**获取通知信息
 * @param talkId 聊天编号，当talkId!=nil时有效
 * @param value 值，当value!=0时有效
 * @param value1 值1，当value1!=0时有效
 * @return 通知信息实例，如果有多个，返回第一个
 */
- (TBNotification*)tbNotificationWithTalkId:(NSString*)talkId value:(uint64_t)value value1:(uint64_t)value1;

/**获取通知信息列表
 * @param talkId 聊天编号，不能为空
 * @param beginTime 时间范围开始，nil=忽略条件
 * @param endTime 时间范围结束，nil=忽略条件
 * @param perPageSize 返回结果最大记录数量(分页)，0=忽略条件
 * @param currentPage 当前页码(从1开始)，必须大于0
 * @param orderByTimeAscending 是否按时间升序排序(最早的排前面)
 * @param checkReaded 是否检查已读状态
 * @param isReaded 是否已读
 * @return 通知信息实例列表
 */
- (NSArray*)tbNotificationsWithTalkId:(NSString*)talkId andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime perPageSize:(NSUInteger)perPageSize currentPage:(NSUInteger)currentPage orderByTimeAscending:(BOOL)orderByTimeAscending checkReaded:(BOOL)checkReaded isReaded:(BOOL)isReaded;

/**获取未读的通知信息数量
 * @param talkId 聊天编号
 * @return 通知信息数量
 */
- (NSUInteger)countOfUnreadTBNotificationsWithTalkId:(NSString*)talkId;

///拥有未读通知的Talk数量
- (NSUInteger)countOfTalksHavingUnreadTBNotification;

/**删除通知信息
 * @param talkId 聊天编号
 */
- (void)deleteTBNotificationsWithTalkId:(NSString*)talkId;

/**设置通知信息已读状态(单条)
 * @param notiId 通知编号
 */
- (void)markTBNotificationAsReadedWithNotiId:(uint64_t)notiId;

/**设置通知信息已读状态(多条)
 * @param talkId 聊天编号
 */
- (void)markTBNotificationsAsReadedWithTalkId:(NSString*)talkId;

/**新建或更新通知消息
 * @param notiId 通知编号，等于0或对应记录不存在时新建
 * @param talkId 聊天编号，不能为空
 * @param isReaded 是否已读
 * @param value 值(数字)
 * @param value1 值1(数字)
 * @param content 内容
 * @param content1 内容1
 * @return TBNotification实例
 */
- (TBNotification*)saveOrUpdateTBNotificationWithNotiId:(uint64_t)notiId talkId:(NSString*)talkId isReaded:(BOOL)isReaded value:(uint64_t)value value1:(uint64_t)value1 content:(NSString*)content content1:(NSString*)content1;

#pragma mark - TBCall
/**查询获取会话信息
 * @param callId 会话编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBCall实例
 */
- (TBCall*)tbCallWithCallId:(uint64_t)callId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;
///新增或更新会话信息
- (void)saveOrUpdateTBCall:(const EBCallInfo*)callInfo;
///删除会话信息
- (void)deleteTBCallWithCallId:(uint64_t)callId;


#pragma mark - TBMessage
/**查询获取符合条件的聊天记录数量
 * @param talkId 对话归类编号
 * @param beginTime 聊天记录发生时间范围下限
 * @param endTime 聊天记录发生时间范围上限
 * @return 聊天记录数量
 */
- (NSUInteger)countOfTBMessagesWithTalkId:(NSString*)talkId andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime;

/**查询获取符合条件的聊天记录数量
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param beginTime 聊天记录发生时间范围下限
 * @param endTime 聊天记录发生时间范围上限
 * @return 聊天记录数量
 */
- (NSUInteger)countOfTBMessagesWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime;

/**查询获取符合条件的聊天记录
 * (TBMessage内部结构)
 * @param talkId 对话归类编号
 * @param beginTime 聊天记录发生时间范围下限
 * @param endTime 聊天记录发生时间范围上限
 * @param perPageSize 每页数量
 * @param currentPage 当前页(从1开始算)
 * @param orderByTimeAscending 是否按聊天记录发生时间升序进行排序
 * @return TBMessage实例数组
 */
- (NSArray*)tbMessagesWithTalkId:(NSString*)talkId andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime perPageSize:(NSUInteger)perPageSize currentPage:(NSUInteger)currentPage orderByTimeAscending:(BOOL)orderByTimeAscending;

/**查询获取符合条件的聊天记录
 * (TBMessage内部结构)
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param beginTime 聊天记录发生时间范围下限
 * @param endTime 聊天记录发生时间范围上限
 * @param perPageSize 每页数量
 * @param currentPage 当前页(从1开始算)
 * @param orderByTimeAscending 是否按聊天记录发生时间升序进行排序
 * @return TBMessage实例数组
 */
- (NSArray*)tbMessagesWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime perPageSize:(NSUInteger)perPageSize currentPage:(NSUInteger)currentPage orderByTimeAscending:(BOOL)orderByTimeAscending;

/**查询获取符合条件的聊天记录(TBMessage内部结构)
 * @param messageId 消息编号，用于定位记录位置
 * @param orderByTimeAscending 是否按聊天记录发生时间升序进行排序；NO=降序排序(回头查询)，YES=升序排序
 * @param perPageSize 结果集最大返回数量
 * @return TBMessage实例数组
 */
- (NSArray*)tbMessagesFromLastMessageId:(uint64_t)messageId orderByTimeAscending:(BOOL)orderByTimeAscending perPageSize:(NSUInteger)perPageSize;

/**获取对应各talk最新一条聊天记录
 * @param talkIds talk编号队列
 * @return TBMessage实例队列
 */
- (NSArray*)lastTBMessagesWithTalkIds:(NSArray*)talkIds;

/**查询获取多个聊天记录
 * @param messageIds 消息编号数组, NSNumber实例
 * @return TBMessage实例数组
 */
- (NSArray*)tbMessagesWithMessageIds:(NSArray*)messageIds;

/**查询获取单个聊天记录
 * @param messageId 消息编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBMessage*)tbMessageWithMessageId:(uint64_t)messageId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询获取单个聊天记录
 * @param tagId 标识编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBMessage*)tbMessageWithTagId:(uint64_t)tagId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**新增或更新聊天记录
 * @param messageId 信息编号
 * @param tagId 标识编号
 * @param isUsingTag 是否使用tagId进行查找聊天记录
 * @param callId 会话编号
 * @param fromUid 信息发起人
 * @param msgTime 信息发起时间
 * @param fileName 文件名
 * @param filePath 文件保存路径(发送/接收文件)
 * @param byteSize 信息内容大小(字节数)
 * @param md5 md5验证码
 * @param isPrivate 是否私聊
 * @param acked 是否已应答(决定是否接收)
 * @param waittingAck 是否正在等待响应接收文件
 * @param isSent 是否已经发送成功
 * @param isSentFailure 是否发送失败
 * @param isReaded 是否已读状态
 * @param offChat 是否离线信息
 * @param msgType 消息类型
 * @param richSubType 富文本消息类型
 * @return 保存在数据库后的实例
 */
- (TBMessage*)saveOrUpdateTBMessage:(uint64_t)messageId tagId:(uint64_t)tagId searchUsingTag:(BOOL)isUsingTag callId:(uint64_t)callId fromUid:(uint64_t)fromUid msgTime:(NSDate*)msgTime fileName:(NSString*)fileName filePath:(NSString*)filePath byteSize:(uint64_t)byteSize md5:(NSString*)md5 isPrivate:(BOOL)isPrivate acked:(BOOL)acked waittingAck:(BOOL)waittingAck isSent:(BOOL)isSent isSentFailure:(BOOL)isSentFailure isReaded:(BOOL)isReaded offChat:(BOOL)offChat msgType:(enum EB_MSG_TYPE)msgType richSubType:(enum EB_RICH_SUB_TYPE)richSubType;

///删除单个聊天记录
- (void)deleteTBMessageWithMessageId:(uint64_t)messageId;

///删除单个聊天记录
- (void)deleteTBMessageWithTagId:(uint64_t)tagId;

/*删除多个聊天记录
 * @param messageIds 消息编号数组
 */
- (void)deleteTBMessagesWithMessageIds:(NSArray*)messageIds;

/**删除多个聊天记录
 * @param talkId 对话归类编号
 */
- (void)deleteTBMessagesWithTalkId:(NSString*)talkId;

/**设置消息的messageId
 * messageId和tagId都不可以等于0
 * @param messageId 信息编号，将被设置的值
 * @param tagId 标识编号，查询条件
 */
- (void)setTBMessageId:(uint64_t)messageId searchWithTagId:(uint64_t)tagId;

/**把聊天记录的talkId换成另外一个
 * @param fromTalkId 原聊天会话编号
 * @param toTalkId 目标聊天会话编号
 */
- (void)changeTBMessageFormTalkId:(NSString*)fromTalkId toTalkId:(NSString*)toTalkId;

///查询未读聊天记录的数量(与talkId无关)
- (NSUInteger)countOfUnreadTBMessages;

/**查询未读聊天记录的数量
 * @param talkId 对话归类编号
 */
- (NSUInteger)countOfUnreadTBMessagesWithTalkId:(NSString*)talkId;

///分组查询未读聊天记录的数量
- (NSArray*)countArrayOfUnreadTBMessagesGroupByTalkId;

///拥有未读聊天记录的对话归类数量
- (NSUInteger)countOfTalksHavingUnreadTBMessage;

/**标记单个聊天记录已读状态
 * @param messageId 消息编号
 */
- (void)markTBMessageAsReadedWithMessageId:(uint64_t)messageId;

/**标记多个聊天记录为已读状态
 * @param talkId 对话归类编号
 */
- (void)markTBMessagesAsReadedWithTalkId:(NSString*)talkId;

///标记所有聊天记录为已读状态
- (void)markAllTBMessagesAsReaded;

/**设置信息(聊天记录)发送状态
 messageId和tagId不可以都等于0
 * @param successState YES=成功：更新isSent=YES和isSendFailure=NO；NO=失败：更新isSent=NO和isSendFailure=YES
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageSentState:(BOOL)successState forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)离线文件资源字符串
 messageId和tagId不可以都等于0
 * @param resourceString 资源字符串
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageResourceString:(NSString*)resourceString forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)是否已应答(决定是否接收文件)
 messageId和tagId不可以都等于0
 * @param acked 是否已应答
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageAcked:(BOOL)acked forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)是否正在等待应答
 messageId和tagId不可以都等于0
 * @param waittingAck 是否正在等待应答
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageWaittingAcked:(BOOL)waittingAck forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)是否拒绝接收
 messageId和tagId不可以都等于0
 * @param rejected 是否拒绝接收
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageRejected:(BOOL)rejected forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)取消状态
 messageId和tagId不可以都等于0
 * @param cancelled 是否取消接收
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageCancelled:(BOOL)cancelled forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)已上传离线文件
 messageId和tagId不可以都等于0
 * @param uploaded 是否已上传离线文件
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageUploaded:(BOOL)uploaded forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)完成百分比
 messageId和tagId不可以都等于0
 * @param percentCompletion 完成百分比
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessagePercentCompletion:(double_t)percentCompletion forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)文件保存路径(相对路径)
 messageId和tagId不可以都等于0
 * @param savedRelativeFilePath 文件保存路径(相对路径)
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageSavedRelativeFilePath:(NSString*)savedRelativeFilePath forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)文件临时保存路径(相对路径)
 messageId和tagId不可以都等于0
 * @param tempRelativeFilePath 文件临时保存路径(相对路径)
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageTempRelativeFilePath:(NSString*)tempRelativeFilePath forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置信息(聊天记录)文件名
 messageId和tagId不可以都等于0
 * @param fileName 接收文件名
 * @param messageId 消息编号
 * @param tagId 标识编号
 */
- (void)setTBMessageFileName:(NSString*)fileName forMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;
#pragma mark - TBChatDot

/**查询获取某个聊天记录中的分块(单个)
 * @param tagId 标识编号
 * @param seq 分块顺序号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBChatDot*)tbChatDotWithTagId:(uint64_t)tagId sequence:(short)seq createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询获取某个聊天记录中的分块(单个)
 * @param messageId 消息编号
 * @param seq 分块顺序号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBChatDot*)tbChatDotWithMessageId:(uint64_t)messageId sequence:(short)seq createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

///查询获取某个聊天记录中的分块(多个)
- (NSArray*)tbChatDotsWithTagId:(uint64_t)tagId;

///查询获取某个聊天记录中的分块(多个)
- (NSArray*)tbChatDotsWithMessageId:(uint64_t)messageId;

/**删除某个聊天记录中的全部分块
 * 两个条件不可以同时等于0，都不等于0时优先使用messageId
 * @param messageId 消息编号 0=忽略
 * @param tagId 标识编号 0=忽略
 */
- (void)deleteTBChatDotsWithMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId;

/**设置聊天记录分块messageId字段值
 * @param messageId 消息编号，将要设置的值
 * @param tagId 标识编号，查询条件
 */
- (void)setTBChatDotMessageId:(uint64_t)messageId withTagId:(uint64_t)tagId;

/**新增或更新聊天记录中的分块(异步非阻塞模式)
 * 两个条件不可以同时等于0，都不等于0时优先使用messageId
 * @param messageId 消息编号 0=忽略
 * @param tagId 标识编号 0=忽略
 * @param seq 分块顺序号
 * @param ebChat 分块内容
 * @param completionBlock 完成后回调
 */
- (void)saveOrUpdateTBChatDotWithMessageId:(uint64_t)messageId orTagId:(uint64_t)tagId sequence:(short)seq ebChat:(EBChat*)ebChat onCompletion:(void(^)(NSError* error))completionBlock;

#pragma mark - TBLogonProperty
/**查询获取一个登录信息
 * @param identification 身份识别(账号、UID等)
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 */
- (TBLogonProperty*)tbLogonPropertyWithIdentification:(NSString*)identification createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**新增或更新登录信息
 * @param identification 身份识别(账号、UID等)
 * @param oauthKey 自动登录验证令牌，客户端主动创建，可长时间有效
 * @return TBLogonProperty实例
 */
- (TBLogonProperty*)insertOrUpdateTBLogonPropertyWithIdentification:(NSString*)identification oauthKey:(NSString*)oauthKey;

/**获取登录信息中的自动登录验证令牌
 * @param identification 身份识别(账号、UID等)
 */
- (NSString*)oauthKeyOfTBLogonPropertyWithIdentification:(NSString*)identification;

/**删除一个登录信息
 * @param identification 身份识别(账号、UID等)
 */
- (void)deleteTBLogonPropertyWithIdentification:(NSString*)identification;

/**查询获取多个登录信息
 * @param ascending 按更新时间升序排序, YES=升序, NO=降序
 * @return NSString实例数组
 */
- (NSArray*)identificationsOfTBLogonPropertyAscending:(BOOL)ascending;

#pragma mark - message

/**查询获取聊天记录
 * (EBMessage结构封装)
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param beginTime 聊天记录发生时间范围下限
 * @param endTime 聊天记录发生时间范围上限
 * @param perPageSize 每页数量
 * @param currentPage 当前页(从1开始算)
 * @param orderByTimeAscending 按聊天记录发生时间升序进行排序
 * @return EBMessage实例数组
 */
- (NSArray*)messagesWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime perPageSize:(NSUInteger)perPageSize currentPage:(NSUInteger)currentPage orderByTimeAscending:(BOOL)orderByTimeAscending;

/**查询获取聊天记录
 * (EBMessage结构封装)
 * @param talkId 对话归类编号
 * @param beginTime 聊天记录发生时间范围下限
 * @param endTime 聊天记录发生时间范围上限
 * @param perPageSize 每页数量
 * @param currentPage 当前页(从1开始算)
 * @param orderByTimeAscending 按聊天记录发生时间升序进行排序
 * @return EBMessage实例数组
 */
- (NSArray*)messagesWithTalkId:(NSString*)talkId andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime perPageSize:(NSUInteger)perPageSize currentPage:(NSUInteger)currentPage orderByTimeAscending:(BOOL)orderByTimeAscending;

/**查询获取符合条件的聊天记录
 * (EBMessage内部结构)
 * @param messageId 消息编号，用于定位记录位置
 * @param orderByTimeAscending 是否按聊天记录发生时间升序进行排序；NO=降序排序(回头查询)，YES=升序排序
 * @param perPageSize 结果集最大返回数量
 * @return EBMessage实例数组
 */
- (NSArray*)messagesFromLastMessageId:(uint64_t)messageId orderByTimeAscending:(BOOL)orderByTimeAscending perPageSize:(NSUInteger)perPageSize;

/**获取各talk对应最新一条聊天记录
 * @param talkIds talk编号队列
 * @return EBMessage实例结果集 {key=talkId, value=EBMessage}
 */
- (NSDictionary*)lastMessagesWithTalkIds:(NSArray*)talkIds;

/**查询获取多个聊天记录
 * @param messageIds 消息编号数组, NSNumber实例
 * @return EBMessage实例数组
 */
- (NSArray*)messagesWithMessageIds:(NSArray*)messageIds;

/**查询获取单条聊天记录
 * (EBMessage结构封装)
 * @param messageId 消息编号
 * @return EBMessage实例数组
 */
- (EBMessage*)messageWithMessageId:(uint64_t)messageId;

/**查询获取单条聊天记录
 * (EBMessage结构封装)
 * @param tagId 标记编号
 * @return EBMessage实例数组
 */
- (EBMessage*)messageWithTagId:(uint64_t)tagId;

/**聊天记录转换为普通对象
 * @param tbMessage 持久化的聊天记录实例
 */
- (EBMessage*)messageWithTBMessage:(TBMessage*)tbMessage;

/**删除单条聊天记录
 * @param messageId 消息编号
 */
- (void)deleteMessageWithMessageId:(uint64_t)messageId;

/**删除单条聊天记录
 * @param tagId 标记编号
 */
- (void)deleteMessageWithTagId:(uint64_t)tagId;

/**删除多条聊天记录
 * @param messageIds 消息编号数组
 */
- (void)deleteMessagesWithMessageIds:(NSArray*)messageIds;

/**删除多条聊天记录
 * @param messageIds 对话归类编号
 */
- (void)deleteMessagesWithTBTalkId:(NSString*)talkId;

#pragma mark - Talk
/**获取所有对话归类
 * @return EBTalk数组
 */
- (NSArray*)talks;

/**查询获取对话归类
 * @param talkId 对话归类编号
 * @return EBTalk实例
 */
- (EBTalk*)talkWithTalkId:(NSString*)talkId;

/**查询获取对话归类，depCode、otherUid和otherAccount不可同时等于0或nil
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param otherAccount 对方用户账号(用于一对一会话)
 * @return EBTalk实例
 */
- (EBTalk*)talkWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid otherAccount:(NSString*)otherAccount;

/**查询获取Talk列表
 * @param type 类型
 * @param EBTalk列表
 */
- (NSArray*)talksWithType:(EB_TALK_TYPE)type;

/**新增或更新对话归类，depCode、otherUid和otherAccount不可同时等于0或nil
 * @param depCode 部门或群组编号(用于用户群组会话, 大于0表示群组会话)
 * @param otherUid 对方用户编号(用于一对一会话)
 * @param otherAccount 对方用户账号(用于一对一会话)
 * @param otherUserName 对方用户名(用于一对一会话)
 * @param otherEmpCode 对方成员编号(用于一对一会话)
 * @param successBlock 成功时调用的block
 * @param failureBlock 失败时调用的block
 */
- (void)insertOrUpdateTalkWithDepCode:(uint64_t)depCode otherUid:(uint64_t)otherUid otherAccount:(NSString*)otherAccount otherUserName:(NSString*)otherUserName otherEmpCode:(uint64_t)otherEmpCode success:(void(^)(EBTalk* talk))successBlock failure:(void(^)(NSError* error))failureBlock;

#pragma mark - Notification

/**获取通知列表
 * @param talkId talk编号
 * @param EBNotification列表
 */
- (NSArray*)notificationsWithTalkId:(NSString*)talkId;

/**获取通知信息
 * @param notiId 通知 编号
 * @param EBNotification实例
 */
- (EBNotification*)notificationWithId:(uint64_t)notiId;

@end


#pragma mark - PersistenceExt2 数据库持久化2
///数据本地保存功能2
@interface ENTBoostClient (PersistenceExt2)
#pragma mark - TBCacheVersion
/**查询获取一个缓存版本对象
 * @param code 编号
 * @param type 版本类型
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBCacheVersion实例
 */
- (TBCacheVersion*)tbCacheVersionWithCode:(uint64_t)code type:(EB_CACHE_VERSION_INFO_TYPE)type createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**查询获取缓存版本对象列表
 * @param code 编号
 * @return TBCacheVersion实例列表
 */
- (NSArray*)tbCacheVersionsWithCode:(uint64_t)code;

/*新增或更新缓存版本对象
 * @param code 编号
 * @param type 版本类型
 * @param version 版本
 * @param description 描述
 * @param value 数值
 * @return 新增或已存在的TBCacheVersion实例
 */
- (TBCacheVersion*)saveOrUpdateTBCacheVersion:(uint64_t)code type:(EB_CACHE_VERSION_INFO_TYPE)type version:(uint64_t)version description:(NSString*)description value:(uint64_t)value;

/**删除一个缓存版本对象
 * @param code 编号
 * @param type 版本类型
 */
- (void)deleteTBCacheVersionWithCode:(uint64_t)code type:(EB_CACHE_VERSION_INFO_TYPE)type;

/**更新缓存加载状态
 * @param code 编号
 * @param type 本地缓存资料版本类型
 * @param loaded 加载状态
 */
- (void)updateTBCacheVersionWithCode:(uint64_t)code andType:(EB_CACHE_VERSION_INFO_TYPE)type loadedState:(BOOL)loaded;

/**更新缓存加载状态
 * @param code 编号
 * @param loaded 加载状态
 */
- (void)updateTBCacheVersionWithCode:(uint64_t)code loadedState:(BOOL)loaded;

#pragma mark - TBGroupInfo

/**以当前用户某个成员编号查询对应的部门或群组编号
 * @param empCode 成员编号
 * @return 部门或群组编号
 */
- (uint64_t)depCodeWithMyEmpCode:(uint64_t)empCode;

/**在本地缓存查询获取多个部门或群组对象
 * @param isEntGroup YES=获取部门信息，NO=获取群组信息
 * @return TBGroupInfo实例的数组
 */
- (NSArray*)tbGroupInfos:(BOOL)isEntGroup;

/**在本地缓存获取全部部门或群组编号
 * @param isEntGroup YES=获取部门编号，NO=获取群组编号
 * @return depCode的数组
 */
- (NSArray*)depCodes:(BOOL)isEntGroup;

/**获取某部门下的子部门数量 - 缓存读取
 * @param parentDepcode 上级部门编号
 * @return 子部门数量
 */
- (NSUInteger)countOfSubGroupInfos:(uint64_t)parentDepcode;

/**获取某部门下的子部门数量 - 缓存读取
 * @param parentDepcode 上级部门编号
 * @return 子部门列表
 */
- (NSArray*)subGroupInfos:(uint64_t)parentDepcode;

/**在本地缓存查询获取一个部门或群组对象
 * @param depCode 部门或群组编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBGroupInfo实例
 */
- (TBGroupInfo*)tbGroupInfoWithDepCode:(uint64_t)depCode createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**在本地缓存删除一个部门或群组对象
 * @param depCode 部门或群组编号
 */
- (void)deleteTBGroupInfoWithDepCode:(uint64_t)depCode;

/**在本地缓存删除多个部门或群组对象
 * @param depCodes 部门或群组编号数组
 */
- (void)deleteTBGroupInfosWithDepCodes:(NSArray*)depCodes;

/**在本地缓存新增或更新一个部门或群组对象
 * @param ebGroupInfo 部门或群组对象
 * @return TBGroupInfo实例
 */
- (TBGroupInfo*)saveOrUpdateTBGroupInfoWithEBGroupInfo:(EBGroupInfo*)ebGroupInfo;

/**在本地缓存新增或更新多个部门或群组对象
 * @param ebGroupInfos 包含部门或群组实例的数组
 */
- (void)saveOrUpdateTBGroupInfosWithEBGroupInfos:(NSDictionary*)ebGroupInfos;

/**在本地缓存更新部门或群组加载状态
 * @param depCode 部门或群组编号
 * @param loaded 加载状态
 */
- (void)updateTBGroupInfoWithDepCode:(uint64_t)depCode loadedState:(BOOL)loaded;

/**在本地缓存更新部门或群组加载状态和版本号
 * @param depCode 部门或群组编号
 * @param verNo 版本号
 * @param loaded 加载状态
 */
- (void)updateTBGroupInfoWithDepCode:(uint64_t)depCode versionNo:(uint64_t)verNo loadedState:(BOOL)loaded;

///**在本地缓存更新部门或群组成员资料版本号
// * @param depCode 部门或群组编号
// * @param verNo 版本号
// */
//- (void)updateTBGroupInfoVerWithDepCode:(uint64_t)depCode verNo:(uint64_t)verNo;

/**在本地缓存更新部门或群组的版本号
 * @param depCode 部门或群组编号
 * @param verNo 版本号
 * @param stepOneBlock 当新旧版本仅相差1，该block将被回调；该block的返回值如果如果等于NO，表示让本方法加载部门或群组下成员信息，反之则不加载；如果该block传入nil，默认执行加载成员信息
 * @param noUpdatedBlock 判断为没有版本更新时的回调函数
 */
- (void)checkAndUpdateTBGroupInfoWithDepCode:(uint64_t)depCode versionNo:(uint64_t)verNo stepOneBlock:(BOOL(^)(void))stepOneBlock noUpdatedBlock:(void(^)(void))noUpdatedBlock;

/**在本地缓存更新多个部门或群组的版本号
 * @param verNos 多个版本号 {key=depCode[NSNumber], entity=verNo[NSNumber]}
 */
- (void)checkAndUpdateTBGroupInfoWithVersionNosData:(NSDictionary*)verNos;

#pragma mark - TBMemberInfo
/**在本地缓存查询获取一个成员信息
 * @param empCode 成员编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBMemberInfo实例
 */
- (TBMemberInfo*)tbMemberInfoWithEmpCode:(uint64_t)empCode createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**在本地缓存查询获取多个成员信息
 * @param empCodes 成员编号列表
 * @return TBMemberInfo实例列表
 */
- (NSArray*)tbMemberInfosWithEmpCodes:(NSArray*)empCodes;

/**在本地缓存查询获取一个成员信息
 * uid和depCode都不可以等于0
 * @param uid 用户编号
 * @param depCode 部门或群组编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBMemberInfo实例
 */
- (TBMemberInfo*)tbMemberInfoWithUid:(uint64_t)uid depCode:(uint64_t)depCode createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**在本地缓存查询获取多个成员信息
 * @param depCode 部门或群组编号
 * @return TBMemberInfo实例数组
 */
- (NSArray*)tbMemberInfosWithDepCode:(uint64_t)depCode;

/**在本地缓存查询获取多个只包含ObjectID的成员对象
 * @param depCode 部门或群组编号
 * @return 只包含ObjectID的对象数组
 */
- (NSArray*)objectsJustHavingIDOfTBMemberInfosWithDepCode:(uint64_t)depCode;

/**在本地缓存删除一个成员信息
 * @param empCode 成员编号
 */
- (void)deleteTBMemberInfoWithEmpCode:(uint64_t)empCode;

/**在本地化缓存删除多个成员信息
 * @param depCode 部门或群组编号
 */
- (void)deleteTBMemberInfosWithDepCode:(uint64_t)depCode;

/**在本地缓存新增或更新成员信息对象
 * @param ebMemberInfo 成员信息
 * @return TBMemberInfo实例
 */
- (TBMemberInfo*)saveOrUpdateTBMemberInfoWithEBMemberInfo:(EBMemberInfo*)ebMemberInfo;

/**在本地缓存新增或更新多个成员信息对象
 * @param ebMemberInfos 成员信息列表
 * @param depCode 成员所属部门(群组)。当=0表示不检验；当>0表示检验缓存内同部门(群组)内成员数量，如缓存内记录不包括在ebMemberInfos列表中，则删除缓存内该记录
 */
- (void)saveOrUpdateTBMemberInfosWithEBMemberInfos:(NSArray*)ebMemberInfos depCode:(uint64_t)depCode;


#pragma mark - TBEmotion

/**在本地缓存查询获取表情、头像资源数据
 * @param resId 资源编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBEmotion实例
 */
- (TBEmotion*)tbEmotionWithResId:(uint64_t)resId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**在本地缓存查询获取全部表情、头像数据
 * @return TBEmotion实例数组
 */
- (NSArray*)tbEmotions;

/**在本地缓存查询获取多个表情、头像数据
 * @param resourceType 资源类型；(只支持EB_RESOURCE_HEAD和EB_RESOURCE_EMOTION)
 * @param entCode 企业编号；(注意：这里0并不代表忽略条件，而代表真正entCode==0，表示全局通用)
 * @param emoClass 分类
 * @return TBEmotion实例数组
 */
- (NSArray*)tbEmotionsWithResouceType:(EB_RESOURCE_TYPE)resourceType entCode:(uint64_t)entCode emoClass:(uint64_t)emoClass;

/**在本地缓存查询获取多个表情、头像数据(对象只包含ObjectID)
 * @param resourceType 资源类型；(只支持EB_RESOURCE_HEAD和EB_RESOURCE_EMOTION)
 * @param entCode 企业编号；(注意：这里0并不代表忽略条件，而代表真正entCode==0，表示全局通用)
 * @param emoClass 分类
 * @return 只包含ObjectID属性的TBEmotion对象数组
 */
- (NSArray*)objectsJustHavingIDOfTBEmotionsWithResouceType:(EB_RESOURCE_TYPE)resourceType entCode:(uint64_t)entCode emoClass:(uint64_t)emoClass;

/**在本地缓存查询获取所有表情、头像数据(对象只包含ObjectID)
 * @return 只包含ObjectID属性的TBEmotion对象数组
 */
- (NSArray*)objectsJustHavingIDOfTBEmotions;

/**在本地缓存删除一个表情、头像数据
 * @param resId 资源编号
 */
- (void)deleteTBEmotionWithResId:(uint64_t)resId;

/**在本地缓存查询删除多个表情、头像数据
 * @param resourceType 资源类型；(只支持EB_RESOURCE_HEAD和EB_RESOURCE_EMOTION)
 * @param entCode 企业编号；(注意：这里0并不代表忽略条件，而代表真正entCode==0，表示全局通用)
 * @param emoClass 分类
 */
- (void)deleteAllTBEmotionsWithResouceType:(EB_RESOURCE_TYPE)resourceType entCode:(uint64_t)entCode emoClass:(uint64_t)emoClass;

///删除本地缓存里全部表情、头像数据
- (void)deleteAllTBEmotions;

/**在本地缓存新增或更新表情、头像数据
 * @param ebEmotionInner 表情、头像实例对象
 * @return TBEmotion实例
 */
- (TBEmotion*)saveOrUpdateTBEmotionWithEBEmotionInner:(EBEmotionInner*)ebEmotionInner;

/**在本地缓存新增或更新多个表情、头像数据
 * @param ebEmotionInners 表情、头像实例列表
 */
- (void)saveOrUpdateTBEmotionsWithEBEmotionInners:(NSArray*)ebEmotionInners;

/**设置某个表情、头像实体接收完成情况
 * @param isReceivedComplete 是否接收完成
 * @param resId 资源编号
 */
- (void)updateTBEmotionWithIsReceivedComplete:(BOOL)isReceivedComplete forResId:(uint64_t)resId;

#pragma mark - EBEmotionInner

/**在本地缓存查询获取一个表情、头像数据
 * @param resId 资源编号
 * @return EBEmotionInner实例
 */
- (EBEmotionInner*)emotionInnerWithResId:(uint64_t)resId;

/**在本地缓存查询获取多个表情、头像数据
 * @param resourceType 资源类型；(只支持EB_RESOURCE_HEAD和EB_RESOURCE_EMOTION)
 * @param entCode 企业编号；(注意：这里0并不代表忽略条件，而代表真正entCode==0，表示全局通用)
 * @param emoClass 分类(0=忽略此条件)
 * @return EBEmotionInner列表
 */
- (NSArray*)emotionInnersWithResouceType:(EB_RESOURCE_TYPE)resourceType entCode:(uint64_t)entCode emoClass:(uint64_t)emoClass;


#pragma mark - TBContactInfo

/**在本地缓存查询获取一个联系人信息
 * @param contactId 联系人编号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBContactInfo实例
 */
- (TBContactInfo*)tbContactInfoWithId:(uint64_t)contactId createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**在本地缓存查询获取一个联系人信息
    uid和account至少一个不等于0或nil
 * @param uid 联系人的用户编号
 * @param account 联系人的用户账号
 * @param createOne 如果查询结果没有记录，是否自动创建一个新的记录
 * @param atomicityBlock 使用context相同线程执行的同一原子操作block；参数object为新对象，应该在此block内进行对象赋值
 * @return TBContactInfo实例
 */
- (TBContactInfo*)tbContactInfoWithUid:(uint64_t)uid orAccount:(NSString*)account createOneIfNotexists:(BOOL)createOne atomicityBlock:(void(^)(id object))atomicityBlock;

/**在本地缓存查询获取全部联系人信息
 * @return TBContactInfo实例数组
 */
- (NSArray*)tbContactInfos;

/**在本地缓存获取全部联系人编号
 * @return contactId的数组
 */
- (NSArray*)contactIds;

/**在本地缓存查询获取多个联系人信息
 * @param groupId 联系人分组编号；(注意：这里0并不代表忽略条件，而代表真正groupId==0)
 * @return TBContactInfo实例数组
 */
- (NSArray*)tbContactInfosWithGroupId:(uint64_t)groupId;

/**在本地缓存查询获取多个联系人对象(只包含ObjectID)
 * @param groupId 联系人分组编号
 * @return 只包含ObjectID的对象数组
 */
- (NSArray*)objectsJustHavingIDOfTBContactInfosWithGroupId:(uint64_t)groupId;

/**在本地缓存查询获取全部联系人对象(只包含ObjectID)
 * @return 只包含ObjectID的对象数组
 */
- (NSArray*)objectsJustHavingIDOfTBContactInfos;

/**在本地缓存删除一个联系人信息
 * @param contactId 联系人编号
 */
- (void)deleteTBContactInfoWithId:(uint64_t)contactId;

/**在本地缓存删除多个联系人信息
 * @param groupId 联系人分组编号
 */
- (void)deleteTBContactInfosWithGroupId:(uint64_t)groupId;

/**在本地缓存删除多个联系人信息
 * @param contactIds 联系人分组编号列表
 */
- (void)deleteTBContactInfosWithIds:(NSArray*)contactIds;

///删除本地缓存里全部联系人信息
- (void)deleteAllTBContactInfos;

/**在本地缓存新增或更新联系人信息对象
 * @param ebContactInfo 成员信息
 * @return TBContactInfo实例
 */
- (TBContactInfo*)saveOrUpdateTBContactInfoWithEBContactInfo:(EBContactInfo*)ebContactInfo;

/**在本地缓存新增或更新多个联系人信息对象
 * @param ebContactInfos 联系人信息列表
 */
- (void)saveOrUpdateTBContactInfosWithEBContactInfos:(NSArray*)ebContactInfos;

#pragma mark - EBContactInfo
/**在本地缓存查询获取一个联系人信息
 * @param contactId 联系人编号
 * @return EBContactInfo实例
 */
- (EBContactInfo*)contactInfoWithId:(uint64_t)contactId;

/**在本地缓存查询获取一个联系人信息
 uid和account至少一个不等于0或nil
 * @param contactUid 联系人的用户编号
 * @param account 联系人的用户账号
 * @return EBContactInfo实例
 */
- (EBContactInfo*)contactInfoWithUid:(uint64_t)contactUid orAccount:(NSString*)account;

@end


//
//  ENTBoostKit.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-22.
//
//

#import "ENTBoostClient.h"
#import "EBMessage.h"

@protocol ENTBoostKitDelegate <ENTBoostClientOuterDelegate>
@optional
/**接收到聊天消息
 * @param message 消息
 */
- (void)onRecevieMessage:(EBMessage*)message;

@end


@class EBContactInfo;
@class EBResourceInfo;

@interface ENTBoostKit : NSObject <ENTBoostClientInnerDelegate, ENTBoostClientOuterDelegate>

#pragma mark - logon

/**设置服务器访问地址,在首次获取[ENTBoostKit sharedToolKit]实例"前"设置才有效，默认访问官方测试服务entboost.entboost.com:18012
 * @param serverAddress 服务器访问地址，格式如：192.168.0.1:18012
 */
+ (void)setServerAddress:(NSString*)serverAddress;

//获取当前服务器访问地址
+ (NSString*)serverAddress;

//获取全局单例
+ (ENTBoostKit*)sharedToolKit;


/**注册应用环境
 * @param appId 应用ID
 * @param appKey 应用key
 * @param delegate SDK事件回调代理
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)registerWithAppId:(NSString*)appId appKey:(NSString*)appKey andDelegate:(id)delegate onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**设置APNS参数
 * 用于使用苹果远程推送服务
 * @param sslId 在恩布平台登记推送证书的编号
 * @param deviceToken 设备令牌
 */
- (void)setAPNSWithSSLId:(uint64_t)sslId andDeviceToken:(NSString*)deviceToken;

/**游客登录(同步调用方式)
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)logonSyncVisitorOnCompletion:(void(^)(EBAccountInfo *accountInfo))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**用户登录(同步调用方式)
 * @param virtualAccount 用户账号或用户编号(UID)或手机号码
 * @param password 用户密码
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)logonSyncWithAccount:(NSString*)virtualAccount password:(NSString*)password onCompletion:(void(^)(EBAccountInfo *accountInfo))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**用户自动登录(同步调用方式)
 * 只要用户在当前终端曾经成功登录过，就可以尝试使用
 * @param account 用户账号
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)autoLogonWithAccount:(NSString*)account onCompletion:(void(^)(EBAccountInfo *accountInfo))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**用户登出
 * @param acceptPush 是否接收推送信息
 */
- (void)asyncLogoffWithAcceptPush:(BOOL)acceptPush;

/**是否尝试自动登录
 * 依据该终端上次用户登录情况，尝试自动登录
 */
@property(nonatomic) BOOL wantAutoLogon;
///IM服务部署编号
@property(nonatomic, readonly) uint64_t serverDeployId;
///IM服务端是否已授权
@property(nonatomic, readonly) BOOL isLicenseUser;
///已授权IM服务端名称
@property(nonatomic, readonly, strong) NSString* productName;
///IM服务端LOGO链接
@property(nonatomic, strong, readonly) NSString* entLogoUrl;
//重置密码联系
@property(nonatomic, strong, readonly) NSString* resetPasswordUrl;



#pragma mark - call function

/**邀请对方用户进行一对一会话
 * 邀请过程中，如果持续时间较长，将执行回调事件onCallAlerting:
 * 如果邀请成功后将执行回调事件onCallConnected:
 * 如果失败后将执行回调事件onCallReject:或者onCallBusy:
 * @param account 用户账号
 * @param failureBlock 失败后的回调函数
 */
- (void)callUserWithAccount:(NSString*)account onFailure:(void(^)(NSError *error))failureBlock;

/**邀请对方用户进行一对一会话
 * 邀请过程中，如果持续时间较长，将执行回调事件onCallAlerting:
 * 如果邀请成功后将执行回调事件onCallConnected:
 * 如果失败后将执行回调事件onCallReject:或者onCallBusy:
 * @param depCode 企业部门或群组编号
 * @param failureBlock 失败后的回调函数
 */
- (void)callGroupWithDepCode:(uint64_t)depCode onFailure:(void(^)(NSError *error))failureBlock;

/**一对一会话转换为临时讨论组
 * @param toUid 对方用户编号
 * @param completionBlock 成功后的回调函数
            参数：newCallId 新建的临时讨论组callId
 * @param failureBlock 失败后的回调函数
 */
- (void)call2TempGroupToUid:(uint64_t)toUid existCallId:(uint64_t)callId onCompletion:(void(^)(uint64_t newCallId))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**回复会话邀请, 用于收到onCallIncoming:事件时回复对方
 * @param callId 会话编号
 * @param accept 是否接受通话, YES=接受, NO=拒绝
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)ackTheCall:(uint64_t)callId accept:(BOOL)accept onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**挂断会话
 * @param callId 会话编号
 * @param acceptPush 是否接收推送信息
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)closeTheCall:(uint64_t)callId acceptPush:(BOOL)acceptPush onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**发送文本消息
 * @param text 文本内容
 * @param callId 会话编号
 * @param beginBlock 开始发送时调用的block
 * @param completionBlock 发送成功后调用的block
 * @param failureBlock    发送失败后调用的block
 */
- (void)sendText:(NSString*)text forCallId:(uint64_t)callId onBegin:(void(^)(uint64_t msgId, uint64_t tagId))beginBlock onCompletion:(void(^)(uint64_t msgId, uint64_t tagId))completionBlock onFailure:(void(^)(NSError *error, uint64_t tagId))failureBlock;

/**发送富文本消息
 * @param message 消息
 * @param callId 会话编号
 * @param beginBlock 开始发送时调用的block
 * @param completionBlock 发送成功后调用的block
 * @param failureBlock    发送失败后调用的block
 */
- (void)sendMessage:(EBMessage*)message forCallId:(uint64_t)callId onBegin:(void(^)(uint64_t msgId, uint64_t tagId))beginBlock onCompletion:(void(^)(uint64_t msgId, uint64_t tagId))completionBlock onFailure:(void(^)(NSError *error, uint64_t tagId))failureBlock;

/**发送文件
 * @param path 文件路径
 * @param fileName 文件名
 * @param callId 会话编号
 * @param offChat 是否发送离线文件
 * @param useMd5 是否使用md5校验码
 * @param requestBlock 发送文件请求成功后调用的block
 * @param beginBlock 开始发送时调用的block
 * @param processingBlock 发送过程中不定期调用的block，用于表现发送进度及传输速率
 * @param completionBlock 发送成功后调用的block
 * @param offFileExistsBlock 离线文件已存在调用的block
 * @param cancelBlock     发送被拒绝或取消后调用的block
 * @param failureBlock    发送失败后调用的block
 */
- (void)sendFileAtPath:(NSString*)path usingFileName:(NSString*)fileName forCallId:(uint64_t)callId offChat:(BOOL)offChat useMd5:(BOOL)useMd5 onRequest:(void(^)(uint64_t msgId))requestBlock onBegin:(void(^)(uint64_t msgId))beginBlock onProcessing:(void(^)(double_t percent, double_t speed, uint64_t callId, uint64_t msgId))processingBlock onCompletion:(void(^)(uint64_t msgId))completionBlock onOffFileExists:(void(^)(uint64_t msgId))offFileExistsBlock onCancel:(void(^)(uint64_t msgId, BOOL initiative))cancelBlock onFailure:(void(^)(NSError *error))failureBlock;

/**取消发送文件
 * @param msgId 消息编号
 * @param callId 会话编号
 * @param completionBlock 发送成功后调用的block
 * @param failureBlock    发送失败后调用的block
 */
- (void)cancelSendingFileWithMsgId:(uint64_t)msgId forCallId:(uint64_t)callId onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**上传头像图片文件
 * @param data 资源数据
 * @param depCode 部门或群组编号
 * @param extendName 图片文件扩展名
 * @param md5 md5检验码
 * @param requestBlock 请求上传头像图片文件请求成功后调用的block
 * @param beginBlock 开始上传时调用的block
 * @param processingBlock 上传过程中不定期调用的block，用于表现上传进度及传输速率
 * @param completionBlock 上传成功后调用的block
 * @param resourceExistsBlock 头像图片文件已存在调用的block
 * @param cancelBlock     上传被拒绝或取消后调用的block
 * @param failureBlock    上传失败后调用的block
 */
- (void)uploadHeadPhoto:(NSData*)data depCode:(uint64_t)depCode extendName:(NSString*)extendName md5:(NSString*)md5 onRequest:(void(^)(uint64_t msgId, uint64_t resId))requestBlock onBegin:(void(^)(uint64_t msgId, uint64_t resId))beginBlock onProcessing:(EB_PROCESSING_BLOCK2)processingBlock onResourceExists:(void(^)(uint64_t msgId, uint64_t resId))resourceExistsBlock onCancel:(void(^)(uint64_t msgId, uint64_t resId, BOOL initiative))cancelBlock onCompletion:(void(^)(uint64_t msgId, uint64_t resId))completionBlock onFailure:(SOTPFailureBlock)failureBlock;

#pragma mark - load function

/**查询用户账号
 * @param uid 用户编号
 * @param completionBlock 发送成功后调用的block
 *          回调参数 account 用户账号
 * @param failureBlock    发送失败后调用的block
 */
- (void)queryAccountWithUid:(uint64_t)uid onCompletion:(void(^)(NSString* account))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

///**查询用户编号
// * @param account 用户账号
// * @param completionBlock 发送成功后调用的block
// *          回调参数 uid 用户编号
// * @param failureBlock    发送失败后调用的block
// */
//- (void)queryUidWithAccount:(NSString*)account onCompletion:(void(^)(uint64_t uid))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**查询用户编号和用户账号
 * @param virtualAccount 用户虚拟账号(可能是：用户账号[邮箱用户名或普通用户名]、手机号码、用户编号、900客服号码)
 * @param completionBlock 发送成功后调用的block
 *          回调参数 uid 用户编号
 *                  account 用户账号
 * @param failureBlock    发送失败后调用的block
 */
- (void)queryAccountInfoWithVirtualAccount:(NSString*)virtualAccount onCompletion:(void(^)(uint64_t uid, NSString* account))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**查询用户编号、用户账号和默认电子名片
 * @param virtualAccount 用户虚拟账号(可能是：用户账号[邮箱用户名或普通用户名]、手机号码、用户编号)
 * @param completionBlock 发送成功后调用的block
 *          回调参数 uid     用户编号
 *                  account 用户账号
 *                  vCard   电子名片
 * @param failureBlock    发送失败后调用的block
 */
- (void)queryUserInfoWithVirtualAccount:(NSString*)virtualAccount onCompletion:(void(^)(uint64_t uid, NSString* account, EBVCard* vCard))completionBlock onFailure:(void(^)(NSError *error))failureBlock;


/**获取会话信息
 * @param callId 会话编号
 * @return 会话信息
 */
- (EBCallInfo*)callInfoWithCallId:(uint64_t)callId;

/**获取会话信息
 * @param uid 用户编号, 0表示忽略本查询条件; 寻找一对一会话时不可以为0
 * @param depCode 群组编号, 等于0表示寻找一对一会话, 大于0表示寻找群组会话
 * @return 会话信息
 */
- (EBCallInfo*)callInfoWithUid:(uint64_t)uid depCode:(uint64_t)depCode;

/**获取会话信息
 * @param account 用户账号, nil表示忽略本查询条件; 寻找一对一会话时不可以为nil
 * @param depCode 群组编号, 等于0表示寻找一对一会话, 大于0表示寻找群组会话
 * @return 会话信息
 */
- (EBCallInfo*)callInfoWithAccount:(NSString*)account depCode:(uint64_t)depCode;

///当前登录用户信息
- (EBAccountInfo*)accountInfo;

///当前用户在线key
- (NSString*)onlineKey;

/**获取登录记录中的用户账号列表
 * @param ascending 是否升序排列
 * @return {NSString} 用户账号实例数组
 */
- (NSArray*)accountsOfLogonListAscending:(BOOL)ascending;

/**当前企业信息
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadEnterpriseInfoOnCompletion:(void (^)(EBEnterpriseInfo *enterpriseInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**所有企业部门的信息, {key = depCode的NSNumber对象, obj = EBGroupInfo对象}
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadEntGroupInfosOnCompletion:(void (^)(NSDictionary *groupInfos))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**个人群组(非企业部门)信息字典, {key = depCode的NSNumber对象, obj = EBGroupInfo对象}
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadPersonalGroupInfosOnCompletion:(void (^)(NSDictionary *groupInfos))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**我所在的企业部门, {key = depCode的NSNumber对象, obj = EBGroupInfo对象}
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMyEntGroupInfosOnCompletion:(void (^)(NSDictionary *groupInfos))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**获取某部门下的子部门数量
 * @param parentDepcode 上级部门编号
 * @return 子部门数量
 */
- (NSUInteger)countOfSubGroupInfos:(uint64_t)parentDepcode;

/**获取某部门下的子部门数量
 * @param parentDepcode 上级部门编号
 * @return 子部门列表
 */
- (NSArray*)subGroupInfos:(uint64_t)parentDepcode;

/**获取部门或群组信息
 * @param depCode 部门或群组编号
 * @return 部门或群主资料实例
 */
- (EBGroupInfo*)groupInfoWithDepCode:(uint64_t)depCode;

/**以当前用户某个成员编号查询部门或群组编号
 * @param empCode 成员编号
 * @return 部门或群组编号
 */
- (uint64_t)depCodeWithMyEmpCode:(uint64_t)empCode;

/**加载一个成员信息
 * @param empCode 成员编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfoWithEmpCode:(uint64_t)empCode onCompletion:(void (^)(EBMemberInfo * memberInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**加载多个成员信息
 * @param empCodes 成员编号列表
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfosWithEmpCodes:(NSArray*)empCodes onCompletion:(void (^)(NSDictionary* memberInfos))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**加载一个成员信息
 * @param uid 用户编号
 * @param depCode 部门或群组编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfoWithUid:(uint64_t)uid depCode:(uint64_t)depCode onCompletion:(void (^)(EBMemberInfo * memberInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**加载某部门或群组下成员信息
 * @param depCode 部门或群组编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfosWithDepCode:(uint64_t)depCode onCompletion:(void(^)(NSDictionary *memberInfos))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**搜索部门成员
 * @param searchKey 搜索条件：名称、账号、手机号、用户编号(uid)
 * @param completionBlock 加载完成后的回调函数
        参数：memberInfos = { key=depCode, value=NSDictionary{key=empCode, value=EBMemberInfo实例} }
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfosOfEntGroupWithSearchKey:(NSString*)searchKey onCompletionBlock:(void(^)(NSDictionary* memberInfos))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**获取全部群组成员
 * @param searchKey 搜索条件：名称、账号、手机号、用户编号(uid)
 * @param completionBlock 加载完成后的回调函数
 参数：memberInfos = { key=depCode, value=NSDictionary{key=empCode, value=EBMemberInfo实例} }
 * @param failureBlock 失败后的回调函数
 */
- (void)loadMemberInfosOfPersonalGroupOnCompletionBlock:(void(^)(NSDictionary* memberInfos))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载获取一个分组信息
 * @param groupId 分组编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadContactGroupWithId:(uint64_t)groupId onCompletion:(void(^)(EBContactGroup* contactGroup))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载联系人分组信息
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadContactGroupsOnCompletion:(void(^)(NSDictionary *contactGroups))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载一个联系人信息
 * @param contactId 联系人编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadContactInfoWithId:(uint64_t)contactId onCompletion:(void (^)(EBContactInfo * contactInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**加载一个联系人信息
 * @param contactUid 联系人的用户编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadContactInfoWithContactUid:(uint64_t)contactUid onCompletion:(void (^)(EBContactInfo * contactInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**加载某分组下联系人信息
 * @param groupId 联系人分组编号，注意：这里0不代表忽略条件，而是真正代表groupId==0(没有分组的联系人)
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadContactInfosWithGroupId:(uint64_t)groupId onCompletion:(void(^)(NSDictionary *contactInfos))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载全部联系人信息
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadContactInfosOnCompletion:(void(^)(NSDictionary *contactInfos))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**获取联系人信息(缓存数据)
 * @param contactId 联系人编号
 * @return EBContactInfo实例
 */
- (EBContactInfo*)contactInfoWithId:(uint64_t)contactId;

/**获取联系人信息(缓存数据)
 * @param contactUid 联系人的用户编号
 * @return EBContactInfo实例
 */
- (EBContactInfo*)contactInfoWithUid:(uint64_t)contactUid;

/**加载某部门或群组下成员在线状态
 * @param depCode 部门或群组编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateOfMembersWithDepCode:(uint64_t)depCode onCompletion:(void(^)(NSDictionary* onlineStates, uint64_t depCode))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载某部门(群组)成员在线人数
 * @param depCode 部门(群组)编号，必须大于0
 * @param completionBlock 加载完成后的回调函数
        回调参数：countOfGroupOnlineState 在线人数，-1表示指定的depCode没有找到
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateCountOfGroupsWithDepCode:(uint64_t)depCode onCompletion:(void(^)(NSInteger countOfGroupOnlineState))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载某部门(群组)成员在线人数
 * @param depCode 部门(群组)编号列表
 * @param completionBlock 加载完成后的回调函数
        回调参数：countsOfGroupOnlineState 各部门(群组)在线人数列表，人数=-1表示指定的depCode没有找到
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateCountsOfGroupsWithDepCodes:(NSArray*)depCodes onCompletion:(void(^)(NSDictionary* countsOfGroupOnlineState))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载全部部门成员在线人数
 * @param completionBlock 加载完成后的回调函数
        回调参数：countsOfGroupOnlineState = {key=depCode的NSNumber对象 : value=在线人数的NSNumber对象}，只返回在线人数大于0的部门数据
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateCountsOfEntGroupsOnCompletion:(void(^)(NSDictionary* countsOfGroupOnlineState))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载全部群组成员在线人数
 * @param completionBlock 加载完成后的回调函数
        回调参数：countsOfGroupOnlineState = {key=depCode的NSNumber对象 : value=在线人数的NSNumber对象}，只返回在线人数大于0的群组数据
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateCountsOfPersonalGroupsOnCompletion:(void(^)(NSDictionary* countsOfGroupOnlineState))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载全部联系人在线状态
 * @param completionBlock 加载完成后的回调函数s
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateOfContactsOnCompletion:(void(^)(NSDictionary* onlineStates))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**加载用户在线状态
 * @param uids 待查询的用户编号(支持多个)
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadOnlineStateOfUsers:(NSArray*)uids onCompletion:(void(^)(NSDictionary* onlineStates))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

///漫游消息URL
- (NSString*)conversationsUrl;

///应用功能列表, {key = subId的NSNumber对象, entity = EBSubscribeFuncInfo对象}
- (NSDictionary*)subscribeFuncInfos;

/**加载某应用功能导航数据
 * @param subId 订购应用编号
 * @param completionBlock 加载完成后的回调函数
 *          回调参数：funcNavigations = @[EBFuncNavigation, ...]
 * @param failureBlock 失败后的回调函数
 */
- (void)loadFuncNavigationsWithSubId:(uint64_t)subId onCompletion:(void(^)(NSArray *funcNavigations))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**获取某地区的下级地区数据
 * @param parentId 上级地区编号
 * @param completionBlock 加载完成后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)loadAreaDictionaryWithParentId:(uint64_t)parentId onCompletion:(void(^)(NSDictionary* areas))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

///联系人验证模式，YES=好友模式(需验证)，NO=普通模式(免验证)
- (BOOL)isContactNeedVerification;
///邀请进入群组是否需要对方验证通过，YES=需要对方验证，NO=不需要对方验证，直接加入
- (BOOL)isInviteAdd2GroupNeedVerification;

///应用功能入口
- (NSString*)subscribeFuncUrl;

///我的消息应用订购ID
- (uint64_t)myMessageSubId;

///邀请好友应用订购ID
- (uint64_t)contactFinderSubId;

/**获取访问应用功能的验证key
 * @param subId 功能订购ID
 * @return 应用功能访问验证key
 */
- (NSString*)funcKeyWithSubId:(uint64_t)subId;

#pragma mark - management

/**注册新用户
 * @param account 用户账号【必填】；电子邮箱格式、手机号码、带保留字符前缀的英文数字组合(例如@abc123)
 * @param userName 名称 【选填】
 * @param gender 性别【选填】
 * @param birthday 生日【选填】
 * @param address 联系地址【选填】
 * @param entName 企业名称【选填】
 * @param isNoNeedRegEmail 新用户是否不需要验证激活
 * @param pwd 密码
 * @param completionBlock 成功后的回调函数
        参数：uid 用户编号
 * @param failureBlock 失败后的回调函数
 */
- (void)registUserWithAccount:(NSString*)account userName:(NSString*)userName gender:(EB_GENDER_TYPE)gender birthday:(NSDate*)birthday address:(NSString*)address entName:(NSString*)entName isNoNeedRegEmail:(BOOL)isNoNeedRegEmail pwd:(NSString*)pwd onCompletion:(void(^)(uint64_t uid))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**编辑当前用户资料
 * @param newAccountInfo 用户资料
 * @param completionBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserInfoWithAccountInfo:(EBAccountInfo*)newAccountInfo onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**编辑当前用户聊天设置
 * @param setting 聊天设置，参考枚举类型 EB_SETTING_VALUE
 * @param completionBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserSetting:(int)setting onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**设置当前用户默认电子名片
 * @param defaultEmp 默认电子名片(默认部门或群组编号)
 * @param completionBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserDefaultEmp:(uint64_t)defaultEmp onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**修改当前用户密码
 * @param newPassword 新密码
 * @param oldPassword 旧密码
 * @param completionBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)changePassword:(NSString*)newPassword oldPassword:(NSString *)oldPassword onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**设置用户在部门或群组的头像
 * @param depCode 部门或群组编号
 * @param resId 头像资源编号，必要大于0
 * @param completionBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserHeadPhotoWithDepCode:(uint64_t)depCode resId:(uint64_t)resId onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**创建部门(或群组)
    groupInfo.depCode必须等于0
 * @param groupInfo 部门(或群组)信息
 * @param groupType 群组类型
 * @param completionBlock 成功后的回调函数
            参数：groupInfo 部门
 * @param failureBlock 失败后的回调函数
 */
- (void)createGroup:(EBGroupInfo*)groupInfo groupType:(EB_GROUP_TYPE)groupType onCompletion:(void(^)(EBGroupInfo* groupInfo))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**编辑部门(或群组)
    groupInfo.depCode必须大于0
 * @param groupInfo 部门(或群组)信息
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)editGroup:(EBGroupInfo*)groupInfo onCompletion:(void(^)(EBGroupInfo* groupInfo))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**删除群组(或部门)
 * @param depCode 部门(或群组)编号
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)deleteGroup:(uint64_t)depCode onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**邀请用户加入个人群组或临时讨论组，account或uid至少填一个
    本方法仅支持邀请个人群组或临时讨论组的成员
 * @param account 用户账号
 * @param uid 用户编号
 * @param depCode 群组(或部门)编号
 * @param description 备注信息
 * @param completionBlock 成功后的回调函数
        参数： empCode 成员编号
              empUid 成员的用户编号
              userLineState 成员的当前在线状态
 * @param inviteSentBlock 邀请已发送的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)inviteMemberWithAccount:(NSString*)account orUid:(uint64_t)uid toGroup:(uint64_t)depCode description:(NSString*)description onCompletion:(void(^)(uint64_t empCode, uint64_t empUid, EB_USER_LINE_STATE userLineState))completionBlock inviteSent:(void(^)(void))inviteSentBlock onFailure:(void(^)(NSError* error))failureBlock;

/**创建部门(项目组)成员
    memberInfo.depCode 必须不等于0，
    memberInfo.empCode 必须等于0，
    memberInfo.uid 和 memberInfo.empAccount 至少一个不等于0或nil
 * @param memberInfo 成员信息
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)createMemberInfo:(EBMemberInfo*)memberInfo onCompletion:(void(^)(uint64_t empCode, uint64_t empUid, EB_USER_LINE_STATE userLineState))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**编辑部门(项目组)或群组(临时讨论组)成员资料
    memberInfo.empCode 必须不等于0
 * @param memberInfo 成员信息
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)editMemberInfo:(EBMemberInfo*)memberInfo onCompletion:(void(^)(EBMemberInfo* memberInfo))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**删除群组成员
 * @param empCode 成员编号
 * @param depCode 群组(或部门)编号
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)deleteMember:(uint64_t)empCode depCode:(uint64_t)depCode onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**创建联系人分组
 * @param groupName 分组名称
 * @param completionBlock 成功后的回调函数
        参数：groupId 分组编号
 * @param failureBlock 失败后的回调函数
 */
- (void)createContactGroupWithGroupName:(NSString*)groupName onCompletion:(void(^)(uint64_t groupId))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**编辑联系人分组信息
 * @param groupId 分组编号
 * @param groupName 分组名称
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)editContactGroupWithId:(uint64_t)groupId groupName:(NSString*)groupName onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**删除联系人分组
 * @param groupId 分组编号
 * @param completionBlock 成功后的回调函数
 * @param failureBlock 失败后的回调函数
 */
- (void)deleteContactGroupWithId:(uint64_t)groupId onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**验证联系人，只用于服务器验证模式下
 * @discussion contactUid与contactAccount不可以都等于0或nil
 * @param contactUid 联系人的用户编号
 * @param contactAccount 联系人的用户账号
 * @param description 备注信息
 * @param verificationSentBlock 验证消息发送成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)verifyContactInfoWithContactUid:(uint64_t)contactUid orContactAccount:(NSString*)contactAccount description:(NSString*)description onVerificationSent:(void (^)(void))verificationSentBlock onFailure:(void (^)(NSError *error))failureBlock;

/**新增、邀请联系人
 * @discussion contactInfo.contactId必须等于0；只可用于服务端非验证模式，不发出邀请给对方而直接建立联系人
 * @param contactInfo 联系人信息
 * @param completionBlock 新增成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)createContactInfo:(EBContactInfo*)contactInfo onCompletion:(void (^)(EBContactInfo* contactInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**编辑联系人
 * @discussion contactInfo.contactId必须不等于0
 * @param contactInfo 联系人信息
 * @param completionBlock 成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)editContactInfo:(EBContactInfo*)contactInfo onCompletion:(void (^)(EBContactInfo* contactInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**删除联系人(或好友)
 * @discussion contactId和contactUid至少一个不等于0
 * @param contactId 联系人编号
 * @param contactUid 联系人的用户编号
 * @param deleteAnother 同时也删除对方列表中的联系人
 * @param completionBlock 成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)deleteContactWithId:(uint64_t)contactId orContactUid:(uint64_t)contactUid deleteAnother:(BOOL)deleteAnother onCompletion:(void (^)(void))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

/**修改联系人(或好友)所属分组
 * @discussion contactId和contactUid至少一个不等于0
 * @param contactId 联系人编号
 * @param contactUid 联系人的用户编号
 * @param groupId 分组编号，等于0表示设置到默认分组
 * @param completionBlock 成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)changeContactGroupWithContactId:(uint64_t)contactId orContactUid:(uint64_t)contactUid groupId:(uint64_t)groupId onCompletion:(void (^)(EBContactInfo* contactInfo))completionBlock onFailure:(void (^)(NSError *error))failureBlock;

#pragma mark - resource
///表情资源, EBEmotion实例
- (NSArray*)expressions;
///系统自带头像资源, EBEmotion实例
- (NSArray*)systemHeadPhotos;
///表情和系统自带头像资源是否已加载完毕
- (BOOL)isEmotionLoaded;

///当前用户是否有设置默认头像
- (BOOL)havingDefaultHeadPhoto;

/**加载当前用户设置的默认头像资源
 * @param completionBlock 加载完成时回调
 * @param failureBlock 加载失败时回调
 */
- (void)loadMyDefaultHeadPhotoOnCompletion:(void(^)(NSString* filePath))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**加载一个资源，以文件绝对路径方式提供
 * 例如头像、表情等资源
 * @param resourceInfo 资源描述实例
 * @param completionBlock 加载完成时回调
 * @param failureBlock 加载失败时回调
 */
- (void)loadResourceWithResourceInfo:(EBResourceInfo*)resourceInfo onCompletion:(void(^)(NSString* filePath))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**加载talk的默认头像，以文件绝对路径方式提供
    只对一对一聊天会话有效
 * 例如头像、表情等资源
 * @param talkId talk编号
 * @param completionBlock 加载完成时回调
 * @param failureBlock 加载失败时回调
 */
- (void)loadHeadPhotoWithTalkId:(NSString*)talkId onCompletion:(void(^)(NSString* filePath))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**加载成员头像资源
 * @param memberInfo 成员信息
 * @param completionBlock 加载完成时回调
        参数：
            filePath 资源加载完毕后保存在本地的文件绝对路径，如资源不存在则值=nil
 * @param failureBlock 加载失败时回调
 */
- (void)loadHeadPhotoWithMemberInfo:(EBMemberInfo*)memberInfo onCompletion:(void(^)(NSString* filePath))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**加载多个成员头像资源
 * @param memberInfos 多个成员信息，EBMemberInfo数组
 * @param completionBlock 加载完成时回调
        参数：
            filePaths 资源加载完毕后保存在本地的文件绝对路径，{key=resId[NSNumber], entity=filePath[NSString]}
 * @param failureBlock 加载失败时回调
 */
- (void)loadHeadPhotosWithMemberInfos:(NSArray*)memberInfos onCompletion:(void(^)(NSDictionary* filePaths))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/**加载多个成员头像资源
 * @param groupInfo 部门或群组信息，EBGroupInfo
 * @param completionBlock 加载完成时回调
        参数：
            filePaths 资源加载完毕后保存在本地的文件绝对路径，{key=resId[NSNumber], entity=filePath[NSString]}
 * @param failureBlock 加载失败时回调
 */
- (void)loadHeadPhotosWithGroupInfo:(EBGroupInfo*)groupInfo onCompletion:(void(^)(NSDictionary* filePaths))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

#pragma mark - AudioVideo

/*!
 @function 请求视频通话
 @discussion 发起视频通话的请求。一对一会话，对方接收到请求并响应接受后，双方再同时上视频；群组会话，申请成功后，不需要等待其他人接受，可以立即上视频。
 @param callId 会话编号
 @param includeVideo 是否包括视频；NO=只有音频，YES=音视频
 @param completionBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avRequestWithCallId:(uint64_t)callId includeVideo:(BOOL)includeVideo onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/*!
 @function 响应视频通话的邀请
 @discussion 一对一会话，响应是否接受音视频请求；群组会话，响应是否接收某一成员的视频
 @param callId 会话编号
 @param toUid 响应接收方，一对一会话时可填0
 @param ackType 响应结果，1=接受，2=拒绝
 @param completionBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avAckWithCallId:(uint64_t)callId toUid:(uint64_t)toUid ackType:(int)ackType onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/*!
 @function 结束视频通话
 @discussion 一对一会话，视频会话结束；群组会话，当前用户退出视频会话，其他人可继续进行视频会话
 @param callId 会话编号
 @param completionBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avEndWithCallId:(uint64_t)callId onCompletion:(void(^)(void))completionBlock onFailure:(void(^)(NSError* error))failureBlock;

/*！发送音频数据
 @function
 @discussion
 @param data 数据内容
 @param callId 会话编号
 @param samplingTime 数据采集时间偏移量(相对于开始时间)，单位毫秒；值要求大于1
 */
- (void)audioSendData:(NSData*)data samplingTime:(unsigned int)samplingTime forCallId:(uint64_t)callId;


/*! 获取一个接收到的音频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @return 音频数据帧
 */
- (EBRTPFrame*)audioFrameInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId;

/*! 获取一个接收到的视频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @return 视频数据帧
 */
- (EBRTPFrame*)videoFrameInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId;

/*! 获取多个接收到的音频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @param limit 返回的最大数量限制
 @return 音频数据帧列表
 */
- (NSArray*)audioFramesInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId limit:(NSUInteger)limit;

/*! 获取多个接收到的视频数据帧
 @param targetUid 发送数据的用户编号
 @param callId 会话编号
 @param limit 返回的最大数量限制
 @return 视频数据帧列表
 */
- (NSArray*)videoFramesInCacheWithTargetUid:(uint64_t)targetUid forCallId:(uint64_t)callId limit:(NSUInteger)limit;

//- (void)audioVideoOnlineWithCallId:(uint64_t)callId;

#pragma mark - talk
//获取所有对话归类
- (NSArray*)talks;

/**获取talk列表
 * @param type 类型
 * @return EBTalk列表
 */
- (NSArray*)talksWithType:(EB_TALK_TYPE)type;

/**获取某个部门或群组对话归类
 * @param depCode 部门或群组编号
 */
- (EBTalk*)talkWithDepCode:(uint64_t)depCode;

/**获取某个一对一对话归类
 * @param uid 对方用户编号
 */
- (EBTalk*)talkWithUid:(uint64_t)uid;

/**获取某个一对一对话归类
 * @param account 对方用户账号
 */
- (EBTalk*)talkWithAccount:(NSString*)account;

/**获取某个对话归类
 * @param talkId 对话归类编号
 */
- (EBTalk*)talkWithTalkId:(NSString*)talkId;

/**删除对话归类
 * @param talkId 对话归类编号
 */
- (void)deleteTalkWithId:(NSString*)talkId;

/**新增或更新对话归类，只适用于群组会话
 * @param depCode 部门或群组编号
 * @param completionBlock 成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)insertOrUpdateTalkWithDepCode:(uint64_t)depCode onCompletion:(void(^)(EBTalk* talk))completionBlock onFailure:(void(^)(NSError *error))failureBlock;

/**新增或更新对话归类，只适用于一对一会话
 * otherUid与otherAccount至少二填一
 * @param otherUid 对方用户编号
 * @param otherAccount 对方用户账号
 * @param otherUserName 对方用户名
 * @param otherEmpCode 对方成员编号
 * @param completionBlock 成功后调用的block
 * @param failureBlock    失败后调用的block
 */
- (void)insertOrUpdateTalkWithUid:(uint64_t)uid otherAccount:(NSString*)otherAccount otherUserName:(NSString*)otherUserName otherEmpCode:(uint64_t)otherEmpCode onCompletion:(void(^)(EBTalk* talk))completionBlock onFailure:(void(^)(NSError *error))failureBlock;


#pragma mark - notification

/**获取通知信息
 * @param notiId 通知编号
 * @return EBNotification实例
 */
- (EBNotification*)notificationWithId:(uint64_t)notiId;

/**获取未读通知记录的数量
 * @param talkId 编号
 */
- (NSUInteger)countOfUnreadNotificationsWithTalkId:(NSString*)talkId;

///拥有未读通知的Talk数量
- (NSUInteger)countOfTalksHavingUnreadNotification;

/**获取通知消息记录
 * @param talkId 编号
 * @return EBNotification列表
 */
- (NSArray*)notificationsWithTalkId:(NSString*)talkId;

/**标记消息通知已读状态
 * @param notiId 通知编号
 */
- (void)markNotificationAsReadedWithNotiId:(uint64_t)notiId;

/**标记消息通知已读状态
 * @param talkId 编号
 */
- (void)markNotificationsAsReadedWithTalkId:(NSString*)talkId;

#pragma mark - message
/**获取聊天记录数量
 * @param talkId 对话归类编号
 * @param beginTime 聊天记录发生时间范围下限，填nil表示无下限
 * @param endTime 聊天记录发生时间范围上限，填nil表示无上限
 */
- (NSUInteger)countOfMessagesWithTalkId:(NSString*)talkId andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime;

/**获取多条聊天记录
 * @param talkId 对话归类编号
 * @param beginTime 聊天记录发生时间范围下限，填nil表示无下限
 * @param endTime 聊天记录发生时间范围上限，填nil表示无上限
 * @param perPageSize 每分页数量
 * @param currentPage 当前页(从1开始)
 * @param orderByTimeAscending 按聊天记录发生时间排序模式；YES=升序，NO=降序
 */
- (NSArray*)messagesWithTalkId:(NSString*)talkId andBeginTime:(NSDate*)beginTime endTime:(NSDate*)endTime perPageSize:(NSUInteger)perPageSize currentPage:(NSUInteger)currentPage orderByTimeAscending:(BOOL)orderByTimeAscending;

/**获取多条聊天记录
 * 通过messageId定位，返回该位置前面或后面的多条记录
 * 返回的聊天记录与指定的messageId都属于同一个TalkId
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

/**获取多条聊天记录
 * @param messageIds 消息编号数组, NSNumber实例
 * @return EBMessage实例数组
 */
- (NSArray*)messagesWithMessageIds:(NSArray*)messageIds;

/**获取单个聊天记录
 * @param messageId 消息编号
 */
- (EBMessage*)messageWithMessageId:(uint64_t)messageId;

/**获取单个聊天记录
 * @param tagId 标记编号
 */
- (EBMessage*)messageWithTagId:(uint64_t)tagId;

/**删除单个聊天记录
 * @param messageId 消息编号
 */
- (void)deleteMessageWithMessageId:(uint64_t)messageId;

/**删除单个聊天记录
 * @param tagId 标记编号
 */
- (void)deleteMessageWithTagId:(uint64_t)tagId;

/**删除多个聊天记录
 * @param messageId 消息编号
 */
- (void)deleteMessageWithMessageIds:(NSArray*)messageIds;

/**删除多个聊天记录
 * @param messageId 消息编号
 */
- (void)deleteMessagesWithTalkId:(NSString*)talkId;

///查询未读聊天记录的总数量
- (NSUInteger)countOfUnreadMessages;

/**查询未读聊天记录的数量
 * @param talkId 对话归类编号
 */
- (NSUInteger)countOfUnreadMessagesWithTalkId:(NSString*)talkId;

/**分组查询未读聊天记录的数量
 * @return 按照talkId分组的未读聊天记录数量；数组中存储实例是NSDictionary，dictionary结构：{key=talkId, entity=NSString}，{key=count, entity=NSNumber}
 */
- (NSArray*)countArrayOfUnreadMessagesGroupByTalkId;

///拥有未读聊天记录的对话归类数量
- (NSUInteger)countOfTalksHavingUnreadMessage;

/**标记单个聊天记录已读状态
 * @param messageId 消息编号
 */
- (void)markMessageAsReadedWithMessageId:(uint64_t)messageId;

/**标记多个聊天记录为已读状态
 * @param talkId 对话归类编号
 */
- (void)markMessagesAsReadedWithTalkId:(NSString*)talkId;

///标记所有聊天记录为已读状态
- (void)markAllMessagesAsReaded;

/**取消聊天消息等待响应状态
 * @param messageId 消息编号
 */
- (void)cancelWaittingAckWithMessageId:(uint64_t)messageId;

@end

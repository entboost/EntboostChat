//
//  UserManager.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-6-27.
//
//

#import "AbstractManager.h"

@class EBAccountInfo;
@class EBEnterpriseInfo;
@class EBMemberInfo;
@class EBGroupInfo;
@class EBVCard;
@class EBServerInfo;
@class EBAVServerInfo;
@class EBContactGroup;
@class EBContactInfo;

@interface UserManager : AbstractManager <SOTPClientDelegate>

/**登记用户在线
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param sslId 推送证书编号
 * @param deviceToken 设备令牌
 * @param loginType 登录类型
 * @param state 在线状态
 * @param usId 用户客户端标识，由服务端生成返回，客户端本地保存，用于标识用户终端硬件或浏览器等
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)onlineWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey sslId:(uint64_t)sslId deviceToken:(NSString*)deviceToken loginType:(enum EB_LOGON_TYPE)loginType state:(enum EB_USER_LINE_STATE)state usId:(NSString*)usId success:(void(^)(NSString* usId, uint64_t entId, NSString* entManagerUrl, uint64_t entDepInfoVer, uint64_t myGroupInfoVer, uint64_t contactInfoVer, NSDictionary* emoVers))successBlock failure:(SOTPFailureBlock)failureBlock;

/**登记用户在线
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param acceptPush 是否接收推送信息
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)offlineWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey acceptPush:(BOOL)acceptPush success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载资源（组织架构[不包括成员]、表情资源）
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param entSuccessBlock 组织架构加载完成后回调函数
 * @param emotionBeginBlock 表情资源加载开始回调函数
 * @param emotionCompletionBlock 表情资源加载完成后回调函数
 * @param failure 失败后回调函数
 */
- (void)loadResourceInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey entSuccess:(void(^)(EBEnterpriseInfo* enterpriseInfo, NSDictionary* entGroupInfos, NSDictionary* personalGroupInfos))entSuccessBlock emotionBegin:(void(^)(NSArray* expressions, NSArray* headPhotos))emotionBeginBlock emotionCompletion:(void(^)(NSArray* expressions, NSArray* headPhotos))emotionCompletionBlock failure:(SOTPFailureBlock)failureBlock;

/**加载企业本身信息
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param successBlock 加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadEnterpriseInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey success:(void(^)(EBEnterpriseInfo* enterpriseInfo))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载企业部门和个人群组
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param successBlock 加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadGroupInfosWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey success:(void(^)(NSDictionary* entGroupInfos, NSDictionary* personalGroupInfos))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载企业部门
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param successBlock 加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadEntGroupInfosWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey success:(void(^)(NSDictionary* entGroupInfos, uint64_t groupInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载个人群组
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param successBlock 加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadPersonalGroupInfosWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey success:(void(^)(NSDictionary* personalGroupInfos, uint64_t groupInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载一个部门或群组自身资料
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param depCode 部门编号
 * @param successBlock 加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadGroupInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey depCode:(uint64_t)depCode success:(void(^)(EBGroupInfo* groupInfo, uint64_t groupInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载部门或群组的一个成员
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param empUid 成员的用户编码
 * @param depCode 部门或群组编号
 * @param successBlock 组织架构加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadMemberInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey empUid:(uint64_t)empUid depCode:(uint64_t)depCode success:(void(^)(EBMemberInfo* memberInfo, uint64_t groupVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载部门或群组的一个成员
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param empCode 成员编码
 * @param successBlock 组织架构加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadMemberInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey empCode:(uint64_t)empCode success:(void(^)(EBMemberInfo* memberInfo, uint64_t groupVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载指定部门或群组成员
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param depCode 部门或群组编码
 * @param successBlock 组织架构加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadMemberInfosWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey depCode:(uint64_t)depCode success:(void(^)(NSDictionary* memberInfos))successBlock failure:(SOTPFailureBlock)failureBlock;

/**搜索部门或群组的成员
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param searchKey 搜索条件：名称、账号、手机号、用户编号(uid)
 * @param successBlock 组织架构加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadMemberInfosWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey searchKey:(NSString*)searchKey success:(void(^)(NSDictionary* memberInfos))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载表情和头像资源
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param beginBlock 加载开始时回调函数
 * @param completionBlock 加载完成后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadEmotionsWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey onBegin:(void(^)(NSArray* expressions, NSArray* headPhotos))beginBlock onCompletion:(void(^)(NSArray* expressions, NSArray* headPhotos))completionBlock failure:(SOTPFailureBlock)failureBlock;

/**加载动态数据(离线信息、用户通知、应用订购关系、部门版本号、个人群组版本号)
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param isLoadMsg 是否加载离线信息、用户通知
 * @param isLoadSubFunc 是否加载订购应用关系
 * @param isLoadGroupVersion 是否加载企业部门和个人群组版本号
 * @param memberOnlineStateDepCode 加载群组成员在线状态时使用的群组编号
 * @param isLoadContactOnlineState 是否加载联系人在线状态
 * @param userOnlineStateUids 加载指定用户在线状态时使用的Uid(支持多个)
 * @param isLoadEntGroupOnlineStateCount 是否加载企业部门/项目组的在线人数
 * @param isLoadMyGroupOnlineStateCount 是否加载个人群组/讨论组的在线人数
 * @param groupOnlineStateCountDepCodes 指定加载部门(群组)成员在线人数的部门(群组)编号列表
 * @param successBlock API本身调用返回正确状态后回调函数(不用等待后续数据加载完成才触发)
 * @param subFuncLoadedBlock 加载应用订购关系完成时回调函数
 * @param groupVersionInfosLoadedBlock 加载部门和群组版本号完成时回调函数
 * @param memberOnlineStateLoadedBlock 加载群组成员在线状态完成时回调函数
 * @param contactOnlineStateLoadedBlock 加载联系人在线状态完成时回调函数
 * @param userOnlineStateLoadedBlock 加载指定用户在线状态完成时回调函数
 * @param groupOnlineStateCountLoadedBlock 加载部门或群组在线成员数量完成时回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)loadInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey isLoadMsg:(BOOL)isLoadMsg isLoadSubFunc:(BOOL)isLoadSubFunc isLoadGroupVersion:(BOOL)isLoadGroupVersion memberOnlineStateDepCode:(uint64_t)memberOnlineStateDepCode isLoadContactOnlineState:(BOOL)isLoadContactOnlineState userOnlineStateUids:(NSArray*)userOnlineStateUids isLoadEntGroupOnlineStateCount:(BOOL)isLoadEntGroupOnlineStateCount isLoadMyGroupOnlineStateCount:(BOOL)isLoadMyGroupOnlineStateCount groupOnlineStateCountDepCodes:(NSArray*)groupOnlineStateCountDepCodes success:(void(^)(void))successBlock subFuncLoadedBlock:(void(^)(NSDictionary* subscribeFuncInfos, NSString* funcUrl, uint64_t groupMsgSubId, uint64_t findAppSubId))subFuncLoadedBlock groupVersionInfosLoadedBlock:(void(^)(uint64_t entGroupVer, uint64_t personalGroupVer, NSDictionary* entGroupVersionInfos, NSDictionary* personalGroupVersionInfos))groupVersionInfosLoadedBlock memberOnlineStateLoadedBlock:(void(^)(NSDictionary* memberStates, uint64_t depCode))memberOnlineStateLoadedBlock contactOnlineStateLoadedBlock:(void(^)(NSDictionary* contactStates))contactOnlineStateLoadedBlock userOnlineStateLoadedBlock:(void(^)(NSDictionary* userStates))userOnlineStateLoadedBlock groupOnlineStateCountLoadedBlock:(void(^)(NSDictionary* countsOfGroupOnlineState))groupOnlineStateCountLoadedBlock failure:(SOTPFailureBlock)failureBlock;

/**加载应用导航列表
 * subId和funcId至少一个不等于0
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param subId 应用订购编号
 * @param funcId 应用编号
 * @param ownerAppId 目标应用编号
 * @param appId 当前客户端应用编号
 * @param appOnlineKey 应用在线Key
 * @param successBlock API本身调用返回正确状态后回调函数(不用等待后续数据加载完成才触发)
 * @param failure 失败后回调函数
 */
- (void)loadFuncNavigationsWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey subId:(uint64_t)subId funcId:(uint64_t)funcId ownerAppId:(uint64_t)ownerAppId appId:(uint64_t)appId appOnlineKey:(NSString*)appOnlineKey success:(void(^)(NSDictionary* funcNavigations))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载字典数据
 * @param type 类型
 * @param value 查询条件
 * @param areaLoadedBlock 地区字典加载完成时回调函数
 * @param failure 失败后回调函数
 */
- (void)loadDictionaryWithType:(int)type value:(uint64_t)value areaLoadedBlock:(void(^)(NSDictionary* areas, uint64_t version))areaLoadedBlock failure:(SOTPFailureBlock)failureBlock;

/**查询用户信息
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param virtualAccount 虚拟账号(账号、手机号、用户编号)
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)queryUserInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey virtualAccount:(NSString*)virtualAccount success:(void(^)(uint64_t uid, NSString* account, EBVCard* vCard))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载联系人分组
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)loadContactGroupsWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey success:(void(^)(NSDictionary* contactGroups))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载联系人信息
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)loadContactInfosWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey success:(void(^)(NSDictionary* contactInfos))successBlock failure:(SOTPFailureBlock)failureBlock;

/**加载一个联系人
    contactId与contactUid至少一个不等于0
 * @param uid 用户唯一编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param contactId 联系人编号，0=忽略
 * @param contactUid 联系人的用户编号，0=忽略
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)loadContactInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey contactId:(uint64_t)contactId orContactUid:(uint64_t)contactUid success:(void(^)(EBContactInfo* contactInfo))successBlock failure:(SOTPFailureBlock)failureBlock;

#pragma mark - Management

/**注册新用户
 * @param appId 应用编号
 * @param appOnlineKey 应用密钥
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
- (void)registUserWithAppId:(NSString*)appId appOnlineKey:(NSString*)appOnlineKey virtualAcount:(NSString*)virtualAccount userName:(NSString*)userName userExt:(NSString*)userExt gender:(EB_GENDER_TYPE)gender birthday:(NSDate*)birthday address:(NSString*)address entName:(NSString*)entName isResendRegEmail:(BOOL)isResendRegEmail isNoNeedRegEmail:(BOOL)isNoNeedRegMail pwd:(NSString*)pwd isEncodePwd:(BOOL)isEncodePwd success:(void(^)(uint64_t uid, int regCode))successBlock failure:(SOTPFailureBlock)failureBlock;

/**编辑当前用户资料
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param accountInfo 当前用户资料
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey accountInfo:(EBAccountInfo*)accountInfo success:(void(^)(NSArray* excutedParams))successBlock failure:(SOTPFailureBlock)failureBlock;

/**编辑当前用户聊天设置
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param setting 聊天设置
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey setting:(int)setting success:(void(^)(int savedSetting))successBlock failure:(SOTPFailureBlock)failureBlock;

/**设置当前用户默认电子名片
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param defaultEmp 默认电子名片(默认部门或群组编号)
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey defaultEmp:(uint64_t)defaultEmp success:(void(^)(uint64_t savedDefaultEmp))successBlock failure:(SOTPFailureBlock)failureBlock;

/**修改当前用户密码
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param newPassword 新密码
 * @param oldPassword 旧密码
 * @param passwordAuthMode 密码验证模式
 * @param accountType 账号类型
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)changePasswordWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey newPassword:(NSString*)newPassword oldPassword:(NSString*)oldPassword passwordAuthMode:(int)passwordAuthMode accountType:(int)accountType success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**申请上传头像文件 或 设置用户在群组(部门)的头像
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param depCode 部门或群组编号
 * @param resId 资源编号 等于0时申请上传头像文件；不等于0时设置用户在部门或群组的头像
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editUserHeadPhotoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey depCode:(uint64_t)depCode resId:(uint64_t)resId success:(void(^)(uint64_t newResId, EBServerInfo* cmServerInfo))successBlock failure:(SOTPFailureBlock)failureBlock;

/**新增/编辑联系人分组
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param groupId 分组编号；0=新建，其它=编辑
 * @param groupName 分组名称
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editContactGroupWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey groupId:(uint64_t)groupId groupName:(NSString*)groupName success:(void(^)(uint64_t groupId))successBlock failure:(SOTPFailureBlock)failureBlock;

/**删除联系人分组
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param groupId 分组编号，不能等于0
 * @param successBlock 成功后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)delContactGroupWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey groupId:(uint64_t)groupId success:(void(^)(uint64_t newContactInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**新增/修改联系人信息
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param contactInfo 联系人信息实例
 * @param successBlock 成功后回调函数
 * @param verificationSentBlock 验证发送后回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)editContactInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey contactInfo:(EBContactInfo*)contactInfo success:(void(^)(uint64_t contactId, uint64_t newContactInfoVer))successBlock verificationSent:(void(^)(void))verificationSentBlock failure:(SOTPFailureBlock)failureBlock;

/**删除联系人信息
 * @discussion  contactId与contactUid不可以同时等于0
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param contactId 联系人编号
 * @param contactUid 联系人的用户编号
 * @param deleteAnother 删除对方
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)delConactInfoWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey contactId:(uint64_t)contactId orContactUid:(uint64_t)contactUid deleteAnother:(BOOL)deleteAnother success:(void(^)(uint64_t newContactInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**修改联系人所属分组
 * @discussion  contactId与contactUid不可以同时等于0
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param contactId 联系人编号
 * @param contactUid 联系人的用户编号
 * @param groupId 分组编号，当等于0表示设置为默认分组
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)changeConactGroupWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey contactId:(uint64_t)contactId orContactUid:(uint64_t)contactUid groupId:(uint64_t)groupId success:(void(^)(uint64_t newContactInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**新增/修改群组(或部门)
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param groupInfo 群组信息
 * @param success 成功后回调函数
        参数：depCode 群组(或部门)编号
             newGroupInfoVer 最新的群组(或部门)资料总版本号
 * @param failure 失败后回调函数
 */
- (void)depEditWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey groupInfo:(EBGroupInfo*)groupInfo success:(void(^)(uint64_t depCode, uint64_t newGroupInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**删除群组(或部门)
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param depCode 群组(或部门)编号，0用于新建
 * @param success 成功后回调函数
            参数：newGroupInfoVer 最新的群组(或部门)资料总版本号
 * @param failure 失败后回调函数
 */
- (void)depDelWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey depCode:(uint64_t)depCode success:(void(^)(uint64_t newGroupInfoVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**1、新增或修改成员信息；2、邀请成员进入群组
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param memberInfo 成员信息
 * @param isNeedEmpInfo 执行成功后是否需要返回emp_info信息；0=不需要，1=需要
 * @param managerLevel 管理权限，选填
 * @param password 密码，选填
 * @param isPasswordEncode，选填 密码是否已经加密；0=未加密，需要加密；1=已加密，直接保存
 * @param successBlock 成功后回调函数
            参数：empCode 成员编号
                 empUid 成员的用户编号
                 newGroupVer 最新的群组(或部门)资料总版本号
                 userLineState 员工的在线状态
 * @param inviteSentBlock 邀请已发送的回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)empEditWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey memberInfo:(EBMemberInfo*)memberInfo isNeedEmpInfo:(BOOL)isNeedEmpInfo managerLevel:(int)managerLevel password:(NSString*)password isPasswordEncode:(BOOL)isPasswordEncode success:(void(^)(uint64_t empCode, uint64_t empUid, uint64_t newGroupVer, EB_USER_LINE_STATE userLineState))successBlock inviteSent:(void(^)(void))inviteSentBlock failure:(SOTPFailureBlock)failureBlock;

/**删除群组(或)部门成员
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param empCode 成员编号
 * @param success 成功后回调函数
            参数：newGroupVer 最新的群组(或部门)资料总版本号
 * @param failure 失败后回调函数
 */
- (void)empDelWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey empCode:(uint64_t)empCode success:(void(^)(uint64_t newGroupVer))successBlock failure:(SOTPFailureBlock)failureBlock;

/**响应业务信息
 * @param uid 用户编号
 * @param onlineKey 用户在线状态key(动态令牌)
 * @param msgId 成员编号
 * @param ackType 响应消息：1 接受、2 拒绝、3 删除信息
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)umMackWithUid:(uint64_t)uid onlineKey:(NSString*)onlineKey msgId:(uint64_t)msgId ackType:(int)ackType success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

#pragma mark - Call
/**发起呼叫请求
 * @param fromUid 发起邀请方用户编号
 * @param toUid 被邀请方用户编号 
 * @param memberCode 被邀请成员代码(部门或群组成员)
 * @param depCode 部门或群组代码
 * @param existCallId 已有的会话编号
 * @param c2d 请求转换为临时讨论组, 默认0=不请求转换, 1=请求会话转临时讨论组
 * @param success 成功后回调函数
 * @param fAck 响应成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cCall:(uint64_t)fromUid toUid:(uint64_t)toUid memberCode:(uint64_t)memberCode depCode:(uint64_t)depCode existCallId:(uint64_t)existCallId c2d:(int16_t)c2d success:(void(^)(uint64_t callId,enum EB_ACCOUNT_TYPE fType, BOOL autoAccept))successBlock fAck:(void(^)(uint64_t callId))fAckBlock failure:(SOTPFailureBlock)failureBlock;

/**响应呼叫请求
 * @param fromUid 发起邀请方用户编号
 * @param callId 会话编号
 * @param ackType 邀请响应: 1=接受,2=拒绝
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cAck:(uint64_t)fromUid callId:(uint64_t)callId ackType:(int16_t)ackType success:(void(^)(EBServerInfo* umServerInfo, NSString* umKey))successBlock failure:(SOTPFailureBlock)failureBlock;

/**进入会话状况
 * @param fromUid 发起邀请方用户编号
 * @param callId 会话编号
 * @param depCode 部门或群组代码
 * @param umKey 进入UM会话令牌
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cEnter:(uint64_t)fromUid callId:(uint64_t)callId depCode:(uint64_t)depCode umKey:(NSString*)umKey success:(void(^)(EBServerInfo* cmServerInfo, NSString* cmKey, uint64_t chatId))successBlock failure:(SOTPFailureBlock)failureBlock;

/**退出会话
 * @param fromUid 发起邀请方用户编号
 * @param callId 会话编号
 * @param hangup 是否挂断会话, FALSE=退出会话,TRUE=挂断会话(只用于一对一会话)
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cHangup:(uint64_t)fromUid callId:(uint64_t)callId hangup:(BOOL)hangup success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

#pragma mark - AV

/*! 请求视频通话 eb_v_request
 @function
 @discussion 发起视频通话的请求。一对一会话，对方接收到请求并响应接受后，双方再同时上视频；群组会话，申请成功后，不需要等待其他人接受，可以立即上视频。
 @param fromUid  请求发起方
 @param callId 会话编号
 @param type 类型；1=音频，2=音视频
 @param successBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avRequestWithFromUid:(uint64_t)fromUid callId:(uint64_t)callId type:(int)type success:(void(^)(EBAVServerInfo* vServerInfo, EBAVServerInfo* aServerInfo))successBlock failure:(SOTPFailureBlock)failureBlock;

/*! 响应视频通话 eb_v_ack
 @function
 @discussion 一对一会话，响应是否接受音视频请求；群组会话，响应是否接收某一成员的视频
 @param fromUid  响应发起方
 @param toUid 响应接收方，一对一会话时可填0
 @param callId 会话编号
 @param ackType 类型；1=接收(打开)，2=拒绝(关闭)
 @param successBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avAckWithFromUid:(uint64_t)fromUid toUid:(uint64_t)toUid callId:(uint64_t)callId ackType:(int)ackType success:(void(^)(EBAVServerInfo* vServerInfo, EBAVServerInfo* aServerInfo))successBlock failure:(SOTPFailureBlock)failureBlock;

/*! 结束视频通话 eb_v_end
 @function
 @discussion 一对一会话，视频会话结束；群组会话，单方退出视频会话，其他人可继续进行视频会话
 @param fromUid  响应发起方
 @param callId 会话编号
 @param successBlock 成功后回调函数
 @param failureBlock 失败后回调函数
 */
- (void)avEndWithFromUid:(uint64_t)fromUid callId:(uint64_t)callId success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

@end

#pragma mark -

///回调代理
@protocol UserManagerDelegate<AbstractManagerDelegate>
@optional

/**对方用户邀请对话事件
 * @param callId 会话编号
 * @param oldCallId 会话编号
 * @param fromUid 响应邀请用户的ID
 * @param fromAccount 响应邀请用户的账号
 * @param vCard 电子名片
 * @param depCode 部门或群组编号
 * @param address 用户登录地址信息
 * @param autoAccept 服务端是否已经自动应答该呼叫
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCCall:(uint64_t)callId oldCallId:(uint64_t)oldCallId fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard depCode:(uint64_t)depCode address:(NSString*)address autoAccept:(BOOL)autoAccept fromServerAddress:(NSString*)fromServerAddress;

/**对方用户响应邀请对话事件
 * @param callId 会话编号
 * @param fromUid 响应邀请用户的ID
 * @param fromAccount 响应邀请用户的账号
 * @param vCard 电子名片
 * @param ackType 邀请结果: 1=接受,2=拒绝,3=用户离线,4=呼叫超时
 * @param address 用户登录地址信息
 * @param umKey UM服务访问动态令牌
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCAck:(uint64_t)callId fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard ackType:(int16_t)ackType address:(NSString*)address umKey:(NSString*)umKey fromServerAddress:(NSString*)fromServerAddress;

/**对方用户响应邀请对话的事件
 * @param callId 会话编号
 * @param fromUid 响应邀请用户的ID
 * @param hangup 是否挂断会话, FALSE=退出会话,TRUE=对方主动挂断会话
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCHangup:(uint64_t)callId fromUid:(uint64_t)fromUid hangup:(BOOL)hangup fromServerAddress:(NSString*)fromServerAddress;

///**会话中对方用户需要被呼叫一下
// * @param callId 会话编号
// * @param fromUid 响应邀请用户的ID
// * @param fromServerAddress 来源服务地址
// */
//- (void)onUserNeedCall:(uint64_t)callId fromUid:(uint64_t)fromUid fromServerAddress:(NSString*)fromServerAddress;

/**离线信息事件
 * @param msgId 消息编号
 * @param fromUid 发起消息通知的用户编号
 * @param fromAccount 发起消息通知的用户账号
 * @param msgType 消息类型
 * @param msgSubType 富文本消息子类型
 * @param msgName 名称
 * @param msgContent 消息内容
 * @param depCode 部门或群组编号
 * @param vCard 电子名片
 * @param fromServerAddress 来源服务地址
 */
- (void)onOfflineMessage:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString*)msgName msgContent:(NSString*)msgContent depCode:(uint64_t)depCode vCard:(EBVCard*)vCard fromServerAddress:(NSString*)fromServerAddress;

/**群组(部门)变更通知事件
 * @param msgId 消息编号
 * @param fromUid 发起消息通知的用户编号
 * @param fromAccount 发起消息通知的用户账号
 * @param msgType 消息类型
 * @param msgSubType 富文本消息子类型
 * @param msgName 名称
 * @param msgContent 消息内容
 * @param depCode 部门或群组编号
 * @param vCard 电子名片
 * @param fromServerAddress 来源服务地址
 */
- (void)onGroupNotification:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString*)msgName msgContent:(NSString*)msgContent depCode:(uint64_t)depCode vCard:(EBVCard*)vCard fromServerAddress:(NSString*)fromServerAddress;

/**联系人变更通知事件
 * @param msgId 消息编号
 * @param fromUid 发起消息通知的用户编号
 * @param fromAccount 发起消息通知的用户账号
 * @param msgType 消息类型
 * @param msgSubType 富文本消息子类型
 * @param msgName 名称
 * @param msgContent 消息内容
 * @param depCode 部门或群组编号
 * @param vCard 电子名片
 * @param fromServerAddress 来源服务地址
 */
- (void)onContactNotification:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgSubType:(enum EB_RICH_SUB_TYPE)msgSubType msgName:(NSString*)msgName msgContent:(NSString*)msgContent depCode:(uint64_t)depCode vCard:(EBVCard*)vCard fromServerAddress:(NSString*)fromServerAddress;

/**广播消息通知事件
 * @param msgId 消息编号
 * @param subType 自定义类型
 * @param msgName 名称
 * @param msgContent 消息内容
 * @param fromServerAddress 来源服务地址
 */
- (void)onBroadcastMessageNotification:(uint64_t)msgId msgName:(NSString*)msgName msgContent:(NSString*)msgContent subType:(int)subType fromServerAddress:(NSString*)fromServerAddress;

/**用户在线状态通知
 * @param msgId 消息编号
 * @param fromUid 发起消息通知的用户编号
 * @param fromAccount 发起消息通知的用户账号
 * @param msgType 消息类型
 * @param msgContent 消息内容
 * @param fromServerAddress 来源服务地址
 */
- (void)onUserLineState:(uint64_t)msgId fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount msgType:(enum EB_MSG_TYPE)msgType msgContent:(NSString*)msgContent fromServerAddress:(NSString*)fromServerAddress;

/**当前用户在别处登录，当前用户被踢出的通知
 * @param fromUid 发起消息通知的用户编号
 * @param fromAccount 发起消息通知的用户账号
 * @param fromServerAddress 来源服务地址
 */
- (void)onUserKickedByAnotherFromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount fromServerAddress:(NSString*)fromServerAddress;

///**接收到版本数据事件
// * @param versionData 表现部门或群组成员数据变更的版本 {key=depCode[NSNumber], entity=versionNo[NSNumber]}
// * @param groupInfoVersion 表现部门或群组本身数据变更的版本
// * @param isEntGroup 上述数据是企业部门还是个人群组数据；YES=企业部门，NO=个人群组
// */
//- (void)onReceiveVersionsData:(NSDictionary*)versionsData groupInfoVersion:(uint64_t)groupInfoVersion isEntGroup:(BOOL)isEntGroup;

/**表情或头像资源加载事件
 * @param msgContent 消息内容
 * @param emoCount 资源数量，>=0表示本次值有效
 * @param cid 调用编号
 * @param beginBlock  加载开始时回调函数
 * @param completionBlock 加载完成后回调函数
 * @param fromServerAddress 来源服务地址
 */
- (void)onEmotion:(NSString*)msgContent emoCount:(int)emoCount cid:(uint32_t)cid onBegin:(void(^)(NSArray* expressions, NSArray* headPhotos))beginBlock onCompletion:(void(^)(NSArray* expressions, NSArray* headPhotos))completionBlock fromServerAddress:(NSString*)fromServerAddress;

#pragma mark -

/*!
 @function 邀请视频通话的事件
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param includeVideo 是否有视频；YES=音视频，NO=音频
 @param fromServerAddress 来源服务地址
 */
- (void)onFAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo fromServerAddress:(NSString*)fromServerAddress;

/*!
 @function 响应视频通话的事件
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param ackType 响应情况；1=接受，2=拒绝
 @param vServer 音频服务信息
 @param aServer 视频服务信息
 @param fromServerAddress 来源服务地址
 */
- (void)onFAVAck:(uint64_t)callId fromUid:(uint64_t)fromUid ackType:(int)ackType vServer:(EBAVServerInfo*)vServer aServer:(EBAVServerInfo*)aServer fromServerAddress:(NSString*)fromServerAddress;

/*!
 @function 结束视频通话的事件
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param fromServerAddress 来源服务地址
 */
- (void)onFAVEnd:(uint64_t)callId fromUid:(uint64_t)fromUid fromServerAddress:(NSString*)fromServerAddress;

@end
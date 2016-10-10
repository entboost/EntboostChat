//
//  LogonCenter.h
//  LogonCenter
//
//  Created by zhong zf on 13-8-8.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import "SOTP_defines.h"
#import "AbstractManager.h"
#import "EBAccountInfo.h"
#import "EBServerInfo.h"

@interface LogonCenter : AbstractManager <SOTPClientDelegate>

///**设置LC服务地址，在首次获取本实例前设置才有效，否则默认使用官方测试服务器
// * @param lcAddress LC服务地址
// */
//+ (void)setLcAddress:(NSString*)lcAddress;
//
////获取LC服务地址
//+ (NSString*)lcAddress;
//
////关闭LC连接
//+ (void)close;
//
/////获取logonCenter全局单实例
//+ (LogonCenter*)sharedLC;


/**应用初始化
 * @param appId 应用编号
 * @param appKey 应用密钥
 * @param success 成功后回调函数  注意(本处返回的参数appOnlieKey与appServerInfo并没有关系)
 * @param failure 失败后回调函数
 */
- (void)initWithAppId:(NSString*)appId appKey:(NSString*)appKey
              success:(void(^)(NSString* appOnlineKey, EBServerInfo* appServerInfo, NSString* accountPrefix, uint16_t openRegister, BOOL isOpenVisitor, NSString* forgetPasswordUrl, NSString* registerUrl, NSString* entLogoUrl, BOOL isSendRegMail, uint64_t deployId, uint16_t saveConversations, NSString* conversationsUrl, int systemSetting, uint16_t autoOpenSubId, BOOL isLicenseUser, NSString* productName, int passwordAuthMode))successBlock
              failure:(SOTPFailureBlock)failureBlock;


/**游客登录验证
 * @param account 用户账号
 * @param acmKey 账号验证令牌，用于网络掉线、电脑休眠后重新登录时替代密码用途
 * @param oauthKey 自动登录验证令牌，客户端主动创建，可长时间有效
 * @param appId 应用编号
 * @param appOnlineKey 应用动态令牌
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)logonVisitor:(NSString*)account acmKey:(NSString*)acmKey oauthKey:(NSString*)oauthKey appId:(NSString*)appId appOnlineKey:(NSString*)appOK
             success:(void(^)(EBServerInfo* umServerInfo, NSString* umOnlineKey, EBAccountInfo* accountInfo, NSString* acmKey))successBlock
             failure:(SOTPFailureBlock)failureBlock;

/**普通用户登录验证
 * @param uid 用户编号
 * @param password 密码
 * @param oauthKey 自动登录验证令牌，客户端主动创建，可长时间有效
 * @param acmKey 账号验证令牌，用于网络掉线、电脑休眠后重新登录时替代密码用途
 * @param passwordAuthMode 密码验证模式
 * @param accountType 账号类型
 * @param appId 应用编号
 * @param appOnlineKey 应用动态令牌
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)logonWithUid:(uint64_t)uid password:(NSString*)password oauthKey:(NSString*)oauthKey acmKey:(NSString*)acmKey passwordAuthMode:(int)passwordAuthMode accountType:(int)accountType appId:(NSString*)appId appOnlineKey:(NSString*)appOK
                 success:(void(^)(EBServerInfo* umServerInfo, NSString* umOnlineKey, EBAccountInfo* accountInfo, NSString* acmKey))successBlock
                 failure:(SOTPFailureBlock)failureBlock;

/**第三方登录验证
 * @param uid 用户编号
 * @param oauthKey 自动登录验证令牌，客户端主动创建，可长时间有效
 * @Param appId 应用编号
 * @param appOK 应用在线key
 * @param success 验证成功后回调函数
 * @param forward 验证不通过后回调函数
 * @param failure 调用失败后回调函数
 */
- (void)oauthWithUid:(uint64_t)uid oauthKey:(NSString*)oauthKey appId:(NSString*)appId appOnlineKey:(NSString*)appOK success:(void(^)(EBServerInfo* umServerInfo, NSString* umOnlineKey, EBAccountInfo* accountInfo, NSString* acmKey))successBlock forward:(void(^)(NSString* oauthUrl, uint32_t cid))forwardBlock failure:(SOTPFailureBlock)failureBlock;

/**查询用户或群组在线信息，用于实现用户呼叫
 * @param fromUid 发起查询的用户编号
 * @param depCode 部门或群组编号
 * @param memberCode 成员编号(部门成员或群组成员)
 * @param account 1.当depCode不等于0时，此处填入自己的账号或用户编号(uid)，查询部门或群组的在线信息; 2.当depCode等于0时，此处填入对方账号或用户编号(uid),查询单个用户信息
 * @param callKey 呼叫来源Key，实现企业呼叫来源限制
 * @param requestType 请求类型
 * @param subType 子类型
 * @param appId 应用ID
 * @param appOK 应用在线Key
 * @param success 成功后的回调函数
 * @param failure 失败后的回调函数
 */
- (void)queryWithUid:(uint64_t)fromUid depCode:(uint64_t)depCode memberCode:(uint64_t)memberCode account:(NSString*)account callKey:(NSString*)callKey requestType:(EB_REQUEST_TYPE)requestType subType:(int)subType appId:(NSString*)appId appOnlineKey:(NSString*)appOK success:(void(^)(uint64_t uid, NSString* account, uint64_t memberCode, uint64_t depCode, NSString* umKey, /*enum EB_STATE_CODE userState,*/int accountType, EBServerInfo* umServerInfo))successBlock failure:(SOTPFailureBlock)failureBlock;


@end

@protocol LogonCenterDelegate <AbstractManagerDelegate>
@optional

/**第三方验证(OAUTH)成功事件
 * @param umServerInfo um服务器信息
 * @param umOnlineKey 主UM访问令牌
 * @param accountInfo 账号相关信息
 * @param acmKey 账号验证令牌，用于网络掉线、电脑休眠后重新登录时替代密码用途
 * @param cid 调用标识
 */
- (void)onOauthSuccess:(EBServerInfo*)umServerInfo umOnlineKey:(NSString*)umOnlineKey accountInfo:(EBAccountInfo*)accountInfo acmKey:(NSString*)acmKey cid:(uint32_t)cid;

@end



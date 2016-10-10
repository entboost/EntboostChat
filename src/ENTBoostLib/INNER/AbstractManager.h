//
//  AbstractManager.h
//  ENTBoostKit
//
//  Created by zhong zf on 13-8-8.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import "SOTPClient.h"
#import "SOTP_defines.h"

@interface AbstractManager : NSObject<SOTPClientDelegate>
{
    @protected
//    __weak id _delegate;
    SOTPClient *_client;
    NSString *_appName; //本服务应用名
//    BOOL _closed; //服务已关闭
}

///回调代理
@property(weak, nonatomic) id delegate;

/**初始化
 * @param host 服务器名或IP地址
 * @param port 端口
 * @param appname 应用名
 * @param aDelegate 回调代理
 * @param needActive 服务连接心跳开关
 */
- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname delegate:(id)aDelegate needActive:(BOOL)needActive;

/**连接到登陆中心服务器
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 * @param timeOver 超时后回调函数
 */
- (void)connect:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**断开登陆中心连接服务
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 * @param timeOver 超时后回调函数
 */
- (void)disconnect:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

//服务是否已经连接
//-(BOOL)isConnected;

///最新一次接到业务数据的时间
- (NSDate*)lastRevBusinessDate;

//获取连接地址
- (NSString*)address;

/**关闭服务
 * @param complete 成功后回调函数
 */
- (void)close:(void(^)(void))onCompletion;

//给参数集追加类型参数
+ (void)addLogonType:(enum EB_LOGON_TYPE)type toParams:(NSMutableDictionary*)params;

/**按加密模式对密码进行加密
 * @param password 密码
 * @param uid 用户编号
 * @param passwordAuthMode 密码加密模式
 * @param accountType 账号类型
 */
- (NSString*)encryptedPassword:(NSString*)password WithUid:(uint64_t)uid forPasswordAuthMode:(int)passwordAuthMode andAccountType:(int)accountType;

@end

///回调代理
@protocol AbstractManagerDelegate

@optional
/**会话失效
 * @param appName 应用名
 * @param cid 唯一标识
 * @param fromServerAddress 来源服务地址
 */
- (void)sessionInvalid:(NSString*)appName cid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress;

/**app onlinekey超时失效
 * @param appName 应用名
 * @param cid 唯一标识
 * @param fromServerAddress 来源服务地址
 */
- (void)appOnlinekeyTimeout:(NSString*)appName cid:(uint32_t)cid fromServerAddress:(NSString *)fromServerAddress;

///**远程服务关闭状态事件
// * @param appName 应用名
// * @param cid 唯一标识
// * @param fromServerAddress 来源服务地址
// */
//- (void)serverHasDown:(NSString*)appName cid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress;

@end

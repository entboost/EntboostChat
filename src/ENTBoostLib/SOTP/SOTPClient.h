//
//  SOTPClient.h
//  EB
//
//  Created by zhong zf on 13-8-8.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOTP.h"

@interface SOTPClient : NSObject<SOTPDelegate>

@property(strong, nonatomic) NSString* host;
@property(nonatomic) uint16_t port;
@property(strong, nonatomic) NSString* appname;
@property(nonatomic) BOOL ack;

//初始化
- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname ack:(BOOL)ack andDelegate:(id)aDelegate needActive:(BOOL)needActive;

/**建立连接
 * @param successBlock 成功后回调的block
 * @param failureBlock 失败后回调的block
 * @param timeOverBlock 超时后回调的block
 */
- (void)connect:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**断开连接
 * @param successBlock 成功后回调的block
 * @param failureBlock 失败后回调的block
 * @param timeOverBlock 超时后回调的block
 */
- (void)disconnect:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**调用api功能函数
 * @param api 函数名称
 * @param signId 函数唯一标识
 * @param parameters 函数入参
 * @param successBlock 成功后回调的block
 * @param failureBlock 失败后回调的block
 * @param timeOverBlock 超时后回调的block
 */
- (void)callWithApi:(NSString*)api signid:(uint32_t)signId parameters:(NSDictionary*)parameters
         andSuccess:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**调用api功能函数
 * @param api 函数名称
 * @param signId 函数唯一标识
 * @param parameters 函数入参
 * @param attach 附件文件
 * @param justCallReturnBlockOneTimes 是否只使用一次api block回调，剩余的数据由onReceiveData回调代理返回给上层
 * @param noReturn 不执行回调函数
 * @param hasSeq 是否产生seq
 * @param successBlock 成功后回调的block
 * @param failureBlock 失败后回调的block
 * @param timeOverBlock 超时后回调的block
 */
- (void)callWithApi:(NSString*)api signid:(uint32_t)signId parameters:(NSDictionary*)parameters attach:(SOTPAttach*)attach justCallReturnBlockOneTimes:(BOOL)justCallReturnBlockOneTimes noReturn:(BOOL)noReturn hasSeq:(BOOL)hasSeq
         andSuccess:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

///服务是否已连接准备好
//- (BOOL)isConneceted;

///最新一次接到业务数据的时间
- (NSDate*)lastRevBusinessDate;

@end

///回调代理协议
@protocol SOTPClientDelegate
@optional

/**接收到数据
 * @param data 数据
 * @param cid 调用标识
 * @param fromServerAddress 来源的服务地址
 */
- (void)onReceiveData:(SOTPData*)data cid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress;

/**会话失效事件
 * @param cid 唯一标识
 * @param fromServerAddress 来源服务地址
 */
- (void)sessionInvalid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress;

/**app onlinekey 超时失效事件
 * @param cid 唯一标识
 * @param fromServerAddress 来源服务地址
 */
- (void)appOnlinekeyTimeout:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress;

///**远程服务关闭状态事件
// * @param cid 唯一标识
// * @param fromServerAddress 来源服务地址
// */
//- (void)serverHasDown:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress;

@end

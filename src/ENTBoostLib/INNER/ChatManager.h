//
//  ChatManager.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-4.
//
//

#import "AbstractManager.h"

@class EBMsgInfo;
@class EBMsgPack;

@interface ChatManager : AbstractManager <SOTPClientDelegate>

/**进入聊天会话
 * @param loginType 登录类型
 * @param fromUid 发起邀请方用户编号
 * @param offUid 被邀请方用户编号(离线时才需要使用)
 * @param depCode 部门或群组代码
 * @param callId 会话编号
 * @param chatId 聊天编号
 * @param chatKey 聊天会话KEY
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cmEnterWithLoginType:(int16_t)loginType fromUid:(uint64_t)fromUid offUid:(uint64_t)offUid depCode:(uint64_t)depCode callId:(uint64_t)callId chatId:(uint64_t)chatId chatKey:(NSString*)chatKey success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**申请发消息
 * @param fromUid 发送方用户编号
 * @param toUid 接收方用户编号(如发送至群时，填0)
 * @param rId 资源ID
 * @param isPrivate 是否私聊(用于群组聊天时)
 * @param chatId 聊天ID
 * @param msgType 消息类型
 * @param subType 消息子类型
 * @param content 文件名称(用于传送文件时)
 * @param size 数据总长度
 * @param packLen 数据分包长度
 * @param md5 文件MD5校验
 * @param offChat 发送离线文件
 * @param successBlock 成功后回调函数
 * @param offFileExistsBlock 离线文件已存在的回调函数
 * @param failureBlock 失败后回调函数
 */
- (void)cmMsgWithFromUid:(uint64_t)fromUid toUid:(uint64_t)toUid rId:(uint64_t)rId isPrivate:(int16_t)isPrivate chatId:(uint64_t)chatId msgType:(enum EB_MSG_TYPE)msgType subType:(enum EB_RICH_SUB_TYPE)subType content:(NSString*)content size:(int64_t)size packLen:(int32_t)packLen md5:(NSString*)md5 offChat:(int16_t)offChat success:(void(^)(uint64_t msgId))successBlock offFileExists:(void(^)(uint64_t msgId))offFileExistsBlock failure:(SOTPFailureBlock)failureBlock;

/**响应数据流
 * @param fromUid 发送方用户编号
 * @param rId 资源ID
 * @param chatId 聊天ID
 * @param msgId 消息ID
 * @param ackType 响应标识, 0=消息接收成功,1=消息接收失败,2=取消发送[接收]消息[文件],3=请求开始接收[文件]
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cmMackWithFromUid:(uint64_t)fromUid rId:(uint64_t)rId chatId:(uint64_t)chatId msgId:(uint64_t)msgId ackType:(int16_t)ackType success:(void(^)(uint64_t msgId, uint64_t resId, uint64_t size, NSString* ext, int32_t packLen, NSString* md5))successBlock failure:(SOTPFailureBlock)failureBlock;

/**响应数据流
 * @param fromUid 发送方用户编号
 * @param rId 资源ID
 * @param chatId 聊天ID
 * @param msgId 消息ID
 * @param ackType 响应标识, 0=消息接收成功,1=消息接收失败,2=取消发送[接收]消息[文件],3=请求开始接收[文件]
 * @param justCallReturnBlockOneTimes 只执行一次回调函数
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)cmMackWithFromUid:(uint64_t)fromUid rId:(uint64_t)rId chatId:(uint64_t)chatId msgId:(uint64_t)msgId ackType:(int16_t)ackType justCallReturnBlockOneTimes:(BOOL)justCallReturnBlockOneTimes success:(void(^)(uint64_t msgId, uint64_t resId, uint64_t size, NSString* ext, int32_t packLen, NSString* md5))successBlock failure:(SOTPFailureBlock)failureBlock;

/**退出会话
 * @param fromUid 发送方用户编号
 * @param chatId 聊天ID
 * @param chatKey 聊天KEY
 * @param exitSession 是否退出会话, NO=离线状况,YES=退出会话，用于挂断一对一会话
 * @param acceptPush 是否接收推送信息
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
-(void)cmExitWithFromUid:(uint64_t)fromUid chatId:(uint64_t)chatId chatKey:(NSString*)chatKey exitSession:(BOOL)exitSession acceptPush:(BOOL)acceptPush success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

/**发送数据流
 * @param fromUid 发送方用户编号
 * @param chatId 聊天ID
 * @param msgId 消息ID
 * @param total 总长度(字节数)
 * @param length 本次长度(字节数)
 * @param index 顺序索引
 * @param 二进制数组
 */
- (void)dsSendWithFormUid:(uint64_t)fromUid chatId:(uint64_t)chatId msgId:(uint64_t)msgId total:(uint64_t)total length:(uint64_t)length index:(uint64_t)index bytes:(const void*)bytes;

/**检查数据流
 * @param fromUid 发送方用户编号
 * @param chatId 聊天ID
 * @param msgId 消息ID
 * @param success 成功后回调函数
 * @param needResend 需要重发数据时回调函数
 * @param failure 失败后回调函数
 */
- (void)dsCheckWithFromUid:(uint64_t)fromUid chatId:(uint64_t)chatId msgId:(uint64_t)msgId success:(void(^)(void))successBlock needResend:(void(^)(NSArray* iArry))needResendBlock failure:(SOTPFailureBlock)failureBlock;

/**响应数据流
 * @param fromUid 发送方用户编号
 * @param chatId 聊天ID
 * @param msgId 消息ID
 * @param ackType 传输结果
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 */
- (void)dsAckWithFromUid:(uint64_t)fromUid chatId:(uint64_t)chatId msgId:(uint64_t)msgId ackType:(int16_t)ackType is:(NSArray*)is success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock;

@end

///回调代理
@protocol ChatManagerDelegate<AbstractManagerDelegate>
@optional

/**对方用户进入聊天会话事件
 * @param chatId 聊天编号
 * @param fromUid 对方用户的ID
 * @param depCode 部门或群组编号
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCMEnter:(uint64_t)chatId fromUid:(uint64_t)fromUid depCode:(uint64_t)depCode fromServerAddress:(NSString*)fromServerAddress;

/**对方用户退出聊天会话事件
 * @param chatId 聊天编号
 * @param fromUid 对方用户编号
 * @param hangup 是否挂断会话, FALSE=离线状况,TRUE=挂断会话
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCMExit:(uint64_t)chatId fromUid:(uint64_t)fromUid hangup:(BOOL)hangup fromServerAddress:(NSString*)fromServerAddress;

/**服务端转发给部门或群组所有在线用户，响应聊天消息
 * @param chatId 聊天编号
 * @param fromUid 对方用户编号
 * @param msgId 信息ID
 * @param ackType 响应标识
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCMMack:(uint64_t)chatId fromUid:(uint64_t)fromUid msgId:(uint64_t)msgId ackType:(uint16_t)ackType fromServerAddress:(NSString*)fromServerAddress;

/**发送数据流
 * @param percent 完成百分比
 * @param chatId 聊天编号
 * @param msgId 消息ID
 * @param error 错误信息
 * @param fromServerAddress 来源服务地址
 */
- (void)onDsSendCompletion:(double_t)percent chatId:(uint64_t)chatId msgId:(int64_t)msgId error:(NSError*)error fromServerAddress:(NSString*)fromServerAddress;

//*接收到聊天消息或离线消息的的描述
// * @param chatId 聊天编号
// * @param fromUid 消息发送方
// * @param toUid 消息接收方(我方，0表示所有人 )
// * @param isPrivate 是否私聊
// * @param msgId 消息ID
// * @param msgType 消息类型
// * @param subType 消息子类型
// * @param content 文件名称(用于传送文件时)
// * @param size 数据总长度
// * @param packLen 数据分包长度
// * @param offChat 是否离线信息
// * @param msgType 消息发送时间
// * @param resId 离线文件资源ID
// * @param resCMServer 离线文件CMServer
// * @param resCMAppName 离线文件CMAppName
// */
//- (void)onFCMMsgWithChatId:(uint64_t)chatId fromUid:(uint64_t)fromUid toUid:(uint64_t)toUid isPrivate:(BOOL)isPrivate msgId:(uint64_t)msgId msgType:(enum EB_MSG_TYPE)msgType subType:(enum EB_RICH_SUB_TYPE)subType content:(NSString*)content size:(int64_t)size packLen:(int32_t)packLen offChat:(int16_t)offChat msgTime:(NSDate*)msgTime resId:(uint64_t)resId resCMServer:(NSString*)resCMServer resCMAppName:(NSString*)resCMAppName;
/**接收到聊天消息或离线消息的的描述
 * @param msgInfo 聊天信息实例
 * @param fromServerAddress 来源服务地址
 */
- (void)onFCMMsg:(EBMsgInfo*)msgInfo fromServerAddress:(NSString*)fromServerAddress;

//**接收到数据
// * @param chatId 聊天编号
// * @param fromUid 消息发送方
// * @param msgId 消息ID
// * @param index 数据流索引
// * @param length 数据长度
// * @param bytes 二进制数组
// */
//- (void)onFdsSendWithChatId:(uint64_t)chatId fromUid:(uint64_t)fromUid msgId:(uint64_t)msgId index:(int32_t)index length:(int32_t)length bytes:(void*)bytes;
/**接收到数据
* @param chatId 聊天编号
* @param fromUid 消息发送方
* @param msgId 消息ID
* @param fromServerAddress 来源服务地址
*/
- (void)onFdsSendWithChatId:(uint64_t)chatId fromUid:(uint64_t)fromUid msgId:(uint64_t)msgId pack:(EBMsgPack*)pack fromServerAddress:(NSString*)fromServerAddress;

@end
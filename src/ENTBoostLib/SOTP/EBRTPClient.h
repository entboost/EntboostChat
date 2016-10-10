//
//  EBRTPClient.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/4/25.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBRTP.h"

@interface EBRTPClient : NSObject <EBRTPDelegate>

@property(strong, nonatomic) NSString* host;
@property(nonatomic) uint16_t port;

//@property(nonatomic) uint64_t vRoomId;

///初始化
- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname delegate:(id)aDelegate;

- (NSString*)address;

///连接
- (BOOL)connect;

///断开连接
- (void)disconnect;

/*! 用户登记上线
 @function
 @discussion
 @param uid 当前用户编号
 @param roomId 房间编号(通常是callId)
 @param destId 房间密钥
 */
- (void)registerSourceWithUid:(uint64_t)uid roomId:(uint64_t)roomId destId:(uint64_t)destId;

/*! 用户注销下线
 @function
 @discussion
 @param uid 当前用户编号
 @param roomId 房间编号(通常是callId)
 */
- (void)unregisterSourceWithUid:(uint64_t)uid roomId:(uint64_t)roomId;

/*! 订阅(接收)某用户音视频
 @function
 @discussion
 @param uid 当前用户编号
 @param targetUid 对方用户
 @param roomId 房间编号(通常是callId)
 */
- (void)registerSinkWithUid:(uint64_t)uid targetUid:(uint64_t)targetUid roomId:(uint64_t)roomId;

/*! 取消订阅(接收)某用户音视频
 @function
 @discussion
 @param uid 当前用户编号
 @param targetUid 对方用户
 @param roomId 房间编号(通常是callId)
 */
- (void)unregisterSinkWithUid:(uint64_t)uid targetUid:(uint64_t)targetUid roomId:(uint64_t)roomId;

/*! 取消所有已订阅(接收)的用户音视频
 @function
 @discussion
 @param uid 当前用户编号
 @param roomId 房间编号(通常是callId)
 */
- (void)unregisterAllSinkWithUid:(uint64_t)uid roomId:(uint64_t)roomId;

/*! 发送rtp数据
 @function
 @discussion
 @param bytes 数据内容字节数组
 @param byteLength 数据内容长度(字节)
 @param totalLength 整个数据帧总长度
 @param unitLength 每个分包大小
 @param index 当前分包索引(从0开始)
 @param samplingTime 数据采集时间偏移量
 @param uid 当前用户编号
 @param roomId 房间编号(通常是callId)
 @param dataType rtp数据类型
 */
- (void)sendBytes:(unsigned char*)bytes byteLength:(uint16_t)byteLength totalLength:(uint32_t)totalLength unitLength:(uint16_t)unitLength index:(uint16_t)index samplingTime:(uint32_t)samplingTime uid:(uint64_t)uid roomId:(uint64_t)roomId dataType:(SOTP_RTP_DATA_TYPE)dataType;

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

@end

@class EBRTPFrame;

@protocol EBRTPClientDelegate

@optional
/*! 接收到数据帧
 @function
 @discussion
 @param frame 数据帧对象
 @param fromUid 发送方的用户编号
 @param roomId 房间编号(通常是callId)
 */
- (void)onReceiveFrame:(EBRTPFrame*)frame fromUid:(uint64_t)fromUid roomId:(uint64_t)roomId;

@end

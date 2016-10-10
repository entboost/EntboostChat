//
//  EBRTP.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/4/25.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOTP_defines.h"
#import "GCDAsyncUdpSocket.h"
#import "SOTPData.h"

@interface EBRTP : NSObject <GCDAsyncUdpSocketDelegate>

@property(strong, nonatomic) NSString* host;
@property(nonatomic) uint16_t port;
@property(strong, nonatomic) NSString* appname;

@property(atomic) BOOL isClosed; //是否已关闭

///初始化函数
- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname delegate:(id)aDelegate;

///连接
- (BOOL)connect;

///断开连接
- (void)disconnect;

//发送rtp命令
- (void)sendRTPCommand:(sotp_rtp_media_command*)cmd;

/*! 发送rtp数据
 @function
 @discussion
 @param data 数据内容
 @param dataLength 音视频数据内容长度(字节)
 @param rtpDataDesc rtp数据包描述结构体
 */
- (void)sendRTPData:(NSData*)data rtpDataDesc:(sotp_rtp_data_desc*)rtpDataDesc;

/**call function api调用
 * @param api 接口函数名称
 * @param signid 接口函数标识
 * @param parameters 接口输入参数
 * @param attach 附件
 * @param justCallReturnBlockOneTimes 是否只使用一次api block回调，剩余的数据由onReceiveData回调代理返回给上层
 * @param noReturn 调用后不返回结果
 * @param hasSeq 是否产生seq
 * @param successBlock 成功后回调block
 * @param failureBlock 失败后回调block
 * @param timeOverBlock 超时后回调block
 */
- (void)callWithApi:(NSString*)api signid:(uint32_t)signid parameters:(NSDictionary*)parameters attach:(SOTPAttach*)attach justCallReturnBlockOneTimes:(BOOL)justCallReturnBlockOneTimes noReturn:(BOOL)noReturn hasSeq:(BOOL)hasSeq
            success:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

@end


@protocol EBRTPDelegate
@optional

/*! 接收到数据补偿的请求
 @param startSeq 请求补偿的网络顺序号开头
 @param endSeq 请求补偿的网络顺序号结尾
 @param roomId 房间编号(通常是callId)
 */
- (void)onReceiveNAKRequestWithStartSeq:(uint16_t)startSeq endSeq:(uint16_t)endSeq roomId:(uint64_t)roomId;

/*! 接收到rtp数据
 @function
 @discussion
 @param bytes 数据内容
 @param dataLength 音视频数据内容长度(字节)
 @param rtpDataDesc rtp数据包描述结构体
 */
- (void)onReceiveRTPBytes:(unsigned char*)bytes dataLength:(uint16_t)dataLength rtpDataDesc:(sotp_rtp_data_desc*)rtpDataDesc;

@end
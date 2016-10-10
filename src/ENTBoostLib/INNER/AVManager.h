//
//  AVManager.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/4/22.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

//#import "AbstractManager.h"
#import "EBRTPClient.h"

@interface AVManager : NSObject <EBRTPClientDelegate> // AbstractManager <SOTPClientDelegate>

///回调代理
@property(weak, nonatomic) id delegate;

//初始化方法
- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname vParam:(uint64_t)vParam logonType:(EB_LOGON_TYPE)logonType delegate:(id)aDelegate;

//获取连接地址
- (NSString*)address;

///连接网络
- (BOOL)networkConnect;

///断开网络
- (void)networkDisconnect;

/*! 在指定会话保持指定用户(通常是当前登录用户)在线
 @function
 @discussion 相当于心跳
 @param callId 会话编号
 @param myUid 当前用户编号
 */
- (void)keepAliveWithCallId:(uint64_t)callId myUid:(uint64_t)myUid;


/*! 退出指定会话的音视频通话
 @function
 @discussion
 @param callId 会话编号
 @param myUid 当前用户编号
 @param offline 是否执行用户注销下线。当offline=NO，只取消与会话相关的订阅；当offline=YES，除了取消与会话相关的订阅之外，还执行用户注销下线。
 */
- (void)asyncHandOffWithCallId:(uint64_t)callId myUid:(uint64_t)myUid offline:(BOOL)offline;

/*! 停止订阅(接收)某一个用户的音视频数据
 @function
 @discussion 仅适用于群组会话(非一对一会话)
 @param targetUid 目标用户编号
 @param myUid 当前用户编号
 @param callId 会话编号
 */
- (void)cancelSinkMember:(uint64_t)targetUid myUid:(uint64_t)myUid forCallId:(uint64_t)callId;

/*!
 @function
 @discussion 发送rtp数据
 @param bytes 数据内容字节数组
 @param byteLength 数据内容长度(字节)
 @param totalLength 整个数据帧总长度
 @param packLength 每个分包大小
 @param index 当前分包索引(从0开始)
 @param samplingTime 数据采集时间偏移量
 @param uid 当前用户编号
 @param callId 会话编号
 @param dataType rtp数据类型
 */
- (void)sendBytes:(unsigned char*)bytes byteLength:(uint16_t)byteLength totalLength:(uint32_t)totalLength packLength:(uint16_t)packLength index:(uint16_t)index samplingTime:(uint32_t)samplingTime uid:(uint64_t)uid callId:(uint64_t)callId dataType:(SOTP_RTP_DATA_TYPE)dataType;

@end


#pragma mark - delegate
@protocol AVManagerDelegate

@optional
/*! 接收到数据帧
 @function
 @discussion
 @param frame 数据帧对象
 @param fromUid 发送方的用户编号
 @param callId 会话编号
 @param fromAddress 来源服务连接地址
 */
- (void)onReceiveFrame:(EBRTPFrame*)frame fromUid:(uint64_t)fromUid callId:(uint64_t)callId fromAddress:(NSString*)fromAddress;

@end

//
//  EBRTPFrame.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/5/15.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eb_define1.h"

#define SOTP_RTP_MAX_PACKETS_PER_FRAME	512
#define MAX_RESEND_COUNT                5

//RTP数据分包协议头定义
@interface EBRtpPacketHead : NSObject

@property(nonatomic) uint64_t   roomId; //房间编号，保留字段
@property(nonatomic) uint64_t   srcId; //通常是uid
@property(nonatomic) uint16_t   seq; //网络顺序号
@property(nonatomic) uint8_t    nakType; //SOTP_RTP_NAK_TYPE，保留字段
@property(nonatomic) uint8_t    dataType; //数据帧类型，包括音频、视频普通帧、视频关键帧三种
@property(nonatomic) uint32_t   ts; //数据帧采集时间
@property(nonatomic) uint32_t   totalLength; //本数据帧总长度(字节)
@property(nonatomic) uint16_t   unitLength; //每分包最大长度(字节)
@property(nonatomic) uint16_t   index; //当前分包索引号(从0开始)

///初始化方法
- (id)initWithRtpDataDesc:(const sotp_rtp_data_desc*)rtpDataDesc;

@end

//RTP数据帧定义
@interface EBRTPFrame : NSObject

@property(nonatomic) uint32_t ts; //数据帧采集时间点
@property(nonatomic) uint16_t firstSeq; //第一个数据分包的seq
@property(nonatomic) uint16_t packetCount; //数据分包数量
@property(nonatomic) uint16_t totalLength; //总长度(字节)
@property(nonatomic) uint32_t expiredTime; //过期时间
@property(nonatomic) uint8_t dataType; //数据帧类型，包括音频、视频普通帧、视频关键帧三种

/*! 填充接收到的数据到缓存区
 @function
 @param bytes 接收到的内容(字节数组)
 @param length 内容长度(字节)
 @param pLastFrameTs 上一个数据帧的采集时间点，指针引用
 @param pWaitForFrameSeq 期望收到的帧seq,指针引用
 @param rtpPacketHead rtp数据分包描述头
 */
- (void)fillRtpData:(const unsigned char*)bytes dataLength:(uint16_t)dataLength lastFrameTs:(uint32_t*)pLastFrameTs waitForFrameSeq:(int32_t*)pWaitForFrameSeq rtpPacketHead:(EBRtpPacketHead*)rtpPacketHead;

///获取已接收的内容
- (NSData*)filledData;

///判断数据帧是否已接收完整
- (BOOL)isWholeFrame;

@end

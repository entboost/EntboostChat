//
//  EBRTPSentCache.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/4/25.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOTP_defines.h"

@interface EBRTPSentCache : NSObject

//获取全局单实例
+ (id)sharedInstance;

//记录rtp开始时间点
@property(nonatomic, strong, readonly) NSDate* rtpStartDate;

/*! 保存已发送的rtp数据
 @function
 @param data 数据内容
 @param rtpDataDesc 用于存放rtp数据描述的结构体指针
 @param seq 序数
 @param roomId 房间编号(通常是callId)
 @param serverAddress 服务端地址
 */
- (void)setSentRtpData:(NSData*)data rtpDatadesc:(sotp_rtp_data_desc*)pRtpDataDesc forSeq:(uint16_t)seq roomId:(uint64_t)roomId serverAddress:(NSString*)serverAddress;

/*! 取出已发送的rtp数据
 @function
 @param pData 用于返回数据内容的指针，输出参数
 @param pRtpDataDesc 用于读取后存放rtp数据的结构体指针，输出参数
 @param seq 序数
 @param roomId 房间编号(通常是callId)
 @param serverAddress 服务端地址
 @return 是否有找到符合条件的数据
 */
- (BOOL)getSentRtpData:(NSData**)pData rtpDataDesc:(sotp_rtp_data_desc*)pRtpDataDesc forSeq:(uint16_t)seq roomId:(uint64_t)roomId serverAddress:(NSString*)serverAddress;

///清除所有暂存的rtp数据
-(void)removeAllSentRtpDatas;

//- (void)setSentRtpBytes:(const void*)bytes length:(unsigned short)length forSeq:(unsigned short)seq;

//- (NSData*)rtpDataForSeq:(unsigned short)seq;

@end

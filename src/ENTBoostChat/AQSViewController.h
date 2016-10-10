//
//  AQSViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/4/27.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENTBoostChat.h"

@interface AQSViewController : UIViewController

@property(atomic) uint64_t callId;      //会话编号
@property(atomic) uint64_t targetUid;   //音视频通话的对方用户，仅用于一对一会话
@property(atomic) uint64_t depCode;     //音视频通话的群组编号，仅用于群组会话
@property(atomic, strong) NSString* targetName; //对方用户或群组名称
@property(atomic, strong) NSString* targetName2; //对方用户或群组名称(详细)

//回调代理
@property(nonatomic, weak) id delegate;

///获取通话状态
- (AV_WORK_STATE)workState;

//返回上一层界面
- (void)goBack;

///录音缓存满回调
- (void)aqsRecorderBufferCallbackWithAudioDataByteSize:(UInt32)audioDataByteSize inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc inStartingPacket:(SInt64)inStartingPacket inNumPackets:(UInt32)inNumPackets audioData:(const void*)audioData inStartTime:(const AudioTimeStamp *)inStartTime;

///播音调取数据回调
- (void)aqsPlayerBufferCallbackWithAudioDataByteSize:(UInt32*)pAudioDataByteSize packetDescriptionCount:(UInt32*)packetDescriptionCount outAudioData:(void*)outAudioData packetDescriptions:(AudioStreamPacketDescription*)outPacketDescriptions;

//发起邀请通话
- (IBAction)requestTalk:(id)sender;

//结束通话
- (IBAction)stopTalk:(id)sender;

/*! 处理被邀请音视频通话的事件
 @function
 @discussion
 @param fromUid 对方的用户编号
 @param includeVideo 是否包括视频
 */
- (void)handleAVRequest:(uint64_t)fromUid includeVideo:(BOOL)includeVideo;

/*! 处理对方接受音视频通话的事件
 @function
 @param fromUid 对方的用户编号
 */
- (void)handleAVAccept:(uint64_t)fromUid;

/*! 处理对方拒绝音视频通话的事件
 @function
 @param fromUid 对方的用户编号
 */
- (void)handleAVReject:(uint64_t)fromUid;

/*! 处理邀请音视频通话超时的事件
 @function
 @param fromUid 对方的用户编号
 */
- (void)handleAVTimeout:(uint64_t)fromUid;

/*! 处理关闭音视频通话的事件
 @function
 @param fromUid 对方的用户编号
 */
- (void)handleAVClose:(uint64_t)fromUid;

///处理接收到第一个数据帧的事件
- (void)handleAVRecevieFirstFrame;

@end


///事件协议
@protocol AQSViewControllerDelegate
@optional

///通话界面退出事件
- (void)aqsViewController:(AQSViewController*)aqsViewController exitWithWorkState:(AV_WORK_STATE)workState;

///*!
// @function
// @discussion 录音开始事件
// @param startTime 录音开始时间
// */
//- (void)aqsRecorderStartInTime:(NSDate*)startTime;
//
///*!
// @function
// @discussion 录音停止事件
// @param stopTime 录音停止时间
// */
//- (void)aqsRecorderStopInTime:(NSDate*)startTime;

@end

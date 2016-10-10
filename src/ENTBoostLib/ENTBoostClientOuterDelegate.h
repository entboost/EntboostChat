//
//  ENTBoostClientOuterDelegate.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/11/10.
//  Copyright © 2015年 entboost. All rights reserved.
//
//  事件协议

#import <Foundation/Foundation.h>
#import "SOTP_defines.h"

//响应接收文件的block定义
typedef void (^EB_RECEIVE_FILE_ACK_BLOCK)(BOOL accept, NSString *savedRelativeFilePath);
//取消接收文件的block定义
typedef void (^EB_RECEIVE_FILE_CANCEL_BLOCK)(void);

@class EBAccountInfo;
@class EBCallInfo;
@class EBVCard;
@class EBGroupInfo;
@class EBMemberInfo;
@class EBContactInfo;

@protocol ENTBoostClientOuterDelegate
@optional

#pragma mark - 登录流程事件

/**自动登录状况回调事件
 * @param state 登录结果状态 YES=成功, NO=失败
 * @param accountInfo 用户信息，当state=YES有效
 * @param error 错误信息，当state=NO有效
 */
- (void)onAutoLogonEvent:(BOOL)state accountInfo:(EBAccountInfo*)accountInfo error:(NSError*)error;

/**开始登录的事件
 * @param account 用户账号
 * @param uid 用户编号
 * @param virtualAccount 使用登录API时填入的虚拟账号(用户账号、用户编号、手机号码)
 * @param type 类型；0=普通登录，1=重新登录，2=自动登录
 */
- (void)onLogonBeginForAccount:(NSString*)account uid:(uint64_t)uid virtualAccount:(NSString*)virtualAccount type:(int)type;

/**正在登录的事件
 * @param step 步骤序号
 */
- (void)onLogonProcessing:(int)step;

/**@登录完成的事件
 * @param accountInfo 当前登录用户信息
 */
- (void)onLogonCompletion:(EBAccountInfo*)accountInfo;

/**登录失败的事件
 * @param error 错误信息
 */
- (void)onLogonError:(NSError*)error;

/**表情和头像资源文件下载完成事件
 * @param expressions 表情资源数组
 * @param headPhotos 头像资源数组
 */
- (void)onLoadedEmotionsComplete:(NSArray*)expressions headPhotos:(NSArray*)headPhotos;

#pragma mark - 呼叫会话事件

/**接收到会话邀请
 * @param callInfo 会话信息
 * @param fromUid 发起邀请的用户编号
 * @param fromAccount 发起邀请的用户账号
 * @param vCard 电子名片
 * @param clientAddress 发起方用户客户端登录地址信息
 */
- (void)onCallIncoming:(const EBCallInfo*)callInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard clientAddress:(NSString*)clientAddress;

/**正在进行会话邀请
 * @param callInfo 会话信息
 * @param toUid 被邀请方
 */
- (void)onCallAlerting:(const EBCallInfo*)callInfo toUid:(uint64_t)toUid;

/**会话已经接通
 * @param callInfo 会话信息
 */
- (void)onCallConnected:(const EBCallInfo*)callInfo;

/**被邀请方拒绝通话
 * @param callInfo 会话信息
 */
- (void)onCallReject:(const EBCallInfo*)callInfo;

/**被邀请方忙，未应答
 * @param callInfo 会话信息
 */
- (void)onCallBusy:(const EBCallInfo*)callInfo;

/**断开会话
 * @param callInfo 会话信息
 */
- (void)onCallHangup:(const EBCallInfo*)callInfo;

///**会话的节目是否已关闭，上层应用应重载并告知内层
// * @param callId 会话编号
// * @param isClosed 界面是否已关闭(输出参数)
// */
//- (void)isChatViewClosedForCall:(uint64_t)callId isClosed:(BOOL*)isClosed;

#pragma mark - 常用事件

/**有新通知，通知上层应用提取内容并更新界面
 * @param type talk类型
 * @param notiId 通知编号
 */
- (void)onNewNotification:(EB_TALK_TYPE)type notiId:(uint64_t)notiId;

#pragma mark - 收发文件事件

/**即将开始接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 * @param msgTime 消息发送时间
 * @param fromUid 文件发送方的用户编号
 * @param fileName 文件名
 * @param fileSize 文件大小(字节数)
 * @param ackBlock 反馈操作的回调函数(确定是否接收文件及提供保存文件的相对路径)
 参数：accept 是否接收文件(输出参数),TRUE=接收，FALSE=拒绝
 savedRelativeFilePath 如确认接收文件，应返回将要保存文件的相对路径(相对于沙盒根目录)
 * @param cancelBlock 取消正在接收文件的操作
 */
- (void)onWillRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId msgTime:(NSDate*)msgTime fromUid:(uint64_t)fromUid fileName:(NSString *)fileName fileSize:(uint64_t)fileSize ackBlock:(EB_RECEIVE_FILE_ACK_BLOCK)ackBlock cancelBlock:(EB_RECEIVE_FILE_CANCEL_BLOCK)cancelBlock;

/**开始接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 */
-(void)onBeginRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**完成接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)onDidRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**正在接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 * @param percent 完成百分比
 * @param speed 传输速率(字节/秒)
 */
- (void)onRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId percent:(double_t)percent speed:(double_t)speed;

/**取消正在接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 * @param initiative YES=我方取消，NO=对方取消
 */
- (void)onCancelRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId initiative:(BOOL)initiative;

/**接收文件失败事件
 * @param error 错误原因
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)onRecevieFileError:(NSError*)error forCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**发送文件完成事件(通常用于接收离线文件)
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)onDidSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**对方取消或拒绝接收文件事件(通常用于接收离线文件)
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)onCancelSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;


#pragma mark - 部门和群组、成员变更事件

/**有人申请入群的通知事件
 * @param groupInfo 部门或群组信息
 * @param description 备注信息
 * @param fromUid 邀请人的用户编号
 * @param fromAccount 邀请人的用户账号
 */
- (void)onRequestToJoinGroup:(EBGroupInfo*)groupInfo description:(NSString*)description fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**被邀请进入群(部门)的通知事件
 * @param depCode 部门或群组编号
 * @param groupName 部门或群组名称
 * @param description 备注信息
 * @param fromUid 邀请人的用户编号
 * @param fromAccount 邀请人的用户账号
 */
- (void)onInvitedToJoinGroup:(uint64_t)depCode groupName:(NSString*)groupName description:(NSString*)description fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**被邀请方拒绝进入群(部门)或者管理员拒绝入群申请的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 被邀请人的用户编号
 * @param fromAccount 被邀请人的用户账号
 */
- (void)onRejectToJoinGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**有一个新成员加入到部门或群组的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)onAddMember:(EBMemberInfo*)memberInfo toGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**部门或群组成员资料变更的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)onUpdateMember:(EBMemberInfo*)memberInfo toGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**有一个成员退出(包括主动和被动)部门或群组的通知事件
 * @param memberInfo 成员信息，如果从未加载过该成员，则等于nil
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param passive 是否被动移出
 * @param targetIsMe 被操作的对象是否当前用户
 */
- (void)onExitMember:(EBMemberInfo*)memberInfo toGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount passive:(BOOL)passive targetIsMe:(BOOL)targetIsMe;

/**新增或修改部门或群组资料的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)onUpdateGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**删除部门或群组的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)onDeleteGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

/**新增临时讨论组的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)onAddTempGroup:(EBGroupInfo*)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

//===========联系人变更事件

/**被邀请加入好友的通知事件
 * @param contactInfo 联系人信息(邀请方)
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param vCard 对方电子名片
 * @param description 备注信息(验证内容)
 */
- (void)onAddContactRequestFromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard description:(NSString*)description;

/**对方接受邀请加入好友的通知事件
 * @param contactInfo 联系人信息(接受方)
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的用户账号
 * @param vCard 对方电子名片
 */
- (void)onAddContactAccept:(EBContactInfo*)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard ;

/**对方拒绝加入好友的通知事件
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param vCard 对方电子名片
 * @param description 备注信息(拒绝原因)
 */
- (void)onAddContactRejectFromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard description:(NSString*)description;

/**删除好友的通知事件
 * @param contactInfo 联系人信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的用户账号
 * @param isBothDeleted 双方删除
 */
- (void)onDeleteContact:(EBContactInfo*)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount isBothDeleted:(BOOL)isBothDeleted;

/**被对方删除好友的通知事件
 * @param contactInfo 联系人信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的用户账号
 * @param vCard 对方电子名片
 * @param isBothDeleted 双方删除
 */
- (void)onBeDeletedContact:(EBContactInfo*)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard isBothDeleted:(BOOL)isBothDeleted;

/**用户在线状态通知事件
 * @param userLineState 在线状态
 * @param fromUid 状态变更的用户编号
 * @param fromAccount 状态变更的用户账号
 * @param entGroupIds 该用户所属的部门列表(depCode列表)
 * @param personalGroupIds 该用户所属的个人群组列表(depCode列表)
 */
- (void)onUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount inEntGroups:(NSArray*)entGroupIds inPersonalGroups:(NSArray*)personalGroupIds;

/**当前用户在别处登录，当前用户被踢出的通知
 * @param fromUid 发起消息通知的用户编号
 * @param fromAccount 发起消息通知的用户账号
 */
- (void)onUserKickedByAnotherFromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount;

#pragma mark - 音视频

/*! 一位演讲者(发出音视频数据的用户)加入音视频通话的事件
 @function
 @discussion 仅适用于群组会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param includeVideo 是否有视频；YES=音视频，NO=音频
 */
- (void)onAVOratorJoin:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo;

/*! 一位接收者(接收音视频数据的用户)加入音视频通话的事件
 @function
 @discussion 仅适用于群组会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)onAVReceiverJoin:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 一位参与者离开音视频通话的事件
 @function
 @discussion 仅适用于群组会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)onAVMemberLeft:(uint64_t)callId fromUid:(uint64_t)fromUid;


/*! 被邀请加入视频通话的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param includeVideo 是否有视频；YES=音视频，NO=音频
 */
- (void)onAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo;

/*! 对方接受视频通话邀请的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)onAVAccept:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 对方拒绝视频通话邀请的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)onAVReject:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 邀请视频通话超时的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)onAVTimeout:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 视频通话结束的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)onAVClose:(uint64_t)callId fromUid:(uint64_t)fromUid;

///*! 接收到数据帧
// @function
// @discussion
// @param frame 数据帧对象
// @param fromUid 发送方的用户编号
// @param fromAddress 来源服务连接地址
// */
//- (void)onReceiveFrame:(EBRTPFrame*)frame fromUid:(uint64_t)fromUid fromAddress:(NSString*)fromAddress;

/*! 接收到第一个数据帧
 @function
 @discussion 用于通知被调用者开始接收数据
 @param callId 会话编号
 */
- (void)onAVRecevieFirstFrame:(uint64_t)callId;

@end


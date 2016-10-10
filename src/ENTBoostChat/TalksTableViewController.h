//
//  TalksTableViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-2.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENTBoostChat.h"
#import "ENTBoost.h"

@class EBMessage;
@class EBCallInfo;
@class EBVCard;
@class TalkViewController;
@class MainViewController;

@interface TalksTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>

@property(weak, nonatomic) MainViewController* tabBarController; //tabBar控制器

@property(strong, nonatomic) NSMutableDictionary* p2pTalkViewControllesrs; //一对一会话聊天控制器
@property(strong, nonatomic) NSMutableDictionary* groupTalkViewControllers; //群组聊天控制器
@property(strong, nonatomic) NSMutableDictionary* notificationTalkViewControllers; //消息通知控制器

@property(strong, nonatomic) NSMutableArray* talkIds; //历史记录队列


//设置导航栏
- (void)configureNavigationBar:(UINavigationItem*)navigationItem;

/**分发处理收到的聊天消息
 * @param ackBlock响应接收文件的block
 * @param cancelBlock取消接收文件的block
 */
- (void)dispatchReceviedMessage:(EBMessage*)message ackBlock:(EB_RECEIVE_FILE_ACK_BLOCK)ackBlock cancelBlock:(EB_RECEIVE_FILE_CANCEL_BLOCK)cancelBlock;

/**重新载入指定行
 * @param talkId 聊天编号
 */
- (void)reloadRowWithTalkId:(NSString*)talkId;

/**更新调整表视图显示顺序
 * @param talkId 对话归类编号
 */
- (void)adjustTableViewWithTalkId:(NSString*)talkId;

/**更新对话未读提示
 * @param talkId 对话归类编号
 */
- (void)updateBadgeWithTalkId:(NSString*)talkId;

///更新TabBar、应用图标右上角提醒内容
- (void)updateBadgeValue;

#pragma mark - 处理登录流程事件

/**处理登录完成的事件
 * @param accountInfo 当前登录用户的信息
 */
- (void)handleLogonCompletion:(EBAccountInfo *)accountInfo;

#pragma mark - 处理聊天会话事件

/**处理会话应答事件
 * @param callInfo 会话对象
 * @param actionType 会话状态类型
 */
- (void)handleCall:(const EBCallInfo*)callInfo callActionType:(CALL_ACTION_TYPE)callActionType;

/**处理会话应答事件
 * @param callInfo 会话对象
 */
- (void)handleCallHangup:(const EBCallInfo*)callInfo;

/**处理发起邀请会话事件
 * @param callInfo 会话对象
 * @param toUid 对方用户编号
 */
- (void)handleCallAlerting:(const EBCallInfo*)callInfo toUid:(uint64_t)toUid;

/**处理被邀请会话事件
 * @param callInfo 会话对象
 * @param fromUid 邀请方用户编号
 * @param fromAccount 邀请方用户账号
 * @param vCard 电子名片 邀请方电子名片
 * @param clientAddress 邀请方客户端地址
 */
- (void)handleCallIncoming:(const EBCallInfo *)callInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard clientAddress:(NSString *)clientAddress;

/**刷新表情和头像资源
 * @param expressions 表情资源数组
 * @param headPhotos 头像资源数组
 */
- (void)refreshEmotions:(NSArray *)expressions headPhotos:(NSArray *)headPhotos;

#pragma mark 处理常用事件

/**有未读的新事件
 @param type talk类型
 @param notiId 通知编号
 */
- (void)handleNewNotification:(EB_TALK_TYPE)type notiId:(uint64_t)notiId;

#pragma mark - 处理联系人、部门、群组变更通知事件

/**处理有人申请入群的通知事件
 * @param groupInfo 部门或群组信息
 * @param description 备注信息
 * @param fromUid 邀请人的用户编号
 * @param fromAccount 邀请人的用户账号
 */
- (void)handleRequestToJoinGroup:(EBGroupInfo *)groupInfo description:(NSString *)description fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理被邀请进入群(部门)的通知事件
 * @param depCode 部门或群组编号
 * @param enterpriseName 企业名称，邀请进入部门才有值，其它情况空白
 * @param description 备注信息
 * @param fromUid 邀请人的用户编号
 * @param fromAccount 邀请人的用户账号
 */
- (void)handleInvitedToJoinGroup:(uint64_t)depCode groupName:(NSString *)groupName description:(NSString *)description fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理被邀请方拒绝进入群(部门)或者管理员拒绝入群申请的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleRejectToJoinGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理新成员加入部门或群组的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
-(void)handleAddMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理部门或群组成员资料变更的通知事件
 * @param memberInfo 成员信息
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleUpdateMember:(EBMemberInfo *)memberInfo toGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理删除部门或群组的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleDeleteGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理新增讨论组的通知事件
 * @param groupInfo 部门或群组信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 */
- (void)handleAddTempGroup:(EBGroupInfo *)groupInfo fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**处理被邀请加好友的通知事件
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param vCard 电子名片
 * @param description 备注信息
 */
- (void)handleAddContactRequestFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard description:(NSString *)description;

/**处理对方接受加好友的通知事件
 * @param contactInfo 联系人信息
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param vCard 电子名片
 */
- (void)handleAddContactAccept:(EBContactInfo*)contactInfo fromUid:(uint64_t)fromUid fromAccount:(NSString*)fromAccount vCard:(EBVCard*)vCard;

/**处理对方接受加好友的通知事件
 * @param fromUid 操作人的用户编号
 * @param fromAccount 操作人的账号
 * @param vCard 电子名片
 * @param description 备注信息
 */
- (void)handleAddContactRejectFromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount vCard:(EBVCard *)vCard description:(NSString *)description;

/**处理用户在线状态通知事件
 * @param userLineState 在线状态
 * @param fromUid 状态变更的用户编号
 * @param fromAccount 状态变更的用户账号
 * @param entGroupIds 该用户所属的部门列表(depCode列表)
 * @param personalGroupIds 该用户所属的个人群组列表(depCode列表)
 */
- (void)handleUserChangeLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount inEntGroups:(NSArray *)entGroupIds inPersonalGroups:(NSArray *)personalGroupIds;

#pragma mark - 处理收发文件事件

/**处理即将开始接收文件事件
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
- (void)handleWillRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId msgTime:(NSDate *)msgTime fromUid:(uint64_t)fromUid fileName:(NSString *)fileName fileSize:(uint64_t)fileSize ackBlock:(EB_RECEIVE_FILE_ACK_BLOCK)ackBlock cancelBlock:(EB_RECEIVE_FILE_CANCEL_BLOCK)cancelBlock;

/**处理开始接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)handleBeginRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**处理接收文件完成事件
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)handleDidRecevieFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**处理正在接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 * @param percent 完成百分比
 * @param speed 传输速率(字节/秒)
 */
- (void)handleRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId percent:(double_t)percent speed:(double_t)speed;

/**处理取消正在接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 * @param initiative YES=我方取消，NO=对方取消
 */
- (void)handleCancelRecevingFileForCall:(uint64_t)callId msgId:(uint64_t)msgId initiative:(BOOL)initiative;

/**处理接收文件失败事件
 * @param error 错误原因
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)handleRecevieFileError:(NSError*)error forCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**处理对方接收文件完成事件
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)handleDidSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

/**处理取消/拒绝接收文件事件
 * @param callId 会话编号
 * @param msgId 消息编号
 */
- (void)handleCancelSentFileForCall:(uint64_t)callId msgId:(uint64_t)msgId;

#pragma mark - 处理音视频通话事件

/*! 处理一位演讲者(发出音视频数据的用户)加入音视频通话的事件
 @function
 @discussion 仅适用于群组会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param includeVideo 是否有视频；YES=音视频，NO=音频
 */
- (void)handleAVOratorJoin:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo;

/*! 处理一位接收者(接收音视频数据的用户)加入音视频通话的事件
 @function
 @discussion 仅适用于群组会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)handleAVReceiverJoin:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理一位参与者离开音视频通话的事件
 @function
 @discussion 仅适用于群组会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)handleAVMemberLeft:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理被邀请加入视频通话的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 @param includeVideo 是否有视频；YES=音视频，NO=音频
 */
- (void)handleAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo;

/*! 处理对方拒绝视频通话邀请的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)handleAVReject:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理被邀请加入视频通话的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)handleAVAccept:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理邀请视频通话超时的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)handleAVTimeout:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理音视频通话结束的事件
 @function
 @discussion 仅适用于一对一会话
 @param callId 会话编号
 @param fromUid 响应邀请用户的ID
 */
- (void)handleAVClose:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理接收到第一个数据帧
 @param callId 会话编号
 */
- (void)handleAVRecevieFirstFrame:(uint64_t)callId;

///处理本机音视频资源不可用通知
- (void)handleAVResourceDisabled;

@end

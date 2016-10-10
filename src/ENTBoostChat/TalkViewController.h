//
//  TalkViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-8.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SETextView.h"
#import "StampInputView.h"
#import "ChatCell.h"
#import "ChatSeparatorCell.h"
#import "AudioToolkit.h"
#import "ENTBoost.h"
#import "FilesBrowserController.h"

//定义响应接收文件block名称
#define RECEIVE_FILE_ACK_BLOCK_NAME @"ackBlock"
//定义取消接收文件block名称
#define RECEIVE_FILE_CANCEL_BLOCK_NAME @"cancelBlock"

@class EmotionViewController;
@class TalksTableViewController;
@class CustomSeparator;
@class ChatCell;
@class EBCallInfo;
@class CoreTextData;
@class CTFrameParserConfig;


@interface TalkViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SETextViewDelegate, ChatCellDelegate, StampInputViewDelegate, AudioToolkitDelegate, FilesBrowserDelegate>

@property(nonatomic) NSString* talkId; //聊天编号
@property(nonatomic) NSDate* updatedTime; //最新活跃时间(接收或发送信息)
//@property(nonatomic) uint64_t currentCallId; //当前会话编号，如等于0表示没关联到会话

@property(nonatomic) uint64_t depCode; //部门或群组编号，如等于0表示当前是一对一会话
//@property(nonatomic, strong) NSString* depName; //部门或群组名称
@property(nonatomic, strong) EBGroupInfo* groupInfo; //部门或群组对象
@property(nonatomic, strong) NSMutableDictionary* memberInfoDict; //成员列表，仅限于群组(部门)会话

@property(nonatomic) uint64_t otherUid; //对方的用户编号,大于0时表示一对一会话
@property(nonatomic, strong) NSString* otherAccount; //对方的用户账号，与uid相匹配
@property(nonatomic, strong) NSString* otherUserName; //对方用户名称，用于一对一会话
//@property(nonatomic) uint64_t otherEmpCode; //对方默认部门或群组编号

@property(nonatomic, strong) NSMutableArray* messages; //聊天信息数组
@property(nonatomic, strong) NSMutableDictionary<NSString*, ChatCell*> *chatCellMap; //聊天记录界面对象缓存

@property(nonatomic, weak) TalksTableViewController* talksController; //对话归类列表控制器

@property(nonatomic, strong) IBOutlet EmotionViewController *emotionViewController; //表情选择控制器
@property(nonatomic, strong) IBOutlet UITableView *talkTableView; //聊天信息显示视图

@property(nonatomic, strong) IBOutlet CustomSeparator* toolbarTopBorder; //仿工具栏视图的上边框
@property(nonatomic, strong) IBOutlet UIButton* keyboardButton; //键盘按钮
@property(nonatomic, strong) IBOutlet UIButton* micButton; //麦克风按钮
@property(nonatomic, strong) IBOutlet UIButton* voiceButton; //"按住说话"按钮
@property(nonatomic, strong) IBOutlet UIButton* toolbarOtherButton; //仿工具栏视图的“其它”按钮
@property(nonatomic, strong) IBOutlet UIView* talkTextAppearance; //信息编辑外框


@property(nonatomic, strong) IBOutlet UIButton* photoButton; //发送照片按钮
@property(nonatomic, strong) IBOutlet UIButton* cameraButton; //发送照相机按钮
@property(nonatomic, strong) IBOutlet UIButton* videoButton; //发送视频按钮
@property(nonatomic, strong) IBOutlet UIButton* folderButton; //发送文件按钮
@property(nonatomic, strong) IBOutlet UIView* toolbarOtherView; //“其它”按钮工具栏视图

@property(nonatomic, strong) IBOutlet UIScrollView *talkScrollView; //发送信息编辑框(滚动底框)
@property(nonatomic, strong) IBOutlet SETextView* talkTextView; //发送信息编辑框
@property(nonatomic, strong) IBOutlet StampInputView* stampInputView; //备选图标表情的视图
@property(nonatomic, strong) IBOutlet UIButton *sendButton; //发送按钮

@property(nonatomic, strong) NSString* headPhotoFilePath; //在聊天会话列表界面(TalksTableViewController)，对方的头像图标文件路径(只用于一对一聊天)

@property(nonatomic) BOOL isFirstShow; //是否第一次显示

@property(nonatomic, strong) NSMutableDictionary* receiveFileBlockCache; //接收文件时使用的响应句柄(block)

///刷新表情选择视图
- (void)refreshStampInputView;

////点击发送按钮事件处理
//- (IBAction)sendTextFieldTaped:(id)sender;

////显示图标表情按钮事件处理
//- (IBAction)showStampInputView:(id)sender;

/**添加消息到表视图
 * @param messages 消息数组
 * @param append 是否在尾部追加, YES=是，NO=插入第一位置
 * @param noUpdateView 是否不更新视图；YES=不更新，NO=更新
 * @return 成功插入的记录数
 */
- (NSUInteger)addMessages:(NSArray*)messages append:(BOOL)append noUpdateView:(BOOL)noUpdateView;

//刷新最新一条消息时间戳
- (void)refreshLastMessageTimestamp;

/*表视图滚动到最后一行记录
 * @param animated 是否动画模式执行
 */
-(void)scrollToBottom:(BOOL)animated;

///是否群组聊天
- (BOOL)isGroup;

///是否正在音视频聊天
- (BOOL)isAVBusying;

///是否已显示音视频通话界面
- (BOOL)isAQSViewControllerShowed;

///停止音视频通话
- (void)stopAVTalking;

///退出音视频通话界面，当前没有进行通话才能有效执行
- (void)dismissAQSViewControllerIfIdle;

/*检查是否已经存在会话，如不存在则自动发起会话
 * @param waittingResult 输出参数 是否需要等待呼叫会话结果
 * @param result 输出参数 会话是否已经准备好
 * @param message 信息对象，用于更新该信息显示的状态，可填入nil
 * @return 会话对象
 */
- (EBCallInfo*)detectAndLaunchCallWithWaitting:(BOOL*)waittingResult result:(BOOL*)result forMessage:(EBMessage*)message;

////标记聊天记录已读状态并刷新badge
//- (void)updateMessagesReadedStateAndBadge;

//界面增加成员
- (void)addMemberInfo:(EBMemberInfo*)memberInfo;

//界面更新成员资料
- (void)updateMemberInfo:(EBMemberInfo*)memberInfo;

//检测本窗口是否当前聊天界面，如果是则把关联的未读聊天记录设置为已读，并更新相关badge
- (void)checkToUpdateMessagesReadedStateAndBadge;

/**tableview更新消息显示
 * @param message 信息对象
 * @param reload 是否重载整个cell
 */
- (void)updateCellWithMessage:(EBMessage*)message reload:(BOOL)reload;

/**更新用户在线状态
 * @param userLineState 在线状态
 * @param fromUid 状态变更的用户编号
 * @param fromAccount 状态变更的用户账号
 */
- (void)updateUserLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount;

/**加载成员在线状态列表，并更新视图；必须主线程执行
 * @parm reloadView 是否刷新视图
 */
- (void)loadOnlineStateOfMembers:(BOOL)reloadView;

#pragma mark - 处理音视频事件

/*! 处理被邀请音视频通话的事件
 @function
 @discussion
 @param callId 会话编号
 @param fromUid 对方的用户编号
 */
- (void)handleAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo;

/*! 处理对方接受音视频通话的事件
 @function
 @param callId 会话编号
 @param fromUid 对方的用户编号
 */
- (void)handleAVAccept:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理对方拒绝音视频通话的事件
 @function
 @discussion
 @param callId 会话编号
 @param fromUid 对方的用户编号
 */
- (void)handleAVReject:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理邀请音视频通话超时的事件
 @function
 @discussion
 @param callId 会话编号
 @param fromUid 对方的用户编号
 */
- (void)handleAVTimeout:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理关闭音视频通话的事件
 @function
 @discussion
 @param callId 会话编号
 @param fromUid 对方的用户编号
 */
- (void)handleAVClose:(uint64_t)callId fromUid:(uint64_t)fromUid;

/*! 处理接收到第一个数据帧的事件
 @param callId 会话编号
 */
- (void)handleAVRecevieFirstFrame:(uint64_t)callId;

@end

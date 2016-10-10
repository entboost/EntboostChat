//
//  WeiXinCell.h
//  WeixinDeom
//
//  Created by iHope on 13-12-31.
//  Copyright (c) 2013年 任海丽. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatView.h"
#import "AudioToolkit.h"
#import "ASProgressPopUpView.h"

//信息状态类型
typedef enum CHAT_CELL_MESSAGE_STATE {
    CHAT_CELL_MESSAGE_STATE_CLEAR,   //清空
    CHAT_CELL_MESSAGE_STATE_FAILURE, //失败
    CHAT_CELL_MESSAGE_STATE_LOADING, //正在加载
    CHAT_CELL_MESSAGE_STATE_COMPLETE //完成
} CHAT_CELL_MESSAGE_STATE;

@class EBMessage;

@interface ChatCell : UITableViewCell <ChatViewDelegate, AudioToolkitDelegate, ASProgressPopUpViewDataSource>

@property(nonatomic) uint64_t msgId; //消息编号
@property(nonatomic) uint64_t tagId; //标记编号(当前用户在本客户端发起的消息才存在)
@property(nonatomic) BOOL isGroup; //是否群组聊天

@property(nonatomic, weak) id delegate; //事件代理
@property(nonatomic, weak) UITableView* talkTableView; //上级Table视图

@property(nonatomic, strong) IBOutlet UIImageView* headImageView; //头像视图
@property(nonatomic, strong) IBOutlet UILabel* nameLabel; //名称
@property(nonatomic, strong) IBOutlet UIView* stateImageView; //状态图标
@property(nonatomic, strong) IBOutlet UILabel* stateLabel; //状态描述

@property(nonatomic, strong) UITapGestureRecognizer* headPhotoTapRecognizer; //头像点击手势事件

/**设置(渲染)信息内容
 * @param message 聊天信息内容
 * @param fromSelf 本信息是否来自于自己, NO=不是, YES=是
 */
- (void)setContent:(EBMessage*)message fromSelf:(BOOL)fromSelf;

/**设置消息状态视图
 * @param messageState 信息状态类型
 */
- (void)setMessageState:(CHAT_CELL_MESSAGE_STATE)messageState;

/**更新显示成员名称
 * @param name 成员名称，如果本参数为nil或长度=0的字符串，名称字段会自动隐藏
 */
- (void)updateMemberNameLabel:(NSString*)name;

/**更新进度条
 * @param progress 进度(0.0-100.0)
 * @param animated 是否执行动画
 */
- (void)updateProgress:(float)progress animated:(BOOL)animated;

@end


@protocol ChatCellDelegate

@required
/**询问消息是否正在发送中
 * @param cell
 * @param message 消息对象
 */
- (BOOL)chatCell:(ChatCell*)cell isSendingMessage:(EBMessage*)message;

@optional
//点击图片事件
- (void)chatCell:(ChatCell*)cell imageClick:(UIImage*)image;

//点击链接事件
- (void)chatCell:(ChatCell *)cell linkClick:(NSString *)url;

//点击文件事件
- (void)chatCell:(ChatCell*)cell fileClick:(uint64_t)msgId;

//删除单条聊天记录事件
- (void)chatCell:(ChatCell*)cell deletedMessage:(uint64_t)msgId tagId:(uint64_t)tagId;

//重发消息事件
- (void)chatCell:(ChatCell*)cell resendMessageWithTagId:(uint64_t)tagId;

/**以离线方式重新发送文件
 * @param msgId 消息编号
 * @param callId 呼叫编号
 */
- (void)chatCell:(ChatCell*)cell resendFileOffChat:(uint64_t)msgId forCallId:(uint64_t)callId;

/**响应接收文件
 * @param msgId 消息编号
 * @param accept 是否接受，YES=接受，NO=拒绝
 */
- (void)chatCell:(ChatCell*)cell ackReceiveFile:(uint64_t)msgId accept:(BOOL)accept;

/**取消正在接收文件的过程
 * @param msgId 消息编号
 */
- (void)chatCell:(ChatCell*)cell cancelReceivingFile:(uint64_t)msgId;

@end
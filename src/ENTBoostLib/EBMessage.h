//
//  EBMessage.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-23.
//
//

@class EBChat;

///消息类
@interface EBMessage : NSObject

@property(nonatomic) uint64_t tagId; //标识编号，用于在msgId还没产生前表示本实例

@property(nonatomic) uint64_t msgId; //信息编号
@property(nonatomic) uint64_t callId; //会话编号
@property(nonatomic) uint64_t fromUid; //消息发起人的用户编号
@property(nonatomic, strong) NSString* fromName; //消息发起人的名称
@property(nonatomic, strong) NSString* talkId; //talkId
@property(nonatomic, strong) NSDate* msgTime; //消息发送时间

@property(nonatomic) BOOL isSent; //是否已经发送完成
@property(nonatomic) BOOL isSentFailure; //是否发送失败
@property(nonatomic) BOOL isReaded; //是否已读状态

@property(nonatomic, strong) NSString* fileName; //文件名
//@property(nonatomic, strong) NSString* tempFilePath; //临时保存文件相对路径(相对于沙盒)
@property(nonatomic, strong) NSString* filePath; //文件绝对路径
@property(nonatomic) double_t percentCompletion; //完成百分比，当消息属于文件类型时才有效
@property(nonatomic) uint64_t fileSize; //文件大小(字节数)，当消息属于文件类型时才有效
@property(nonatomic, strong) NSString* md5; //md5码，当消息属于文件类型时才有效
@property(nonatomic, strong) NSString* resourceString; //离线文件资源描述(格式resId;cmAddress;cmAppName)，当消息属于文件类型时才有效
@property(nonatomic, strong) NSString* gpsCoordinates; //GPS坐标
@property(nonatomic) BOOL rejected; //是否拒绝接收，当消息属于文件类型时才有效
@property(nonatomic) BOOL acked; //是否已应答(决定是否接收)，当消息属于文件类型时才有效
@property(nonatomic) BOOL waittingAck; //正在等待是否接收的响应，当消息属于文件类型时才有效
@property(nonatomic) BOOL cancelled; //是否取消接收，当消息属于文件类型时才有效
@property(nonatomic) BOOL uploaded; //是否已经上传到离线文件，当消息属于文件类型时才有效
@property(nonatomic) BOOL isFile; //消息是否文件类型

@property(nonatomic) BOOL offChat; //是否离线信息

@property(nonatomic) BOOL isWorking; //正在传输，当消息属于文件类型时才有效；(注意：本字段没有被持久化，只存在于内存，程序重启后复位)

@property(nonatomic, strong) NSString* customField; //自定义字段；SDK内部不使用本字段，仅便利于SDK使用者
@property(nonatomic, strong) NSDictionary* customData; //自定义字段；SDK内部不使用本字段，仅便利于SDK使用者

/**初始化方法
 * @param fromUid 消息发起人用户编号
 * @param callId 会话编号
 * @return 本实例对象
 */
- (id)initWithFromUid:(uint64_t)fromUid callId:(uint64_t)callId;

/**初始化方法
 * @param chatDot 一个聊天内容
 * @param fromUid 消息发起人用户编号
 * @param callId 会话编号
 * @return 本实例对象
 */
- (id)initWithChatDot:(EBChat*)chatDot andFromUid:(uint64_t)fromUid callId:(uint64_t)callId;

/**初始化方法
 * @param chatDots 一组聊天内容
 * @param fromUid 消息发起人用户编号
 * @param callId 会话编号
 * @return 本实例对象
 */
- (id)initWithChatDots:(NSArray*)chatDots andFromUid:(uint64_t)fromUid callId:(uint64_t)callId;

/**加入一个或多个聊天内容
 * @param chatDot 一个或多个聊天内容
 * @return 本实例对象
 */
- (id)addChatDot:(EBChat*)chatDot;

/**加入一组聊天内容
 * @param chatDots 一组聊天内容
 */
- (void)addChatDots:(NSArray *)chatDots;

/**获取富文本子元素数组
 * @return 一个或多个聊天内容，类型包括EBChatText、EBChatResource、EBChatImage、EBChatAudio
 */
- (NSArray*)chats;

//消息内容的大小(字节)
- (uint64_t)byteSize;

@end

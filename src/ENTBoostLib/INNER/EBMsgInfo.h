//
//  EBMsgInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-8.
//
//

#import "SOTP_defines.h"

@class SOTPAttach;

//聊天消息分包
@interface EBMsgPack : NSObject

@property(nonatomic) uint64_t index;
@property(nonatomic) uint64_t length;
@property(nonatomic) void* bytes;

- (id)initWithIndex:(uint64_t)index length:(uint64_t)length bytes:(void*)bytes;
- (id)initWithAttach:(SOTPAttach*)attach;

@end


///聊天消息结构
@interface EBMsgInfo : NSObject

@property(nonatomic) uint64_t msgId;    //消息ID
@property(nonatomic) uint64_t chatId;   //聊天ID
@property(nonatomic) uint64_t fromUid;  //消息发起方用户编号
@property(nonatomic) uint64_t toUid;    //消息接收方用户编号
@property(nonatomic) BOOL isPrivate;    //是否私聊
@property(nonatomic) enum EB_MSG_TYPE msgType;  //消息类型
@property(nonatomic) enum EB_RICH_SUB_TYPE subType; //消息子类型
@property(nonatomic) uint64_t size;  //消息总长度(字节数)
@property(nonatomic) int32_t packLen;   //数据分包长度
@property(nonatomic) int16_t offChat;   //是否离线信息
@property(nonatomic, strong) NSString* fileName;    //文件名
@property(nonatomic, strong) NSDate* msgTime;   //消息发送时间，空为当前时间
@property(nonatomic) uint64_t resId;    //离线文件资源ID
@property(nonatomic, strong) NSString* resCMServer; //离线文件CM Server
@property(nonatomic, strong) NSString* resCMAppName;    //离线文件CM AppName

@property(nonatomic, strong) NSDate* lastRevDataTime; //最新一次接收到的时间
@property(nonatomic) BOOL isFiredEvent; //是否已经触发完成事件

@property(nonatomic) BOOL isSaveToFile; //是否保存在文件中,存入文件将不再保存在内存中
@property(strong, nonatomic) NSString* tempRelativeFilePath; //临时保存文件相对路径(相对于沙盒根路径)
@property(strong, nonatomic) NSString* savedRelativeFilePath; //保存文件相对路径(相对于沙盒根路径；最终保存路径)
@property(strong, nonatomic) NSFileHandle* fileHandle; //写入文件的句柄
@property(strong, nonatomic) NSString* md5; //文件内容MD5

@property(atomic) BOOL isCancel; //是否已取消
@property(atomic) BOOL isFailure; //发送或接收失败

@property(atomic, strong) NSDate* lastSpeedCalculateTime; //上一次速率计算时间
@property(nonatomic) int32_t lastCompletionPackCount; //上一次速率计算时已完成的分包数量

- (id)initWithParameters:(NSDictionary*)parameters andAttach:(SOTPAttach*)attach;

///是否已经完成接收/发送
- (BOOL)isComplete;

///分包总数
- (int32_t)totalPackCount;

///剩余分包总数
- (int32_t)recoupPackCount;

/**添加分包
 * @param pack 数据分包
 * @return 是否正常添加(非重复), TRUE=正常,FALSE=重复
 */
- (BOOL)addPack:(EBMsgPack*)pack;

//生成全部分包索引信息
- (void)createRecoupPackIndexs;

/**获取未接收分包索引
 * @param max 最大数量限制
 */
- (NSArray*)recoupPackIndexsWithMax:(int)max;

///获取整条信息数据
- (NSData*)data;


@end

//
//  EBCallInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-11.
//
//

#import "SOTP_defines.h"

@class EBServerInfo;
@class EBAVServerInfo;
@class EBVCard;
@class EBGroupInfo;

@interface EBPersonOfCall : NSObject

@property(nonatomic) uint64_t uid; //用户编号
@property(nonatomic, strong) NSString* account; //用户账号
@property(nonatomic, strong) NSString* name; //用户名称
@property(nonatomic) uint64_t memberCode; //在部门或群组中的成员编号
@property(nonatomic, strong) EBVCard* vCard; //电子名片
@property(nonatomic, strong) NSString* clientAddress; //客户端登陆地址信息

//@property(atomic) BOOL isOffline; //当前是离线

- (id)initWithUid:(uint64_t)uid account:(NSString*)account memberCode:(uint64_t)memberCode vCard:(EBVCard*)vCard name:(NSString*)name clientAddress:(NSString*)clientAddress;

@end

@interface EBCallInfo : NSObject

@property(nonatomic) uint64_t callId; //会话编号
@property(nonatomic) uint64_t chatId; //聊天编号
@property(nonatomic, strong) NSString* chatKey; //聊天密钥
@property(nonatomic) uint64_t depCode; //部门或群组编号
@property(nonatomic) uint64_t myUid; //当前登录用户编号

//@property(nonatomic) uint64_t otherSideUid; //对方的用户编号，只针对于一对一会话有效

@property(nonatomic, strong) EBServerInfo* cmServer; //聊天服务端信息
@property(nonatomic, strong) EBServerInfo* umServer; //UM服务端信息
@property(nonatomic, strong) NSString* umKey; //UM密钥

@property(atomic) BOOL includeVideo; //打开视频标识
@property(atomic) BOOL includeAudio; //打开音频标识
@property(nonatomic, strong) EBAVServerInfo* vServer; //视频服务端信息
@property(nonatomic, strong) EBAVServerInfo* aServer; //音频服务端信息
@property(nonatomic, strong) NSMutableDictionary* avSpeakers; //出音视频的成员(演讲者)。注意：应先通过[speakers copy]复制一份再进行循环遍历这个dictionary；不允许对它进行写操作，以免与内部多线程操作有冲突
@property(nonatomic, strong) NSMutableDictionary* avListeners; //接收音视频的成员(接收者，这里也包括收听者本人)。注意：应先通过[listeners copy]复制一份再进行循环遍历这个dictionary；不允许对它进行写操作，以免与内部多线程操作有冲突

//@property(nonatomic) BOOL isConnected; //是否已经完成连接

@property(nonatomic, strong) NSDate* lastRevTime; //最新一次接收数据时间
@property(nonatomic, strong) NSDate* invalidTime; //开始失效时间
//@property(nonatomic) BOOL isDeleted; //是否失效并将要被删除
@property(atomic) EB_CALL_STATE callState; //会话状态

@property(nonatomic, strong) NSMutableDictionary* persons; //成员列表{key =uid ,obj = EBPersonOfCall}; 注意：应先通过[persons copy]复制一份再进行循环遍历这个dictionary；不允许对它进行写操作，以免与内部多线程操作有冲突

/**初始化方法
 * @param callId 会话编号
 * @param depCode 部门或群组编号，一对一会话填0
 * @param person 一个成员信息，非一对一会话填nil
 */
- (id)initWitCallId:(uint64_t)callId depCode:(uint64_t)depCode person:(EBPersonOfCall*)person;

/**初始化方法, 群组会话
 * @param depCode 部门或群组信息，这里不可以填0
 * @param memberInfos 群组成员
 * @param callId 会话编号
 * @param exceptionUid 除外的用户编号，与该编号相等的成员不加入列表
 */
- (id)initWithGroup:(uint64_t)depCode memberInfos:(NSArray*)memberInfos callId:(uint64_t)callId exceptUid:(uint64_t)exceptUid;

///是否部门或群组会话
- (BOOL)isGroupCall;

/**获取会话中某一成员
 * @param uid 成员的用户编号
 * @return 成员实例
 */
- (EBPersonOfCall*)personWithUid:(uint64_t)personUid;

///获取会话中一个成员，当前登录用户除外
- (EBPersonOfCall*)onePerson;

/////获取当前会话离线的成员
//- (NSArray*)personsOfOffline;

///向会话追加一个成员，如果成员已经存在则覆盖
- (void)addPerson:(EBPersonOfCall*)person;

///**更新成员在线状态
// * @param isOffline 在线状态(相对于是否在已经进入会话而已，非一般在线离线状态)
// * @param uid 用户编号
// */
//- (void)updatePersonOffline:(BOOL)isOffline forUid:(uint64_t)uid;

/**更新成员电子名片
 * @param vCard 电子名片,如果为nil就不更新
 * @param clientAddress 用户客户端登陆地址信息,如果为nil就不更新
 * @param uid 用户编号
 */
- (void)updatePersonVCard:(EBVCard*)vCard andClientAddress:(NSString*)clientAddress forUid:(uint64_t)uid;

/////会话是否允许发消息(每次发消息前都应该检查一次)
//- (BOOL)isCanTalk;

////获取获取UID最小的在线成员(自己除外)
//- (EBPersonOfCall*)minUidOnlinePerson;

@end

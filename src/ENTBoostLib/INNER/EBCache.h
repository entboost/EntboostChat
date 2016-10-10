//
//  EBCache.h
//  ENTBoostKit/Users/zhongzf/Documents/developer/ios/ENTBoostKit/ENTBoostKit/LogonCenter.h
//
//  Created by zhong zf on 14-7-1.
//
//

@class EBLoadingData;
@class EBMsgPack;
@class EBMsgInfo;
@class EBCallInfo;
@class EBPersonOfCall;
@class EBRTPFrame;

//FCMMack 响应回调模块
typedef void(^EB_CM_MACK_BLOCK)(uint64_t chatId, uint64_t msgId, uint64_t fromUid, int ackType);

/*内容发送进度回调模块
 percent 传输完成百分比
 speed 传输速率
 */
typedef void(^EB_PROCESSING_BLOCK)(double_t percent, double_t speed, uint64_t callId, uint64_t msgId);
typedef void(^EB_PROCESSING_BLOCK2)(double_t percent, double_t speed, uint64_t callId, uint64_t msgId, uint64_t resId);

//FCMMack Block封装类
@interface BlockEntity : NSObject

@property(strong, nonatomic) EB_CM_MACK_BLOCK cmMackBlock;
@property(strong, nonatomic) EB_PROCESSING_BLOCK processingBlock;
@property(nonatomic) BOOL isCancel; //消息是否被取消发送
@property(strong, nonatomic) NSDate* createdTime;

- (id)initWithCMMackBlock:(EB_CM_MACK_BLOCK)cmMackBlock andProcessingBlock:(EB_PROCESSING_BLOCK)processingBlock;

@end

@interface EBCache : NSObject


//获取全局单实例
+ (EBCache*)sharedCache;

///**记录一个临时数据实例
// * @param lData 数据实例
// */
//- (void)addLdData:(EBLoadingData*)lData;

/**获取已有的临时数据实例
 * @param cid 调用标识
 */
- (EBLoadingData*)ldData:(uint32_t)cid;

#pragma mark - 文件收发

/**记录一个Block
 * @param cmMackBlock
 * @param processingBlock
 * @param msgId 消息编号
 */
- (void)addCMMackBlock:(EB_CM_MACK_BLOCK)cmMackBlock andProcessingBlock:(EB_PROCESSING_BLOCK)processingBlock forMsgId:(uint64_t)msgId;

///获取FCMMackBlock
- (EB_CM_MACK_BLOCK)cmMackBlockWithMsgId:(uint64_t)msgId;
///获取ProcessingBlock
- (EB_PROCESSING_BLOCK)processingBlockWithMsgId:(uint64_t)msgId;
/////设置取消发送标记为TRUE
//- (void)cancelMsg:(uint64_t)msgId;
/////获取消息取消发送标记
//- (BOOL)isMsgCancel:(uint64_t)msgId;
///删除block
- (void)removeBLockWithMsgId:(uint64_t)msgId;

///控制信息并发下载的信号量
@property(strong, nonatomic) dispatch_semaphore_t msgLoadingSemaphore;

#pragma mark - 资源加载

/**判断一个资源加载任务是否存在
 * @param resId 资源编号
 * @return NO=不存在，YES=存在
 */
- (BOOL)isResourceLoadingExists:(uint64_t)resId;

/**加入一个资源加载任务
 * @param resId 资源编号
 * @return 是否成功加入；NO=不成功(相同资源编号的任务正在加载)，YES=成功
 */
- (BOOL)addResourceLoading:(uint64_t)resId;

/**删除一个资源加载任务
 * @param resId 资源编号
 */
- (void)removeResourceLoading:(uint64_t)resId;

///删除所有资源加载任务
- (void)removeAllResourceLoading;

#pragma mark - 聊天信息

/**记录一个聊天信息实例
 * @param msgInfo 聊天信息实例
 * @return 是否记录(非重复), TRUE=正常, FALSE=重复
 */
- (BOOL)addMsg:(EBMsgInfo*)msgInfo;

/**记录一个聊天信息数据分包
 * @param pack 数据分包
 * @param msgId 聊天信息ID
 * @return 是否正常记录(非重复), TRUE=正常, FALSE=重复
 */
- (BOOL)addMsgPack:(EBMsgPack*)pack forMsgId:(uint64_t)msgId;

/**获取聊天信息实例
 * @param msgId 聊天信息ID
 * @return 聊天信息实例
 */
- (EBMsgInfo*)msgInfoWithMsgId:(uint64_t)msgId;

/**获取消息未完成数据包索引
 * @param msgId 聊天信息ID
 * @return 聊天信息实例
 */
- (NSArray*)recoupPackWithMsgId:(uint64_t)msgId;

/**获取消息已完成百分比
 * @param msgId 聊天信息ID
 * @return 聊天信息实例
 */
- (double_t)completionPercentWithMsgId:(uint64_t)msgId;

/**获取消息传输速率
 * @param msgId 聊天信息ID
 * @return 聊天信息实例
 */
- (double_t)speedRateWithMsgId:(uint64_t)msgId;

/**删除一个聊天信息实例
 * @param msgId 聊天信息ID
 */
- (void)removeMsgInfo:(uint64_t)msgId;

///删除全部聊天信息实例 
- (void)removeAllMsgInfo;

///暂存离线信息，等待排序后一起触发接收完成事件
- (void)addOffChat:(EBMsgInfo*)msgInfo callId:(uint64_t)callId fromServerAddress:(NSString*)fromServerAddress;

/**触发离线信息接收完成事件
 * @param eventBlock 执行触发事件的回调block
 */
- (void)offChatFireEventWithBlock:(void(^)(NSArray* msgInfos))eventBlock;


#pragma mark - 聊天会话

///加入会话信息
- (void)addCallInfo:(EBCallInfo*)callInfo;

///获取全部会话信息
- (NSDictionary*)callInfos;

///获取会话信息
- (EBCallInfo*)callInfoWithCallId:(uint64_t)callId;

///获取会话信息
- (EBCallInfo*)callInfoWithChatId:(uint64_t)chatId;

/**获取会话信息
 * @param uid 用户编号, 0=不作为查询条件
 * @param account 用户账号, nil=不作为查询条件
 * @param depCode 群组编号, 0=寻找一对一会话, 大于0寻找群组会话
 */
- (EBCallInfo*)callInfoWithUid:(uint64_t)uid account:(NSString*)account depCode:(uint64_t)depCode;

///**添加成员到会话中
// * @param person 成员信息
// * @param callId 会话编号
// */
//- (BOOL)addPerson:(EBPersonOfCall*)person forCallId:(uint64_t)callId;

///**删除会话中成员
// * @param uid 成员用户编号
// * @param callId 会话编号
// */
//- (BOOL)removePersonWithUid:(uint64_t)uid forCallId:(uint64_t)callId;

///删除会话信息
- (void)removeCallInfoWithCallId:(uint64_t)callId;

///删除所有会话信息
- (void)removeAllCallInfo;

#pragma mark - 音视频

/*! 获取音视频演讲者列表
 @function
 @discussion
 @param callId 会话编号
 @return NSDictionary类型 演讲者列表
 */
- (NSDictionary*)avSpeakersWithCallId:(uint64_t)callId;

/*! 添加音视频演讲者到会话
 @function
 @discussion
 @param speaker 演讲者的用户编号
 @param callId 会话编号
 */
- (void)addAVSpeaker:(uint64_t)speaker forCallId:(uint64_t)callId;

/*! 从会话删除指定音视频演讲者
 @function
 @discussion
 @param uid 演讲者的用户编号
 @param callId 会话编号
 */
- (void)removeAVSpeaker:(uint64_t)uid forCallId:(uint64_t)callId;

/*! 删除会话所有音视频演讲者
 @function
 @discussion
 @param callId 会话编号
 */
- (void)removeAllAVSpeakerWithCallId:(uint64_t)callId;


/*! 获取音视频接收者列表
 @function
 @discussion
 @param callId 会话编号
 @return NSDictionary类型 接收者列表
 */
- (NSDictionary*)avListenersWithCallId:(uint64_t)callId;

/*! 添加音视频接收者到会话
 @function
 @discussion
 @param listener 接收者的用户编号
 @param callId 会话编号
 */
- (void)addAVListener:(uint64_t)listener forCallId:(uint64_t)callId;

/*! 从会话删除指定音视频接收者
 @function
 @discussion
 @param speaker 接收者的用户编号
 @param callId 会话编号
 */
- (void)removeAVListener:(uint64_t)listener forCallId:(uint64_t)callId;

/*! 删除会话所有音视频接收者
 @function
 @discussion
 @param callId 会话编号
 */
- (void)removeAllAVListenerWithCallId:(uint64_t)callId;

/*! 删除所有会话内音视频演讲者和接收者信息
 @function
 @discussion
 @param callId 会话编号
 */
- (void)clearAllAVSpeakersAndListeners;

/*! 添加数据帧到缓存队列
 @function
 @param newRtpFrame RTP数据帧
 @param fromUid 数据帧发送方
 @param callId 会话编号
 @param delegate 回调代理
 */
- (void)addRtpFrame:(EBRTPFrame*)newRtpFrame fromUid:(uint64_t)fromUid callId:(uint64_t)callId delegate:(id)delegate;

/*! 获取并删除首个音频数据帧
 @function
 @param fromUid 数据帧发送方
 @param callId 会话编号
 @return 首个音频数据帧
 */
- (EBRTPFrame*)eraseFirstRtpAudioFrameWithUid:(uint64_t)fromUid callId:(uint64_t)callId;

/*! 获取并删除首个视频数据帧
 @function
 @param fromUid 数据帧发送方
 @param callId 会话编号
 @return 首个视频数据帧
 */
- (EBRTPFrame*)eraseFirstRtpVideoFrameWithUid:(uint64_t)fromUid callId:(uint64_t)callId;

/*! 获取并删除多个音频数据帧
 @function
 @discussion 按从头到尾顺序
 @param fromUid 数据帧发送方
 @param callId 会话编号
 @param limit 返回数据帧数量最大限制
 @return 音频数据帧列表
 */
- (NSArray*)eraseRtpAudioFramesWithUid:(uint64_t)fromUid callId:(uint64_t)callId limit:(NSUInteger)limit;

/*! 获取并删除多个视频数据帧
 @function
 @discussion 按从头到尾顺序
 @param fromUid 数据帧发送方
 @param callId 会话编号
 @param limit 返回数据帧数量最大限制
 @return 视频数据帧列表
 */
- (NSArray*)eraseRtpVideoFramesWithUid:(uint64_t)fromUid callId:(uint64_t)callId limit:(NSUInteger)limit;

/*!清空某会话的RTP数据帧
 @param callId 会话编号
 */
- (void)clearRtpFramesWithCallId:(uint64_t)callId;

///清空RTP数据帧缓存
- (void)clearAllRtpFrames;

@end


#pragma mark - extension
@interface EBCache()

///获取表情资源
- (NSArray*)expressions;

///获取头像资源
- (NSArray*)headPhotos;

/**批量加入表情或头像资源描述信息,每次调用都将删除原有旧数据
 * @param emmotions 表情或头像资源集
 */
- (void)setEmotions:(NSDictionary*)emotions;

///获取表情或头像资源描述信息
- (NSDictionary*)emotions;

/**设置某个表情或头像资源加载完成
 * @param resId 资源ID
 */
- (void)emotionCompletion:(uint64_t)resId;

///表情和头像资源是否已经全部加载完毕
- (BOOL)isLoadEmotionsComplete;

@end
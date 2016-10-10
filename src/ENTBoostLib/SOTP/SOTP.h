//
//  SOTP.h
//  SOTP
//
//  Created by zhong zf on 13-7-24.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "SOTP_defines.h"
#import "SOTPData.h"

//发送重试最大次数
#define SOTP_RETRY_TIMES_MAX 4
//发送重试时间间隔，3秒
#define SOTP_RETRY_INTERVA_MAX dispatch_time(DISPATCH_TIME_NOW, 3.0f * NSEC_PER_SEC)

@class SOTPCache;

@interface SOTP : NSObject<GCDAsyncUdpSocketDelegate>

@property(strong, nonatomic) NSString* host;
@property(nonatomic) uint16_t port;
@property(strong, nonatomic) NSString* appname;
@property(strong, nonatomic) NSString* account;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) NSString* encode;
@property(nonatomic) BOOL ack;

@property(strong, atomic) NSString* aesPwd; //aes密钥

//本SOTP实例是否已经关闭
@property(atomic) BOOL isClosed;
//最新一次接收到业务数据
@property(strong, atomic) NSDate* lastRevBusinessDate;

- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname delegate:(id)aDelegate isCheckActive:(BOOL)isCheckActive isCheckRevBusiness:(BOOL)isCheckRevBusiness;

- (id)initWithHost:(NSString*)host port:(int16_t)port appname:(NSString*)appname account:(NSString*)account password:(NSString*) password encode:(NSString*)encode ack:(BOOL)ack delegate:(id)aDelegate isCheckActive:(BOOL)isCheckActive isCheckRevBusiness:(BOOL)isCheckRevBusiness;

///-----------访问服务器功能

/**open session 打开会话
 * @param successBlock 成功后回调block
 * @param failureBlock 失败后回调block
 * @param timeOverBlock 超时后回调block
 */
- (void)openSession:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**close session 关闭会话
 * @param successBlock 成功后回调block
 * @param failureBlock 失败后回调block
 * @param timeOverBlock 超时后回调block
 */
- (void)closeSession:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**激活会话
 * @param successBlock 成功后回调block
 * @param failureBlock 失败后回调block
 * @param timeOverBlock 超时后回调block
 */
- (void)activeSession:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

/**call function api调用
 * @param api 接口函数名称
 * @param signid 接口函数标识
 * @param parameters 接口输入参数
 * @param attach 附件
 * @param justCallReturnBlockOneTimes 是否只使用一次api block回调，剩余的数据由onReceiveData回调代理返回给上层
 * @param noReturn 调用后不返回结果
 * @param hasSeq 是否产生seq
 * @param successBlock 成功后回调block
 * @param failureBlock 失败后回调block
 * @param timeOverBlock 超时后回调block
 */
- (void)callWithApi:(NSString*)api signid:(uint32_t)signid parameters:(NSDictionary*)parameters attach:(SOTPAttach*)attach justCallReturnBlockOneTimes:(BOOL)justCallReturnBlockOneTimes noReturn:(BOOL)noReturn hasSeq:(BOOL)hasSeq
            success:(SOTPSuccessBlock)successBlock failure:(SOTPFailureBlock)failureBlock timeOver:(SOTPTimeOverBlock)timeOverBlock;

///-----------保存seq关联数据sotp data
/**保存sotp数据
 * @param data sotp数据
 * @param seq 序列号
 */
- (void)setData:(SOTPData*)data withSeq:(uint16_t)seq;

/**读取sotp数据
 * @param seq 序列号
 * @return sotp数据
 */
- (SOTPData*)dataWithSeq:(uint16_t)seq;

/**删除一条sotp数据
 * @param seq 序列号
 */
- (void)removeDataWithSeq:(uint16_t)seq;

///删除所有seq数据
- (void)removeAllSeqDatas;



///----------辅助工具

//域名转换为IP
//如果不成功时依然返回的是域名
+ (NSString*)ipFromHost:(NSString*)host;

/*!
    @param data 数据对象
    @param bSent 是否待发送的数据; YES=待发送的数据，NO=接收到的数据
    @param security 接收的数据是否已加密
 */
+ (void)printData:(NSData*)data forSent:(BOOL)bSent security:(BOOL)security;

///产生 指令发送的cid
+ (uint32_t)nextCid;

///服务器地址格式转换

/** 组合访问地址
 * @param host ip地址或域名
 * @param port 端口号
 * 
 * @return 访问地址，如：abc.com:8888
 */
+ (NSString*)addressWithHost:(NSString*)host port:(int16_t)port;

/** 提取IP地址或域名
 * @param address 访问地址，如：abc.com:8888
 *
 * @return ip地址
 */
+ (NSString*)hostWithAddress:(NSString*)address;


/** 提取端口号
 * @param address 访问地址，如：abc.com:8888
 * 
 * @return 端口号
 */
+ (int16_t)portWithAddress:(NSString*)address;


@end

//回调事件协议
@protocol SOTPDelegate
@optional

///SOTP会话失效，接收到该事件后一般都需要重新调用openSession()进行重新验证
- (void)sotpSessionInvaild:(uint32_t)cid;

///APPID onlinekey失效
- (void)sotpAppOnlinekeyTimeout:(uint32_t)cid;

///**远程服务关闭状态
// * @param cid
// * @param type 类型，1. SOTP 2. SOTPClient
// */
//- (void)sotpServerHasDown:(uint32_t)cid type:(NSString*)type;

///接收到信息
- (void)onReceiveData:(SOTPData*)data cid:(uint32_t)cid;

@end

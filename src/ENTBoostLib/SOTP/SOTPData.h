//
//  SOTPData.h
//  SOTP
//
//  Created by zhong zf on 13-7-25.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SOTPData_h
#define SOTPData_h


//协议操作枚举定义
typedef enum 
{
    OPEN = 0,
    CLOSE,
    ACTIVE,
    CALL,
    ACK
} SOTP_ACTION;

// 字串 to 枚举
//#define cSOTPActionEnum(string) ([SOTPActionGet indexOfObject:string])
//end 协议动作枚举定义

//c类型字符串转换为对象字符串
#define cToOCStr(cstring) [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding]

@class SOTPData;
@class SOTP;
@class SOTPAttach;

///成功后回调的block块定义
typedef void (^SOTPSuccessBlock)(SOTPData* revData, uint32_t cid);
///失败后回调的block块定义
typedef void (^SOTPFailureBlock)(NSError* error);
///超时后回调的block块定义
typedef void (^SOTPTimeOverBlock)(NSError* error);

@interface SOTPData : NSObject

@property(nonatomic) SOTP_ACTION action;
@property(nonatomic) uint16_t seq;
@property(nonatomic) BOOL hasSeq; //seq是否存在
@property(nonatomic) BOOL ack; //要求等待对方ack响应
@property(strong, nonatomic) NSString* account;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) NSString* encode;
@property(nonatomic) uint32_t cid;
@property(strong, nonatomic) NSString* sid;
@property(nonatomic) uint32_t signId;
@property(strong, nonatomic) NSString* appname;
@property(strong, nonatomic) NSString* api;
@property(strong, nonatomic) NSDictionary* parameters;
@property(strong, nonatomic) SOTPAttach* attach;
@property(nonatomic) BOOL isAcked; //已经接收到ack响应
@property(nonatomic) int32_t returnCode; //返回状态码

@property(strong, atomic) NSString* ssl; //公钥
@property(strong, atomic) NSString* aesPwd; //AES密钥
@property(nonatomic) BOOL isSecurity; //是否加密

//@property(atomic) uint8_t sentTimes; //已经重试的次数
@property(atomic, strong) NSDate* callTime; //开始调用的时间
@property(atomic) BOOL isReceivedAtLeaseOneData; //是否已经至少接收到一次回复(非ack回复)
@property(nonatomic) BOOL isJustCallReturnBlockOneTimes; //是否只使用一次api block回调，剩余的数据由onReceiveData回调代理返回给上层

@property(copy, nonatomic) SOTPSuccessBlock successBlock; //成功后调用的block
@property(copy, nonatomic) SOTPFailureBlock failureBlock; //失败后调用的block
@property(copy, nonatomic) SOTPTimeOverBlock timeOverBlock; //超时后调用的block

//默认初始化函数，action = CALL
- (id)init;
/**初始化函数
 * @param action 协议操作
 */
- (id)initWithAction:(SOTP_ACTION)action;

/**协议操作类型(枚举)转换为字符串
 * @paramm type
 */
+ (NSString*)cSOTPActionString:(SOTP_ACTION)type;

@end


#endif /* SOTPData_h */

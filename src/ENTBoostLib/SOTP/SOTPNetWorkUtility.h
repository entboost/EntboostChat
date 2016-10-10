//
//  SOTPNetWorkUtility.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/11/1.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOTPNetWorkUtility : NSObject

@property (atomic) BOOL isIPv6; //是否IPv6协议
@property (atomic) BOOL isCheckIPType; //是否已成功检测IP类型(V4 or V6)

//获取全局单例
+ (SOTPNetWorkUtility*)sharedInstance;

//获取本机IP地址(必须在有网的情况下才有效)
+ (NSString*)deviceIPAdress;

///输入的value参数是否IP地址(支持IPV6)
+ (BOOL)isIP:(NSString*)value;

///输入的value参数是否IPV4地址
+ (BOOL)isIPV4:(NSString*)value;

///输入的value参数是否IPV6地址
+ (BOOL)isIPV6:(NSString*)value;

/**
 * 通过域名或主机名解析为IPV6地址
 * 也可以把IPV4地址自动转换为IPV6地址(IOS9.2+)
 * 默认仅获取SOCK_DGRAM(报文方式-UDP)相关地址信息
 * @param host 域名、主机名、IP地址
 */
+ (NSString*)getIPV6:(NSString*)host;

/**
 * 通过域名或主机名解析IP地址(支持IPV6)
 * 也可以把IPV4地址自动转换为IPV6地址(IOS9.2+)
 * 默认仅获取SOCK_DGRAM(报文方式-UDP)相关地址信息
 * @param host 域名、主机名、IP地址
 * @param v6 是否获取IPV6地址；YES=获取IPV6，NO=获取IPV4
 */
+ (NSString*)getIPV4V6:(NSString*)host forV6:(BOOL)v6;

/**
 * 通过域名或主机名解析IP地址(支持IPV6)
 * 也可以把IPV4地址自动转换为IPV6地址(IOS9.2+)
 * @param host 域名、主机名、IP地址
 * @param v6 是否获取IPV6地址；YES=获取IPV6，NO=获取IPV4
 * @param sockType sock类型；仅支持SOCK_DGRAM(报文方式-UDP)和SOCK_STREAM(流方式-TCP);
 */
+ (NSString*)getIPV4V6:(NSString*)host forV6:(BOOL)v6 sockType:(int)sockType;

///检测当前设备IP类型
- (void)checkIpType;

///启动域名解析任务线程
- (void)startResolveDomainTask;

///结束域名解析任务线程
- (void)stopResolveDomainTask;

///从本地化缓存中获取IP，如果不存在则尝试解析
///本方法以阻塞方式执行
- (NSString*)ipInCacheWithDomain:(NSString*)hostName;

@end

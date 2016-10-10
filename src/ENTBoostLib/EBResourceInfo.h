//
//  EBResourceInfo.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/1/6.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EBServerInfo;

@interface EBResourceInfo : NSObject

///头像资源CM服务器连接信息
@property(strong, nonatomic) EBServerInfo* cmServerInfo;
///头像文件MD5码
@property(strong, nonatomic) NSString* md5;
///头像资源ID
@property(nonatomic) uint64_t resId;

///初始化方法
- (id)initWithDictionary:(NSDictionary *)dict;

///初始化方法
- (id)initWithResId:(uint64_t)resId md5:(NSString*)md5 cmHttpServer:(NSString*)cmHttpServer cmAppName:(NSString*)cmAppName cmServer:(NSString*)cmServer;

@end

//
//  SOTPBuilder.h
//  SOTP
//
//  Created by zhong zf on 13-8-4.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SOTPData;
@class SOTP;

@interface SOTPBuilder : NSObject

//解析接收的格式数据
+ (SOTPData*)parseSOTP:(NSData*)data sotp:(SOTP*)sotp;
//创建发送的格式数据
+ (NSData*)bulidSOTPData:(SOTPData*)sotpData sotp:(SOTP*)sotp;

/*! 在字节数组的开始位置匹配指定子字节数组
 @function
 @param pBuffer 源字节数组
 @param pCompare 子字节数组
 @param pLeftIndex (输出)，能匹配上时，字节数组的结束位置向后延一个字节
 @return 是否能匹配
 */
+ (BOOL)compareWithBytes:(const char *) pBuffer andCompare:(const char *) pCompare andLeftIndex:(int*) pLeftIndex;

@end

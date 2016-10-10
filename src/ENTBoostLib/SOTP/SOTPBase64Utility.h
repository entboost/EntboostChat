//
//  SOTPBase64Utility.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/4/3.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOTPBase64Utility : NSObject

/** base64格式字符串转换为二进制数据
 * @param string base64格式字符串
 * @return 二进制数据对象
 */
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;


/**二进制数据转换为base64格式字符串
 * @param data 二进制数据对象
 * @return base64格式字符串
 */
+ (NSString *)base64EncodedStringFrom:(NSData *)data;

@end

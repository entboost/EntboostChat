//
//  SOTPAESUtility.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/4/3.
//  Copyright (c) 2015年 entboost. All rights reserved.
//


#import <Foundation/Foundation.h>

@class NSString;

@interface SOTPAESUtility : NSObject

/*!
    @function AES加密
    @discussion 支持CBC/NoPadding填充模式，不足16位的整数倍，填充0后再加密
    @param data 加密前数据
    @param key 密钥
    @return 加密后数据
 */
+ (NSData *)encryptData:(NSData*)data usingKey:(NSString *)key;

/*!
    @function AES解密
    @discussion 支持CBC/NoPadding填充模式
    @param data 解密前数据
    @param key 密钥
    @return 解密后数据
 */
+ (NSData *)decryptData:(NSData*)data usingKey:(NSString *)key;

@end

//
//  CHKeychain.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-5.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserNamePassword;

@interface CHKeychain : NSObject

/**保存用户名和密码
 * @param userName 用户名
 * @param password 密码
 */
+ (void)saveUserName:(NSString*)userName AndPassword:(NSString*)password;

/////删除记录的密码
//+ (void)removePassword;

///删除记录的用户名
+ (void)removeUserName:(NSString*)userName;

/*! 获取最新一个已保存的用户名和密码
 @return UserNamePassword对象
 */
+ (UserNamePassword*)lastUserNamePassword;

///获取全部已保存的用户名和密码队列
+ (NSArray*)userNamePasswords;

/////获取已保存的密码
//+ (NSString*)password;

+ (void)save:(NSString *)service data:(id)data;

+ (id)load:(NSString *)service;

+ (void)del:(NSString *)service;

@end

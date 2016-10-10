//
//  UserNamePassword.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/9/1.
//  Copyright (c) 2015年 EB. All rights reserved.
//

//  用户名和密码对象

#import <Foundation/Foundation.h>

@interface UserNamePassword : NSObject <NSCoding>

@property(nonatomic, strong) NSString*  userName;
@property(nonatomic, strong) NSString*  password;
@property(nonatomic, strong) NSDate*    updatedDate;

- (id)initWithUserName:(NSString*)userName password:(NSString*)password updatedDate:(NSDate*)updatedDate;

@end

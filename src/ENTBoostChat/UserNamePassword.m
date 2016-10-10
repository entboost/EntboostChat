//
//  UserNamePassword.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/9/1.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "UserNamePassword.h"

@implementation UserNamePassword

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self =[super init]) {
        self.userName = [aDecoder decodeObjectForKey:@"userName"];
        self.password = [aDecoder decodeObjectForKey:@"password"];
        self.updatedDate = [aDecoder decodeObjectForKey:@"updatedDate"];
    }
    
    return self;
}

- (id)initWithUserName:(NSString*)userName password:(NSString*)password updatedDate:(NSDate*)updatedDate
{
    if (self=[super init]) {
        self.userName = userName;
        self.password = password;
        self.updatedDate = updatedDate;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.userName forKey:@"userName"];
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeObject:self.updatedDate forKey:@"updatedDate"];
}

@end
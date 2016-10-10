//
//  NSString+Utility.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/8/29.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utility)

///验证邮箱格式合法性
- (BOOL)validatedEmail;

///验证手机号码格式合法性
- (BOOL)validatedCellPhone;

///URL转义
- (NSString *)URLEncodedString;

@end

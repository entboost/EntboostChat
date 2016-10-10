//
//  seedUtility.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "SeedUtility.h"

@implementation SeedUtility

+ (NSString*)uuid
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    
    CFRelease(uuid_ref);
    NSString *uuid = [NSString stringWithString:(__bridge NSString*)uuid_string_ref];
    
    CFRelease(uuid_string_ref);
    return uuid;
}

@end

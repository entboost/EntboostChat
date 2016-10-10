//
//  SOTPAttach.h
//  SOTP
//
//  Created by zhong zf on 13-7-27.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOTPAttach : NSObject

@property(strong, nonatomic) NSString* name;
@property(nonatomic) uint64_t total;
@property(nonatomic) uint64_t index;
@property(nonatomic) uint64_t length;
@property(nonatomic) void* bytes;

- (id)initWithName:(NSString*)name total:(uint64_t)total length:(uint64_t)length index:(uint64_t)index bytes:(const void*)bytes;

@end

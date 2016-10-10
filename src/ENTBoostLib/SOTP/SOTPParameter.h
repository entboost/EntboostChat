//
//  SOTPParameter.h
//  SOTP
//
//  Created by zhong zf on 13-7-27.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import <Foundation/Foundation.h>

//SOTP参数枚举定义
typedef enum
{
    STRING =0,
    INT,
    BIG_INT,
    FLOAT,
    STREAM
} SOTP_PARAMETER_TYPE;


@interface SOTPParameter : NSObject

@property(strong, nonatomic) NSString* name;
@property(nonatomic) SOTP_PARAMETER_TYPE type;
@property(nonatomic) NSInteger byteLength;
@property(strong, nonatomic) NSString* value;
//@property(nonatomic) Byte* bValue;

- (id)initWithName:(NSString*)name type:(SOTP_PARAMETER_TYPE)type value:(NSString*)value;
- (id)initWithName:(NSString*)name type:(SOTP_PARAMETER_TYPE)type value:(NSString*)value byteLength:(NSInteger)length;

- (NSString*)stringValue;

- (BOOL)booleanValue;

- (int)intValue;
- (int)intValueWithDefault:(int)defaultVal;

- (long)longValue;
- (long)longValueWithDefault:(long)defaultVal;

- (unsigned long)unsignedLongValue;
- (unsigned long)unsignedLongValueWithDefault:(unsigned long)defaultVal;

- (int64_t)longLongValue;
- (int64_t)longLongValueWithDefault:(int64_t)defaultVal;

- (uint64_t)unsignedLongLongValue;
- (uint64_t)unsignedLongLongValueWithDefault:(uint64_t)defaultVal;

- (float_t)floatValue;
- (float_t)floatValueWithDefault:(float_t)defaultVal;

- (double_t)doubleValue;
- (double_t)doubleValueWithDefault:(double_t)defaultVal;

+ (NSString*)cSOTPParameterTypeString:(SOTP_PARAMETER_TYPE)type;
+ (SOTP_PARAMETER_TYPE)cSOTPParameterTypeEnum:(NSString*)string;

@end


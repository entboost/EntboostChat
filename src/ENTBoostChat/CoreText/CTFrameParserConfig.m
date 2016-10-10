//
//  CTFrameParserConfig.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-11-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "CTFrameParserConfig.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"

#define RGB(A, B, C)    [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]

@implementation CTFrameParserConfig

- (id)init {
    if (self = [super init]) {
        _width = 200.0f;
        _fontSize = 14.0f;
        _lineSpace = 0.0f;
//        _textColor = RGB(108, 108, 108);
        _textColor = [UIColor blackColor];
    }
    return self;
}

+ (CTFrameParserConfig*)sharedConfig
{
    static CTFrameParserConfig* sharedConfig;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if (!sharedConfig) {
            sharedConfig = [[CTFrameParserConfig alloc] init];
            sharedConfig.width = [[UIScreen mainScreen] bounds].size.width - CHAT_CONTENT_GAP_WIDTH;
        }
    });
    return sharedConfig;
}

@end

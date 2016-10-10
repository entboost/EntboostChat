//
//  CTFrameParserConfig.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-11-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTFrameParserConfig : NSObject

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, strong) UIColor *textColor;

///获取全局单实例
+ (CTFrameParserConfig*)sharedConfig;

@end

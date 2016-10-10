//
//  CustomSeparator.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "CustomSeparator.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"

@implementation CustomSeparator

- (id)init
{
    if (self = [super init]) {
        self.color1 = CUSTOM_SEPARATOR_DEFAULT_COLOR;
        self.lineHeight1 = CUSTOM_SEPARATOR_DEFAULT_LINE_HEIGHT;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.color1 = CUSTOM_SEPARATOR_DEFAULT_COLOR;
        self.lineHeight1 = CUSTOM_SEPARATOR_DEFAULT_LINE_HEIGHT;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.color1 = CUSTOM_SEPARATOR_DEFAULT_COLOR;
        self.lineHeight1 = CUSTOM_SEPARATOR_DEFAULT_LINE_HEIGHT;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //必须设置背景色透明，否则IOS7中不能正常显示
    self.backgroundColor = [UIColor clearColor];

    CGContextRef context = UIGraphicsGetCurrentContext();

    //设置背景透明
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);

    //画线1(最底下)
    if (self.lineHeight1) {
        CGContextSetStrokeColorWithColor(context, self.color1.CGColor);
        CGContextSetLineWidth(context, self.lineHeight1);
        CGContextStrokeRect(context, CGRectMake(0, rect.size.height - self.lineHeight1, rect.size.width, self.lineHeight1));
    }
    
    //画线2(中间)
    if (self.lineHeight2) {
        CGContextSetStrokeColorWithColor(context, self.color2.CGColor);
        CGContextSetLineWidth(context, self.lineHeight2);
        CGContextStrokeRect(context, CGRectMake(0, rect.size.height - self.lineHeight1 - self.lineHeight2, rect.size.width, self.lineHeight2));
    }

    //画线3(最上层)
    if (self.lineHeight3) {
        CGContextSetStrokeColorWithColor(context, self.color3.CGColor);
        CGContextSetLineWidth(context, self.lineHeight3);
        CGContextStrokeRect(context, CGRectMake(0, rect.size.height - self.lineHeight1 - self.lineHeight2 - self.lineHeight3, rect.size.width, self.lineHeight3));
    }
}

@end

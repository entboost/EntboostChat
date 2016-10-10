//
//  CustomCell.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "CustomCell.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"

@implementation CustomCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.customSeparatorColor = CUSTOM_SEPARATOR_DEFAULT_COLOR;
        self.customSeparatorHeight = CUSTOM_SEPARATOR_DEFAULT_LINE_HEIGHT;
        self.hiddenCustomSeparatorTop = YES;
        self.hiddenCustomSeparatorBottom = NO;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)drawRect:(CGRect)rect
//{
//    [super drawRect:rect];
//    
////    //必须设置背景色透明，否则IOS7中不能正常显示
//    self.backgroundColor = [UIColor clearColor];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
////    //设置背景透明
////    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
////    CGContextFillRect(context, rect);
//    
//    //(顶部)
//    if (!self.hiddenCustomSeparatorTop) {
//        CGContextSetStrokeColorWithColor(context, self.customSeparatorColor.CGColor);
//        CGContextSetLineWidth(context, self.customSeparatorHeight);
//        CGContextStrokeRect(context, CGRectMake(0, 0, rect.size.width, self.customSeparatorHeight));
//    }
//    
//    //(底部)
//    if (!self.hiddenCustomSeparatorBottom) {
//        CGContextSetStrokeColorWithColor(context, self.customSeparatorColor.CGColor);
//        CGContextSetLineWidth(context, self.customSeparatorHeight);
//        CGContextStrokeRect(context, CGRectMake(0, rect.size.height - self.customSeparatorHeight, rect.size.width, self.customSeparatorHeight));
//    }
//}

@end

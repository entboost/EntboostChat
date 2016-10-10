//
//  CustomSeparator.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSeparator : UIView

@property(nonatomic, strong) UIColor* color1; //颜色1
@property(nonatomic, strong) UIColor* color2; //颜色2
@property(nonatomic, strong) UIColor* color3; //颜色3

//1、2、3分别从底到高排列
@property(nonatomic) CGFloat lineHeight1; //线高度1
@property(nonatomic) CGFloat lineHeight2; //线高度2
@property(nonatomic) CGFloat lineHeight3; //线高度3

@end

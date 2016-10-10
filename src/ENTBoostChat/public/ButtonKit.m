//
//  ButtonKit.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "ButtonKit.h"

@implementation ButtonKit

+ (UIBarButtonItem*)goBackBarButtonItemWithTarget:(id)target action:(SEL)action
{
//    UIButton* lBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [lBtn1 addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//    [lBtn1 setImage:[UIImage imageNamed:@"navigation_goback"] forState:UIControlStateNormal];
//    UIBarButtonItem * leftButton1 = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:nil action:nil];
//    leftButton1.customView = lBtn1;
//    
//    return leftButton1;
    return [self barButtonItemWithTarget:target action:action imageName:@"navigation_goback" title:@"返回"];
}

+ (UIBarButtonItem*)saveBarButtonItemWithTarget:(id)target action:(SEL)action
{
//    CGRect btnFrame = CGRectMake(0, 0, 30, 24);
//    UIButton* rbtn1 = [[UIButton alloc] initWithFrame:btnFrame];
//    [rbtn1 addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
//    [rbtn1 setImage:[UIImage imageNamed:@"navigation_save"] forState:UIControlStateNormal];
//    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton1.customView = rbtn1;
//    
//    return rightButton1;
    return [self barButtonItemWithTarget:target action:action imageName:@"navigation_save" title:@"保存"];
}

+ (UIBarButtonItem*)refreshBarButtonWithTarget:(id)target action:(SEL)action
{
    return [self barButtonItemWithTarget:target action:action imageName:@"navigation_refresh" title:@"刷新页面"];
}

+ (UIBarButtonItem*)searchBarButtonWithTarget:(id)target action:(SEL)action
{
    return [ButtonKit barButtonItemWithTarget:target action:action imageName:@"navigation_search" title:@"搜索"];
}

+ (UIBarButtonItem*)popMenuBarButtonWithTarget:(id)target action:(SEL)action
{
    return [ButtonKit barButtonItemWithTarget:target action:action imageName:@"navigation_menu" title:@"下拉菜单"];
}

+ (UIBarButtonItem*)barButtonItemWithTarget:(id)target action:(SEL)action imageName:(NSString*)imageName title:(NSString*)title
{
    CGRect btnFrame = CGRectMake(0, 0, 30, 24);
    UIButton* btn1 = [[UIButton alloc] initWithFrame:btnFrame];
    [btn1 addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn1 setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    UIBarButtonItem * button1 = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:nil];
    button1.customView = btn1;
    
    return button1;
}

@end

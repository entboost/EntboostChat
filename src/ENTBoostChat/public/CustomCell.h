//
//  CustomCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property(nonatomic, strong) UIColor* customSeparatorColor; //自定义分隔线颜色
@property(nonatomic) CGFloat customSeparatorHeight; //自定义分隔线高度
@property(nonatomic) BOOL hiddenCustomSeparatorTop; //隐藏自定义分隔线顶部
@property(nonatomic) BOOL hiddenCustomSeparatorBottom; //隐藏自定义分隔线底部

@end

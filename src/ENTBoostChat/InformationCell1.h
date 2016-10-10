//
//  MyInformationCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/29.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface InformationCell1 : CustomCell

@property(nonatomic, strong) IBOutlet UIImageView* customImageView; //自定义头像视图
@property(nonatomic, strong) IBOutlet UILabel* customTextLabel; //自定义标题Label
@property(nonatomic, strong) IBOutlet UILabel* customDetailTextLabel; //自定义详细Label
@property(nonatomic, strong) IBOutlet UILabel* customDetailTextLabel2; //自定义详细Label2

@property(nonatomic, strong) IBOutlet UISegmentedControl* customSegmentedCtrl; //分段选择器
@property (nonatomic, strong) UITapGestureRecognizer* customTapRecognizer; //点击视图手势识别器

@end

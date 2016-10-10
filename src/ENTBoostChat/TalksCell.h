//
//  TalksCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-9-10.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "BadgeCell.h"

@class CustomSeparator;

@interface TalksCell : BadgeCell

@property(nonatomic, strong) NSString* talkId; //对话归类编号
@property(nonatomic, strong) IBOutlet UIImageView* customImageView; //自定义头像视图
@property(nonatomic, strong) IBOutlet UILabel* customTextLabel; //自定义标题Label
@property(nonatomic, strong) IBOutlet UILabel* customDetailTextLabel; //自定义详细Label
@property(nonatomic, strong) IBOutlet UILabel* timeTextLabel; //时间标签Label

//@property(nonatomic, strong) IBOutlet CustomSeparator* customSeparator; //自定义分割线
@property(nonatomic, strong) UIColor* customSeparatorColor; //自定义分隔线颜色
@property(nonatomic) CGFloat customSeparatorHeight; //自定义分隔线高度
@property(nonatomic) BOOL hiddenCustomSeparatorTop; //隐藏自定义分隔线顶部
@property(nonatomic) BOOL hiddenCustomSeparatorBottom; //隐藏自定义分隔线底部

//@property(nonatomic, strong) NSIndexPath* currentIndexPath; //当前行

@property (nonatomic, strong) UITapGestureRecognizer* headPhotoTapRecognizer; //点击头像事件

@end
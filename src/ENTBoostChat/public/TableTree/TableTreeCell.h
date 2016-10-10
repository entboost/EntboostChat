//
//  TableTreeCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableTreeNode.h"

#define TableTreeCellIndent 10.0f

typedef enum {
    TableTree_CellType_Department = 1, //目录
    TableTree_CellType_Employee   //雇员
} TableTree_CellType;

@class TableTree;
@class TableTreeCell;
@class CustomSeparator;

//Cell内部控件事件代理
@protocol TableTreeCellDelegate <NSObject>
@required

//点击展开/折叠按钮事件
- (void)plusViewTap:(TableTreeCell *)cell;
//点击对话按钮事件
- (void)talkViewTap:(TableTreeCell *)cell;
//点击查看属性按钮事件
- (void)propertiesViewTap:(TableTreeCell *)cell;
////点击勾选按钮事件
//- (void)tickViewTap:(TableTreeCell *)cell;

@end

//TableTree视图元素
@interface TableTreeCell : UITableViewCell

@property (nonatomic, strong) TableTreeNode* node;

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView; //头像
@property (nonatomic, strong) IBOutlet UIImageView *plusImageView; //伸缩图标
@property (nonatomic, strong) IBOutlet UIImageView *talkImageView; //点击对话按钮
@property (nonatomic, strong) IBOutlet UIImageView *propertiesImageView; //点击查看属性按钮
@property (nonatomic, strong) IBOutlet UIImageView *tickImageView; //勾选按钮
@property (nonatomic, strong) IBOutlet UILabel *labelTitle; //文字标题
//@property (nonatomic, strong) IBOutlet UIView *underLine;
@property (nonatomic, strong) IBOutlet CustomSeparator* separator; //分隔线

@property (nonatomic) BOOL isHiddenTalkImageView; //是否隐藏点击对话按钮
@property (nonatomic) BOOL isHiddenPropertiesImageView; //是否隐藏查看属性按钮
@property (nonatomic) BOOL isHiddenTickImageView; //是否隐藏勾选按钮
@property (nonatomic) BOOL isDisableAvatarImageViewTap; //是否禁用点击头像事件

@property (nonatomic, strong) UITapGestureRecognizer* avatarImageViewTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* plusViewTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* talkViewTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* propertiesViewTapRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* tickViewTapRecognizer;

@property (weak, nonatomic) id<TableTreeCellDelegate> delegate;

+ (CGFloat)heightForCellWithType:(TableTree_CellType)type;

- (void)fillWithNode:(TableTreeNode*)node inCell:(TableTreeCell*)cell tree:(TableTree*)tree;

@end

//
//  TableTreeCell.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "TableTreeCell.h"
#import "TableTree.h"
#import "ENTBoost+Utility.h"
#import "ResourceKit.h"
#import "CustomSeparator.h"
#import "ENTBoostChat.h"

#define DepartmentCellHeight 50
#define EmployeeCellHeight  60

@interface TableTreeCell ()
@end

@implementation TableTreeCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarImageView.layer.cornerRadius = 5.f;
    self.avatarImageView.layer.masksToBounds = YES;
    CGFloat lineHeight = 1.0f;
    self.separator.lineHeight1 = lineHeight;
    self.separator.frame = CGRectMake(0, self.bounds.size.height-lineHeight, self.bounds.size.width, lineHeight);
}

+ (CGFloat)heightForCellWithType:(TableTree_CellType)type
{
    if (type == TableTree_CellType_Department) {
        return DepartmentCellHeight;
    }
    return EmployeeCellHeight;
}

///**计算指定节点下所有叶子节点的数量
// * @param parentNode 待计算的父节点
// * @param count 已累加数量
// */
//- (void)calculateAllLeafWithNode:(TableTreeNode*)parentNode count:(NSInteger*)count
//{
//    if (!parentNode.isDepartment)
//        return;
//    
//    if (parentNode.data[@"leafCount"]) {
//        NSInteger leafCount = ((NSNumber*)parentNode.data[@"leafCount"]).integerValue;
//        (*count) += leafCount;
//    }
//    
//    for (TableTreeNode* node in parentNode.subNodes) {
//        if (node.isDepartment) {
//            [self calculateAllLeafWithNode:node count:count];
//        }
//    }
//}

- (void)fillWithNode:(TableTreeNode*)node inCell:(TableTreeCell*)cell tree:(TableTree*)tree
{
    self.node = node;
    if (node) {
        TableTree_CellType cellType = node.isDepartment?TableTree_CellType_Department:TableTree_CellType_Employee;
        
        self.isHiddenTalkImageView = node.isHiddenTalkBtn;
        self.isHiddenPropertiesImageView = node.isHiddenPropertiesBtn;
        self.isHiddenTickImageView = node.isHiddenTickBtn;
        
        int level = 0;
        [tree caculateLevelOfNode:node level:&level];
        [self setCellStypeWithType:cellType originX:/*[node isRoot]?TableTreeCellIndent:*/node.originX level:level];
        //初始化标题颜色
        self.labelTitle.textColor = EBCHAT_DEFAULT_FONT_COLOR;//[UIColor colorWithHexString:@"#194E62"];
        
        //NSDictionary *dic = node.data;
        if (cellType == TableTree_CellType_Department) {
//            //设置背景颜色
//            if (level%2 == 1)
//                self.contentView.backgroundColor = [UIColor colorWithHexString:@"#D4F4FF"];
//            else
//                self.contentView.backgroundColor = [UIColor colorWithHexString:@"#EFFAFE"];
            
            //设置分隔线
//            CGRect frame = cell.separator.frame;
//            cell.separator.frame = CGRectMake(frame.origin.x, frame.origin.y - 1.0f, frame.size.width, 1.0f);
//            cell.separator.lineHeight1 = 1.0f;
//            cell.separator.color1 = [UIColor colorWithHexString:@"#c1dce5"];
//            cell.separator.lineHeight2 = 2.0f;
//            cell.separator.color2 = [UIColor colorWithHexString:@"#effafe"];
//            cell.separator.lineHeight3 = 1.0f;
//            cell.separator.color3 = [UIColor colorWithHexString:@"#c1dce5"];
            
            NSInteger leafCount = ((NSNumber*)node.data[@"leafCount"]).integerValue;
            
            NSInteger onlineCount = 0;
            NSNumber* onlineCountNum = [node.data objectForKey:@"onlineCount"];
            if (onlineCountNum)
                onlineCount = [onlineCountNum integerValue];
            
            if (leafCount) {
//                NSInteger allLeafCount =0 ;
//                [self calculateAllLeafWithNode:node count:&allLeafCount];
                NSMutableString* strFormat = [[NSMutableString alloc] init];
                [strFormat appendString:[NSString stringWithFormat:@"%@ [", node.name]];
                
                if (onlineCount>-1)
                    [strFormat appendString:[NSString stringWithFormat:@"%@/", @(onlineCount)]];
                
                [strFormat appendString:[NSString stringWithFormat:@"%@]", @(leafCount)]];
                self.labelTitle.text = strFormat; //[NSString stringWithFormat:strFormat, node.name, @(onlineCount), @(leafCount)];//node.subNodes.count];
            } else {
                self.labelTitle.text = node.name;
            }
            
            if (level < tree.deepInLevel) {
                EBGroupInfo* groupInfo = node.data[@"groupInfo"];
                if (node.isOpen) {
                    self.plusImageView.image = [UIImage imageNamed:groupInfo?[ResourceKit minusAccessoryImageNameWithGroupType:groupInfo.type]:@"minusAccessory"];
                } else {
                    self.plusImageView.image = [UIImage imageNamed:groupInfo?[ResourceKit plusAccessoryImageNameWithGroupType:groupInfo.type]:@"plusAccessory"];
                }
            } else {
                self.plusImageView.image = [UIImage imageNamed:@"deepAccessory"];
            }
            
//            self.avatarImageView.image = [UIImage imageNamed:@"Group"];
        } else {
            self.contentView.backgroundColor = [UIColor whiteColor];//[UIColor colorWithHexString:@"#effafe"];
            self.labelTitle.text = [NSString stringWithFormat:@"%@",node.name];
            if (node.textColor)
                self.labelTitle.textColor = node.textColor;
            
            if (node.icon) {
                self.avatarImageView.image = node.isOffline?[[UIImage imageWithContentsOfFile:node.icon] convertToGrayscale]:[UIImage imageWithContentsOfFile:node.icon];
            } else {
                self.avatarImageView.image = node.isOffline?[[UIImage imageNamed:[ResourceKit defaultImageNameOfUser]] convertToGrayscale]:[UIImage imageNamed:[ResourceKit defaultImageNameOfUser]];
            }
        }
        
        //设置图标垂直居中
        CGFloat centerY = cell.contentView.center.y;
        self.plusImageView.center = CGPointMake(self.plusImageView.center.x, centerY);
        self.talkImageView.center = CGPointMake(self.talkImageView.center.x, centerY);
        self.propertiesImageView.center = CGPointMake(self.propertiesImageView.center.x, centerY);
        self.tickImageView.center = CGPointMake(self.tickImageView.center.x, centerY);
    }
}

- (void)setCellStypeWithType:(TableTree_CellType)type originX:(CGFloat)x level:(int)level
{
    const CGFloat space = 8.0f;
    
    //获取按钮尺寸
    static CGRect propertiesImageViewFrame; //记录“查看属性”按钮最初位置
    static CGRect tickImageViewFrame;       //记录"勾选"按钮最初位置
    static CGRect talkImageViewFrame;       //记录"talk"按钮位置
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        propertiesImageViewFrame = self.propertiesImageView.frame;
        tickImageViewFrame = self.tickImageView.frame;
        talkImageViewFrame = self.talkImageView.frame;
    });
    
    if (type == TableTree_CellType_Department) { //部门节点
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                            self.contentView.frame.origin.y,
                                            self.contentView.frame.size.width, DepartmentCellHeight);
        
//        const CGFloat avatarWidth = 28.0f;
//        const CGFloat avatarHeight = avatarWidth;
//        const CGFloat avatarY = (DepartmentCellHeight - avatarHeight)/2;
        
        self.avatarImageView.hidden = YES;
        
        //设置 + 号的位置
        self.plusImageView.frame = CGRectMake(x + TableTreeCellIndent*(level+1), self.plusImageView.frame.origin.y,
                                              self.plusImageView.frame.size.width, self.plusImageView.frame.size.height);
        
//        //设置头像的位置
//        self.avatarImageView.frame = CGRectMake(self.plusImageView.frame.origin.x + space + self.plusImageView.frame.size.width, avatarY,
//                                                avatarWidth, avatarHeight);
        
        
        //设置标题宽度
        CGFloat width = self.contentView.frame.size.width - self.plusImageView.frame.origin.x - self.plusImageView.frame.size.width - (space*2);
        if (!self.isHiddenPropertiesImageView)
            width -= propertiesImageViewFrame.size.width;
        if (!self.isHiddenTalkImageView)
            width -= talkImageViewFrame.size.width;
        
        //设置标题的位置和尺寸
        self.labelTitle.frame = CGRectMake(self.plusImageView.frame.origin.x + self.plusImageView.frame.size.width + space, 0,
                                           width,
                                           self.contentView.frame.size.height);
//        //underline
//        self.underLine.frame = CGRectMake(x,
//                                          self.contentView.frame.size.height - 0.5,
//                                          self.contentView.frame.size.width - x,
//                                          0.5);
//        self.underLine.backgroundColor = [UIColor colorWithRed:242/255.f green:244/255.f blue:246/255.f alpha:1];
        
    } else { //成员节点
        self.accessoryType = UITableViewCellAccessoryNone;
        
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x,
                                            self.contentView.frame.origin.y,
                                            self.contentView.frame.size.width, EmployeeCellHeight);
        
        self.plusImageView.hidden = YES;
        
        //设置头像的位置
        CGFloat iconWidth = EmployeeCellHeight - 10;
        self.avatarImageView.frame = CGRectMake(x + TableTreeCellIndent*(level+1), EmployeeCellHeight/2.f - iconWidth/2.f, iconWidth, iconWidth);
        
        //设置标题宽度
        CGFloat width = self.contentView.frame.size.width - self.avatarImageView.frame.origin.x - self.avatarImageView.frame.size.width - (space*2);
        if (!self.isHiddenPropertiesImageView)
            width -= propertiesImageViewFrame.size.width;
        if (!self.isHiddenTalkImageView)
            width -= talkImageViewFrame.size.width;
        //设置标题的位置和尺寸
        self.labelTitle.frame = CGRectMake(self.avatarImageView.frame.origin.x+self.avatarImageView.frame.size.width + space,
                                           0,
                                           width,
                                           self.contentView.frame.size.height);
        
 //       self.talkImageView.hidden = YES;
//        //underline
//        self.underLine.frame = CGRectMake(x,
//                                          self.contentView.frame.size.height - 0.5,
//                                          self.contentView.frame.size.width - x,
//                                          0.5);
//        self.underLine.backgroundColor = [UIColor colorWithRed:242/255.f green:244/255.f blue:246/255.f alpha:1];
    }
    
    //设置是否隐藏按钮
    self.talkImageView.hidden = self.isHiddenTalkImageView;
    self.propertiesImageView.hidden = self.isHiddenPropertiesImageView;
    self.tickImageView.hidden = self.isHiddenTickImageView;
    
    //初始化位置
    self.propertiesImageView.frame = propertiesImageViewFrame;
    self.tickImageView.frame = tickImageViewFrame;
    self.talkImageView.frame = talkImageViewFrame;
    
    //如果右边按钮被隐藏，左边按钮向右偏移
    if (self.talkImageView.hidden) {
        self.propertiesImageView.frame = talkImageViewFrame; //"查看属性"按钮占最右侧
        self.tickImageView.frame = propertiesImageViewFrame; //“勾选”按钮占"查看属性"的原有位置
        
        if (self.propertiesImageView.hidden) {
            self.tickImageView.frame = talkImageViewFrame; //如果“查看属性”按钮也被隐藏，“勾选”按钮占最右侧(talk的位置)
        }
    } else {
        //如果“查看属性”按钮被隐藏，“勾选”按钮占"查看属性"位置
        if (self.propertiesImageView.hidden) {
            self.tickImageView.frame = propertiesImageViewFrame;
        }
    }
    
    //删除旧的点击事件触发器
    if (self.avatarImageViewTapRecognizer)
        [self removeGestureRecognizer:self.avatarImageViewTapRecognizer];
    if(self.plusViewTapRecognizer)
        [self removeGestureRecognizer:self.plusViewTapRecognizer];
    if(self.talkViewTapRecognizer)
        [self removeGestureRecognizer:self.talkViewTapRecognizer];
    if(self.propertiesViewTapRecognizer)
        [self removeGestureRecognizer:self.propertiesViewTapRecognizer];
    if (self.tickViewTapRecognizer)
        [self removeGestureRecognizer:self.tickViewTapRecognizer];
    
    //注册plusView点击事件触发器
    self.plusViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPlusViewTap)];
    [self.plusImageView addGestureRecognizer:self.plusViewTapRecognizer];
    
    //注册点击事件触发器
    if (!self.isDisableAvatarImageViewTap) {
        self.avatarImageViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPropertiesViewTap)];
        [self.avatarImageView addGestureRecognizer:self.avatarImageViewTapRecognizer];
    }
    if (!self.talkImageView.hidden) {
        self.talkViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTalkViewTap)];
        [self.talkImageView addGestureRecognizer:self.talkViewTapRecognizer];
    }
    if (!self.propertiesImageView.hidden) {
        self.propertiesViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPropertiesViewTap)];
        [self.propertiesImageView addGestureRecognizer:self.propertiesViewTapRecognizer];
    }
    if (!self.tickImageView.hidden) {
        self.tickViewTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTickViewTap)];
        [self.tickImageView addGestureRecognizer:self.tickViewTapRecognizer];
    }
    
    //更新勾选按钮
    [self updateTickView];
}

- (void)didPlusViewTap
{
    if([self.delegate respondsToSelector:@selector(plusViewTap:)]) {
        [self.delegate plusViewTap:self];
    }
}

- (void)didTalkViewTap
{
    if([self.delegate respondsToSelector:@selector(talkViewTap:)]) {
        [self.delegate talkViewTap:self];
    }
}

- (void)didPropertiesViewTap
{
    if([self.delegate respondsToSelector:@selector(propertiesViewTap:)]) {
        [self.delegate propertiesViewTap:self];
    }
}

- (void)didTickViewTap
{
    //取反
    BOOL isTickChecked = !self.node.isTickChecked;
    //更新数据
    self.node.isTickChecked = isTickChecked;
    //更新勾选按钮
    [self updateTickView];
}

//更新勾选按钮
- (void)updateTickView
{
    if (self.node.isTickChecked) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tick"]];
        imageView.frame = self.tickImageView.bounds;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [self.tickImageView addSubview:imageView];
    } else {
        for (UIView* view in  [self.tickImageView subviews]) {
            [view removeFromSuperview];
        }
    }
}

@end

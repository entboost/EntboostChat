//
//  CellUtility.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/2/26.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "CellUtility.h"
#import "ENTBoost+Utility.h"
#import "ENTBoostChat.h"
#import "InformationCell1.h"

@implementation CellUtility

//创建操作功能的cell
+ (InformationCell1*)tableView:(UITableView *)tableView functionCellForRowAtIndexPath:(NSIndexPath *)indexPath identifier:(NSString*)identifier functions:(NSArray*)functions buttonBlock:(void(^)(UIButton* button, NSString* function))block
{
    InformationCell1* cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if (functions.count) {
        NSMutableDictionary* views = [[NSMutableDictionary alloc] init];
        CGFloat hPadding = 10.0; //横向间隔
        CGFloat vPadding = 10.0; //纵向间隔
        CGFloat bHeight = 30.0; //按钮高度
        CGFloat bWidth = (cell.bounds.size.width - (hPadding*(functions.count+1)))/functions.count; //按钮宽度
        
        NSDictionary* metrics = @{@"bWidth":@(bWidth), @"bHeight":@(bHeight), @"hPadding":@(hPadding), @"vPadding":@(vPadding)};
        NSMutableString* vflH = [[NSMutableString alloc] initWithString:@"|"]; //横向VFL
        NSMutableString* vflV = [[NSMutableString alloc] initWithString:@"V:|"]; //纵向VFL
        
        for (NSUInteger i=0; i<functions.count; i++) {
            NSString* function = functions[i];
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.translatesAutoresizingMaskIntoConstraints = NO; //禁止自动生成约束
            EBCHAT_UI_SET_CORNER_VIEW_CLEAR1(button); //设置圆角边框
            
            [cell.contentView addSubview:button];
            
            //回调设置特殊属性
            if (block)
                block(button, function);
            
            //圆角边框
//            EBCHAT_UI_SET_CORNER_BUTTON_2(button);
            //按钮常规属性
            [button.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            [button setTitleShadowColor:[UIColor grayColor] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
            [button setBackgroundImage:[UIImage imageNamed:@"button-selected.png"] forState:UIControlStateSelected];
            
            //生成约束
            views[function] = button;
            [vflH appendFormat:@"-hPadding-[%@(bWidth)]", function];
            if (i==0)
                [vflV appendFormat:@"-vPadding-[%@(bHeight)]", function];
            else
                [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[%@(bHeight)]", function] options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
        }
        
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vflH options:NSLayoutFormatAlignAllTop metrics:metrics views:views]];
        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:vflV options:NSLayoutFormatAlignAllLeft metrics:metrics views:views]];
    }
    
    return cell;
}

@end

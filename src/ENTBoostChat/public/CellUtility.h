//
//  CellUtility.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/2/26.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InformationCell1;

@interface CellUtility : NSObject

/**创建操作功能的cell
 * @param tableView table视图
 * @param indexPath 索引
 * @param identifier xib标识
 * @param functions 操作功能列表
 * @param block 设置操作功能特殊属性回调
 */
+ (InformationCell1*)tableView:(UITableView *)tableView functionCellForRowAtIndexPath:(NSIndexPath *)indexPath identifier:(NSString*)identifier functions:(NSArray*)functions buttonBlock:(void(^)(UIButton* button, NSString* function))block;

@end

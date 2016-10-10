//
//  NSArray+Utility.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/8/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Utility)

/*! 创建用于gbk字符集排序的description
 @param fieldName 字段名称，通常'_'开头
 @param ascending 是否升序
 @return 排序条件描述
 */
+ (NSSortDescriptor*)gbkSortDescriptionWithFieldName:(NSString*)fieldName ascending:(BOOL)ascending;

@end

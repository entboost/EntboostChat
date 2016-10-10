//
//  TableTreeNode.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "TableTreeNode.h"

@implementation TableTreeNode

- (id)init
{
    if (self = [super init]) {
        self.sortIndex = kTableTreeNode_NormalSortIndex;
        self.departmentTypeSortIndex = kTableTreeNode_DepartmentTypeSortIndex;
        
        self.isHiddenPropertiesBtn = YES;
        self.isHiddenTalkBtn = YES;
        self.isHiddenTickBtn = YES;
    }
    return self;
}

- (BOOL)isRoot
{
    return self.parentNodeId == nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"name:%@",self.name];
}

@end
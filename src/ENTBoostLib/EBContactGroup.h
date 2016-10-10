//
//  EBContactGroup.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/1/22.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBContactGroup : NSObject

@property(nonatomic) uint64_t groupId; //分组编号
@property(nonatomic, strong) NSString* groupName; //分组名称

/**初始化方法
 * @param groupId 分组编号
 * @param groupName 分组名称
 */
- (id)initWithId:(uint64_t)groupId groupName:(NSString*)groupname;

@end

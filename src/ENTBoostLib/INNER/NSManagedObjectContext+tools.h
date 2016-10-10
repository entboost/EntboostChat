//
//  NSManagedObjectContext+tools.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/11/26.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (tools)

///创建关联的私有context
+ (NSManagedObjectContext*)generatePrivateContextWithParent:(NSManagedObjectContext*)parentContext;

@end

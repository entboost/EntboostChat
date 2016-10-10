//
//  TBLogonProperty.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/12/12.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBLogonProperty : NSManagedObject

@property (nonatomic, retain) NSString * identification;
@property (nonatomic, retain) NSString * oauthKey;
@property (nonatomic, retain) NSDate * updatedTime;

@end

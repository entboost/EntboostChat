//
//  TBNotification.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/7/14.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBNotification : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * content1;
@property (nonatomic, retain) NSNumber * isReaded;
@property (nonatomic, retain) NSNumber * notiId;
@property (nonatomic, retain) NSString * talkId;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSNumber * value;
@property (nonatomic, retain) NSNumber * value1;
@property (nonatomic, retain) NSNumber * owner;

@end

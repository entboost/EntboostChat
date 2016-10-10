//
//  TBChatDot.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/12/9.
//  Copyright © 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TBChatDot : NSManagedObject

@property (nullable, nonatomic, retain) NSNumber *byteSize;
@property (nullable, nonatomic, retain) NSNumber *chatType;
@property (nullable, nonatomic, retain) NSData *data;
@property (nullable, nonatomic, retain) NSNumber *messageId;
@property (nullable, nonatomic, retain) NSNumber *seq;
@property (nullable, nonatomic, retain) NSNumber *subType;
@property (nullable, nonatomic, retain) NSNumber *tagId;
@property (nullable, nonatomic, retain) NSNumber *owner;

@end

//
//  TBTalk.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/2/3.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBTalk : NSManagedObject

@property (nonatomic, retain) NSNumber * currentCallId;
@property (nonatomic, retain) NSNumber * depCode;
@property (nonatomic, retain) NSString * depName;
@property (nonatomic, retain) NSString * iconFile;
@property (nonatomic, retain) NSNumber * invisible;
@property (nonatomic, retain) NSString * otherAccount;
@property (nonatomic, retain) NSNumber * otherEmpCode;
@property (nonatomic, retain) NSNumber * otherUid;
@property (nonatomic, retain) NSString * otherUserName;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * talkId;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSString * talkName;

@end

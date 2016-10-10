//
//  TBCall.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/12/12.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBCall : NSManagedObject

@property (nonatomic, retain) NSNumber * callId;
@property (nonatomic, retain) NSNumber * chatId;
@property (nonatomic, retain) NSString * clientAddress;
@property (nonatomic, retain) NSNumber * depCode;
@property (nonatomic, retain) NSString * fromAccount;
@property (nonatomic, retain) NSNumber * fromUid;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * talkId;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSString * vCardEmail;
@property (nonatomic, retain) NSString * vCardName;
@property (nonatomic, retain) NSString * vCardPhone;
@property (nonatomic, retain) NSString * vCardTelphone;
@property (nonatomic, retain) NSString * vCardTitle;
@property (nonatomic, retain) NSNumber * vCardUserType;

@end

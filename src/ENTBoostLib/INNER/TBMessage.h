//
//  TBMessage.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/9/24.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * acked;
@property (nonatomic, retain) NSNumber * byteSize;
@property (nonatomic, retain) NSNumber * callId;
@property (nonatomic, retain) NSNumber * cancelled;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * fileName;
@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, retain) NSString * fromAccount;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSNumber * fromUid;
@property (nonatomic, retain) NSString * gpsCoordinates;
@property (nonatomic, retain) NSNumber * isPrivate;
@property (nonatomic, retain) NSNumber * isReaded;
@property (nonatomic, retain) NSNumber * isSent;
@property (nonatomic, retain) NSNumber * isSentFailure;
@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSNumber * messageId;
@property (nonatomic, retain) NSDate * messageTime;
@property (nonatomic, retain) NSNumber * offChat;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSNumber * percentCompletion;
@property (nonatomic, retain) NSNumber * rejected;
@property (nonatomic, retain) NSString * resourceString;
@property (nonatomic, retain) NSNumber * richType;
@property (nonatomic, retain) NSNumber * tagId;
@property (nonatomic, retain) NSString * talkId;
@property (nonatomic, retain) NSString * tempFilePath;
@property (nonatomic, retain) NSNumber * toUid;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * uploaded;
@property (nonatomic, retain) NSNumber * waittingAck;

@end

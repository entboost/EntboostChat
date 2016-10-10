//
//  TBEmotion.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/12/11.
//  Copyright © 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface TBEmotion : NSManagedObject

@property (nonatomic, retain) NSString *cmAddress;
@property (nonatomic, retain) NSString *cmHttpAddress;
@property (nonatomic, retain) NSString *cmHttpAddressSSL;
@property (nonatomic, retain) NSString *cmAppName;
@property (nonatomic, retain) NSNumber *emoClass;
@property (nonatomic, retain) NSNumber *entCode;
@property (nonatomic, retain) NSString *httpServer;
@property (nonatomic, retain) NSString *httpServerSSL;
@property (nonatomic, retain) NSNumber *index;
@property (nonatomic, retain) NSNumber *isReceivedComplete;
@property (nonatomic, retain) NSNumber *owner;
@property (nonatomic, retain) NSString *realFilepath;
@property (nonatomic, retain) NSNumber *isFileInCache;
@property (nonatomic, retain) NSNumber *resId;
@property (nonatomic, retain) NSNumber *resourceType;
@property (nonatomic, retain) NSString *md5;
@property (nonatomic, retain) NSString *descri;

@end

//
//  TBGroupInfo.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/2/9.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBGroupInfo : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * depCode;
@property (nonatomic, retain) NSString * depName;
@property (nonatomic, retain) NSString * descri;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * entCode;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSNumber * loaded;
@property (nonatomic, retain) NSNumber * memberCount;
@property (nonatomic, retain) NSNumber * myEmpCode;
@property (nonatomic, retain) NSNumber * offset;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSNumber * parentCode;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * verNo;
@property (nonatomic, retain) NSNumber * creatorUid;
@property (nonatomic, retain) NSString * creatorAccount;
@property (nonatomic, retain) NSDate * createdTime;

@end

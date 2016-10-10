//
//  TBMemberInfo.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/12/12.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBMemberInfo : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * cellPhone;
@property (nonatomic, retain) NSNumber * csExt;
@property (nonatomic, retain) NSNumber * csId;
@property (nonatomic, retain) NSNumber * depCode;
@property (nonatomic, retain) NSString * descri;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * empAccount;
@property (nonatomic, retain) NSNumber * empCode;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSNumber * gender;
@property (nonatomic, retain) NSString * hcmAppName;
@property (nonatomic, retain) NSString * hcmHttpServer;
@property (nonatomic, retain) NSString * hcmServer;
@property (nonatomic, retain) NSString * hMD5;
@property (nonatomic, retain) NSNumber * hResId;
@property (nonatomic, retain) NSNumber * jobPosition;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSNumber * managerLevel;
@property (nonatomic, retain) NSNumber * offset;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSDate * updatedTime;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * workPhone;

@end

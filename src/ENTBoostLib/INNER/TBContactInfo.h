//
//  TBContactInfo.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/1/27.
//  Copyright (c) 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TBContactInfo : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSNumber * contactId;
@property (nonatomic, retain) NSString * desrci;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * fax;
@property (nonatomic, retain) NSNumber * groupId;
@property (nonatomic, retain) NSString * jobTitle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * tel;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * verified;

@end

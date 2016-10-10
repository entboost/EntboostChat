//
//  CoreTextLinkData.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-11-15.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreTextLinkData : NSObject

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * url;
@property (assign, nonatomic) NSRange range;

@end

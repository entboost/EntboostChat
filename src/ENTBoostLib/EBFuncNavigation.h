//
//  EBFuncNavigation.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/12/19.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBFuncNavigation : NSObject

@property(nonatomic) uint64_t navId; //导航编号
@property(nonatomic) int32_t index; //显示顺序，高排上面，低排下面

@property(nonatomic) uint64_t parentNavId; //上级导航编号
@property(nonatomic, strong) NSString* name; //导航名称
@property(nonatomic, strong) NSString* descri; //备注信息
@property(nonatomic, strong) NSString* url; //导航链接
@property(nonatomic) uint16_t type; //导航类型；0=HTML网页，1=XML数据，2=打开外部程序路径

///初始化方法
- (id)initWithDictionary:(NSDictionary*)dict;

@end

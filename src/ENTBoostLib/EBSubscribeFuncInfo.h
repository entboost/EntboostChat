//
//  EBSubscribeFuncInfo.h
//  ENTBoostLib
//
//  Created by zhong zf on 14/12/17.
//  Copyright (c) 2014年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "eb_define1.h"

@interface EBSubscribeFuncInfo : NSObject

@property(nonatomic) uint64_t   subId; //订购ID
@property(nonatomic) int32_t    index; //排序

@property(nonatomic) uint64_t   iconResId; //图标资源ID
@property(nonatomic, strong)    NSString* iconCMServer; //图标文件资源服务地址
@property(nonatomic, strong)    NSString* iconMD5; //图标文件MD5验证码
@property(nonatomic, strong)    NSString* iconHttpServer; //图标文件资源http服务地址
@property(nonatomic, strong)    NSString* iconUrl; //

@property(nonatomic, strong)        NSString* funcName; //显示名称
@property(nonatomic) int32_t        location; //功能显示位置
@property(nonatomic) EB_FUNC_MODE   funcMode; //应用模式
@property(nonatomic) float          winWidth; //窗口宽度
@property(nonatomic) float          winHeight; //窗口高度
@property(nonatomic) uint16_t       funcExt; //功能控制 1=屏蔽邮件菜单，2=屏蔽滚动条

///初始化方法
- (id)initWithDictionary:(NSDictionary*)dict;

@end

//
//  EBEmailDescription.h
//  ENTBoostLib
//
//  Created by zhong zf on 15/11/13.
//  Copyright © 2015年 entboost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBEmailDescription : NSObject

@property(nonatomic) uint64_t uid;              //用户编号
@property(nonatomic) uint64_t emailAddressId;   //邮件地址编号
@property(nonatomic) uint64_t emailId;          //邮件编号
@property(nonatomic) int size;             //邮件大小(单位字节Byte)
@property(nonatomic) int attachCount;      //附件数量
@property(nonatomic, strong) NSDate* fromDate;  //邮件发送日期
@property(nonatomic, strong) NSString* fromName;//发送者名称
@property(nonatomic, strong) NSString* fromEmail;//发送者邮件地址
@property(nonatomic, strong) NSString* subject; //邮件主题
@property(nonatomic) NSString* customParam; //附带参数

///以格式化字符串进行初始化
- (id)initWithFormatedString:(NSString*)formatedString;

@end

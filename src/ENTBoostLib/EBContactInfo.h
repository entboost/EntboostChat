//
//  EBContactInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-28.
//
//

#import <Foundation/Foundation.h>
#import "eb_define1.h"

@class TBContactInfo;

@interface EBContactInfo : NSObject

@property(nonatomic) uint64_t contactId; //联系人编号
@property(nonatomic) uint64_t groupId; //分组编号
@property(nonatomic) uint64_t uid; //用户编号

@property(strong, nonatomic) NSString* account; //联系人账号
//@property(strong, nonatomic) NSString* groupName; //分组
@property(strong, nonatomic) NSString* name; //名称
@property(strong, nonatomic) NSString* phone; //手机号码
@property(strong, nonatomic) NSString* email; //电子邮件地址
@property(strong, nonatomic) NSString* address; //联系地址
@property(strong, nonatomic) NSString* descri; //备注信息
@property(strong, nonatomic) NSString* company; //公司名称
@property(strong, nonatomic) NSString* jobTitle; //职位
@property(strong, nonatomic) NSString* tel; //固定电话
@property(strong, nonatomic) NSString* fax; //传真
@property(strong, nonatomic) NSString* url; //网站地址

@property(nonatomic) EB_USER_LINE_STATE userlineState; //在线状态，验证联系人模式才有效
@property(nonatomic) BOOL verified; //是否经过好友验证

///初始化方法
- (id)initWithDictionary:(NSDictionary*)dict;

///初始化方法
- (id)initWithTBContactInfo:(TBContactInfo*)tbContactInfo;

///使用本实例字段填充至Dictionary对象
- (void)fillParameters:(NSMutableDictionary*)parameters;

///使用本实例字段值填充到一个TBContactInfo实例字段值
- (void)parseToTBContactInfo:(TBContactInfo*)tbContactInfo;

@end

//
//  EnterpriseInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-1.
//
//

@interface EBEnterpriseInfo : NSObject

@property(nonatomic) uint64_t entCode; //企业代码
@property(strong, nonatomic) NSString* entName; //企业名称
@property(strong, nonatomic) NSString* phone; //联系电话
@property(strong, nonatomic) NSString* fax; //传真号码
@property(strong, nonatomic) NSString* email; //电子邮箱
@property(strong, nonatomic) NSString* url; //主页地址
@property(strong, nonatomic) NSString* address; //联系地址
@property(strong, nonatomic) NSString* descri; //备注信息
@property(strong, nonatomic) NSString* callKey; //呼叫来源KEY，实现企业呼叫来源限制
@property(strong, nonatomic) NSString* creatorAccount; //企业资料创建者的账号
@property(nonatomic) uint64_t creatorUid; //企业资料创建者的用户编号


- (id)initWithDictionary:(NSDictionary*)dict;

@end

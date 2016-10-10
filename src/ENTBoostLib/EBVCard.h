//
//  EBVCard.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-4.
//
//

@class EBResourceInfo;

@interface EBVCard : NSObject

@property(nonatomic) uint16_t type;//帐户类型
@property(nonatomic) uint64_t empCode;//成员编码
@property(strong, nonatomic) NSString *name;//名称
@property(strong, nonatomic) NSString *phone;//手机
@property(strong, nonatomic) NSString *telphone;//电话号码
@property(strong, nonatomic) NSString *email;//电子邮件
@property(strong, nonatomic) NSString *title;//职务
@property(strong, nonatomic) NSString *depName;//群（部门）名称
@property(strong, nonatomic) NSString *entName;//公司名称
@property(strong, nonatomic) NSString *address;//地址
@property(nonatomic) uint64_t usid; //保留字段

///头像加载所需信息
@property(strong, nonatomic) EBResourceInfo* headPhotoInfo;

///字符串转换成EBVCard结构
-(id)initWithStrValue:(NSString*)strValue;


@end

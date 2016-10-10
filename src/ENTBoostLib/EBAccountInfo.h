//
//  EBAccountInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-6-23.
//
//  当前登录用户资料

#import "eb_define1.h"

@class EBResourceInfo;
@class EBArea;

@interface EBAccountInfo : NSObject

///登录类型
@property(atomic) enum EB_LOGON_TYPE loginType;
///用户编号
@property(atomic) uint64_t uid;
///用户账号
@property(strong, atomic) NSString* account;
///用户名或昵称
@property(strong, atomic) NSString* userName;
///描述
@property(strong, atomic) NSString* descri;
///个人设置
@property(atomic) int setting;
///默认成员编号
@property(atomic) uint64_t defaultEmpCode;
///是否游客
@property(atomic, readonly) BOOL isVisitor;
///头像资源
@property(nonatomic, strong) EBResourceInfo* headPhotoResource;
///地区
@property(atomic, strong) EBArea* area;
///地址
@property(atomic, strong) NSString* address;
///主页
@property(atomic, strong) NSString* url;
///性别
@property(atomic) EB_GENDER_TYPE gender;
///电话
@property(atomic, strong) NSString* tel;
///手机
@property(atomic, strong) NSString* mobile;
///邮箱
@property(atomic, strong) NSString* email;
///生日
@property(atomic, strong) NSDate* birthday;
///邮编
@property(atomic, strong) NSString* zipcode;

/**使用包含SOTPParameter对象的dictionary进行初始化
 * @param dict
 */
- (id)initWithDictionary:(NSDictionary*)dict;

/**使用本实例字段填充至Dictionary对象
 * @param parameters 属性字段(输出)
 * @return 有效执行的字段
 */
- (NSArray*)fillParameters:(NSMutableDictionary*)parameters;

@end

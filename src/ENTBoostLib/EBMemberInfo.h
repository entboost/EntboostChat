//
//  EBMemberInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-2.
//
//
#import "SOTP_defines.h"

@class EBGroupInfo;
@class TBMemberInfo;
@class EBServerInfo;
@class EBResourceInfo;

@interface EBMemberInfo : NSObject

/**  基础信息 **/
///成员编号
@property(nonatomic) uint64_t empCode;
///部门或群组编号
@property(nonatomic) uint64_t depCode;
///用户编号
@property(nonatomic) uint64_t uid;
///成员账号
@property(strong, nonatomic) NSString* empAccount;
///名称
@property(strong, nonatomic) NSString* userName;
///性别
@property(nonatomic) EB_GENDER_TYPE gender;
///生日
@property(strong, nonatomic) NSDate* birthday;
///职务
@property(strong, nonatomic) NSString*  jobTitle;
///岗位级别
@property(nonatomic) int jobPosition;
///联系电话
@property(strong, nonatomic) NSString* cellPhone;
///传真号码
@property(strong, nonatomic) NSString* fax;
///工作电话
@property(strong, nonatomic) NSString* workPhone;
///电子邮件
@property(strong, nonatomic) NSString* email;
///联系地址
@property(strong, nonatomic) NSString* address;
///备注信息
@property(strong, nonatomic) NSString* descri;
///管理权限
@property(nonatomic) EB_MANAGER_LEVEL managerLevel;

/** 客服相关信息 **/
///客服分机号
@property(nonatomic) int csExt;
///客服号
@property(nonatomic) uint64_t csId;

///** 聊天连接相关信息 **/
/////在线UM服务器连接信息
//@property(strong, nonatomic) EBServerInfo* umServerInfo;

/** 资源相关信息 **/
///头像加载所需信息
@property(strong, nonatomic) EBResourceInfo* headPhotoInfo;

///初始化方法
- (id)initWithEmpCode:(uint64_t)empCode depCode:(uint64_t)depCode uid:(uint64_t)uid empAccount:(NSString*)empAccount userName:(NSString*)userName gender:(EB_GENDER_TYPE)gender birthday:(NSDate*)birthday jobTitle:(NSString*)jobTitle jobPosition:(int)jobPosition cellPhone:(NSString*)cellPhone fax:(NSString*)fax workPhone:(NSString*)workPhone email:(NSString*)email address:(NSString*)address descri:(NSString*)descri managerLevel:(int)managerLevel csExt:(int)csExt csId:(uint64_t)csId;

///初始化方法
- (id)initWithDictionary:(NSDictionary*)dict;

///初始化方法
- (id)initWithTBMemberInfo:(TBMemberInfo*)tbMemberInfo;

///使用本实例字段值填充到一个TBMemberInfo实例字段值
- (void)parseToTBMemberInfo:(TBMemberInfo*)tbMemberInfo;

///使用本实例字段填充至字典对象
- (void)fillParameters:(NSMutableDictionary*)parameters;

@end

//
//  EBGroupInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-2.
//
//

#import "SOTP_defines.h"

@class TBGroupInfo;

@interface EBGroupInfo : NSObject

@property(nonatomic) uint64_t entCode; //企业代码，如是个人群组则为0
@property(nonatomic) uint64_t depCode; //部门或群组代码
@property(nonatomic) uint64_t parentCode; //上层部门或群组
@property(strong, nonatomic) NSString* depName; //部门或群组名称
@property(strong, nonatomic) NSString* phone; //联系电话
@property(strong, nonatomic) NSString* fax; //传真号码
@property(strong, nonatomic) NSString* email; //电子邮箱
@property(strong, nonatomic) NSString* url; //主页地址
@property(strong, nonatomic) NSString* address; //联系地址
@property(strong, nonatomic) NSString* descri; //备注信息

@property(nonatomic) uint64_t creatorUid; //创建者(群主)的用户编号
@property(strong, nonatomic) NSString* creatorAccount; //创建者(群组)的用户账号
@property(strong, nonatomic) NSDate* createdTime; //创建时间

@property(nonatomic) EB_GROUP_TYPE type; //群组类型

@property(nonatomic) uint64_t myEmpCode; //当前用户在该部门中的成员编号；如果当前用户不在该部门中，则等于0

@property(nonatomic) int memberCount; //成员数量；即便members还没有加载，该值也可以反映服务器上的真实数量

@property(nonatomic) uint64_t verNo; //数据版本号，用于判断本地缓存的该部门内成员数据是否与服务器版本相同

/** 初始化方法
 * @param depCode 企业部门(或项目组)编号；0=创建，其它=编辑
 * @param depName 名称
 * @param parentCode 上级部门编号
 * @param phone 电话
 * @param fax 传真
 * @param email 电子邮箱
 * @param url 主页
 * @param address 联系地址
 * @param descri 备注信息
 */
- (id)initWithDepCode:(uint64_t)depCode depName:(NSString*)depName parentCode:(uint64_t)parentCode phone:(NSString*)phone fax:(NSString*)fax email:(NSString*)email url:(NSString*)url address:(NSString*)address descri:(NSString*)descri;

///初始化方法
- (id)initWithDictionary:(NSDictionary*)dict;

///初始化方法
- (id)initWithTBGroupInfo:(TBGroupInfo*)tbGroupInfo;

///使用本实例字段填充至字典对象
- (void)fillParameters:(NSMutableDictionary*)parameters;

///是否企业群组(非个人群组)
- (BOOL)isEntGroup;

@end

//
//  LoadingCache.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-1.
//
//

@class EBEnterpriseInfo;
@class EBGroupInfo;
@class EBMemberInfo;
@class EBEmotionInner;
@class EBContactGroup;
@class EBContactInfo;
@class EBSubscribeFuncInfo;
@class EBFuncNavigation;
@class EBAreaField;

///加载数据缓存
@interface EBLoadingData : NSObject


///调用标识
@property(nonatomic) uint32_t cid;
///创建时间
@property(strong, nonatomic)NSDate* createdTime;
///数据更新时间
@property(strong, nonatomic)NSDate* updatedTime;

///-----加载企业组织架构(包括资源)-------
///企业数
@property(atomic) int32_t entCount;
///企业部门数量
@property(atomic) int32_t entDepCount;
///个人群组数量
@property(atomic) int32_t myDepCount;

///表情与头像资源数量
@property(atomic) int32_t emoCount;

///联系人数量
@property(atomic) int32_t contactCount;
///联系人分组数量
@property(atomic) int32_t contactGroupCount;

///地区数据数量
@property(atomic) int32_t areaCount;
///地区字典数据版本号，表示字典数据发生变更
@property(atomic) uint64_t areaVer;

///企业部门总版本号，表示整个企业所有部门资料本身的变更
@property(atomic) uint64_t entGroupInfoVer;
///个人群组总版本号，表示所有个人群组资料本身的变更
@property(atomic) uint64_t personalGroupInfoVer;
///企业部门版本号数量
@property(atomic) int32_t entGroupVersionInfosCount;
///个人群组版本号数量
@property(atomic) int32_t personalGroupVersionInfosCount;

///应用功能数量
@property(atomic) int32_t subscribeFuncInfoCount;
///应用访问入口
@property(nonatomic, strong) NSString* funcUrl;
///我的消息应用订购ID
@property(nonatomic) uint64_t groupMsgSubid;
///邀请好友应用订购ID
@property(nonatomic) uint64_t findAppSubId;

///应用功能导航数量
@property(atomic) int32_t funcNavigationCount;

///企业部门或个人群组总版本号，表示部门或群组资料本身发生变更
@property(atomic) uint64_t groupInfoVer;
///企业部门或个人群组版本号，表示内部成员发生变更，例如增加或减少成员
@property(atomic) uint64_t groupVer;


///群组成员状态数量
@property(atomic) int32_t onlineStateCount;
///企业群组编号
@property(atomic) uint64_t onlineStateDepCode;

///部门或群组在线人数总记录数量
@property(atomic) int32_t  groupOnlineStateCountsCount;
///加载部门或群组在线人数记录数量标记：NO=未统计，YES=已统计
@property(atomic) BOOL isSettedGroupOnlineStateCountsOfEntGroup; //企业部门
@property(atomic) BOOL isSettedGroupOnlineStateCountsOfMyGroup; //个人群组
@property(atomic) BOOL isSettedGroupOnlineStateCountsOfOneGroup; //指定一个部门或群组

///企业信息
@property(strong, nonatomic) EBEnterpriseInfo* enterpriseInfo;


- (id)initWithCid:(uint32_t)cid;

/**记录部门或群组中人员数量
 * @param count 数量
 * @param depCode 部门或群组代码
 */
- (void)addEmpCountOfGroup:(int32_t)count forGroup:(uint64_t)depCode;

/**读取部门或群组成员数量
 * 仅表示当前查询返回的数量，不一定等于该部门或群组的总成员数量
 * @param depCode 部门或群组代码
 */
- (int32_t)empCountOfGroup:(uint64_t)depCode;

/**记入部门信息
 * @param groupInfo 部门信息
 */
- (void)addEntGroupInfo:(EBGroupInfo*)groupInfo;

/**获取部门信息
 * @param groupInfo 部门信息
 */
- (EBGroupInfo*)entGroupInfo:(uint64_t)depCode;

///获取全部企业部门信息
- (NSDictionary*)entGroupInfos;

/**记入个人群组信息
 * @param groupInfo 群组信息
 */
- (void)addGroupInfo:(EBGroupInfo*)groupInfo;

/**获取个人群组信息
 * @param groupInfo 群组信息
 */
- (EBGroupInfo*)groupInfo:(uint64_t)depCode;

///获取全部个人群组信息
- (NSDictionary*)groupInfos;

/**记录成员信息
 * @param memberInfo 成员信息
 */
- (void)addMemberInfo:(EBMemberInfo*)memberInfo;

//获取部门或群组中成员信息
- (NSArray*)memberInfos:(uint64_t)depCode;

///**获取成员信息
// * @param empCode 成员编号
// */
//- (EBMemberInfo*)memberInfo:(uint64_t)empCode;

///获取所有成员信息
-(NSDictionary*)memberInfos;

////补全企业组织架构信息
//- (void)complementOrganizationalStructure;

/////没有成员的部门或群组数量
//- (int32_t)countOfZeroMemberGroup;

/**记录部门或群组版本号
 * @param groupVersionInfos 部门或群组版本号
 * @param isEntGroup 是否企业部门， YES = 企业部门, NO = 个人群组
 */
- (void)addGroupVersionInfos:(NSDictionary*)groupVersionInfos isEntGroup:(BOOL)isEntGroup;

/**获取部门或群组版本号信息
 * @param isEntGroup 是否企业部门，YES = 获取企业部门版本号信息，NO = 获取个人群组版本号信息
 */
- (NSDictionary*)groupVersionInfos:(BOOL)isEntGroup;

///记录应用功能
- (void)addSubscribeFuncInfo:(EBSubscribeFuncInfo*)sFuncInfo;

///获取应用功能列表
- (NSDictionary*)subscribeFuncInfos;

///记录应用导航
- (void)addFuncNavigation:(EBFuncNavigation*)funcNavigation;

///获取应用导航列表
- (NSDictionary*)funcNavigations;


/**记录群组在线成员状态
 * @param onlineStates 群组成员在线状态
 */
- (void)addOnlineStates:(NSDictionary*)onlineStates;

///获取群组在线成员状态
- (NSDictionary*)onlineStates;


/**记录各部门(群组)在线人员数量
 * @param groupOnlineStateCounts 各部门(群组)在线人员数量
 */
- (void)addGroupOnlineStateCounts:(NSDictionary*)groupOnlineStateCounts;

///获取各部门(群组)在线人员数量
- (NSDictionary*)groupOnlineStateCounts;


///是否可以触发加载企业自身信息完成的事件,如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadEnterpriseInfosFinishedEvent;

///是否可以触发加载企业部门完成的事件,如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllEntGroupsFinishedEvent;

///是否可以触发加载个人群组完成的事件,如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllPersonalGroupsFinishedEvent;

///是否可以触发加载部门或群组内成员完成的事件,如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllMembersFinishedEventNoUsingDepCode:(BOOL)noUsingDepCode;

///是否可以触发加载部门或群组版本号信息完成的事件,如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllGroupVersionInfosFinishedEvent;

///是否可以触发加载应用功能列表完成的事件，如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllSubscribeFuncinfosFinishedEvent;

///是否可以触发加载应用导航列表完成的事件，如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllFuncNavigationsFinishedEvent;

///是否可以触发加载部门或群组成员在线状态完成的事件，如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllOnlineStatesFinishedEvent;

///是否可以触发加载部门或群组成员在线人数完成的事件，如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllGroupOnlineStateCountsFinishedEvent;


///记入表情或头像资源描述信息
- (void)addEmotion:(EBEmotionInner*)emotion;
///获取表情或头像资源描述信息列表{key="cmAddress", value="nsMutableArray"}
- (NSDictionary*)emotions;
///已接收到表情或头像资源描述信息的数量
- (int32_t)countOfReceivedEmotion;
///是否可以触发加载表情资源完成的事件,如果一旦返回一次TRUE，再次调用将一直返回FALSE(避免多次触发事件)
- (BOOL)isCanFireLoadAllEmotionsFinisedEvent;


///记录联系人信息
- (void)addContactInfo:(EBContactInfo*)contactInfo;
///获取所有联系人信息
- (NSDictionary*)contactInfos;
///是否可以触发加载联系人完成的事件,如果一旦返回一次TRUE，再次调用将一直返回FALSE(避免多次触发事件)
- (BOOL)isCanFireLoadAllContactInfosFinishedEvent;


///记录联系人分组
- (void)addContactGroup:(EBContactGroup*)contactGroup;
///获取所有联系人分组
- (NSDictionary*)contactGroups;
///是否可以触发加载联系人分组完成的事件，如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllContactGroupsFinishedEvent;


///记录地区字典信息
- (void)addAreaField:(EBAreaField*)areaField;
///获取地区字典数据
- (NSDictionary*)areas;
///是否可以触发加载地区字典完成的事件，如果一旦返回一次YES，再次调用将一直返回NO(避免多次触发事件)
- (BOOL)isCanFireLoadAllAreaDictionaryFinishedEvent;

@end

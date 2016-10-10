//
//  EBReceiveDataHandle.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-3.
//
//

#import "SOTPData.h"

@class SOTPData;
@class EBEnterpriseInfo;

@interface EBReceiveDataHandle : NSObject

/**加载联系人分组数据处理
 * @param revData 接到的数据
 * @param cid 调用编号
 * @param fromServerAddress 事件来源服务地址
 * @param successBlock 加载完成后回调函数
 */
+ (void)loadContactGroupHandle:(SOTPData*)revData forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress success:(void(^)(NSDictionary* contactGroups))successBlock;

/**加载联系人数据处理
 * @param revData 接到的数据
 * @param cid 调用编号
 * @param fromServerAddress 事件来源服务地址
 * @param successBlock 加载完成后回调函数
 */
+ (void)loadContactInfoHandle:(SOTPData*)revData forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress isLoadOne:(BOOL)isLoadOne success:(void(^)(NSDictionary* contactInfos))successBlock;

///**加载资源数据处理
// * @param revData 接到的数据
// * @param delegate 回调代理
// * @param cid 调用编号
// * @param fromServerAddress 事件来源服务地址
// * @param entSuccessBlock 组织架构加载完成后回调函数
// * @param emotionSuccessBlock 表情资源加载完成后回调函数
// */
//+ (void)loadResourceInfoHandle:(SOTPData*)revData delegate:(id)delegate forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress entSuccess:(void(^)(EBEnterpriseInfo* enterpriseInfo, NSDictionary* entGroupInfos, NSDictionary* personalGroupInfos/*, NSDictionary* memberInfos*/))entSuccessBlock emotionSucess:(void(^)(NSArray* expressions, NSArray* headPhotos))emotionSuccessBlock;

/**加载资源数据处理
 * @param revData 接到的数据
 * @param delegate 回调代理
 * @param cid 调用编号
 * @param fromServerAddress 事件来源服务地址
 * @param isLoadEmp 是否加载成员信息
 * @param isLoadEntDep 是否加载企业部门信息
 * @param isLoadPersonalGroup 是否加载个人群组信息
 * @param isLoadImage 是否加载头像表情信息
 * @param isLoadOneGroupInfo 是否只加载一个部门自身资料
 * @param isLoadOneEmp 是否只加载一个成员信息
 * @param searchKey 搜索成员
 * @param entLoadedBlock 企业信息加载完成后回调函数
 * @param entGroupLoadedBlock 企业部门加载完成后回调函数
 * @param personalGroupLoadedBlock 个人群组加载完成后回调函数
 * @param membersLoadedBlock 成员加载完成后回调函数, memberInfos结构：{key=depCode, entity=EBMemberInfo}实例数组
 * @param emotionBeginBlock  表情资源开始加载时回调函数
 * @param emotionLoadedBlock 表情资源加载完成后回调函数
 */
+ (void)loadResourceInfoHandle:(SOTPData*)revData delegate:(id)delegate forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress
            isLoadEmp:(BOOL)isLoadEmp isLoadEntDep:(BOOL)isLoadEntDep isLoadPersonalGroup:(BOOL)isLoadPersonalGroup isLoadImage:(BOOL)isLoadImage
            isLoadOneGroupInfo:(BOOL)isLoadOneGroupInfo isLoadOneEmp:(BOOL)isLoadOneEmp
            searchKey:(NSString*)searchKey
            entLoadedBlock:(void(^)(EBEnterpriseInfo* enterpriseInfo))entLoadedBlock
            entGroupLoadedBlock:(void(^)(NSDictionary* entGroupInfos, uint64_t groupInfoVer))entGroupLoadedBlock
            personalGroupLoadedBlock:(void(^)(NSDictionary* personalGroupInfos, uint64_t groupInfoVer))personalGroupLoadedBlock
            membersLoadedBlock:(void(^)(NSDictionary* memberInfos, uint64_t groupVer))membersLoadedBlock
            emotionBeginBlock:(void(^)(NSArray* expressions, NSArray* headPhotos))emotionBeginBlock emotionLoadedBlock:(void(^)(NSArray* expressions, NSArray* headPhotos))emotionLoadedBlock;

/**加载字典数据处理
 * @param revData 接到的数据
 * @param delegate 回调代理
 * @param cid 调用编号
 * @param fromServerAddress 事件来源服务地址
 * @param areasLoadedBlock 地区字典加载完成后回调函数
 */
+ (void)loadDictionaryHandle:(SOTPData*)revData delegate:(id)delegate forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress areasLoadedBlock:(void(^)(NSDictionary* areas, uint64_t version))areasLoadedBlock;

///**加载部门或群组成员数据处理
// * @param revData 接到的数据
// * @param delegate 回调代理
// * @param cid 调用编号
// * @param fromServerAddress 事件来源服务地址
// * @param successBlock 组织架构加载完成后回调函数
// */
//+ (void)loadMemberInfosHandle:(SOTPData*)revData depCode:(uint64_t)depCode delegate:(id)delegate forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress success:(void(^)(NSArray* memberInfos))successBlock;

/**加载加载动态数据(应用订购关系、部门和群组版本号)处理
 * @param revData 接到的数据
 * @param delegate 回调代理
 * @param cid 调用编号
 * @param fromServerAddress 事件来源服务地址
 * @param isLoadSubFunc 是否加载应该订购关系
 * @param isLoadGroupVersion 是否加载部门和群组版本号
 * @param memberOnlineStateDepCode 加载群组成员状态时使用的群组编号
 * @param isLoadContactOnlineState 是否加载联系人状态
 * @param isLoadUserOnlineState 是否加载用户在线状态
 * @param isLoadEntGroupOnlineStateCount 是否加载企业部门/项目组的在线人数
 * @param isLoadMyGroupOnlineStateCount 是否加载个人群组/讨论组的在线人数
 * @param isLoadGroupOnlineStateCountByDepCode 是否通过部门(群组)编号查询成员在线人数
 * @param subFuncloadedBlock 应用功能描述列表
 * @param groupVersionInfosLoadedBlock 成员加载完成后回调函数
            entGroupVersionInfos、personalGroupVersionInfos结构：{key=depCode, entity=versionNo}实例数组
 * @param memberOnlineStateLoadedBlock 成员在线状态加载完成回调函数
 * @param contactOnlineStateLoadedBlock 联系人在线状态加载完成回调函数
 * @param userOnlineStateLoadedBlock 用户在线状态加载完成回调函数
 * @param groupOnlineStateCountLoadedBlock 加载企业部门在线成员数量完成时回调函数
 */
+ (void)loadInfoHandle:(SOTPData*)revData delegate:(id)delegate forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress isLoadSubFunc:(BOOL)isLoadSubFunc isLoadGroupVersion:(BOOL)isLoadGroupVersion memberOnlineStateDepCode:(uint64_t)memberOnlineStateDepCode isLoadContactOnlineState:(BOOL)isLoadContactOnlineState isLoadUserOnlineState:(BOOL)isLoadUserOnlineState isLoadEntGroupOnlineStateCount:(BOOL)isLoadEntGroupOnlineStateCount isLoadMyGroupOnlineStateCount:(BOOL)isLoadMyGroupOnlineStateCount isLoadGroupOnlineStateCountByDepCode:(BOOL)isLoadGroupOnlineStateCountByDepCode subFuncLoadedBlock:(void(^)(NSDictionary* subscribeFuncInfos, NSString* funcUrl, uint64_t groupMsgSubId, uint64_t findAppSubId))subFuncLoadedBlock groupVersionInfosLoadedBlock:(void(^)(uint64_t entGroupVer, uint64_t personalGroupVer, NSDictionary* entGroupVersionInfos, NSDictionary* personalGroupVersionInfos))groupVersionInfosLoadedBlock memberOnlineStateLoadedBlock:(void(^)(NSDictionary* memberStates, uint64_t depCode))memberOnlineStateLoadedBlock contactOnlineStateLoadedBlock:(void(^)(NSDictionary* contactStates))contactOnlineStateLoadedBlock userOnlineStateLoadedBlock:(void(^)(NSDictionary* userStates))userOnlineStateLoadedBlock groupOnlineStateCountLoadedBlock:(void(^)(NSDictionary* countsOfGroupOnlineState))groupOnlineStateCountLoadedBlock;

/**加载应用导航数据处理
 * @param revData 接到的数据
 * @param delegate 回调代理
 * @param cid 调用编号
 * @param fromServerAddress 事件来源服务地址
 * @param successBlock 加载完成后回调函数
 */
+ (void)loadFuncNavigationsHandle:(SOTPData*)revData delegate:(id)delegate forCid:(uint32_t)cid fromServerAddress:(NSString*)fromServerAddress successBlock:(void(^)(NSDictionary* funcNavigations))successBlock;

/**默认处理1
 * @param revData 接到的数据
 * @param cid 调用标识
 * @param failure 失败后回调函数
 * @param message 默认出错信息
 */
+ (BOOL)defaultHandle:(SOTPData*)revData forCid:(uint32_t)cid failure:(SOTPFailureBlock)failureBlock defaultFailMessage:(NSString*)message;

/**默认处理2
 * @param revData 接到的数据
 * @param cid 调用标识
 * @param success 成功后回调函数
 * @param failure 失败后回调函数
 * @param message 默认出错信息
 */
+ (BOOL)defaultHandle:(SOTPData*)revData forCid:(uint32_t)cid success:(void(^)(void))successBlock failure:(SOTPFailureBlock)failureBlock defaultFailMessage:(NSString*)message;

@end

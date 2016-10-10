//
//  RelationshipHelper.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/20.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "TableTreeNode.h"
#import "TableTree.h"

@interface RelationshipHelper : NSObject

@property(strong, nonatomic) TableTree* myDepartmentTree; //我的部门树实例指针
@property(strong, nonatomic) TableTree* personalGroupTree; //个人群组树实例指针
@property(strong, nonatomic) TableTree* enterpriseTree; //企业架构树实例指针
@property(strong, nonatomic) TableTree* contactTree; //联系人树实例指针


/**初始化
 * @param toolbar 工具栏视图
 * @param treeContainer 树结构显示的容器
 * @param selectedViewLabel 当前选中标签页的标题显示控件
 * @param selectedViewBottomBorder 当前选中按钮下划线
 * @param toolbarBottomBorder 工具栏下边框
 * @param myDepartmentBtn "我的部门"按钮
 * @param contactBtn "通讯录"按钮
 * @param personalGroupBtn "个人群组"按钮
 * @param enterpriseBtn "组织架构"按钮
 * @param floatMarkedLine 标记线
 * @param delegate 事件代理
 */
- (id)initWithToolbar:(UIView*)toolbar treeContainer:(UIView*)treeContainer selectedViewLabel:(UILabel*)selectedViewLabel selectedViewBottomBorder:(CustomSeparator*)selectedViewBottomBorder toolbarBottomBorder:(CustomSeparator*)toolbarBottomBorder myDepartmentBtn:(UIButton*)myDepartmentBtn contactBtn:(UIButton*)contactBtn personalGroupBtn:(UIButton*)personalGroupBtn enterpriseBtn:(UIButton*)enterpriseBtn floatMarkedLine:(UIView*)floatMarkedLine delegate:(id)delegate;

//设置工具栏
- (void)initToolbar:(UIView*)superView;

/**读取数据及填充视图
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 */
- (void)fillTreesWithIsHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn;

///重新载入通讯录视图
- (void)reloadContactTree;

//设置选中视图的属性
- (void)initSelectedView;

//设置当前选中标记线位置
- (void)setSelectedButtonAtIndex:(NSUInteger)index;

//更新企业架构标题
- (void)updateSelectedViewLabelOfEnterpriseView;

/*!显示属性界面
 @param node 节点对象
 @param navigationController 导航栏controller
 @param delegate 回调代理对象
 */
+ (void)showPropertiesWithNode:(TableTreeNode *)node navigationController:(UINavigationController*)navigationController delegate:(id)delegate;

/**以联系人资料生成树结构节点
 * @param contactInfo 联系人资料
 * @param leafCount 成员人数
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 */
+ (TableTreeNode*)treeNodeWithContactInfo:(EBContactInfo*)contactInfo outLeafCount:(int*)leafCount isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn;

/**以群组(部门)资料生成树结构节点
 * @param groupInfo 群组(或部门)信息
 * @param groupType 联系人类型
 * @param onlineCountOfMembers 成员在线人数
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 */
+ (TableTreeNode*)treeNodeWithGroupInfo:(EBGroupInfo*)groupInfo groupType:(RELATIONSHIP_TYPE)groupType onlineCountOfMembers:(NSInteger)onlineCountOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn;

/*把企业部门信息列表转换为树状视图数据源
 * @param groupInfos EBGroupInfo实例数组
 * @param groupType 联系人类型
 * @param onlineCountsOfMembers 各部门(群组)成员在线人数
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 * @return TableTreeNode实例数组
 */
+ (NSMutableArray*)treeNodesDataWithGroupInfos:(NSDictionary*)groupInfos groupType:(RELATIONSHIP_TYPE)groupType onlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn;

/**获取某部门所有子部门信息及该部门内成员信息
 * @param parentGroupInfo
 * @param tableTree
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 * @param completionBlock 成功后回调模块
 * @param failureBlock 失败后回调模块
 */
+ (void)loadNodesInGroup:(EBGroupInfo*)parentGroupInfo tableTree:(TableTree*)tableTree isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray *nodes))completionBlock failureBlock:(void(^)(NSError *error))failureBlock;

/**加载“我的部门”数据
 * @param onlineCountsOfMembers 各部门成员在线人数
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 * @param completionBlock 成功后回调模块
 * @param failureBlock 失败后回调模块
 */
- (void)loadMyDepartmentNodesWithOnlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock;

/**获取所有个人群组信息
 * @param onlineCountsOfMembers 各群组成员在线人数
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 * @param completionBlock 成功后回调模块
 * @param failureBlock 失败后回调模块
 */
- (void)loadPersonalGroupNodesWithOnlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock;

/**获取所有企业部门信息
 * @param onlineCountsOfMembers 各群组成员在线人数
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param isHiddenGroupTickBtn 是否隐藏群组(部门、分类)上的勾选按钮
 * @param completionBlock 成功后回调模块
 * @param failureBlock 失败后回调模块
 */
- (void)loadEnterpriseGroupNodesWithOnlineCountsOfMembers:(NSDictionary*)onlineCountsOfMembers isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn isHiddenGroupTickBtn:(BOOL)isHiddenGroupTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock;

/**获取通讯录信息
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @return TableTreeNode实例数组
 * @param completionBlock 成功后回调模块
 * @param failureBlock 失败后回调模块
 */
- (void)loadContactNodesWithIsHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn onCompletion:(void(^)(NSArray* nodes))completionBlock onFailureBlock:(void(^)(NSError *error))failureBlock;

/**获取某个部门或群组成员在线人数
 * @discussion 本方法将阻塞执行，最长15秒
 * @param depCode
 * @return 在线人数
 */
+ (NSInteger)loadOnlineStateCountsOfGroupsWithDepCode:(uint64_t)depCode;

/**获取所有部门成员总人数
 * @param completionBlock 完成时回调函数
 */
+ (void)loadTotalMemberCountOfEntGroupsOnCompletion:(void(^)(NSInteger totalMemberCount))completionBlock;

/**获取所有部门成员在线总人数
 * @param completionBlock 完成时回调函数
 */
+ (void)loadTotalOnlineStateCountOfEntGroupsOnCompletion:(void(^)(NSInteger totalOnlineStateCount))completionBlock;

#pragma mark -
/**请求加载某节点下一层的叶子节点数据
 * @param tableTree 树对象
 * @param parentNode 请求加载下一层叶子的目标节点
 * @param isHiddenTalkBtn 是否隐藏点击聊天按钮
 * @param isHiddenPropertiesBtn 是否隐藏点击查看属性按钮
 * @param isHiddenTickBtn 是否隐藏勾选按钮
 * @param completionBlock 完成加载后的回调block
 */
+ (void)tableTree:(TableTree *)tableTree loadLeavesUnderNode:(TableTreeNode *)parentNode isHiddenTalkBtn:(BOOL)isHiddenTalkBtn isHiddenPropertiesBtn:(BOOL)isHiddenPropertiesBtn isHiddenTickBtn:(BOOL)isHiddenTickBtn onCompletion:(void(^)(NSArray *))completionBlock;

/**进入更深层节点事件
 * @param tableTree 树对象
 * @param node 被选中节点
 * @param groupInfo 出参，返回群组实例
 * @return 是否进入下一层
 */
+ (BOOL)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node groupInfo:(EBGroupInfo**)groupInfo;

///联系人管理(验证、编辑、创建)
+ (void)manageContact:(NSDictionary*)parameters;

///删除联系人
+ (void)deleteContact:(uint64_t)contactId onCompletion:(void(^)(void))completionBlock onFailureBlock:(void(^)(NSError* error))failureBlock;

///对列表进行排序
+ (void)sortNodes:(NSMutableArray*)nodes;

/**获取已勾选节点
 * @return TableTreeNode列表
 */
- (NSArray*)tickCheckedNodes;

@end

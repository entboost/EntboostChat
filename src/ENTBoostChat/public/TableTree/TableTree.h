//
//  TableTree.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENTBoost.h"
#import "TableTreeCell.h"

@class TableTree;
@class TableTreeNode;

@protocol TableTreeDelegate <NSObject>
@optional
/**行选中事件
 * @param tableTree 树对象
 * @param node 被选中节点
 */
- (void)tableTree:(TableTree *)tableTree didSelectedRowWithNode:(TableTreeNode *)node;

/**点击对话按钮事件
 * @param tableTree 树对象
 * @param node 被选中节点
 */
- (void)tableTree:(TableTree *)tableTree talkBtnTapInNode:(TableTreeNode *)node;

/**点击查看属性按钮事件
 * @param tableTree 树对象
 * @param node 被选中节点
 */
- (void)tableTree:(TableTree *)tableTree propertiesBtnTapInNode:(TableTreeNode *)node;

/**请求加载某节点下一层的叶子节点数据
 * @param tableTree tree对象
 * @param parentNode 请求加载下一层叶子的目标节点
 * @param completionBlock 完成加载后的回调block
 */
- (void)tableTree:(TableTree *)tableTree loadLeavesUnderNode:(TableTreeNode *)parentNode onCompletion:(void(^)(NSArray* nodes))completionBlock;

/**进入更深层节点事件
 * @param tableTree tree对象
 * @param node 被选中节点
 */
- (void)tableTree:(TableTree *)tableTree deepInToNode:(TableTreeNode *)node;

///**请求对两个节点进行顺序比较
// * @param tableTree tree对象
// * @param node1 节点1
// * @param node2 节点2
// * @return 比较结果
// */
//- (NSComparisonResult)tableTree:(TableTree *)tableTree compareWithNode1:(TableTreeNode*)node1 node2:(TableTreeNode*)node2;

/**请求对节点数据进行排序
 * @param tableTree tree对象
 * @param nodes 节点数组
 */
- (void)tableTree:(TableTree *)tableTree sortNodes:(NSMutableArray*)nodes;

@end

@interface TableTree : UIView <TableTreeCellDelegate>
@property (nonatomic, weak) id <TableTreeDelegate>delegate;
@property (nonatomic, strong, readonly) UITableView* tableView;

@property(nonatomic) int deepInLevel; //部门节点从哪一层开始弹出新界面，还没达到层次时在当前界面展开；deepInLevel=0表示首层

/**
 *@method initWithFrame:nodes:
 *@abstract 初始化
 *@param frame  坐标大小
 *@param nodes  TableTreeNode数组
 *@return 当前对象
 */
- (id)initWithFrame:(CGRect)frame nodes:(NSArray *)nodes;

/**设置节点数据
 * @param nodes TableTreeNode数组
 */
- (void)setNodes:(NSArray*)nodes;

///设置背景颜色
- (void)setBackgroundColor:(UIColor *)backgroundColor;

///刷新视图
- (void)reloadData;

///节点是否存在
- (BOOL)isNodeExists:(NSString*)nodeId;

///节点是否正被显示
- (BOOL)isNodeShowed:(NSString*)nodeId;

///**插入一个组节点
// * @param groupNode 组节点
// */
//- (void)insertGroupNode:(TableTreeNode*)groupNode;

//以节点编号获取节点对象
- (TableTreeNode*)nodeWithId:(NSString*)nodeId;

/**删除节点
 * @param nodeId 节点编号 
 * @param updateParentNodeLoadedState 是否更新父节点加载子节点的状态
 */
- (void)removeNodeWithId:(NSString*)nodeId updateParentNodeLoadedState:(BOOL)updateParentNodeLoadedState;

/**插入或更新节点
 * 如果父节点没有展开，则忽略处理
 * @param node 叶子节点
 * @param inFirstLevel 在首层插入
 */
- (void)insertOrUpdateWithNode:(TableTreeNode*)node inFirstLevel:(BOOL)inFirstLevel;

//计算节点所在层次
- (void)caculateLevelOfNode:(TableTreeNode*)node level:(int*)level;

/*! 对同组内子节点(包括子组节点)进行排序
 @param nodeId 组内某子节点编号
 */
- (void)sortNodesOfSameGroupWithNodeId:(NSString*)nodeId;

/**更新通讯录联系人在线状态
 * @param memberOnlineState 在线状态
 * @param contactId 通讯录联系人编号
 */
- (void)updateMemberOnlineState:(EB_USER_LINE_STATE)memberOnlineState forContactId:(uint64_t)contactId;

/**更新成员在线状态
 * @param memberOnlineState 在线状态
 * @param uid 成员的用户编号
 */
- (void)updateMemberOnlineState:(EB_USER_LINE_STATE)memberOnlineState forUid:(uint64_t)uid;

/**更新所有成员的在线状态
 * @param memberOnlineStates 非离线成员的在线状态
 */
- (void)updateMemberOnlineStates:(NSDictionary *)memberOnlineStates;

/**更新部门节点下所有成员的在线状态
 * @param memberOnlineStates 非离线成员的在线状态
 * @param parentNodeId 父节点编号，等于nil时表示更新所有成员节点
 */
- (void)updateMemberOnlineStates:(NSDictionary*)memberOnlineStates forParentNodeId:(NSString*)parentNodeId;

/**更新多个节点在线人数
 * @param countsOfGroupOnlineState 部门在线人数记录列表
 */
- (void)updateCountsOfGroupOnlineState:(NSDictionary*)countsOfGroupOnlineState;

/**更新某节点在线人数
 * @param countOfGroupOnlineState 在线人数记录
 * @param groupNodeId 部门节点编号
 */
- (void)updateCountOfGroupOnlineState:(NSInteger)countOfGroupOnlineState forGroupNodeId:(NSString*)groupNodeId;

/**以某用户将被删除后的在线状态进行计算后，更新其父节点在线人数，仅使用与联系人(contactTree)视图
 * @param nodeId 节点编号
 */
- (void)updateOnlineStateCountOfGroupOnWillRemoveNode:(NSString*)nodeId;

/**以某用户变更的在线状态进行计算后，更新其父节点在线人数，仅使用与联系人(contactTree)视图
 * @param userLineState 在线状态
 * @param contactUid 联系人用户编号
 */
- (void)updateOnlineStateCountOfGroupWithUserLineState:(EB_USER_LINE_STATE)userLineState forContactUid:(uint64_t)contactUid;

/**重载子节点视图
 * @param parentNodeId 父节点编号
 */
- (void)reloadSubNodesUnderParentNodeId:(NSString*)parentNodeId;

/**获取已勾选的节点列表
 * @return TableTreeNode列表
 */
- (NSArray*)tickCheckedNodes;

/**获取已加载子节点的部门节点列表
 * @return TableTreeNode部门节点列表
 */
- (NSArray*)departmentNodesOfLoadedSubNodes;

@end

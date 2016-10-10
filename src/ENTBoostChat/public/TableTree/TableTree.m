//
//  TableTree.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "TableTree.h"
#import "TableTreeNode.h"
#import "ENTBoostChat.h"
#import "BlockUtility.h"
#import "SOTP+FormatTools.h"

@interface TableTree () <UITableViewDataSource,UITableViewDelegate>
{
    //UITableView *_tableView;
    NSMutableArray *_dataSource; //已经进入tableView的数据
    NSMutableArray *_nodesArray; //备选(全部)数据(包括已经进入和未进入tableView的数据);
}
@end

@implementation TableTree

@synthesize tableView = _tableView;

- (id)initWithFrame:(CGRect)frame nodes:(NSArray *)nodes
{
    if (self = [super initWithFrame:frame]) {
        _deepInLevel = 10; //最多10层
        
        //设置节点数据
        [self setNodes:nodes];
        
        //tableview
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
    }
    return self;
}

- (void)setNodes:(NSArray*)nodes
{
    _dataSource = [[NSMutableArray alloc] init];
    _nodesArray = [[NSMutableArray alloc] init];
    
    if (nodes && nodes.count) {
        [_nodesArray addObjectsFromArray:nodes];
        
        for (TableTreeNode * node in _nodesArray) {
            [self fillChildrenInNode:node];
        }
        
        NSArray* rootNodes = [self rootNodes];
        //添加根节点
        [_dataSource addObjectsFromArray:rootNodes];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.tableView.backgroundColor = backgroundColor;
}

+ (void)copyNode:(TableTreeNode*)srcNode toNode:(TableTreeNode*)destNode
{
    if (destNode.icon)
        destNode.icon = srcNode.icon;
    destNode.name = srcNode.name;
    destNode.data = srcNode.data;
    destNode.nodeId = srcNode.nodeId;
    
    destNode.sortIndex = srcNode.sortIndex;
    destNode.departmentTypeSortIndex = srcNode.departmentTypeSortIndex;
    destNode.isDepartment = srcNode.isDepartment;
    
    destNode.isHiddenTalkBtn = srcNode.isHiddenTalkBtn;
    destNode.isHiddenPropertiesBtn = srcNode.isHiddenPropertiesBtn;
    destNode.isHiddenTickBtn = srcNode.isHiddenTickBtn;
    destNode.isTickChecked = srcNode.isTickChecked;
    
//    destNode.subNodes = srcNode.subNodes;
//    destNode.parentNodeId = srcNode.parentNodeId;
//    destNode.isOpen = srcNode.isOpen;
//  isLoadedSubNodes;   //是否已经加载过该节点下一层叶子节点
}

- (BOOL)isNodeExists:(NSString*)nodeId
{
    __block BOOL result = NO;
    [BlockUtility syncPerformBlockInMainQueue:^{
        if (!nodeId) {
            return;
        }
        
        for (TableTreeNode* node in _nodesArray) {
            if ([node.nodeId isEqualToString:nodeId]) {
                result = YES;
                break;
            }
        }
    }];
    return result;
}

- (BOOL)isNodeShowed:(NSString*)nodeId
{
    __block BOOL result = NO;
    [BlockUtility syncPerformBlockInMainQueue:^{
        if (!nodeId) {
            return;
        }
        
        for (TableTreeNode* node in _dataSource) {
            if ([node.nodeId isEqualToString:nodeId]) {
                result = YES;
                break;
            }
        }
    }];
    return result;
}

//更新父节点包含子节点数量
- (void)reduceSubNodeWithParent:(NSString*)parentNodeId nodeId:(NSString*)nodeId
{
    for (NSUInteger j=0; j<_dataSource.count; j++) {
        TableTreeNode* parentNode = _dataSource[j];
        if ([parentNode.nodeId isEqualToString:parentNodeId]) {
            NSInteger leafCount = [parentNode.data[@"leafCount"] integerValue];
            if (leafCount) {
                //删除父节点下子节点缓存
                for (TableTreeNode* subNode in [parentNode.subNodes copy]) {
                    if ([subNode.nodeId isEqualToString:nodeId]) {
//                        NSMutableArray* tmpArray = [parentNode.subNodes mutableCopy];
                        [parentNode.subNodes removeObject:subNode];
//                        parentNode.subNodes = tmpArray;
                        break;
                    }
                }
                
                //设置成员数量减一
                leafCount--;
//                NSMutableDictionary* tempData = [parentNode.data mutableCopy];
                parentNode.data[@"leafCount"] = @(leafCount);
//                parentNode.data = tempData;
                //如果没有任何子节点，设置父节点为折叠状态
                if (leafCount==0)
                    parentNode.isOpen = NO;
                
                [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:j inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }
}

//删除备用数据里的node
- (void)removeFromNodeArrayWithId:(NSString*)nodeId
{
//    for (TableTreeNode* tmpNode in [_nodesArray copy]) {
//        if ([tmpNode.nodeId isEqualToString:nodeId]) {
//            [_nodesArray removeObject:tmpNode];
//        }
//    }
    NSMutableIndexSet* toDelIndexes = [[NSMutableIndexSet alloc] init];
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        if ([tmpNode.nodeId isEqualToString:nodeId])
            [toDelIndexes addIndex:i];
    }
    [_nodesArray removeObjectsAtIndexes:toDelIndexes];
}

//删除tabview数据源里的node
- (void)removeFromDataSourceAndTableViewWithId:(NSString*)nodeId
{
//    NSArray* dsArray = [_dataSource copy];
//    for (int i=0; i<dsArray.count; i++) {
//        TableTreeNode* tmpNode = dsArray[i];
//        if ([tmpNode.nodeId isEqualToString:nodeId]) {
//            //删除节点
//            [_dataSource removeObjectAtIndex:i];
////            [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
////            break;
//        }
//    }
    NSMutableIndexSet* indexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* tmpNode = _dataSource[i];
        if ([tmpNode.nodeId isEqualToString:nodeId]) {
            [indexes addIndex:i];
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    [_dataSource removeObjectsAtIndexes:indexes];
    [_tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

//以id获取节点对象
- (TableTreeNode*)nodeWithId:(NSString*)nodeId
{
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        if ([tmpNode.nodeId isEqualToString:nodeId])
            return tmpNode;
    }
    return nil;
}

//获取节点在视图中的行数(从0开始计算)，返回小于0表示没有找到
- (int)rowWithNodeId:(NSString*)nodeId
{
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* node = _dataSource[i];
        if ([nodeId isEqualToString:node.nodeId]) {
            return i;
        }
    }
    return -1;
}

- (void)removeNodeWithId:(NSString*)nodeId updateParentNodeLoadedState:(BOOL)updateParentNodeLoadedState
{
    TableTreeNode* node = [self nodeWithId:nodeId];
    if (!node) return;
    
    if (node.isDepartment) { //部门
        //折叠子节点
        [self minusNodesByNode:node];
        
        //删除子节点
        if (node.subNodes.count) {
            for (TableTreeNode* subNode in node.subNodes) {
                //删除备用数据里的node
                [self removeFromNodeArrayWithId:subNode.nodeId];
//                //删除tabview数据源里的node
//                [self removeFromDataSourceWithId:subNode.nodeId];
//                [self removeNodeWithId:subNode.nodeId updateParentNodeLoadedState:YES];
            }
            //清空子节点列表
            [node.subNodes removeAllObjects];
        }
        
        //删除自己
        [self removeFromNodeArrayWithId:nodeId]; //删除备用数据里的node
        [self removeFromDataSourceAndTableViewWithId:nodeId];
    } else { //成员
        [self removeFromNodeArrayWithId:nodeId]; //删除备用数据里的node和更新视图
        [self removeFromDataSourceAndTableViewWithId:nodeId]; //删除tabview数据源里的node和更新视图
        
        //更新父节点包含子节点数量
        if (node.parentNodeId)
            [self reduceSubNodeWithParent:node.parentNodeId nodeId:nodeId];
    }
    
    if (updateParentNodeLoadedState) {
        if (node.parentNodeId) {
            TableTreeNode* parentNode = [self nodeWithId:node.parentNodeId];
            if (parentNode)
                parentNode.isLoadedSubNodes = NO;
        }
    }
}

- (void)insertOrUpdateWithNode:(TableTreeNode*)node inFirstLevel:(BOOL)inFirstLevel
{
    if (inFirstLevel) {
        NSArray* rootNodes = [self rootNodes];
        
        //遍历查找是否已存在，如果存在直接更新信息
        BOOL isExist = NO;
        for (int i=0; i<rootNodes.count; i++) {
            TableTreeNode* rootNode = rootNodes[i];
            if ([node.nodeId isEqualToString:rootNode.nodeId]) {
                isExist = YES;
                [TableTree copyNode:node toNode:rootNode];
//                rootNode.originX += TableTreeCellIndent;
//                [_tableView reloadData];
                int row = [self rowWithNodeId:node.nodeId];
                if (row>=0) {
                    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
//                return;
            }
        }
        
        if (isExist) return;
        
        node.parentNodeId = nil; //因为插入在首层，所有需要设置上层等于nil
//        node.originX += TableTreeCellIndent; //缩进
        
        [_nodesArray addObject:node];
        
        //更新至tableView
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_dataSource.count inSection:0];
        [_dataSource addObject:node];
        
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        //插入或更新子节点
        for (int index=0; index<_dataSource.count; index++) {
            TableTreeNode* parentNode = _dataSource[index];
            //寻找上级节点，上层节点要求是部门
            if ([parentNode.nodeId isEqualToString:node.parentNodeId] && parentNode.isDepartment) {
//                parentNode.isLoadedSubNodes = NO;
                //查找节点是否已存在
                TableTreeNode* existNode = nil;
                for (TableTreeNode* subNode in parentNode.subNodes) {
                    //判断节点是否已经存在
                    if ([subNode.nodeId isEqualToString:node.nodeId]) {
                        existNode = subNode;
                        break;
                    }
                }
                
                if (existNode) {
                    [TableTree copyNode:node toNode:existNode];
                    
                    //刷新父节点(待完成)
                    
                    int row = [self rowWithNodeId:node.nodeId];
                    if (row>=0) {
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
//                    [_tableView reloadData];
                } else {
                    [_nodesArray addObject:node];
//                    parentNode.subNodes = [parentNode.subNodes arrayByAddingObject:node];
                    [parentNode.subNodes addObject:node];
                    
                    //判断上级是否已经展开
                    if (parentNode.isOpen /*&& parentNode.isLoadedSubNodes*/) {
                        //更新至tableView
//                        node.originX = parentNode.originX + TableTreeCellIndent; //缩进
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index+1/*parentNode.subNodes.count*/ inSection:0];
//                        NSLog(@"originX = %f, parentNode.subNodes.count = %i, index = %i", node.originX, parentNode.subNodes.count, index);
                        
                        [_dataSource insertObject:node atIndex:index+1];
                        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    
                    //刷新父节点
                    [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                break;
            }
        }
    }
}

- (NSArray*)tickCheckedNodes
{
    NSMutableArray* nodes = [[NSMutableArray alloc] init];
    for (TableTreeNode* node in _nodesArray) {
        if (node.isTickChecked)
            [nodes addObject:node];
    }
    
    return nodes;
}

- (NSArray*)departmentNodesOfLoadedSubNodes
{
    NSMutableArray* departmentNodes = [[NSMutableArray alloc] init];
    for (TableTreeNode* node in _nodesArray) {
        if (node.isDepartment && node.isLoadedSubNodes && node.subNodes.count>0)
            [departmentNodes addObject:node];
    }
    
    return departmentNodes;
}

/*! 对同组内子节点(包括子组节点)进行排序
 @param node 组内某子节点
 */
- (void)sortNodesOfSameGroupWithNode:(TableTreeNode*)node
{
    if ([_delegate respondsToSelector:@selector(tableTree:sortNodes:)]) {
        //非首层节点
        if (node.parentNodeId) {
            TableTreeNode* parentNode = [self nodeWithId:node.parentNodeId];
            if (parentNode.subNodes) {
                //折叠同层节点
                for (TableTreeNode* tmpNode in parentNode.subNodes) {
                    [self minusNodesByNode:tmpNode];
                }
                //排序
                [_delegate tableTree:self sortNodes:parentNode.subNodes];
                
                //更新视图
                int firstIndex = -1;
                NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
                for (int i=0; i<_dataSource.count; i++) {
                    TableTreeNode* tmpNode = _dataSource[i];
                    
                    if (/*!tmpNode.isDepartment && */[tmpNode.parentNodeId isEqualToString:parentNode.nodeId]) {
                        //用重新排序后的节点替换掉已在视图中的节点
                        if (firstIndex==-1) {
                            firstIndex = i;
                            [_dataSource replaceObjectsInRange:NSMakeRange(firstIndex, parentNode.subNodes.count) withObjectsFromArray:parentNode.subNodes];
                        }
                        
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                }
                
                //重新载入需要更新的成员
                if (indexPaths.count)
                    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                
            }
        } else { //首层节点
            //折叠非首层的节点
            for (TableTreeNode* tmpNode in [self rootNodes]) {
                [self minusNodesByNode:tmpNode];
            }
            
            [_delegate tableTree:self sortNodes:_nodesArray];
            [_delegate tableTree:self sortNodes:_dataSource];
            [_tableView reloadData];
        }
    }
}

- (void)updateMemberOnlineState:(EB_USER_LINE_STATE)memberOnlineState forNode:(TableTreeNode*)node
{
    if (memberOnlineState==EB_LINE_STATE_OFFLINE || memberOnlineState==EB_LINE_STATE_UNKNOWN)
        node.isOffline = YES;
    else
        node.isOffline = NO;
    
    [self sortNodesOfSameGroupWithNode:node];
}

- (void)updateMemberOnlineState:(EB_USER_LINE_STATE)memberOnlineState forContactId:(uint64_t)contactId
{
    if (!contactId)
        return;
    
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* node = _nodesArray[i];
        
        //只有成员才有在线状态
        if (!node.isDepartment && node.data[@"type"]) {
            int type = [node.data[@"type"] intValue];
            
            uint64_t localContactId = 0;
            if (type==RELATIONSHIP_TYPE_CONTACT) {
                EBContactInfo* contactInfo = node.data[@"contactInfo"];
                localContactId = contactInfo.contactId;
            }
            
            if (localContactId==contactId)
                [self updateMemberOnlineState:memberOnlineState forNode:node];
        }
    }
}

- (void)updateMemberOnlineState:(EB_USER_LINE_STATE)memberOnlineState forUid:(uint64_t)uid
{
    if (!uid)
        return;
    
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* node = _nodesArray[i];
        
        //只有成员才有在线状态
        if (!node.isDepartment && node.data[@"type"]) {
            int type = [node.data[@"type"] intValue];
            
            uint64_t localUid = 0;
            if (type==RELATIONSHIP_TYPE_CONTACT) {
                EBContactInfo* contactInfo = node.data[@"contactInfo"];
                localUid = contactInfo.uid;
            } else if (type==RELATIONSHIP_TYPE_MEMBER){
                EBMemberInfo* memberInfo = node.data[@"memberInfo"];
                localUid = memberInfo.uid;
            }
            
            if (localUid==uid)
                [self updateMemberOnlineState:memberOnlineState forNode:node];
        }
    }
}

- (void)updateMemberOnlineStates:(NSDictionary *)memberOnlineStates
{
    //存放等待更新的节点
    NSMutableDictionary* toUpdateNodes = [[NSMutableDictionary alloc] init];
    
    //更新备选数据
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        if (!tmpNode.isDepartment) { //成员节点
            EBMemberInfo* memberInfo = tmpNode.data[@"memberInfo"];
            if (memberInfo) {
                if (memberOnlineStates[@(memberInfo.uid)]) { //有在线状态
                    EB_USER_LINE_STATE memberOnlineState = [memberOnlineStates[@(memberInfo.uid)] intValue];
                    
                    if (memberOnlineState==EB_LINE_STATE_OFFLINE || memberOnlineState==EB_LINE_STATE_UNKNOWN)
                        tmpNode.isOffline = YES;
                    else
                        tmpNode.isOffline = NO;
                } else { //没有在线状态，默认为离线
                    tmpNode.isOffline = YES;
                }
                
                toUpdateNodes[tmpNode.nodeId] = tmpNode;
            }
        }
    }
    
    //更新视图
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* tmpNode = _dataSource[i];
        
        //只有成员才有在线状态
        if (!tmpNode.isDepartment) {
            if (toUpdateNodes[tmpNode.nodeId])
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    if (indexPaths.count)
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)validateUpdateMemberOnlineStates:(NSDictionary*)memberOnlineStates node:(TableTreeNode*)node toUpdateNodes:(NSMutableDictionary*)toUpdateNodes
{
    if (!node.isDepartment && node.data[@"type"]) { //成员节点
        int type = [node.data[@"type"] intValue];
        uint64_t localUid = 0;
        if (type==RELATIONSHIP_TYPE_CONTACT) {
            EBContactInfo* contactInfo = node.data[@"contactInfo"];
            localUid = contactInfo.uid;
        } else if(type==RELATIONSHIP_TYPE_MEMBER) {
            EBMemberInfo* memberInfo = node.data[@"memberInfo"];
            localUid = memberInfo.uid;
        }
        
        if (localUid) {
            if (memberOnlineStates[@(localUid)]) { //有在线状态
                EB_USER_LINE_STATE memberOnlineState = [memberOnlineStates[@(localUid)] intValue];
                
                if (memberOnlineState==EB_LINE_STATE_OFFLINE || memberOnlineState==EB_LINE_STATE_UNKNOWN)
                    node.isOffline = YES;
                else
                    node.isOffline = NO;
            } else { //没有在线状态，默认为离线
                node.isOffline = YES;
            }
            
            toUpdateNodes[node.nodeId] = node;
        }
    }
}

- (void)updateMemberOnlineStates:(NSDictionary*)memberOnlineStates forParentNodeId:(NSString*)parentNodeId;
{
    //存放等待更新的节点
    NSMutableDictionary* toUpdateNodes = [[NSMutableDictionary alloc] init];
    
    //更新备选数据
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        
        if (parentNodeId) {
            //寻找指定的部门节点
            if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:parentNodeId]) {
                //遍历子节点
                for (TableTreeNode* subNode in tmpNode.subNodes) {
                    [self validateUpdateMemberOnlineStates:memberOnlineStates node:subNode toUpdateNodes:toUpdateNodes];
                }
                if ([_delegate respondsToSelector:@selector(tableTree:sortNodes:)])
                    [_delegate tableTree:self sortNodes:tmpNode.subNodes];
            }
        } else if (!tmpNode.isDepartment && !tmpNode.parentNodeId) { //当没指定父节点时，只处理第一层成员节点
            [self validateUpdateMemberOnlineStates:memberOnlineStates node:tmpNode toUpdateNodes:toUpdateNodes];
        }
    }
    
    //更新视图
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* tmpNode = _dataSource[i];
        
        //只有成员才有在线状态
        if (!tmpNode.isDepartment) {
            if (toUpdateNodes[tmpNode.nodeId])
                [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    if (indexPaths.count)
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

//获取部门成员在线人数
- (NSInteger)countOfGroupOnlineStateWithNodeId:(NSString*)nodeId inCountsOfGroupOnlineState:(NSDictionary*)countsOfGroupOnlineState
{
    NSInteger countOfGroupOLS = 0;
    NSNumber* obj = [countsOfGroupOnlineState objectForKey:@([nodeId unsignedLongLongValue])];
    if (obj) {
        countOfGroupOLS = [obj integerValue];
        if (countOfGroupOLS<0) countOfGroupOLS = 0;
    }
    
    return countOfGroupOLS;
}

- (void)updateCountsOfGroupOnlineState:(NSDictionary*)countsOfGroupOnlineState
{
    //更新备选数据
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        
        if (tmpNode.isDepartment)
            tmpNode.data[@"onlineCount"] = @([self countOfGroupOnlineStateWithNodeId:tmpNode.nodeId inCountsOfGroupOnlineState:countsOfGroupOnlineState]);
    }
    
    //更新视图
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* tmpNode = _dataSource[i];
        
        if (tmpNode.isDepartment) {
            tmpNode.data[@"onlineCount"] = @([self countOfGroupOnlineStateWithNodeId:tmpNode.nodeId inCountsOfGroupOnlineState:countsOfGroupOnlineState]);
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    if (indexPaths.count)
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateCountOfGroupOnlineState:(NSInteger)countOfGroupOnlineState forGroupNodeId:(NSString*)groupNodeId
{
    //更新备选数据
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        
        if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:groupNodeId])
            tmpNode.data[@"onlineCount"] = @(countOfGroupOnlineState);
    }
    
    //更新视图
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* tmpNode = _dataSource[i];
        
        if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:groupNodeId]) {
            tmpNode.data[@"onlineCount"] = @(countOfGroupOnlineState);
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    if (indexPaths.count)
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateOnlineStateCountOfGroupOnWillRemoveNode:(NSString*)nodeId
{
    //计算分组在线人数增量变化
    NSMutableDictionary* groupNodeIds = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        if ([tmpNode.nodeId isEqualToString:nodeId] && !tmpNode.isDepartment && tmpNode.parentNodeId && [tmpNode.data[@"type"] intValue] == RELATIONSHIP_TYPE_CONTACT) {
            NSNumber* obj = [groupNodeIds objectForKey:tmpNode.parentNodeId];
            if (!obj)
                groupNodeIds[tmpNode.parentNodeId] = @0;
            int existGapCount = [groupNodeIds[tmpNode.parentNodeId] intValue]; //已记录的增量变化
            if (!tmpNode.isOffline) //原来在线
                groupNodeIds[tmpNode.parentNodeId] = @(existGapCount - 1);
        }
    }
    
    //更新分组节点
    if (groupNodeIds.count>0) {
        for (NSString* groupNodeId in groupNodeIds) {
            int gapCount = [groupNodeIds[groupNodeId] intValue];
            if (gapCount!=0) {
                //更新备选数据
                for (int i=0; i<_nodesArray.count; i++) {
                    TableTreeNode* tmpNode = _nodesArray[i];
                    if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:groupNodeId]) {
                        tmpNode.data[@"onlineCount"] = @([tmpNode.data[@"onlineCount"] intValue] + gapCount);
                    }
                }
                
                //更新视图
                for (int i=0; i<_dataSource.count; i++) {
                    TableTreeNode* tmpNode = _dataSource[i];
                    if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:groupNodeId]) {
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            }
        }
    }
}

- (void)updateOnlineStateCountOfGroupWithUserLineState:(EB_USER_LINE_STATE)userLineState forContactUid:(uint64_t)contactUid
{
    if (!contactUid) return;
    
    //计算分组在线人数增量变化
    NSMutableDictionary* groupNodeIds = [[NSMutableDictionary alloc] initWithCapacity:1];
    for (int i=0; i<_nodesArray.count; i++) {
        TableTreeNode* tmpNode = _nodesArray[i];
        if (!tmpNode.isDepartment && tmpNode.parentNodeId && [tmpNode.data[@"type"] intValue] == RELATIONSHIP_TYPE_CONTACT) {
            EBContactInfo* contactInfo = tmpNode.data[@"contactInfo"];
            if (contactInfo.uid == contactUid) {
                NSNumber* obj = [groupNodeIds objectForKey:tmpNode.parentNodeId];
                if (!obj)
                    groupNodeIds[tmpNode.parentNodeId] = @0;
                
                int existGapCount = [groupNodeIds[tmpNode.parentNodeId] intValue]; //已记录的增量变化
                if (tmpNode.isOffline) { //原来离线
                    if (userLineState>EB_LINE_STATE_OFFLINE) //当前在线
                        groupNodeIds[tmpNode.parentNodeId] = @(existGapCount + 1);
                } else { //原来在线
                    if (userLineState<=EB_LINE_STATE_OFFLINE) //当前在线
                        groupNodeIds[tmpNode.parentNodeId] = @(existGapCount - 1);
                }
            }
        }
    }
    
    //更新分组节点
    if (groupNodeIds.count>0) {
        for (NSString* groupNodeId in groupNodeIds) {
            int gapCount = [groupNodeIds[groupNodeId] intValue];
            if (gapCount!=0) {
                //更新备选数据
                for (int i=0; i<_nodesArray.count; i++) {
                    TableTreeNode* tmpNode = _nodesArray[i];
                    if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:groupNodeId]) {
                        tmpNode.data[@"onlineCount"] = @([tmpNode.data[@"onlineCount"] intValue] + gapCount);
                    }
                }
                
                //更新视图
                for (int i=0; i<_dataSource.count; i++) {
                    TableTreeNode* tmpNode = _dataSource[i];
                    if (tmpNode.isDepartment && [tmpNode.nodeId isEqualToString:groupNodeId]) {
                        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                }
            }
        }
        
    }
}

- (void)reloadSubNodesUnderParentNodeId:(NSString*)parentNodeId
{
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];
    for (int i=0; i<_dataSource.count; i++) {
        TableTreeNode* node = _dataSource[i];
        if ([node.parentNodeId isEqualToString:parentNodeId]) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    if (indexPaths.count) {
        [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)reloadData
{
    [_tableView reloadData];
}

#pragma mark - private methods
//填充节点的子节点列表
- (void)fillChildrenInNode:(TableTreeNode*)parentNode
{
    parentNode.subNodes = [[NSMutableArray alloc] init];
    for(TableTreeNode *node in _nodesArray) {
        if ([node.parentNodeId isEqualToString:parentNode.nodeId]) {
            [parentNode.subNodes addObject:node];
        }
    }
}

- (NSArray *)rootNodes
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (TableTreeNode *node in _nodesArray) {
        if ([node isRoot]) {
            [array addObject:node];
        }
    }
    return array;
}

- (void)executeAddSubNodesByFatherNode:(TableTreeNode *)parentNode atIndex:(NSInteger)index
{
    if (parentNode.subNodes.count) {
        parentNode.isOpen = YES;
        
        //刷新父节点
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        
        NSUInteger count = index;
        NSMutableArray *cellIndexPaths = [NSMutableArray array];
        for (int i=0;i < parentNode.subNodes.count; i++) {
//            TableTreeNode* node = parentNode.subNodes[i];
//            node.originX = parentNode.originX + 10/*space*/;
            [cellIndexPaths addObject:[NSIndexPath indexPathForRow:count++ inSection:0]];
        }
        
        [_tableView beginUpdates];
        
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, parentNode.subNodes.count)];
        [_dataSource insertObjects:parentNode.subNodes atIndexes:indexes];
        
        [_tableView insertRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        [_tableView endUpdates];
        
        //滚动到中间位置
        NSIndexPath* indexPath = cellIndexPaths[0];
//        NSLog(@"_dataSource.count = %lu, indexPath.row = %li, indexPath.section = %li ", (unsigned long)_dataSource.count, (long)indexPath.row, (long)indexPath.section);
        [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

//追加或更新节点列表
- (void)addOrUpdateNodesArray:(NSArray*)nodes
{
    for (TableTreeNode* newNode in nodes) {
        BOOL isNew = YES;
        for (TableTreeNode* oldNode in _nodesArray) {
            if ([oldNode.nodeId isEqualToString:newNode.nodeId]) {
                [TableTree copyNode:newNode toNode:oldNode];
                isNew = NO;
            }
        }
        
        if (isNew)
            [_nodesArray addObject:newNode];
    }
}

//添加子节点
- (void)addSubNodesByFatherNode:(TableTreeNode *)parentNode atIndex:(NSInteger )index
{
    if (parentNode) {
        //待加载的下一层叶子节点数量
//        NSInteger leafCount = ((NSNumber*)parentNode.data[@"leafCount"]).integerValue;
        if (parentNode.isLoadedSubNodes /*|| !leafCount*/) { //已经加载过下一层叶子节点
            [self executeAddSubNodesByFatherNode:parentNode atIndex:index];
        } else { //没有加载过子节点数据
            if ([_delegate respondsToSelector:@selector(tableTree:loadLeavesUnderNode:onCompletion:)]) {
                [_delegate tableTree:self loadLeavesUnderNode:parentNode onCompletion:^(NSArray *nodes) {
                    parentNode.isLoadedSubNodes = YES;
//                    if (nodes.count) { 没有成员但只有子部门的无法展开
                    [self addOrUpdateNodesArray:nodes];

                    [parentNode.subNodes removeAllObjects];
                    
                    for (TableTreeNode* node in _nodesArray) {
                        if ([node.parentNodeId isEqualToString:parentNode.nodeId]) {
                            [parentNode.subNodes addObject:node];
                        }
                    }
                    
                    //排序
                    if ([_delegate respondsToSelector:@selector(tableTree:sortNodes:)])
                        [_delegate tableTree:self sortNodes:parentNode.subNodes];
                    
                    [self executeAddSubNodesByFatherNode:parentNode atIndex:index];
//                    }
                }];
            }
        }
    }
}

//根据节点减去子节点
- (void)minusNodesByNode:(TableTreeNode *)node
{
    if (node) {
//        NSArray *nodes = [_dataSource copy];
//        for (int i=0; i<nodes.count; i++) {
//            TableTreeNode *nd = nodes[i];
//            if ([nd.parentNodeId isEqualToString:node.nodeId]) {
//                [_dataSource removeObjectAtIndex:i];
//                [_tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
////                [self minusNodesByNode:nd];
//            }
//        }
        NSMutableIndexSet* indexes = [[NSMutableIndexSet alloc] init]; //待删除的数组索引
        NSMutableArray* toDelNodeIndexPaths = [[NSMutableArray alloc] init]; //待删除的tableview索引
        NSMutableArray* toDelNodes = [[NSMutableArray alloc] init]; //待删除的拥有子节点的部门节点
        
        for (int i=0; i<_dataSource.count; i++) {
            TableTreeNode *tmpNode = _dataSource[i];
            if ([tmpNode.parentNodeId isEqualToString:node.nodeId]) {
                [indexes addIndex:i];
                [toDelNodeIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                
                if (tmpNode.isDepartment && tmpNode.subNodes.count && tmpNode.isOpen)
                    [toDelNodes addObject:tmpNode];
            }
        }
        
        [_dataSource removeObjectsAtIndexes:indexes];
        [_tableView deleteRowsAtIndexPaths:toDelNodeIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        for (TableTreeNode *tmpNode in toDelNodes) {
            [self minusNodesByNode:tmpNode];
        }
        
        node.isOpen = NO;
        //[_tableView reloadData];
    }
}

#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableTreeNode *node = _dataSource[indexPath.row];
    TableTree_CellType type = node.isDepartment?TableTree_CellType_Department:TableTree_CellType_Employee;
    return [TableTreeCell heightForCellWithType:type];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TableTreeCell";
    
    TableTreeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray* topObjects = [[NSBundle mainBundle] loadNibNamed:@"TableTreeCell" owner:self options:nil];
        cell = [topObjects objectAtIndex:0];
    }
    
    [cell setDelegate:self];
    [cell fillWithNode:_dataSource[indexPath.row] inCell:cell tree:self];
    return cell;
}

//部门节点点击事件处理
- (void)departmentClickedHandle:(TableTreeNode *)node atIndexPath:(NSIndexPath *)indexPath
{
    int level = 0;
    [self caculateLevelOfNode:node level:&level];
    
    //非深层次节点直接收缩或展开
    if (level < self.deepInLevel) {
        if (node.isOpen) {
            //减
            [self minusNodesByNode:node];
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            //            [_tableView reloadData];
        } else {
            //加一个
            NSUInteger index = indexPath.row + 1;
            [self addSubNodesByFatherNode:node atIndex:index];
        }
    }
    //深层次节点抛出事件
    else {
        if ([self.delegate respondsToSelector:@selector(tableTree:deepInToNode:)]) {
            [self.delegate tableTree:self deepInToNode:node];
        }
    }
}

//计算节点所在层次
- (void)caculateLevelOfNode:(TableTreeNode*)node level:(int*)level
{
    if (node.parentNodeId) {
        for (TableTreeNode* tmpNode in _dataSource) {
            if ([tmpNode.nodeId isEqualToString:node.parentNodeId]) {
                (*level)++;
                if (tmpNode.parentNodeId)
                    [self caculateLevelOfNode:tmpNode level:level];
                break;
            }
        }
    }
}

//Cell点击事件处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    TableTreeNode *node = _dataSource[indexPath.row];
    
    if (node.isDepartment) {
        [self departmentClickedHandle:node atIndexPath:indexPath];
//        //执行点击属性按钮回调
//        if ([self.delegate respondsToSelector:@selector(tableTree:propertiesBtnTapInNode:)]) {
//            [self.delegate tableTree:self propertiesBtnTapInNode:node];
//        }
    } else {
        //执行点击聊天按钮回调
        if ([self.delegate respondsToSelector:@selector(tableTree:talkBtnTapInNode:)])
            [self.delegate tableTree:self talkBtnTapInNode:node];
//        if ([self.delegate respondsToSelector:@selector(tableTree:didSelectedRowWithNode:)]) {
//            [self.delegate tableTree:self didSelectedRowWithNode:node];
//        }
    }
}

//收缩/展开按钮点击事件处理
- (void)plusViewTap:(TableTreeCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TableTreeNode *node = _dataSource[indexPath.row];
    
    if (node.isDepartment)
        [self departmentClickedHandle:node atIndexPath:indexPath];
}

//对话按钮点击事件处理
- (void)talkViewTap:(TableTreeCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TableTreeNode *node = _dataSource[indexPath.row];
    
    if([self.delegate respondsToSelector:@selector(tableTree:talkBtnTapInNode:)]) {
        [self.delegate tableTree:self talkBtnTapInNode:node];
    }
}

//查看属性按钮点击事件处理
- (void)propertiesViewTap:(TableTreeCell *)cell
{
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    TableTreeNode *node = _dataSource[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(tableTree:propertiesBtnTapInNode:)]) {
        [self.delegate tableTree:self propertiesBtnTapInNode:node];
    }
}

- (void)sortNodesOfSameGroupWithNodeId:(NSString*)nodeId
{
    TableTreeNode* node = [self nodeWithId:nodeId];
    if (node)
        [self sortNodesOfSameGroupWithNode:node];
}

@end

//
//  TableTreeNode.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/19.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kTableTreeNode_NormalSortIndex 1000
#define kTableTreeNode_DepartmentTypeSortIndex 1000

@interface TableTreeNode : NSObject

@property (nonatomic, assign) CGFloat       originX;            //坐标x
@property (nonatomic, strong) NSString      *name;              //名称
@property (nonatomic, strong) UIColor       *textColor;         //文字颜色
@property (nonatomic, strong) NSMutableDictionary *data;        //节点详细
@property (nonatomic, strong) NSString      *icon;              //图标
@property (nonatomic, strong) NSMutableArray *subNodes;         //子节点
@property (nonatomic, strong) NSString      *parentNodeId;      //父节点的id
@property (nonatomic, strong) NSString      *nodeId;            //当前节点id
@property (nonatomic, assign) BOOL          isDepartment;       //是否是部门
@property (nonatomic, assign) BOOL          isOpen;             //是否展开的
@property (nonatomic, assign) BOOL          isHiddenTalkBtn;    //是否隐藏点击对话按钮
@property (nonatomic, assign) BOOL          isHiddenPropertiesBtn; //是否隐藏查看属性按钮
@property (nonatomic, assign) BOOL          isHiddenTickBtn;    //是否隐藏勾选按钮
@property (nonatomic, assign) BOOL          isLoadedSubNodes;   //是否已经加载过该节点下一层叶子节点

@property (nonatomic, assign) NSInteger     sortIndex;          //排序数值，从小到大排序；初始化默认值1000
@property (nonatomic, assign) NSInteger     departmentTypeSortIndex;//部门排序数值，从小到大排序；初始化默认值1000

@property (nonatomic, weak) UIImageView* iconView; //显示头像的视图
@property (nonatomic) BOOL isOffline; //是否离线，只对非部门节点有效
@property (nonatomic) BOOL isTickChecked; //勾选是否选中

//检查是否根节点
- (BOOL)isRoot;

@end

//
//  DropDownList.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/9/21.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropDownList : NSObject

//列表数据
@property(nonatomic, strong) NSMutableArray* data;

- (id)initWithInputView:(UIView*)inputView rootView:(UIView*)rootView delegate:(id)delegate;

///是否隐藏视图
- (BOOL)isHidden;

///*! 显示/隐藏 下拉列表
// @discussion
// @param hidden 是否隐藏；YES=隐藏，NO=显示
// @param targetFrame 显示的位置和尺寸
// */
//- (void)show:(BOOL)hidden toTargetFrame:(CGRect)targetFrame;

/*! 显示/隐藏 下拉列表
 @discussion
 @param hidden 是否隐藏；YES=隐藏，NO=显示
 */
- (void)show:(BOOL)hidden;

///刷新视图内容
- (void)refresh;

@end

@protocol DropDownListDelegate <NSObject>

@required

/*! 请求补全Cell资料的事件
 @param dropDownList 下拉列表对象
 @param cell 待补全资料的行对象
 @param row 行号
 @param data 相关联的数据
 */
- (void)dropDownList:(DropDownList*)dropDownList atRow:(NSUInteger)row supplyCell:(UITableViewCell*)cell data:(id)data;

/*! 选中行的事件
 @param dropDownList 下拉列表对象
 @param row 行号
 @param data 相关联的数据
 */
- (void)dropDownList:(DropDownList*)dropDownList atRow:(NSUInteger)row didSelectedWithData:(id)data;

/*! 删除行的事件
 @param dropDownList 下拉列表对象
 @param row 行号
 @param data 相关联的数据
 */
- (void)dropDownList:(DropDownList*)dropDownList atRow:(NSUInteger)row deleteWithData:(id)data;


@end
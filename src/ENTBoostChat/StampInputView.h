//
//  StampInputView.h
//  ENTBoostChat
//
//  Created by zhong zf on 14-9-17.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SETextView;

@interface StampButton : UIButton

@property(nonatomic, strong) NSDictionary* data; //自定义数据

@end

@interface StampInputView : UIView

@property(nonatomic) BOOL isRealShow; //表情资源是否真正被显示过,而不是替代图标
//@property(nonatomic, strong) NSArray* expressions; //表情资源, EBEmotion实例
//@property(nonatomic, strong) NSArray* imageButtons; //图标按钮 StampButton实例

@property(nonatomic, weak) SETextView* textView; //上层编辑区视图
@property(nonatomic, weak) id delegate; //代理

///填充表情图标
- (void)fillStamps;

@end

//事件代理
@protocol StampInputViewDelegate <NSObject>

@optional

//普通图标按钮被点击
- (void)stampInputView:(StampInputView*)stampInputView stampTaped:(StampButton*)button;

//退格键被点击
- (void)stampInputView:(StampInputView*)stampInputView deleteBackwordTaped:(UIButton*)button;

//自定义按钮1被点击
- (void)stampInputView:(StampInputView*)stampInputView customButton1Taped:(UIButton*)button;

@end
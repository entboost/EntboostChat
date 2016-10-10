//
//  ConversationViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/4.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationViewController : UIViewController<UIWebViewDelegate>

//群组(部门)编号，用于群聊
@property(nonatomic) uint64_t gid;
//对方用户编号，用于单聊
@property(nonatomic) uint64_t fUid;

@end

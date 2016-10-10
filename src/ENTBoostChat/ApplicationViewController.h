//
//  ApplicationViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/4.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EBSubscribeFuncInfo;
@class CustomSeparator;

@interface ApplicationViewController : UIViewController<UIWebViewDelegate>

///应用功能描述对象
@property(nonatomic, strong) EBSubscribeFuncInfo* subscribeFuncInfo;
///应用功能入口
@property(nonatomic, strong) NSString* subscribeFuncUrl;
//自定义参数，自动追加在url后
@property(nonatomic, strong) NSString* customParam;

///上分隔线
@property(nonatomic, strong) IBOutlet CustomSeparator* topSeparator;

///产生访问应用的完整链接地址
- (NSString*)generateUrl;

@end

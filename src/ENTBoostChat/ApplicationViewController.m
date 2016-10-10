//
//  ApplicationViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/4.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "ApplicationViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "SOTP+FormatTools.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "EBSubscribeFuncInfo.h"
#import "EBFuncNavigation.h"
#import "CustomSeparator.h"
#import "PopupMenu.h"
#import "ButtonKit.h"

@interface ApplicationViewController ()
{
    UIActivityIndicatorView* _activityIndicatorView; //加载进度视图
    UIView* _alphaView; //加载中半透明遮挡视图
    NSArray* _rootOfFuncNavigations; //底部第一层导航栏数据
    NSArray* _funcNavigations; //底部导航栏数据
    
    PopupMenu* _popupMenu; //弹出菜单实例
}

@property(strong, nonatomic) IBOutlet UIWebView* webView;

@end

@implementation ApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置顶上导航栏
    [self initTopNavigationBar];
    
    //设置底部自定义导航栏
    [self initCustomBottomNavigationBar];
}

- (NSString*)generateUrl
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    NSString* urlStr = [NSString stringWithFormat:@"%@?uid=%llu&ok=%@&sub_id=%llu&fk=%@", self.subscribeFuncUrl, ebKit.accountInfo.uid, ebKit.onlineKey, self.subscribeFuncInfo.subId, [ebKit funcKeyWithSubId:self.subscribeFuncInfo.subId]];

    //检测首位置是否有&字符，如没有则插入一个
    if (self.customParam.length>0) {
        NSRange range = [self.customParam rangeOfString:@"&"];
        if (range.location==0)
            urlStr = [NSString stringWithFormat:@"%@%@", urlStr, self.customParam];
        else
            urlStr = [NSString stringWithFormat:@"%@&%@", urlStr, self.customParam];
    }
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return urlStr;
//    return @"http://www.baidu.com";
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_alphaView) {
        //设置等待背景
        _alphaView = [[UIView alloc] initWithFrame:self.webView.bounds];
        [_alphaView setBackgroundColor:[UIColor blackColor]];
        [_alphaView setAlpha:0.2];
        [self.view addSubview:_alphaView];
        //设置进度视图(菊花)
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_alphaView addSubview:_activityIndicatorView];
        [_activityIndicatorView setCenter:_alphaView.center];
        
        //加载默认URL
        NSString* urlStr = [self generateUrl];
        NSURL *url = [NSURL URLWithString:[urlStr URLEncodedString]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
//        [self.webView setScalesPageToFit:NO];
        [self.webView loadRequest:request];
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//设置导航栏
- (void)initTopNavigationBar
{
    //设置标题
    self.navigationItem.title = self.subscribeFuncInfo.funcName;
    
//    //左边按钮1
//    UIButton* lBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [lBtn1 addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
//    [lBtn1 setImage:[UIImage imageNamed:@"navigation_goback"] forState:UIControlStateNormal];
//    UIBarButtonItem * leftButton1 = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
//    leftButton1.customView = lBtn1;
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
}

//设置底部自定义导航栏
- (void)initCustomBottomNavigationBar
{
    //生成弹出菜单实例
    _popupMenu = [[PopupMenu alloc] init];
    //设置弹出菜单基本参数
    [_popupMenu setTitleFont:[UIFont systemFontOfSize:18.f]];
    
//    [_popupMenu setBackgroundColor:[UIColor colorWithHexString:@"#EEFAFE"]];
    [_popupMenu setCornerRadius:4.f];
    
    [[ENTBoostKit sharedToolKit] loadFuncNavigationsWithSubId:self.subscribeFuncInfo.subId onCompletion:^(NSArray *funcNavigations) {
        [BlockUtility performBlockInMainQueue:^{
            UIView* barView = [self.view viewWithTag:101];
            //遍历查询高度约束
            NSArray* constraints = [barView constraints];
            NSLayoutConstraint* constraint;
            for (NSLayoutConstraint* tmpConstraint in constraints) {
                if(tmpConstraint.firstItem == barView && tmpConstraint.secondItem == nil && tmpConstraint.firstAttribute == NSLayoutAttributeHeight)
                    constraint = tmpConstraint;
            }
            
            _funcNavigations = funcNavigations;
            
            //设置高度
            if (funcNavigations.count)
                constraint.constant = 44.f;
            else
                constraint.constant = 0.f;
            
            //设置上分隔线高度
            self.topSeparator.lineHeight1 = 1.f;
            self.topSeparator.color1 = EBCHAT_DEFAULT_BORDER_CORLOR;//[UIColor colorWithHexString:@"#83c5db"];
            [self.topSeparator setNeedsDisplay];
            
            //生成第一层导航
            _rootOfFuncNavigations = [self rootsOfFuncNavigations];
            CGFloat bWidth = floorf(((float)self.view.bounds.size.width)/_rootOfFuncNavigations.count); //按钮宽度
            for (int i=0; i<_rootOfFuncNavigations.count; i++) {
                EBFuncNavigation* funcNav = _rootOfFuncNavigations[i];
                
                //生成按钮
                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.tag = 201 + i;
                [button setFrame:CGRectFromString([NSString stringWithFormat:@"{{%f, 4},{%f, 32}}", bWidth*i, bWidth])];
                [button setTitle:funcNav.name forState:UIControlStateNormal];
                [button setTitleColor:EBCHAT_DEFAULT_FONT_COLOR/*[UIColor colorWithHexString:@"#194e62"]*/ forState:UIControlStateNormal];
                [button addTarget:self action:@selector(navigationAction:) forControlEvents:UIControlEventTouchUpInside];
                [barView addSubview:button];
                
                //生成分隔线
                if (i < _rootOfFuncNavigations.count-1) {
                    CustomSeparator* separator = [[CustomSeparator alloc] initWithFrame:CGRectFromString([NSString stringWithFormat:@"{{%f, 5}, {1.f, 34}}", bWidth*(i+1)])];
                    separator.lineHeight1 = 36.0f;
                    separator.color1 = self.topSeparator.color1;
                    [barView addSubview:separator];
                }
            }
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"loadFuncNavigationsWithSubId %llu error, code = %li, msg = %@", self.subscribeFuncInfo.subId, (long)error.code, error.localizedDescription);
    }];
}

//获取底部导航栏第一层数据
- (NSArray*)rootsOfFuncNavigations
{
    NSMutableArray* rootFuncNavigations = [[NSMutableArray alloc] init];
    for (EBFuncNavigation* funcNav in _funcNavigations) {
        if (!funcNav.parentNavId)
            [rootFuncNavigations addObject:funcNav];
    }
    return rootFuncNavigations;
}

//获取底部某一导航的子菜单数据
- (NSArray*)subFuncNavigationsWithParentNavId:(uint64_t)parentNavId
{
    NSMutableArray* subFuncNavigations = [[NSMutableArray alloc] init];
    for (EBFuncNavigation* funcNav in _funcNavigations) {
        if (funcNav.parentNavId == parentNavId)
            [subFuncNavigations addObject:funcNav];
    }
    return subFuncNavigations;
}

//点击首层导航栏
- (void)navigationAction:(UIButton*)sender
{
    EBFuncNavigation* currentFuncNav = _rootOfFuncNavigations[sender.tag-201];
    if (currentFuncNav) {
        NSArray* subFuncNavigations = [self subFuncNavigationsWithParentNavId:currentFuncNav.navId];
        if (subFuncNavigations.count) { //有子菜单
            //生成菜单项
            NSMutableArray* menuItems = [[NSMutableArray alloc] init];
            for (EBFuncNavigation* funcNav in subFuncNavigations) {
                PopupMenuItem* item = [PopupMenuItem menuItem:funcNav.name image:nil target:self action:@selector(menuItemAction:) tag:funcNav.navId];
                item.foreColor = EBCHAT_DEFAULT_FONT_COLOR;//[UIColor colorWithHexString:@"#194e62"];
                item.alignment = NSTextAlignmentCenter;
                [menuItems addObject:item];
            }
            
            //坐标转换
            UIView* barView = [self.view viewWithTag:101];
            CGRect fromRect = [barView convertRect:sender.frame toView:self.view];
            //显示弹出菜单
            [_popupMenu showMenuInView:self.view fromRect:fromRect menuItems:menuItems arrowSize:10.f target:nil cancelAction:nil];
        } else { //没有子菜单
            if (currentFuncNav.url.length) {
                //直接加载URL
                NSURL *url = [NSURL URLWithString:currentFuncNav.url];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                [self.webView loadRequest:request];
            }
        }
    }
}

- (void)menuItemAction:(id)sender
{
    PopupMenuItem* menuItem = (PopupMenuItem*)sender;
    uint64_t navId = menuItem.tag;
    if (navId) {
        //遍历寻找导航项
        for (EBFuncNavigation* funcNav in _funcNavigations) {
            if (funcNav.navId == navId) {
                if (funcNav.url.length) {
                    //加载URL
                    NSURL *url = [NSURL URLWithString:funcNav.url];
                    NSURLRequest *request = [NSURLRequest requestWithURL:url];
                    [self.webView loadRequest:request];
                }
                break;
            }
        }
    }
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//Go按钮点击事件
- (IBAction)goButtonTaped:(id)sender
{
//    NSURL *url = [NSURL URLWithString:@"http://www.entboost.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
}

//浏览器加载页面开始
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (![_alphaView superview])
        [self.view addSubview:_alphaView];
    [_activityIndicatorView startAnimating];
}

//浏览器加载页面完成
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_alphaView removeFromSuperview];
    [_activityIndicatorView stopAnimating];
}

//浏览器加载页面失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"webView load error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
    [_alphaView removeFromSuperview];
    [_activityIndicatorView stopAnimating];
}

//浏览器内触发链接
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"click URL: %@", request.URL);
    
    //解析恩布IM功能标签
    NSString* urlStr = [request.URL absoluteString];
    if ([urlStr hasPrefix:@"ebim-call-account://"]) { //单聊功能
        NSString* account = [urlStr substringFromIndex:@"ebim-call-account://".length];
        account = [account stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去两边空格
        if (account.length) {
            //发起单聊通知
            NSDictionary* userInfo = @{@"ebim-tag" : @"call-account", @"account" : account};
            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT object:self userInfo:userInfo];
        }
        return NO;
    } else if ([urlStr hasPrefix:@"ebim-call-group://"]){ //群聊功能
        NSString* depCodeStr = [urlStr substringFromIndex:@"ebim-call-group://".length];
        depCodeStr = [depCodeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去两边空格
        if (depCodeStr.length) {
            //判断纯数字
            uint64_t depCode = 0;
            NSScanner* scan = [NSScanner scannerWithString:depCodeStr];
            if ([scan scanUnsignedLongLong:&depCode] && [scan isAtEnd] && depCode) {
                //发起群聊通知
                NSDictionary* userInfo = @{@"ebim-tag" : @"call-group", @"depCode" : @(depCode)};
                [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT object:self userInfo:userInfo];
            }
        }
        return NO;
    } else if ([urlStr hasPrefix:@"eb-close://"]) { //关闭应用窗口(手机应用中相当于Pop Controller)
        [self goBack];
        return NO;
    } else if ([urlStr hasPrefix:@"eb-open-file://"] || [urlStr hasPrefix:@"eb-open://"] || [urlStr hasPrefix:@"eb-open2://"]) {
        //暂无实现
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}
*/
@end

//
//  ConversationViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/4.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "ConversationViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost.h"
#import "SOTP+FormatTools.h"
#import "BlockUtility.h"
#import "ENTBoost+Utility.h"
#import "ButtonKit.h"

@interface ConversationViewController ()
{
    UIActivityIndicatorView* _activityIndicatorView; //加载进度视图
    UIView* _alphaView; //加载中半透明遮挡视图
}

@property(strong, nonatomic) IBOutlet UIWebView* webView;

@end

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置顶上导航栏
    [self initTopNavigationBar];
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
        
        //加载URL
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        NSString* urlStr = [NSString stringWithFormat:@"%@?uid=%llu&ok=%@",ebKit.conversationsUrl, ebKit.accountInfo.uid, ebKit.onlineKey];
        if (self.fUid) {
            urlStr = [NSString stringWithFormat:@"%@&fuid=%llu", urlStr, self.fUid];
        } else if (self.gid) {
            urlStr = [NSString stringWithFormat:@"%@&gid=%llu", urlStr, self.gid];
        }
        urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"urlStr = %@", urlStr);
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
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
    self.navigationItem.title = @"漫游聊天记录";
    
//    //右边按钮1
//    UIButton* rbtn1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 24)];
//    [rbtn1 setImage:[UIImage imageNamed:@"navigation_refresh"] forState:UIControlStateNormal] ;
//    [rbtn1 addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"刷新页面" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton1.customView = rbtn1;

    self.navigationItem.leftBarButtonItem   = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem  = [ButtonKit refreshBarButtonWithTarget:self action:@selector(refresh)];
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//刷新当前页面
- (void)refresh
{
    [self.webView reload];
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
    NSLog(@"webView load error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    [_alphaView removeFromSuperview];
    [_activityIndicatorView stopAnimating];
}

//浏览器内触发链接
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"%@", request.URL);
    
//    //解析恩布IM功能标签
//    NSString* urlStr = [request.URL absoluteString];
//    if ([urlStr hasPrefix:@"ebim-call-account://"]) { //单聊功能
//        NSString* account = [urlStr substringFromIndex:@"ebim-call-account://".length];
//        account = [account stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去两边空格
//        if (account.length) {
//            //发起单聊通知
//            NSDictionary* userInfo = @{@"ebim-tag" : @"call-account", @"account" : account};
//            [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT object:self userInfo:userInfo];
//        }
//        return NO;
//    } else if ([urlStr hasPrefix:@"ebim-call-group://"]){ //群聊功能
//        NSString* depCodeStr = [urlStr substringFromIndex:@"ebim-call-group://".length];
//        depCodeStr = [depCodeStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去两边空格
//        if (depCodeStr.length) {
//            //判断纯数字
//            uint64_t depCode = 0;
//            NSScanner* scan = [NSScanner scannerWithString:depCodeStr];
//            if ([scan scanUnsignedLongLong:&depCode] && [scan isAtEnd] && depCode) {
//                //发起群聊通知
//                NSDictionary* userInfo = @{@"ebim-tag" : @"call-group", @"depCode" : @(depCode)};
//                [[NSNotificationCenter defaultCenter] postNotificationName:EBCHAT_NOTIFICATION_APPLICATION_DIDSELECT object:self userInfo:userInfo];
//            }
//        }
//        return NO;
//    } else if ([urlStr hasPrefix:@"eb-close://"]) { //关闭应用窗口(手机应用中相当于Pop Controller)
//        [self goBack];
//        return NO;
//    } else if ([urlStr hasPrefix:@"eb-open-file://"] || [urlStr hasPrefix:@"eb-open://"] || [urlStr hasPrefix:@"eb-open2://"]) {
//        //暂无实现
//        return NO;
//    } else {
//        return YES;
//    }
    return YES;
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

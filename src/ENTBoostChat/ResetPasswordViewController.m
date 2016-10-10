//
//  ResetPasswordViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/8/29.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "ButtonKit.h"

@interface ResetPasswordViewController ()
{
    BOOL _isOpen;   //页面是否已经加载
    UIActivityIndicatorView* _activityIndicatorView; //加载进度视图
    UIView* _alphaView; //加载中半透明遮挡视图
}

@property(nonatomic, strong) IBOutlet UIWebView* webView;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad
{
    _isOpen = NO;
    
    self.title = @"重置密码";
    
    //导航栏左边按钮1
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!_isOpen) {
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
        NSURL *url = [NSURL URLWithString:self.resetPwdUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    }
}

//返回上一级
- (void)goBack
{
    [_activityIndicatorView stopAnimating];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end

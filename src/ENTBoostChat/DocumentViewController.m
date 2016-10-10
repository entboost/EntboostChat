//
//  DocumentViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/3/17.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "DocumentViewController.h"
#import "ButtonKit.h"

@interface DocumentViewController ()
{
    UIActivityIndicatorView* _activityIndicatorView; //加载进度视图
    UIView* _alphaView; //加载中半透明遮挡视图
}
@property(nonatomic, strong) IBOutlet UIWebView* webView;

@end

@implementation DocumentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.navigationItem.title = self.filePath?[self.filePath lastPathComponent]:@"PDF浏览";
    
    //定义返回按钮
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
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
        
        //加载文档
        if ([self.pathExtension isEqualToString:@"txt"]) {
            ///编码可以解决 .txt 中文显示乱码问题
            NSStringEncoding *useEncodeing = nil;
            //带编码头的如utf-8等，这里会识别出来
            NSString *body = [NSString stringWithContentsOfFile:self.filePath usedEncoding:useEncodeing error:nil];
            //识别不到，按GBK编码再解码一次.这里不能先按GB18030解码，否则会出现整个文档无换行bug。
            if (!body)
                body = [NSString stringWithContentsOfFile:self.filePath encoding:0x80000632 error:nil];
            
            //还是识别不到，按GB18030编码再解码一次.
            if (!body)
                body = [NSString stringWithContentsOfFile:self.filePath encoding:0x80000631 error:nil];
            
            if (body) {
                NSString* responseStr = [NSString stringWithFormat:
                                         @"<HTML>"
                                         "<head>"
                                         "<title>Text View</title>"
                                         "</head>"
                                         "<BODY>"
                                         "<pre>"
                                         "%@"
                                         "/pre>"
                                         "</BODY>"
                                         "</HTML>",
                                         body];
                
                [self.webView loadHTMLString:responseStr baseURL: nil];
            }
        } else {
            NSURL *url = [NSURL fileURLWithPath:self.filePath];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            [self.webView loadRequest:request];
        }
    }
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
- (void)goBack
{
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

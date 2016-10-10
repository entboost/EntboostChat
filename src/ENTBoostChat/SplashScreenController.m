//
//  SplashScreenController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-10-16.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "SplashScreenController.h"
#import "GifView.h"

@interface SplashScreenController ()

//@property(nonatomic, strong) IBOutlet UIWebView* progressbarView;
@property(nonatomic, strong) IBOutlet GifView* gifView;

@end

@implementation SplashScreenController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat rate = self.view.bounds.size.height/self.view.bounds.size.width;
    
    //比率小于1.7的是3.5吋屏iphone
    if (rate < 1.7)
        self.imageView.image = [UIImage imageNamed:@"splash1"];
    else
        self.imageView.image = [UIImage imageNamed:@"splash2"];
    
//    //显示进度条
//    NSData* gifData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"progressbar" ofType:@"gif"]];
//    [self.progressbarView setBackgroundColor:[UIColor clearColor]];
//    [self.progressbarView loadData:gifData MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"progressbar" withExtension:@"gif"];
    [self.gifView setFileURL:fileUrl];
    [self.gifView startAnimation];
    
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide]; //显示状态栏
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.gifView)
        [self.gifView stopAnimation];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hidden
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

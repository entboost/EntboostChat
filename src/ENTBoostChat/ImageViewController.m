//
//  ImageViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 13-1-24.
//  Copyright (c) 2013年 zhong zf. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
{
    UIToolbar *_toolbar;
    BOOL _isToolbarShowed;
}
@end

@implementation ImageViewController

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
    
    if (!self.image) {
        NSLog(@"no image");
        return;
    }
    
    self.imageView.image = self.image;
    NSLog(@"image.size = %@", NSStringFromCGSize(self.image.size));
    self.imageView.frame = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    //注册手势触摸事件
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewclick:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;
    
    //设置滚动内容
    CGSize scrollSize = self.scrollView.bounds.size;
    CGSize imageSize = self.imageView.bounds.size;
    CGSize maxSize = scrollSize;
    
    CGFloat widthRatio = maxSize.width/imageSize.width;
    CGFloat heightRatio = maxSize.height/imageSize.height;
    CGFloat initialZoom = (widthRatio > heightRatio) ? heightRatio : widthRatio;
    
    [self.scrollView setContentSize:CGSizeMake(imageSize.width, imageSize.height)];
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    
    /*
     ** 设置UIScrollView的最大和最小放大级别（注意如果MinimumZoomScale == MaximumZoomScale，
     ** 那么UIScrllView就缩放不了了
     */
    [self.scrollView setMinimumZoomScale:initialZoom/2];
    [self.scrollView setMaximumZoomScale:5];
    
    // 设置UIScrollView初始化缩放级别
    [self.scrollView setZoomScale:initialZoom];
    
    //设置背景色
    self.view.backgroundColor = [UIColor blackColor];
    
    
    //生成工具栏
    UIBarButtonItem *fixedSpace =nil;
    
    NSMutableArray* buttons =[[NSMutableArray alloc] initWithCapacity:0];
    [buttons addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_goback"] style:UIBarButtonItemStylePlain target:self action:@selector(backToParent:)]];
//    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(backToParent:)]];
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil]];
    fixedSpace =[buttons lastObject];
    fixedSpace.width =30;
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navigation_save"] style:UIBarButtonItemStylePlain target:self action:@selector(savePhoto:)]];
//    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(savePhoto:)]];
    
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil]];
    fixedSpace =[buttons lastObject];
    fixedSpace.width =30;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height-44.0, self.view.frame.size.width, 44.0)];
    [_toolbar setTintColor:[UIColor whiteColor]];
    [_toolbar setBarStyle:UIBarStyleBlack];
    [_toolbar setTranslucent:YES];
    _toolbar.autoresizingMask =UIViewAutoresizingFlexibleTopMargin;
    [_toolbar setItems:buttons];
    [_toolbar setTag:101];

    _isToolbarShowed =YES;
    [self setToolbarHidden:!_isToolbarShowed animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width?scrollView.contentSize.width/2 : xcenter;
    
    //同上，此处修改y值
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height?scrollView.contentSize.height/2 : ycenter;
    
    [self.imageView setCenter:CGPointMake(xcenter, ycenter)];
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)imageViewclick:(UITapGestureRecognizer *)gesture
{
    [self setToolbarHidden:_isToolbarShowed animated:YES];
}

//隐藏或显示工具栏
-(void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    id toolbar =[self.view viewWithTag:101];
    
    if(toolbar) { //toobar已显示
        if(hidden) {
            [toolbar removeFromSuperview];
            _isToolbarShowed =NO;
        }
    } else { //toobar还未显示
        if(!hidden) {
            [self.view addSubview:_toolbar];
            _isToolbarShowed =YES;
        }
    }
}

#pragma mark - toolbar
//返回上一层界面
-(void)backToParent:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//保存当前图片到相册
-(void)savePhoto:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

//保存当前图片到相册完成
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        NSLog(@"error:%@", error);
    } else {
        UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"友好提示" message:@"图片成功保存在相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
}

@end

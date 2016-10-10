//
//  HeadPhotoSettingViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/23.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "HeadPhotoSettingViewController.h"
#import "ENTBoost.h"
#import "ENTBoostChat.h"
#import "ButtonKit.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "FileUtility.h"
#import "FVCustomAlertView.h"
#import "CustomSeparator.h"
#import <objc/runtime.h>
#import "PhotoEditorController.h"

@interface HeadPhotoSettingViewController () <UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PhotoEditorControllerDelegate>
{
    UIStoryboard* _settingStoryboard;
}
@property(nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property(nonatomic, strong) NSMutableArray* headPhotos;
@property(nonatomic, strong) UIImageView* currentImageView;

@end

@implementation HeadPhotoSettingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder]) {
        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)]; //导航栏左边按钮1
    
    self.scrollView.delegate = self;
    
    self.headPhotos = [[[ENTBoostKit sharedToolKit] systemHeadPhotos] mutableCopy];
    [self renderHeadPhotosView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//返回上一级
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

const CGFloat bigImageWidth = 80.0;     //大图标宽度
const CGFloat bigImageHeight= 80.0;     //大图标高度
const CGFloat imageWidth    = 50.0;     //图标宽度
const CGFloat imageHeight   = 50.0;     //图标高度
const CGFloat marginHorizontal = 10.0; //左右横向间隙
const CGFloat marginVertical   = 10.0; //上下纵向间隙
const CGFloat minSpace         = 10.0; //最小间隙

//渲染头像列表视图
- (void)renderHeadPhotosView
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    CGFloat contentWidth = [[UIScreen mainScreen] bounds].size.width; //内容视图宽度
    CGFloat imageViewBeginY = marginVertical + bigImageHeight + 50.0; //小图标显示开始纵坐标
    CGFloat contentHeight = imageViewBeginY; //内容视图高度
    
    //===计算全部小图标分布视图尺寸===
    //计算每行最大容纳个数
    CGFloat n = (contentWidth - (2*marginHorizontal) + minSpace)/(imageWidth+minSpace);
    int maxCount = floor(n);
    //计算图标间实际间隙
    CGFloat space = 0.0;
    if (maxCount>1)
        space = (contentWidth - (2*marginHorizontal) - (imageWidth*maxCount))/(maxCount-1);
    //计算图标行数
    int rowCount = (((int)self.headPhotos.count+maxCount-1)/maxCount);
    
    contentHeight += (imageHeight+space)*rowCount;
    // 设置内容视图尺寸
    self.scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);

    //定义常用参数值
    UIFont* font = [UIFont boldSystemFontOfSize:12.0];
    NSTextAlignment textAlignment = NSTextAlignmentCenter;
    UIColor* color = [UIColor lightGrayColor];
    UIColor* borderColor = [UIColor colorWithHexString:@"#D9D6CB"];
    
    //====显示大图标====
    self.currentImageView = [[UIImageView alloc] initWithFrame:(CGRect){(contentWidth-bigImageWidth)/2, marginVertical, bigImageWidth, bigImageHeight}]; //大图标
    self.currentImageView.backgroundColor = [UIColor clearColor];
    EBCHAT_UI_SET_CORNER_VIEW(self.currentImageView, 1.0f, borderColor);
    
//    if ([ebKit havingDefaultHeadPhoto]) {
//        [ebKit loadMyDefaultHeadPhotoOnCompletion:^(NSString *filePath) {
//            [BlockUtility performBlockInMainQueue:^{
//                [self.currentImageView setImage:[UIImage imageWithContentsOfFile:filePath]];
//            }];
//        } onFailure:^(NSError *error) {
//            NSLog(@"loadMyDefaultHeadPhoto error, code = %@, msg = %@", @(error.code), error.localizedDescription);
//        }];
//    }
    if (self.memberInfo) {
        __weak typeof(self) safeSelf = self;
        [ebKit loadHeadPhotoWithMemberInfo:self.memberInfo onCompletion:^(NSString *filePath) {
            [BlockUtility performBlockInMainQueue:^{
                [safeSelf.currentImageView setImage:[UIImage imageWithContentsOfFile:filePath]];
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"loadHeadPhotoWithMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } else {
        UILabel* label = [[UILabel alloc] initWithFrame:(CGRect){5, (bigImageHeight-20)/2 , bigImageWidth-10, 20}];
        label.text = @"没有头像";
        label.font = font;
        label.textAlignment = textAlignment;
        label.textColor = color;
        [self.currentImageView addSubview:label];
    }
    
    [self.scrollView addSubview:self.currentImageView];
    
    //===显示自定义头像按钮====
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = (CGRect){(self.currentImageView.origin.x + bigImageWidth) + (contentWidth-(self.currentImageView.origin.x + bigImageWidth)-100)/2, marginVertical+(bigImageHeight + 20 -24)/2, 100, 24};
    [button setTitle:@"自定义头像" forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button.titleLabel setFont:font];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(button, 1.0f, borderColor, 2.0f);
    [button addTarget:self action:@selector(photoPicker:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:button];
    
    //当前头像文字提示
    UILabel* label1 = [[UILabel alloc] initWithFrame:(CGRect){self.currentImageView.frame.origin.x, self.currentImageView.frame.origin.y + bigImageHeight, bigImageWidth, 20}];
    label1.text = @"当前头像";
    label1.font = font;
    label1.textAlignment = textAlignment;
    label1.textColor = color;
    [self.scrollView addSubview:label1];
    
    //系统头像文字提示
    UILabel* label2 = [[UILabel alloc] initWithFrame:(CGRect){marginHorizontal, imageViewBeginY-24, 100, 16}];
    label2.text = @"经典头像";
    label2.font = font;
    label2.textAlignment = NSTextAlignmentLeft;
    label2.textColor = color;
    [self.scrollView addSubview:label2];
    
    //分隔线
    CustomSeparator* separator = [[CustomSeparator alloc] initWithFrame:(CGRect){marginHorizontal, label2.frame.origin.y+label2.frame.size.height, contentWidth-marginHorizontal*2, 1.0}];
    separator.color1 = [UIColor lightGrayColor];;
    separator.lineHeight1 = 1.0;
    [self.scrollView addSubview:separator];
    
    //====显示备选小图标====
    for (int i=0; i<self.headPhotos.count; i++) {
        EBEmotion* emotion = self.headPhotos[i];
        int row = maxCount>1?(i/maxCount):0;
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:(CGRect){marginHorizontal + (i%maxCount)*(imageWidth+space), imageViewBeginY + row*(imageHeight+space), imageWidth, imageHeight}];
        imageView.image = [UIImage imageWithContentsOfFile:emotion.dynamicFilepath];
        EBCHAT_UI_SET_CORNER_VIEW((imageView), 1.0f, [UIColor colorWithHexString:@"#D9D6CB"]);
        //添加点击手势
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setHeadPhoto:)];
        [imageView addGestureRecognizer:tapRecognizer];
        //关联数据
        objc_setAssociatedObject(tapRecognizer , @"resId", @(emotion.resId), OBJC_ASSOCIATION_RETAIN);
        
        [self.scrollView addSubview:imageView];
    }
}

//选取自定义头像图片
- (void)photoPicker:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    UIImagePickerControllerEditedImage
//    imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
    [self presentViewController:imagePicker animated:YES completion:nil];
//    [self.navigationController pushViewController:imagePicker animated:YES];
}

//编辑头像图片
- (void)editHeadPhoto:(UIImage*)image
{
    PhotoEditorController* vc = [_settingStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_PHOTO_EDITOR_CONTROLLER];
    vc.originImage = image;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//执行设置头像
- (void)setHeadPhoto:(UIGestureRecognizer*)recognizer
{
    uint64_t resId = [objc_getAssociatedObject(recognizer, @"resId") unsignedLongLongValue]; //取出关联数据
    
    __weak typeof(self) weakSelf = self;
    id delegate = self.delegate;
    UIImageView* currentImageView = self.currentImageView;
    uint64_t depCode = self.memberInfo.depCode;
    uint64_t empCode = self.memberInfo.empCode;
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    if (empCode && depCode) {
        //保存设置头像
        [ebKit editUserHeadPhotoWithDepCode:depCode resId:resId onCompletion:^{
            [ebKit loadMemberInfoWithEmpCode:empCode onCompletion:^(EBMemberInfo *memberInfo) {
                //刷新当前成员资料
                [BlockUtility performBlockInMainQueue:^{
                    HeadPhotoSettingViewController* safeSelf = weakSelf;
                    safeSelf.memberInfo = memberInfo;
                }];
                //刷新视图
                [ebKit loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
                    [BlockUtility performBlockInMainQueue:^{
                        currentImageView.image = [UIImage imageWithContentsOfFile:filePath];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"loadHeadPhotoWithMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                }];
                
                //回调上层
                [BlockUtility performBlockInMainQueue:^{
                    if ([delegate respondsToSelector:@selector(headPhotoSettingViewController:updateHeadPhoto:dataObject:)])
                        [delegate headPhotoSettingViewController:weakSelf updateHeadPhoto:resId dataObject:nil];
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"loadMemberInfoWithEmpCode error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"editUserHeadPhoto error, depCode = %llu, code = %@, msg = %@", depCode, @(error.code), error.localizedDescription);
        }];
    }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(__bridge NSString *)kUTTypeImage]) {
        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self editHeadPhoto:img];
//        [self performSelector:@selector(editHeadPhoto:) withObject:img afterDelay:0.1];
    }
}

//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - PhotoEditorControllerDelegate

- (void)photoEditorController:(PhotoEditorController *)viewController croppedImage:(UIImage *)croppedImage
{
    //检查是否有超过最大分辨率限制，如超过就缩小至最大限制
    UIImage* image;
    CGSize realSize;
    CGSize originSize = croppedImage.size;
    if ([UIImage decreaseUnderSize:CGSizeMake(150, 150) originSize:originSize realSize:&realSize]) {
        image = [croppedImage scaleToSize:realSize];
        NSLog(@"photoEditorController->image origin size = %@ scale to real size = %@", NSStringFromCGSize(originSize), NSStringFromCGSize(realSize));
    }
    
    //图片对象转换为二进制数据对象
    NSString* extendName = @"jpg";
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    if (!data) {
        data = UIImagePNGRepresentation(image);
        extendName = @"png";
    }
    
    if(!data) {
        NSLog(@"不能识别选中的头像图片格式");
        return;
    }
    
//    NSString* filePath = [NSString stringWithFormat:@"%@/111.jpg", [FileUtility documentDirectory]];
//    NSString* filePath = @"/Users/zhongzf/Library/Developer/CoreSimulator/Devices/C2D35DE7-0D7E-4E45-91B4-26677722BF34/data/Containers/Data/Application/FE7AB2EB-52FC-4A75-A3E7-7C3110F8D7EE/Library/Caches/entboost/resources/2132073218886594.jpg";
//    [FileUtility writeFileAtPath:filePath data:data];
//    NSString* tmpMD5 = [FileUtility md5AtPath:filePath];
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    __weak typeof(self) weakSelf = self;
    id delegate = self.delegate;
    UIImageView* currentImageView = self.currentImageView;
    uint64_t depCode = self.memberInfo.depCode;
    uint64_t empCode = self.memberInfo.empCode;
    
    //成功上传后执行的处理模块
    void(^successBlock)(uint64_t msgId, uint64_t resId) = ^(uint64_t msgId, uint64_t resId) {
        [ebKit loadMemberInfoWithEmpCode:empCode onCompletion:^(EBMemberInfo *memberInfo) {
            //刷新当前成员资料
            [BlockUtility performBlockInMainQueue:^{
                HeadPhotoSettingViewController* safeSelf = weakSelf;
                safeSelf.memberInfo = memberInfo;
            }];
            //刷新视图
            [ebKit loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
                [BlockUtility performBlockInMainQueue:^{
                    currentImageView.image = [UIImage imageWithContentsOfFile:filePath];
                }];
            } onFailure:^(NSError *error) {
                NSLog(@"loadHeadPhotoWithMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            }];
            //回调上层
            [BlockUtility performBlockInMainQueue:^{
                if ([delegate respondsToSelector:@selector(headPhotoSettingViewController:updateHeadPhoto:dataObject:)])
                    [delegate headPhotoSettingViewController:weakSelf updateHeadPhoto:resId dataObject:nil];
            }];
            CloseAlertView();
        } onFailure:^(NSError *error) {
            NSLog(@"loadMemberInfoWithEmpCode error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            CloseAlertView();
        }];
        
//        //更新视图
//        [ebKit loadMyDefaultHeadPhotoOnCompletion:^(NSString *filePath) {
//            [BlockUtility performBlockInMainQueue:^{
//                currentImageView.image = [UIImage imageWithContentsOfFile:filePath];
//            }];
//            
//            //回调上层
//            [BlockUtility performBlockInMainQueue:^{
//                if ([delegate respondsToSelector:@selector(headPhotoSettingViewController:updateHeadPhoto:dataObject:)])
//                    [delegate headPhotoSettingViewController:weakSelf updateHeadPhoto:resId dataObject:nil];
//            }];
//            CloseAlertView();
//        } onFailure:^(NSError *error) {
//            NSLog(@"loadMyDefaultHeadPhoto error, code = %@, msg = %@", @(error.code), error.localizedDescription);
//            CloseAlertView();
//        }];
    };
    

    if (empCode && depCode) {
        NSString* md5 = [FileUtility md5WithBytes:data.bytes length:data.length];
        NSLog(@"upload head photo md5:%@", md5);
        
        ShowAlertView();
        
        [ebKit uploadHeadPhoto:data depCode:depCode extendName:extendName md5:md5 onRequest:^(uint64_t msgId, uint64_t resId) {
            
        } onBegin:^(uint64_t msgId, uint64_t resId) {
            
        } onProcessing:^(double_t percent, double_t speed, uint64_t callId, uint64_t msgId, uint64_t resId) {
            
        } onResourceExists:^(uint64_t msgId, uint64_t resId) {
            successBlock(msgId, resId);
        } onCancel:^(uint64_t msgId, uint64_t resId, BOOL initiative) {
            CloseAlertView();
        } onCompletion:^(uint64_t msgId, uint64_t resId) {
            successBlock(msgId, resId);
        } onFailure:^(NSError *error) {
            NSLog(@"uploadHeadPhoto error, code = %@, msg = %@", @(error.code), error.localizedDescription);
            CloseAlertView();
        }];
        
    }
}

@end

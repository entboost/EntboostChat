//
//  TalkViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 14-8-8.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <objc/runtime.h>
#import "TalkViewController.h"
#import "ENTBoostChat.h"
#import "TalksTableViewController.h"
#import "MainViewController.h"
#import "ImageViewController.h"
#import "ENTBoost.h"
#import "MJRefresh.h"
#import "CustomSeparator.h"
#import "ENTBoost+Utility.h"
#import "BlockUtility.h"
#import "SeedUtility.h"
#import "FileUtility.h"
#import "ResourceKit.h"
#import "PopupMenu.h"
#import "MultimediaUtility.h"
#import "ConversationViewController.h"
#import "UserInformationViewController.h"
#import "GroupInformationViewController.h"
#import "FilesBrowserController.h"
#import "DocumentViewController.h"
#import "AQSViewController.h"
#import "ControllerManagement.h"
#import "ButtonKit.h"
#import "PublicUI.h"
#import "Reachability.h"
#import "CTFrameParser.h"
#import <objc/runtime.h>

#define EB_CHAT_PER_PAGE_SIZE 10
#define EB_CHAT_MAX_PICTRUE_SIZE CGSizeMake(640, 1136)

//分隔线对象
#define messageOfSeparate @"separate"

@interface TalkViewController () <AQSViewControllerDelegate>
{
    UIImage* _keyboardImage;
    UIImage* _emotionImage;
    BOOL _isKeyboardShow; //键盘是否已显示
    BOOL _isWaittingStampView; //是否将要显示表情视图
    CGFloat _curentKeyboardHeight;
//    NSUInteger _currentStampPage; //表情视图当前页数
    
    //记录正在发送的信息实例
    NSMutableDictionary* _sendingMessages;
    
    //录音音量显示图标视图
    UIImageView* _voiceRecordImageView;
    
    //成员在线状态
    NSMutableDictionary* _onlineStateOfMembers;
    
    
//    //暂存我的头像图片实例
//    UIImage* _myHeadPhoto;
//    //头像图片实例的缓存(非全部成员，使用过的才有)
//    NSMutableDictionary* _headPhotos;
    //成员名称的缓存(非全部成员，使用过的才有)
//    NSMutableDictionary* _memberNames;
    
    //下拉菜单实例
    PopupMenu* _popupMenu;
    //下拉菜单的子菜单项
    NSMutableArray* _menuItems;
    
    UIStoryboard* _talkStoryobard;
    UIStoryboard* _appStoryboard;
    UIStoryboard* _imageViewStoryboard;
    UIStoryboard* _otherStoryboard;
//    UIStoryboard* _settingStoryboard;
    
    //漫游消息Controller
    ConversationViewController* _conversationController;
    //属性Controller
    UITableViewController* _propertiesController;
    
    AQSViewController* _aqsController; //音视频通话界面控制器
    UINavigationController* _aqsNavigationController; //音视频通话界面导航控制器
}

//是否放弃发送语音
@property(atomic) BOOL isCancelVoice;
//记录加载头像情况, {@(uid):{@NO或UIImage实例}}
@property(nonatomic, strong) NSMutableDictionary* headPhotoLoadedCache;

@end

@implementation TalkViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) {
//        self.currentCallId = 0;
        self.depCode = 0;
        self.otherUid = 0;
        self.messages = [NSMutableArray array];
        _keyboardImage = [UIImage imageNamed:@"keyboard"];
        _emotionImage = [UIImage imageNamed:@"emotion"];
        _isKeyboardShow = NO;
        _isFirstShow = YES;
        _isWaittingStampView = NO;
        _curentKeyboardHeight = 0.0;
//        _currentStampPage = 1;
        
        _sendingMessages = [[NSMutableDictionary alloc] init];
        self.isCancelVoice = NO;
        
//        _headPhotos = [[NSMutableDictionary alloc] init];
//        _memberNames = [[NSMutableDictionary alloc] init];
        self.receiveFileBlockCache = [[NSMutableDictionary alloc] init];
        
        _talkStoryobard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_TALK bundle:nil];
        _appStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_APP bundle:nil];
        _imageViewStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_IMAGEVIEW bundle:nil];
        _otherStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_OTHER bundle:nil];
//        _settingStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_SETTING bundle:nil];
        
        self.chatCellMap = [[NSMutableDictionary alloc] init];
        self.headPhotoLoadedCache = [[NSMutableDictionary alloc] init];
        
        //注册事件监测器
        [self registerNotifications];
    }
    return self;
}

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
    
    //设置导航栏
    [self initNavigationBar];
    
    //设置工具栏
    [self initToolbar];
    
    //读取本地聊天记录并显示
    NSArray* messages = [[ENTBoostKit sharedToolKit] messagesWithTalkId:self.talkId andBeginTime:nil endTime:nil perPageSize:EB_CHAT_PER_PAGE_SIZE currentPage:1 orderByTimeAscending:NO];
    [self addMessages:messages append:NO noUpdateView:YES]; //添加到待显示队列
    if (self.messages.count>0)
        [self refreshMessageTimestampAtStartIndex:0 endIndex:self.messages.count-1 noUpdateView:YES]; //刷新显示时间戳
    
    //集成下拉刷新控件
    [self setupRefresh];
    
    //隐藏工具栏里部分控件
    [self.voiceButton setHidden:YES];
    [self.keyboardButton setHidden:YES];
    
    //设置输入框属性
    self.talkTextView.returnKeyType             = UIReturnKeySend;
    self.talkTextView.spellCheckingType         = UITextSpellCheckingTypeNo;
    self.talkTextView.autocorrectionType        = UITextAutocorrectionTypeNo;
    self.talkTextView.autocapitalizationType    = UITextAutocapitalizationTypeNone;
    
//    self.stampInputView = [[StampInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, _curentKeyboardHeight?_curentKeyboardHeight:216)];
//    self.stampInputView.textView = self.talkTextView;
//    [self.stampInputView fillStamps];
    
    //设置录音音量图标
    [self initVoiceRecordView];

    //加载成员在线状态
    [self loadOnlineStateOfMembers:YES];
    
    //加载头像图片
    [self loadHeadPhoto];
}

//设置导航栏
- (void)initNavigationBar
{
    //设置标题
    self.navigationItem.title = self.isGroup?self.groupInfo.depName:self.otherUserName;
    
    //右边按钮1
    UIBarButtonItem * rightButton1 = [ButtonKit barButtonItemWithTarget:self action:@selector(showProperties) imageName:self.isGroup?@"navigation_show_user_properties":@"navigation_show_group_properties" title:@"查看属性"];
    //右边按钮2
    UIBarButtonItem * rightButton2 = [ButtonKit barButtonItemWithTarget:self action:@selector(openConversations) imageName:@"navigation_conversation" title:@"漫游聊天记录"];
    //右边按钮3
    UIBarButtonItem * rightButton3 = [ButtonKit popMenuBarButtonWithTarget:self action:@selector(popupMenu)];
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItems = @[rightButton3, rightButton2, rightButton1];
}

//设置工具栏
- (void)initToolbar
{
    //输入框参数设置
    self.talkTextView.delegate = self;
    self.talkTextView.editable = YES; //开启编辑模式
    self.talkTextView.font = [UIFont systemFontOfSize:20.0f]; //设定字体
    self.talkTextView.lineSpacing = 1.0f; //行距
    self.talkTextView.paragraphSpacing = 0.0f;
    self.talkTextView.lineHeightMultiple = 0.0f;
    
    
    const CGFloat borderWidth = 1.0f; //定义边框线宽度
    UIColor* clearColor = [UIColor clearColor];
    UIColor* borderColor = EBCHAT_DEFAULT_BORDER_CORLOR; //[UIColor colorWithHexString:@"#74bad1"]; //定义边框颜色
    self.toolbarTopBorder.color1 = borderColor; //设置仿工具栏上边框颜色
    self.toolbarTopBorder.lineHeight1 = borderWidth; //设置仿工具栏上边框高度
    
    //群组会话暂不支持实时语音
    if (self.isGroup)
        self.videoButton.hidden = YES;
    
    //设置键盘按钮圆角边框
    EBCHAT_UI_SET_CORNER_VIEW(self.keyboardButton, borderWidth, clearColor);
    //设置麦克风按钮圆角边框
    EBCHAT_UI_SET_CORNER_VIEW(self.micButton, borderWidth, clearColor);
    //设置"按住说话"按钮圆角边框
    EBCHAT_UI_SET_CORNER_VIEW(self.voiceButton, borderWidth, clearColor);
    //设置仿工具栏的“其它”按钮圆角边框
    EBCHAT_UI_SET_CORNER_VIEW(self.toolbarOtherButton, borderWidth, clearColor);
    //设置信息编辑外框为圆角边框
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(self.talkTextAppearance, borderWidth, borderColor, 0.0);
//    EBCHAT_UI_SET_CORNER_VIEW(self.talkTextAppearance, borderWidth, borderColor);
    
    //设置"发送其它"图标圆角边框
    const CGFloat radiusWidth2 = 2.0f;
    const CGFloat borderWidth2 = 1.0f;
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(self.photoButton, borderWidth2, clearColor, radiusWidth2);
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(self.cameraButton, borderWidth2, clearColor, radiusWidth2);
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(self.videoButton, borderWidth2, clearColor, radiusWidth2);
    EBCHAT_UI_SET_CORNER_VIEW_RADIUS(self.folderButton, borderWidth2, clearColor, radiusWidth2);
    
    
    //“发送其它”图标按钮排列视图
    //计算约束的参数
    NSDictionary* metrics = @{@"top":@5.f, @"padding":@55.f, @"spacing":@10.f, @"hButton":@44.f, @"vButton":@44.f};
    NSMutableDictionary* views = [@{@"photoBtn":self.photoButton, @"folderBtn":self.folderButton} mutableCopy];
    if (!self.cameraButton.hidden)
        views[@"cameraBtn"] = self.cameraButton;
    if (!self.videoButton.hidden)
        views[@"videoBtn"] = self.videoButton;

    //=====生成约束=====
    //横向约束
    NSMutableString* constraintString = [[NSMutableString alloc] initWithString:@"|-padding-[photoBtn(hButton)]"]; //相册选择
    if (!self.cameraButton.hidden)
        [constraintString appendString:@"-spacing-[cameraBtn(hButton)]"]; //相机现拍
    if (!self.videoButton.hidden)
        [constraintString appendString:@"-spacing-[videoBtn(hButton)]"]; //实时音视频
    [constraintString appendString:@"-spacing-[folderBtn(hButton)]"]; //本地文件
    [constraintString appendString:@"-(>=padding)-|"];
    NSArray* contrains = [NSLayoutConstraint constraintsWithVisualFormat:constraintString options:NSLayoutFormatAlignAllTop metrics:metrics views:views];
    [self.toolbarOtherView addConstraints:contrains];
    
    //纵向约束
    //相册选择
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[photoBtn(vButton)]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
    [self.toolbarOtherView addConstraints:contrains];
    //相机现拍
    if (!self.cameraButton.hidden) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[cameraBtn(vButton)]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
        [self.toolbarOtherView addConstraints:contrains];
    }
    //实时音视频
    if (!self.videoButton.hidden) {
        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[videoBtn(vButton)]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
        [self.toolbarOtherView addConstraints:contrains];
    }
    //本地文件
    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[folderBtn(vButton)]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
    [self.toolbarOtherView addConstraints:contrains];
    
//    //图片视图与文件容量大小视图(横向)，文件名与文件容量大小(纵向)
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[imageView]-5-[fileSizeLabel]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
//    [_contentView addConstraints:contrains];
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[fileSizeLabel]" options:NSLayoutFormatAlignAllLeft metrics:metrics views:views];
//    [_contentView addConstraints:contrains];
//    
//    //完成状态视图(横向)，文件名视图与完成状态视图(纵向)
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[completionStateLabel]-0-|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
//    [_contentView addConstraints:contrains];
//    contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[completionStateLabel]" options:0 metrics:metrics views:views];
//    [_contentView addConstraints:contrains];
//    
//    //"拒绝"按钮与完成状态视图(横向)，文件名视图与"拒绝"按钮(纵向)
//    if (rejectButton) {
//        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"[rejectButton(hButton)]-[completionStateLabel]" options:NSLayoutFormatDirectionLeadingToTrailing metrics:metrics views:views];
//        [_contentView addConstraints:contrains];
//        contrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[fileNameLabel]-0-[rejectButton(vButton)]" options:0 metrics:metrics views:views];
//        [_contentView addConstraints:contrains];
//    }
    //================
    
//    //均匀分布"发送其它"图标按钮间距
//    NSDictionary* buttons = @{[NSString stringWithFormat:@"%p", self.photoButton]:self.photoButton, [NSString stringWithFormat:@"%p", self.cameraButton]:self.cameraButton, [NSString stringWithFormat:@"%p", self.videoButton]:self.videoButton, [NSString stringWithFormat:@"%p", self.folderButton]:self.folderButton};
//    const CGFloat padding = 55.0f; //左右缩进量
//    const CGFloat buttonWidth = self.photoButton.bounds.size.width; //单个按钮宽度
//    UIView* boardView = [self.view viewWithTag:121]; //其它图标按钮面板
//    const CGFloat boardViewWidth = self.view.bounds.size.width;
//    
//    //计算未隐藏的按钮
//    int countToShow = 0;
//    for (NSString* key in buttons) {
//        UIButton* button = buttons[key];
//        if (!button.hidden)
//            countToShow++;
//    }
//    
//    //多于一个按钮时需要调整约束
//    if (countToShow >1) {
//        CGFloat spacing = (boardViewWidth - padding*2 - countToShow*buttonWidth)/(countToShow-1);
//        if (spacing > 43)
//            spacing = 43;
//        
//        NSArray* constraints = [boardView constraints]; //获取该view里所有约束
//        //遍历检查相关的间距约束
//        for (NSLayoutConstraint* tmpConstraint in constraints) {
//            if (tmpConstraint.firstItem != nil && tmpConstraint.secondItem != nil && tmpConstraint.firstAttribute == NSLayoutAttributeLeading && tmpConstraint.secondAttribute == NSLayoutAttributeTrailing) {
//                UIButton* button1 = buttons[[NSString stringWithFormat:@"%p", tmpConstraint.firstItem]];
//                UIButton* button2 = buttons[[NSString stringWithFormat:@"%p", tmpConstraint.secondItem]];
//                if (button1 && button2) {
//                    //设置隐藏状态的按钮宽度约束等于0
////                    if (button1.hidden)
////                        [self setZeroWidthForButton:button1];
////                    if (button2.hidden)
////                        [self setZeroWidthForButton:button2];
//                    
////                    //两个按钮都未隐藏
////                    if (!button1.hidden && !button2.hidden) {
//                        tmpConstraint.constant = spacing;
////                        continue;
////                    } else {
////                        //在两个按钮中，只要有一个隐藏状态，间距约束设置为0
////                        tmpConstraint.constant = 0.0f;
////                    }
//                }
//            }
//        }
//    }
    
    //隐藏“发送其它”工具栏
    [self hideOtherToolbar];
}

////使用约束把按钮宽度设置为0
//- (void)setZeroWidthForButton:(UIButton*)btn
//{
//    NSArray* constraints = [btn constraints];
//    for (NSLayoutConstraint* constraint in constraints) {
//        NSLog(@"first item = %@(attr:%i)%@,  second item = %@(attr:%i)%@", ((NSObject*)constraint.firstItem).class, constraint.firstAttribute, constraint.firstItem, ((NSObject*)constraint.secondItem).class, constraint.secondAttribute, constraint.secondItem);
//        if (constraint.firstItem == btn && constraint.firstAttribute == NSLayoutAttributeWidth && constraint.secondItem == nil)
//            constraint.constant = 0.0f;
//    }
//}

//获取当前ViewController
- (UIViewController*)currentViewController
{
    return [self.talksController.navigationController visibleViewController];
}

//切换显示工具栏里控件
- (IBAction)toggleInputControlls:(id)sender
{
    if ([self.voiceButton isHidden]) {
        [self.voiceButton setHidden:NO];
        [self.keyboardButton setHidden:NO];
        [self.micButton setHidden:YES];
        [self.talkTextAppearance setHidden:YES];
    } else {
        [self.micButton setHidden:NO];
        [self.talkTextAppearance setHidden:NO];
        [self.voiceButton setHidden:YES];
        [self.keyboardButton setHidden:YES];
    }
}

//设置录音音量图标
- (void)initVoiceRecordView
{
    _voiceRecordImageView = [[UIImageView alloc] initWithFrame:CGRectFromString(@"{ {0, 0}, {75, 111}}")];
    _voiceRecordImageView.image = [UIImage imageNamed:@"record_animate_01.png"];
    [self.view addSubview:_voiceRecordImageView];
    [self.view bringSubviewToFront:_voiceRecordImageView];
    [_voiceRecordImageView setCenter:self.view.center];
    [_voiceRecordImageView setHidden:YES];
}


//加载头像图片
- (void)loadHeadPhoto
{
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] loadHeadPhotoWithTalkId:self.talkId onCompletion:^(NSString *filePath) {
        if (filePath.length > 0) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.headPhotoFilePath = filePath;
                [safeSelf.talksController reloadRowWithTalkId:safeSelf.talkId];
            }];
        }
    } onFailure:^(NSError *error) {
        NSLog(@"TalkViewController-> loadHeadPhotoWithTalkId error, talkId = %@, code = %@, msg = %@", safeSelf.talkId, @(error.code), error.localizedDescription);
    }];
}

- (void)registerNotifications
{
    //应用切换后台事件监测
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

- (void)refreshStampInputView
{
    //刷新tableView，把原来缺失的图标显示出来
    [self.talkTableView reloadData];
    //填充表情图标
    [self.stampInputView fillStamps];
}

- (void)viewWillLayoutSubviews
{
    [self updateLayout];
}

//返回上一层
- (void)goBack
{
    //停止正在进行的语音播放
    AudioToolkit* aToolkit = [AudioToolkit sharedInstance];
    if (aToolkit.playing)
        [aToolkit stopPlaying];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//查询用户或群组属性
- (void)showProperties
{
    if (self.depCode) {
        [[ControllerManagement sharedInstance] fetchGroupControllerWithDepCode:self.depCode onCompletion:^(GroupInformationViewController *gvc) {
            //进入属性界面
            [self.navigationController pushViewController:gvc animated:YES];
        } onFailure:nil];
    } else {
        [[ControllerManagement sharedInstance] fetchUserControllerWithUid:self.otherUid orAccount:nil checkVCard:YES onCompletion:^(UserInformationViewController *uvc) {
            //进入属性界面
            [self.navigationController pushViewController:uvc animated:YES];
        } onFailure:nil];
    }
}

//下拉菜单
- (void)popupMenu
{
    if (!_popupMenu) {
        _popupMenu = [[PopupMenu alloc] init];
        //设置弹出菜单基本参数
        [_popupMenu setTitleFont:[UIFont systemFontOfSize:20.f]];
        [_popupMenu setBackgroundColor:EBCHAT_DEFAULT_COLOR];//[UIColor colorWithHexString:@"#3ec6f8"]];
        [_popupMenu setCornerRadius:2.f];
        [_popupMenu setHiddenSeparator:YES];
        
        //生成菜单项
        _menuItems = [[NSMutableArray alloc] init];
        PopupMenuItem* item1 = [PopupMenuItem menuItem:@"清除本地记录" image:[UIImage imageNamed:@"navigation_delete-m"] target:self action:@selector(deleteMessages) tag:201];
        item1.foreColor = [UIColor whiteColor];
        item1.alignment = NSTextAlignmentLeft;
        [_menuItems addObject:item1];
        
        if (!self.depCode) {
            PopupMenuItem* item2 = [PopupMenuItem menuItem:@"创建讨论组" image:[UIImage imageNamed:@"navigation_create_group-m"] target:self action:@selector(createTempGroup) tag:202];
            item2.foreColor = [UIColor whiteColor];
            item2.alignment = NSTextAlignmentLeft;
            [_menuItems addObject:item2];
        }
    }
    
    //显示弹出菜单
    CGRect fromRect = CGRectMake(self.view.bounds.size.width - 24 - 20, 0, 24, 0);
    [_popupMenu showMenuInView:self.view fromRect:fromRect menuItems:_menuItems arrowSize:10.f target:nil cancelAction:nil];
}

//创建讨论组
- (void)createTempGroup
{
    BOOL waittingResult = NO;
    BOOL result = NO;
    
    //检测并获取已有callId
    EBCallInfo* callInfo = [self detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:nil];
    if (callInfo) {
        NSLog(@"原会话存在，直接呼叫创建新讨论组");
        [self call2TempGroup:@(callInfo.callId)];
    } else {
        NSLog(@"原会话不存在，稍后再尝试创建讨论组");
        [self performSelector:@selector(call2TempGroup:) withObject:nil afterDelay:3.0];
    }
}

//执行创建讨论组
- (void)call2TempGroup:(NSNumber*)numberCallId
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    
    if (!numberCallId) {
        EBCallInfo* callInfo = [ebKit callInfoWithAccount:self.otherAccount depCode:self.depCode];
        if (callInfo) {
            [ebKit call2TempGroupToUid:self.otherUid existCallId:callInfo.callId onCompletion:^(uint64_t newCallId) {
                NSLog(@"会话创建新讨论组, newCallId = %llu", newCallId);
            } onFailure:^(NSError *error) {
                NSLog(@"会话创建新讨论组失败，existCallId = %llu, code = %@, msg = %@", callInfo.callId, @(error.code), error.localizedDescription);
            }];
        } else {
            NSLog(@"会话创建新讨论组失败，原有一对一会话不存在");
        }
    } else {
        [ebKit call2TempGroupToUid:self.otherUid existCallId:[numberCallId unsignedLongLongValue] onCompletion:^(uint64_t newCallId) {
            NSLog(@"会话创建新讨论组, newCallId = %llu", newCallId);
        } onFailure:^(NSError *error) {
            NSLog(@"会话创建新讨论组失败，existCallId = %@, code = %@, msg = %@", numberCallId, @(error.code), error.localizedDescription);
        }];
    }
}

//查看漫游消息
- (void)openConversations
{
    if (!_conversationController) {
        _conversationController = [_appStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_CONVERSATION_CONTROLLER];
        _conversationController.gid = self.depCode;
        _conversationController.fUid = self.otherUid;
    }
    
    [self.navigationController pushViewController:_conversationController animated:YES];
}

//定义删除本地聊天记录确认框的Tag
const NSInteger tagOfDeleteMessages = 200;

//删除本Talk相关的全部聊天记录
- (void)deleteMessages
{
    [self showAlertViewWithTag:tagOfDeleteMessages title:@"清空记录" message:@"真得要删除本对话全部聊天记录吗?"];
}

//以消息编号或标记编号查询缓存的消息顺序号
- (NSInteger)indexOfMessage:(uint64_t)msgId orTagId:(uint64_t)tagId
{
    NSInteger result = -1;
    for (NSInteger i=0; i<self.messages.count; i++) {
        id obj = self.messages[i];
        if ([obj isMemberOfClass:[EBMessage class]]) {
            EBMessage* message = obj;
            if (msgId>0 && message.msgId == msgId) {
                result = i;
                break;
            }
            if (tagId>0 && message.tagId==tagId) {
                result = i;
                break;
            }
        }
    }
    return result;
}

//提示框后续处理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        //处理 是否显示选择发送文件界面
        case tagOfShowFloderAlertView:
        {
            if (buttonIndex == 1)
                [self executeShowFolderView];
        }
            break;
        //处理 是否显示实时音视频通话界面
        case tagOfShowAudioVideoAlertView:
        {
            if (buttonIndex == 1)
                [self presentAudioVideoViewControllerCompletion:nil];
        }
            break;
        //处理 是否清空聊天记录
        case tagOfDeleteMessages:
        {
            if (buttonIndex == 1) {
                [[ENTBoostKit sharedToolKit] deleteMessagesWithTalkId:self.talkId];
                [self.messages removeAllObjects];
                [self.talkTableView reloadData];
            }
        }
            break;
        //处理 是否删除单条聊天记录
        case tagOfDeleteOneMessage:
        {
            if (buttonIndex == 1) {
                //取出关联数据
                uint64_t msgId = [objc_getAssociatedObject(alertView, @"msgId") unsignedLongLongValue];
                uint64_t tagId = [objc_getAssociatedObject(alertView, @"tagId") unsignedLongLongValue];
                
                NSInteger index = [self indexOfMessage:msgId orTagId:tagId];
                
                if (index > -1) {
                    //执行删除聊天记录
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    //删除持久化数据
                    if (msgId>0)
                        [[ENTBoostKit sharedToolKit] deleteMessageWithMessageId:msgId];
                    else if (tagId>0)
                        [[ENTBoostKit sharedToolKit] deleteMessageWithTagId:tagId];
                    
                    [self.messages removeObjectAtIndex:index]; //在缓存删除数据
                    [self.talkTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone]; //删除当前视图中记录
                    
                    //==更新相近的时间戳==
                    id previousObj; //上一条记录
                    id nextObj;     //下一条记录
                    //刷新上一条记录
                    if (index>0) {
                        previousObj = self.messages[index-1];
                        if ([previousObj isKindOfClass:[NSString class]] && [previousObj isEqualToString:messageOfSeparate])
                            [self.talkTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index-1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    //刷新下一条记录
                    if (self.messages.count>index) {
                        nextObj = self.messages[index];
                        if ([nextObj isKindOfClass:[NSString class]] && [nextObj isEqualToString:messageOfSeparate])
                            [self.talkTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
                    }
                    
                    //==处理多余的分割线==
                    if (self.messages.count>index && index>0) {
                        //拥有两条连续时间戳，删除后面那条
                        if ([nextObj isKindOfClass:[NSString class]] && [nextObj isEqualToString:messageOfSeparate]
                                && [previousObj isKindOfClass:[NSString class]] && [previousObj isEqualToString:messageOfSeparate]) {
                            [self.messages removeObjectAtIndex:index];
                            [self.talkTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationNone];
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

/**
 *  集成刷新控件
 */
- (void)setupRefresh
{
    // 1.下拉刷新(进入刷新状态就会调用self的headerRereshing)
    [self.talkTableView addHeaderWithTarget:self action:@selector(headerRereshing) viewHeight:0.0 clipsToBounds:YES];
    
    // 设置文字
    self.talkTableView.headerPullToRefreshText = @"下拉加载更多聊天记录";
    self.talkTableView.headerReleaseToRefreshText = @"松开马上加载";
    self.talkTableView.headerRefreshingText = @"加载中,请稍后...";
}

//执行刷新动作
- (void)headerRereshing
{
    //调用endRefreshing可以结束刷新状态
    [self.talkTableView headerEndRefreshing];
    
    NSUInteger originCount = self.messages.count;
    
    // 查询数据
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    NSArray* messages;
    
    if(self.messages.count>0) {
        EBMessage* message;

        if ([[self.messages objectAtIndex:0] isMemberOfClass:[EBMessage class]])
            message = [self.messages objectAtIndex:0];
        else if (self.messages.count>1 && [[self.messages objectAtIndex:1] isMemberOfClass:[EBMessage class]])
            message = [self.messages objectAtIndex:1];
        
        if (message)
            messages = [ebKit messagesFromLastMessageId:message.msgId orderByTimeAscending:NO perPageSize:EB_CHAT_PER_PAGE_SIZE];
    } else {
        messages = [ebKit messagesWithTalkId:self.talkId andBeginTime:nil endTime:nil perPageSize:EB_CHAT_PER_PAGE_SIZE currentPage:1 orderByTimeAscending:NO];
    }
    
    NSUInteger endIndex = messages.count-1;
    
    // 加入到聊天界面中
    if (messages && messages.count>0) {
//        //检测缓存内第一条记录是否时间戳，如果是则删除它
//        if (self.messages.count>0) {
//            id obj = self.messages[0];
//            if (![obj isMemberOfClass:[EBMessage class]]) {
//                endIndex++;
//                [self.messages removeObjectAtIndex:0];
//                [self.talkTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//            }
//        }
        
        //加入缓存队列
        [self addMessages:messages append:NO noUpdateView:NO];
        //更新时间戳显示
        [self refreshMessageTimestampAtStartIndex:0 endIndex:endIndex noUpdateView:NO];
        
        //滚动到未刷新前的记录位置
        NSUInteger scrollToRow = self.messages.count - originCount;
        if (scrollToRow) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:scrollToRow inSection:0];
            [self performSelector:@selector(delayScroll:) withObject:indexPath afterDelay:0.01];
//            [self.talkTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
}

//延迟滚动到指定位置
- (void)delayScroll:(NSIndexPath*)indexPath
{
    [self.talkTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)executeUpdateBadge:(NSString*)talkId
{
    [self.talksController updateBadgeWithTalkId:talkId]; //更新Cell的badge
    [self.talksController updateBadgeValue]; //更新TabBar、应用图标右上角提醒内容
}

- (void)updateMessagesReadedStateAndBadge
{
    //设置聊天记录已读状态
    [[ENTBoostKit sharedToolKit] markMessagesAsReadedWithTalkId:self.talkId];
    //为了等待保存状态完毕，延迟0.5秒钟刷新视图
    [self performSelector:@selector(executeUpdateBadge:) withObject:self.talkId afterDelay:0.5];
}

- (void)viewDidAppear:(BOOL)animated
{
    //注册键盘活动事件监测
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil]; //self.talkTextView
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:) name:UIKeyboardDidHideNotification object:nil];
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //只有在第一次显示界面的时候才需要自动滚动到最后
    if(self.isFirstShow) {
        self.isFirstShow = NO;
        [self scrollToBottom:YES];
//        [self.talkTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
//    [self updateMessagesReadedStateAndBadge];
    [self checkToUpdateMessagesReadedStateAndBadge];
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //取消输入焦点
    if([self.talkTextView isFirstResponder])
        [self.talkTextView resignFirstResponder];
    
    //注销监测键盘活动事件
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    
//    //更新未读信息提示
//    [self updateMessagesReadedStateAndBadge];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
//    //删除手势监测注册
//    if (self.leftSwipeGestureRecognizer && self.stampInputView)
//        [self.stampInputView removeGestureRecognizer:self.leftSwipeGestureRecognizer];
//    if (self.rightSwipeGestureRecognizer && self.stampInputView)
//        [self.stampInputView removeGestureRecognizer:self.rightSwipeGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //删除事件监测注册
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isGroup
{
    return self.depCode?YES:NO;
}

- (BOOL)isAVBusying
{
    if (_aqsController && _aqsNavigationController) {
        return (_aqsController.workState>=AV_WORK_STATE_INCOMING)?YES:NO;
    }
    return NO;
}

- (BOOL)isAQSViewControllerShowed
{
    return (_aqsController && _aqsNavigationController)?YES:NO;
}

- (void)stopAVTalking
{
    if ([self isAVBusying]) {
        [_aqsController stopTalk:nil];
    }
}

//查找已存在的消息记录
- (EBMessage*)findInnerMessageWithMessage:(EBMessage*)message outIndex:(NSUInteger*)pIndex
{
    EBMessage* result;
    for (int i=0; i<self.messages.count; i++) {
        id obj = self.messages[i];
        if ([obj isMemberOfClass:[EBMessage class]]) {
            EBMessage* innerMessage = obj;
            if ( (message.msgId && message.msgId==innerMessage.msgId) || (message.tagId && message.tagId==innerMessage.tagId)
                || (message.customField && innerMessage.customField && [message.customField isEqualToString:innerMessage.customField]) ) {
                *pIndex = i;
                result = innerMessage;
                break;
            }
        }
    }
    return result;
}

//更新消息内容：文件名
- (void)updateCellWithFileName:(NSString*)fileName forMessage:(EBMessage*)message
{
    NSUInteger index = NSUIntegerMax;
    EBMessage* innerMessage = [self findInnerMessageWithMessage:message outIndex:&index];
    if (innerMessage) {
        innerMessage.fileName = fileName;
        
        //刷新视图相关Cell
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [self.talkTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)updateCellWithMessage:(EBMessage*)message reload:(BOOL)reload
{
    NSUInteger index = NSUIntegerMax;
    EBMessage* innerMessage = [self findInnerMessageWithMessage:message outIndex:&index];
    if (innerMessage) {
        message.customField = innerMessage.customField;
        message.customData = innerMessage.customData;
        self.messages[index] = message;
        
        if (reload) {
            //刷新视图相关Cell
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.talkTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            
            //如果是最后一行，而且是文件消息，则视图滚动到最后
            if (index==self.messages.count-1 && message.isFile)
                [self scrollToBottom:YES];
        } else if (message.isFile){ //否则，如果是文件消息，只更新进度条
            NSArray* cells = [self.talkTableView visibleCells];
            for (id obj in cells) {
                if ([obj isMemberOfClass:[ChatCell class]]) {
                    ChatCell* cell = obj;
                    if (cell.msgId == message.msgId) {
                        [cell updateProgress:message.percentCompletion animated:YES];
                        break;
                    }
                }
            }
        }
    }
}

- (NSUInteger)addMessages:(NSArray*)messages append:(BOOL)append noUpdateView:(BOOL)noUpdateView
{
    NSUInteger originCount = self.messages.count;
    
    //检查是否有重复消息(messageId相同)
    for (id obj in messages) {@autoreleasepool {
        if (![obj isMemberOfClass:[EBMessage class]])
              continue;
        
        EBMessage* message = obj;
        BOOL isEqual = NO;
        for (id obj1 in self.messages) {
            if (![obj1 isMemberOfClass:[EBMessage class]])
                continue;
            
            EBMessage* innerMessage = obj1;
//            NSLog(@"addMessages message.msgId = %llu, innerMessage.msgId = %llu; customField = %@", message.msgId, innerMessage.msgId, message.customField);
            if ( (message.msgId && message.msgId==innerMessage.msgId)
                    || (message.tagId && message.tagId==innerMessage.tagId)
                    || (message.customField && innerMessage.customField && [message.customField isEqualToString:innerMessage.customField]) ) {
                isEqual = YES;
                break;
            }
        }

        //找不到相同消息才加入到待显示的队列中
        if(!isEqual) {
            if(append)
                [self.messages addObject:message];
            else
                [self.messages insertObject:message atIndex:0];
        }
    }}
    
    if (!noUpdateView) {
        [self.talkTableView beginUpdates];
        
        //生成索引路径
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:0];
        
        if(append) {
            for (NSUInteger ind = originCount; ind < self.messages.count; ind++) {
                NSIndexPath *newPath =  [NSIndexPath indexPathForRow:ind inSection:0];
                [insertIndexPaths addObject:newPath];
            }
        } else {
            for (NSUInteger ind = 0; ind < self.messages.count - originCount; ind++) {
                NSIndexPath *newPath =  [NSIndexPath indexPathForRow:ind inSection:0];
                [insertIndexPaths addObject:newPath];
            }
        }
        
        //插入到表视图
        if(insertIndexPaths.count > 0)
            [self.talkTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        
        [self.talkTableView endUpdates];
    }
    
    return (self.messages.count-originCount);
}

- (void)refreshLastMessageTimestamp
{
    if (self.messages.count>0)
        [self refreshMessageTimestampAtStartIndex:self.messages.count-1 endIndex:self.messages.count-1 noUpdateView:NO];
}

//刷新聊天记录显示时间戳
- (void)refreshMessageTimestampAtStartIndex:(NSUInteger)startIndex endIndex:(NSUInteger)endIndex noUpdateView:(BOOL)noUpdateView
{
    for (NSUInteger i=startIndex; i<=endIndex; i++) {
        id obj = self.messages[i];
        if (![obj isMemberOfClass:[EBMessage class]])
            continue;
        
        static const NSTimeInterval interval = 120.0; //前后两条消息时间间隔(秒)
        EBMessage* message = obj;
        
        if (i==0) {
            endIndex++;
            
            //插入待显示数据
            [self.messages insertObject:messageOfSeparate atIndex:0];
            //更新视图
            if (!noUpdateView)
                [self.talkTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            
            continue;
        }
        
        //检测最后一条消息
        if (i==self.messages.count-1) {
            if ([[NSDate date] timeIntervalSinceDate:message.msgTime] > interval) {
                endIndex++;
                
                //插入待显示数据
                [self.messages addObject:messageOfSeparate];
                //更新视图
                if (!noUpdateView)
                    [self.talkTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.messages.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
        
        //与前一条消息时间相比
        id lastObj = self.messages[i-1];
        if ([lastObj isMemberOfClass:[EBMessage class]]) {
            EBMessage* lastMessage = lastObj;
            if ([message.msgTime timeIntervalSinceDate:lastMessage.msgTime] > interval) {
                endIndex++;
                
                //插入待显示数据
                [self.messages insertObject:messageOfSeparate atIndex:i];
                 //更新视图
                if (!noUpdateView)
                    [self.talkTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                
                //递归处理下一条消息
                if (endIndex > i)
                    [self refreshMessageTimestampAtStartIndex:i+1 endIndex:endIndex noUpdateView:noUpdateView];
                break;
            } else {
                continue;
            }
        } else {
            continue;
        }
    }
}

- (void)scrollToBottom:(BOOL)animated
{
    NSUInteger sectionCount = [self.talkTableView numberOfSections];
    if (sectionCount) {
        NSUInteger rowCount = [self.talkTableView numberOfRowsInSection:0];
        if (rowCount) {
            NSUInteger ii[2] = {0, rowCount - 1};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [self.talkTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    }
}

- (void)loadOnlineStateOfMembers:(BOOL)reloadView
{
    if (self.depCode) {
        __weak typeof(self) safeSelf = self;
        [[ENTBoostKit sharedToolKit] loadOnlineStateOfMembersWithDepCode:self.depCode onCompletion:^(NSDictionary *newOnlineStates, uint64_t depCode) {
            [BlockUtility performBlockInMainQueue:^{
                _onlineStateOfMembers = [newOnlineStates mutableCopy];
                [safeSelf.headPhotoLoadedCache removeAllObjects];
//                [_headPhotos removeAllObjects];
                //重载可见Cell
                if (reloadView)
                    [safeSelf reloadVisibleCells];
            }];
        } onFailure:^(NSError *error) {
            NSLog(@"加载成员在线状态失败，code = %@, msg = %@", @(error.code), error.localizedDescription);
        }];
    } else { //单聊认为对方都在线，待定
        if (!_onlineStateOfMembers)
            _onlineStateOfMembers = [[NSMutableDictionary alloc] init];
        _onlineStateOfMembers[@(self.otherUid)] = @(EB_LINE_STATE_ONLINE);
        //重载可见Cell
        if (reloadView)
            [self reloadVisibleCells];
    }
}

- (void)updateUserLineState:(EB_USER_LINE_STATE)userLineState fromUid:(uint64_t)fromUid fromAccount:(NSString *)fromAccount
{
    if (self.depCode) { //群组聊天
        for (id key in self.memberInfoDict) {
            EBMemberInfo* memberInfo = self.memberInfoDict[key];
            if (memberInfo.uid == fromUid) {
                _onlineStateOfMembers[@(fromUid)] = @(userLineState);
                [self.headPhotoLoadedCache removeObjectForKey:@(fromUid)];
//                [_headPhotos removeObjectForKey:@(fromUid)];
                [self reloadVisibleCellsWithUid:fromUid];
                break;
            }
        }
    } else { //单聊
        if (self.otherUid == fromUid) {
            _onlineStateOfMembers[@(fromUid)] = @(userLineState);
            [self reloadVisibleCellsWithUid:fromUid];
//            [self.talkTableView reloadData];
        }
    }
}

//从服务端加载用户在线状态并更新当前缓存和试图
- (void)loadAndUpdateUserLineStateCacheAndCellWithUid:(uint64_t)uid
{
    NSNumber* key = @(uid);
    
    //获取上下线状态
    [[ENTBoostKit sharedToolKit] loadOnlineStateOfUsers:@[key] onCompletion:^(NSDictionary *onlineStates) {
        [BlockUtility performBlockInMainQueue:^{
            //更新缓存
            NSNumber* stateNum = onlineStates[key];
            if (stateNum)
                _onlineStateOfMembers[key] = stateNum;
            else
                [_onlineStateOfMembers removeObjectForKey:key];
            
            [self.headPhotoLoadedCache removeAllObjects];
//            [_headPhotos removeAllObjects];
            //刷新相关聊天信息Cell
            [self reloadVisibleCellsWithUid:uid];
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"loadOnlineStateOfUsers uids[%@]", key);
    }];
}

- (void)addMemberInfo:(EBMemberInfo*)memberInfo
{
    //更新当前缓存
    self.memberInfoDict[@(memberInfo.uid)] = memberInfo;
    //从服务端加载用户在线状态并更新当前缓存
    [self loadAndUpdateUserLineStateCacheAndCellWithUid:memberInfo.uid];
}

- (void)updateMemberInfo:(EBMemberInfo*)memberInfo
{
    //更新当前缓存
    self.memberInfoDict[@(memberInfo.uid)] = memberInfo;
    //从服务端加载用户在线状态并更新当前缓存
    [self loadAndUpdateUserLineStateCacheAndCellWithUid:memberInfo.uid];
//    [_headPhotos removeObjectForKey:@(memberInfo.uid)];
//    //刷新相关聊天信息Cell
//    [self reloadVisibleCellsWithUid:memberInfo.uid];
}

//重载所有可见行
- (void)reloadVisibleCells
{
    NSArray* cells = [self.talkTableView visibleCells]; //获取当前可见行
    if (cells.count) {
        NSMutableArray* indexPaths = [[NSMutableArray alloc] initWithCapacity:cells.count];
        for (UITableViewCell* cell in cells) {
            NSIndexPath* indexPath = [self.talkTableView indexPathForCell:cell];
            [indexPaths addObject:indexPath];
        }
        
        [self.talkTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    }
}

//重载指定成员相关可见Cell
- (void)reloadVisibleCellsWithUid:(uint64_t)uid
{
    //匹配聊天消息发送者
    NSMutableArray* matchedMessage = [NSMutableArray array];
    NSMutableArray* matchedIndexes = [NSMutableArray array];
    for (int i=0; i<self.messages.count; i++) {
        id obj = self.messages[i];
        if ([obj isMemberOfClass:[EBMessage class]]) {
            EBMessage* message = obj;
            if (message.fromUid==uid) {
                [matchedMessage addObject:message];
                [matchedIndexes addObject:@(i)];
            }
        }
    }
    //寻找需要更新视图的行
    NSMutableArray* indexPaths = [NSMutableArray array];
    NSArray* cells = [self.talkTableView visibleCells];
    for (int i=0; i<cells.count; i++) {
        id obj = cells[i];
        if ([obj isMemberOfClass:[ChatCell class]]) {
            ChatCell* cell = obj;
            for (int j=0; j<matchedMessage.count; j++) {
                EBMessage* message = matchedMessage[j];
                if ( (cell.msgId && cell.msgId==message.msgId) || (cell.tagId && cell.tagId==message.tagId) ) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:[matchedIndexes[j] intValue] inSection:0]];
                }
            }
        }
    }
    
    if (indexPaths.count>0)
        [self.talkTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)checkToUpdateMessagesReadedStateAndBadge
{
    if ([self.navigationController topViewController] == self) {
        [self updateMessagesReadedStateAndBadge];
    }
//    if ([self.talksController.tabBarController selectedViewController] == self.parentViewController) { //tarBar当前选中的ViewController与当前窗口的父ViewController是否一致
//        UIViewController* topViewController = [((UINavigationController*)[self parentViewController]) topViewController];
//        if (topViewController == self) {  //当前窗口是否处于最顶端
//            [self updateMessagesReadedStateAndBadge];
//        }
//    }
}

#pragma mark - application notification
- (void)applicationWillResignActive:(NSNotification*)notification
{
//    //把当前窗口关联的未读聊天记录设置为已读，并更新相关badge
//    if ([self.talksController.tabBarController selectedViewController] == self.parentViewController) { //tarBar当前选中的ViewController与当前窗口的父ViewController是否一致
//        UIViewController* topViewController = [((UINavigationController*)[self parentViewController]) topViewController];
//        if (topViewController == self) {  //当前窗口是否处于最顶端
//            [self updateMessagesReadedStateAndBadge];
//        }
//    }
}

#pragma mark - extendOther ToolBar(Photo, FromCamera, Video, File)

static const CGFloat toolbarShowHeight = 100.0f; //“发送其它”工具栏显示时高度
static const CGFloat toolbarHiddenHeight = 44.0f; //“发送其它”工具栏隐藏时高度

//“发送其它”工具栏切换(隐藏/显示)
- (IBAction)toggleOtherToolbar:(id)sender
{
    NSLayoutConstraint* constraint = [self constraintForToolbarHeight];
    if (constraint) {
        if (constraint.constant == toolbarShowHeight)
            constraint.constant = toolbarHiddenHeight;
        else
            constraint.constant = toolbarShowHeight;
    }
}

//隐藏“发送其它”工具栏
- (void)hideOtherToolbar
{
    NSLayoutConstraint* constraint = [self constraintForToolbarHeight];
    if (constraint)
        constraint.constant = toolbarHiddenHeight;
}

//获取toolbar的高度约束
- (NSLayoutConstraint*)constraintForToolbarHeight
{
    UIView* toolbar = [self.view viewWithTag:111];
    NSArray* constraints = [toolbar constraints];
    for (NSLayoutConstraint* tmpConstraint in constraints) {
        if(tmpConstraint.firstItem == toolbar && tmpConstraint.secondItem == nil && tmpConstraint.firstAttribute == NSLayoutAttributeHeight) {
            return tmpConstraint;
        }
    }
    return nil;
}

//寻找主视图与toolbar的底部间距约束
- (NSLayoutConstraint*)constraintForToolbarBottom
{
    UIView* toolbar = [self.view viewWithTag:111];
    //    NSLog(@"toolbar:%@", toolbar);
    NSArray* constraints = [toolbar constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
    for (NSLayoutConstraint* tmpConstraint in constraints) {
        //        NSLog(@"first item = %@(attr:%i)%@,  second item = %@(attr:%i)%@", ((NSObject*)tmpConstraint.firstItem).class, tmpConstraint.firstAttribute, tmpConstraint.firstItem, ((NSObject*)tmpConstraint.secondItem).class, tmpConstraint.secondAttribute, tmpConstraint.secondItem);
        if(tmpConstraint.firstItem == self.view && tmpConstraint.secondItem == toolbar && tmpConstraint.firstAttribute == NSLayoutAttributeBottom && tmpConstraint.secondAttribute == NSLayoutAttributeBottom)
            return tmpConstraint;
    }
    return nil;
}

#pragma mark - sendMessage Utils
//发送内容显示在消息界面
- (void)showMessageToInterface:(EBMessage*)message clearInputField:(BOOL)clearInputField
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        //刷新最新一条信息时间戳
        [self refreshLastMessageTimestamp];
        
        //在聊天界面中显示本信息
        [safeSelf addMessages:@[message] append:YES noUpdateView:NO];
        [safeSelf scrollToBottom:NO];
        
        if (clearInputField) {
            //safeSelf.talkTextField.text = @""; //清空发送内容
            [safeSelf.talkTextView clearAll]; //清空发送内容
            safeSelf.sendButton.enabled = YES; //启用"发送"按钮
        }
        
        //使上层的talks表视图更新排序
        MainViewController* mainViewController = (MainViewController*)safeSelf.parentViewController.parentViewController;
        [mainViewController.talksController adjustTableViewWithTalkId:safeSelf.talkId];
    }];
}

- (void)sendMessageFailure:(NSError*)error resetSendButton:(BOOL)resetSendButton forMessage:(EBMessage*)message
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{ //主线程中执行
        NSLog(@"发送消息失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
        
        if (message) {
            //从正在发送缓存里删除
            [_sendingMessages removeObjectForKey:[NSString stringWithFormat:@"%p", message]];
            message.isSentFailure = YES;
            [safeSelf updateCellWithMessage:message reload:YES];
            
            //更新talks相关cell
            [safeSelf.talksController updateBadgeWithTalkId:message.talkId];
        }
        
        if (resetSendButton)
            safeSelf.sendButton.enabled = YES; //启用"发送"按钮
    }];
}

- (EBCallInfo*)detectAndLaunchCallWithWaitting:(BOOL*)waittingResult result:(BOOL*)result forMessage:(EBMessage*)message
{
    //初始化结果
    *waittingResult = NO;
    *result = NO;
    
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    EBCallInfo* callInfo = [ebKit callInfoWithAccount:self.otherAccount depCode:self.depCode]; //查询是否已经有关联的会话
    if(!callInfo) {
        if(self.depCode) { //群组会话
            [ebKit callGroupWithDepCode:self.depCode onFailure:^(NSError *error) {
                NSLog(@"呼叫群组失败, depCode = %llu, code = %li, msg = %@", self.depCode, (long)error.code, error.localizedDescription);
                [self sendMessageFailure:error resetSendButton:YES forMessage:message];
            }];
        } else { //一对一会话
            if (!self.otherAccount) { //预防有时otherAccount不正常存在
                [ebKit queryAccountWithUid:self.otherUid onCompletion:^(NSString *account) {
                    self.otherAccount = account;
                    [ebKit callUserWithAccount:self.otherAccount onFailure:^(NSError *error) {
                        NSLog(@"呼叫个人失败2, account = %@, code = %li, msg = %@", self.otherAccount, (long)error.code, error.localizedDescription);
                        [self sendMessageFailure:error resetSendButton:YES forMessage:message];
                    }];
                } onFailure:^(NSError *error) {
                    NSLog(@"查询账号失败, uid = %llu, code = %li, msg = %@", self.otherUid, (long)error.code, error.localizedDescription);
                    [self sendMessageFailure:error resetSendButton:YES forMessage:message];
                }];
            } else {
                [ebKit callUserWithAccount:self.otherAccount onFailure:^(NSError *error) {
                    NSLog(@"呼叫个人失败1, account = %@, code = %li, msg = %@", self.otherAccount, (long)error.code, error.localizedDescription);
                    [self sendMessageFailure:error resetSendButton:YES forMessage:message];
                }];
            }
        }
        *waittingResult = YES;
        
        return nil;
    } else { //会话已经存在
        //self.currentCallId = callInfo.callId;
        *result = YES;
        return callInfo;
    }
}

//等待未就绪的会话，就绪时执行发送消息任务
- (void)waittingSendWithExecuteBlock:(void(^)(uint64_t callId))executeBlock onFailure:(void(^)(void))failureBlock
{
    NSString* talkId = self.talkId;
    
    [BlockUtility performBlockInGlobalQueue:^{ //在非主线程中执行
        int maxTimes = 30; //最大重试次数
        __block int tryTimes = 0; //当前重试次数
        __block BOOL callReady = NO;
        EBTalk* talk;
        EBCallInfo* waitCallInfo;
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        
        do {
            [NSThread sleepForTimeInterval:0.5]; //等待0.5秒
            talk = [ebKit talkWithTalkId:talkId];
            NSLog(@"check for talkId = %@, talk = %@, tryTimes = %i", talkId, talk, tryTimes+1);
            
            //判断会话是否准备就绪
            if([talk isReady:&waitCallInfo])
                callReady = YES;
            
            tryTimes++;
        } while(!callReady && tryTimes < maxTimes);
        
        if(callReady && waitCallInfo) { //会话就绪后
            if (executeBlock) executeBlock(waitCallInfo.callId);
        } else {
            if (failureBlock) failureBlock();
        }
    }];
}

//显示提示(选择)框
- (UIAlertView*)showAlertViewWithTag:(NSInteger)tag title:(NSString*)title message:(NSString*)message
{
    return [[PublicUI sharedInstance] showAlertViewWithTag:tag title:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认"];
}

/**检测会话状态以决定发送消息动作
 * @param message 待发送消息对象
 * @param readyBlock 会话准备就绪回调函数
 * @param failureBlock 会话准备失败回调函数
 */
- (void)checkCallWithMessage:(EBMessage*)message onReadyBlock:(void(^)(uint64_t callId))readyBlock onFailure:(void(^)(void))failureBlock
{
    BOOL waittingResult = NO, result = NO;
    EBCallInfo* existCallInfo = [self detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:message]; //检测会话
    
    if(result && existCallInfo) {//会话就绪
        if (readyBlock)
            readyBlock(existCallInfo.callId);
//        [safeSelf executeSendMessage:message forCallId:existCallInfo.callId];
    } else if(waittingResult) { //等待呼叫结果
        [self waittingSendWithExecuteBlock:^(uint64_t callId){
            if (readyBlock)
                readyBlock(callId);
//            [safeSelf executeSendMessage:message forCallId:callId];
        } onFailure:^{
            if (failureBlock)
                failureBlock();
//            [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") messageType:@"富文本" resetSendButton:YES forMessage:message];
        }];
    }
}

//发送输入框的信息
- (void)executeSendMessage:(EBMessage*)message forCallId:(uint64_t)callId
{
    message.callId = callId;
    
    __weak typeof(self) safeSelf = self;
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [[ENTBoostKit sharedToolKit] sendMessage:message forCallId:callId onBegin:^(uint64_t msgId, uint64_t tagId) {
        [BlockUtility performBlockInMainQueue:^{
            message.msgId = msgId;
            message.tagId = tagId;
            //更新tableView的相关Cell
            [safeSelf updateCellWithMessage:message reload:YES];
        }];
        
        dispatch_semaphore_signal(sem);
    } onCompletion:^(uint64_t msgId, uint64_t tagId){
        [BlockUtility performBlockInMainQueue:^{
            message.msgId = msgId;
            message.tagId = tagId;
            
            //从正在发送缓存里删除
            [_sendingMessages removeObjectForKey:[NSString stringWithFormat:@"%p", message]];
            //更新tableView的相关Cell
            [safeSelf updateCellWithMessage:message reload:YES];
            //更新talks相关cell
            [safeSelf.talksController updateBadgeWithTalkId:message.talkId];
        }];
    } onFailure:^(NSError *error, uint64_t tagId) {
        [safeSelf sendMessageFailure:error resetSendButton:YES forMessage:message];
    }];
    
    long result = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
    if (result!=0) {
        //延迟刷新聊天记录界面(否则，当网络异常时，进度动态图不能正常显示)
        [self performSelector:@selector(delayUpdateMessageCell:) withObject:message afterDelay:1.0];
    }
}

//刷新聊天记录界面
- (void)delayUpdateMessageCell:(EBMessage*)message
{
    [BlockUtility performBlockInMainQueue:^{
        [self updateCellWithMessage:message reload:YES];
    }];
}

#pragma mark - sendTextField
// 点击发送按钮事件处理
- (IBAction)sendTextFieldTaped:(id)sender
{
    self.sendButton.enabled = NO; //禁用"发送"按钮
    
    EBMessage* message = [self messageFromInputTextFieldWithCallId:0];
    //内容不足以发送
    if (!message)
        return;
    
    _sendingMessages[[NSString stringWithFormat:@"%p", message]] = message;
    [self showMessageToInterface:message clearInputField:YES];
    
    __weak typeof(self) safeSelf = self;
    [self checkCallWithMessage:message onReadyBlock:^(uint64_t callId) {
        [safeSelf executeSendMessage:message forCallId:callId];
    } onFailure:^{
        [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") resetSendButton:YES forMessage:message];
    }];
    
//    BOOL waittingResult = NO, result = NO;
//    EBCallInfo* existCallInfo = [self detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:message]; //检测会话
//    
//    __weak typeof(self) safeSelf = self;
//    if(result && existCallInfo) {//会话就绪
//        [safeSelf executeSendMessage:message forCallId:existCallInfo.callId];
//    } else if(waittingResult) { //等待呼叫结果
//        [safeSelf waittingSendWithExecuteBlock:^(uint64_t callId){
//            [safeSelf executeSendMessage:message forCallId:callId];
//        } onFailure:^{
//            [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") messageType:@"富文本" resetSendButton:YES forMessage:message];
//        }];
//    }
}

//输入框当前内容产生信息实例
- (EBMessage*)messageFromInputTextFieldWithCallId:(uint64_t)callId
{
    //----------------------分析输入框中富文本内容-----------------------------------
    //获取包含CTRunDelegate属性的分段
    NSAttributedString* attrText = self.talkTextView.attributedText;
    NSLog(@"attrText.length = %lu", (unsigned long)attrText.length);
    
    //信息内容只有空白字符，提示不允许发送空白内容
    NSString* text = attrText.string;
    if(text.length == 0) {
        self.sendButton.enabled = YES; //启用"发送"按钮
        return nil;
    }
    
    //检测并转换非字符内容
    NSMutableArray* attachRanges = [NSMutableArray array];
    NSMutableDictionary* emotions = [NSMutableDictionary dictionary]; //表情图标
    NSMutableDictionary* pictures = [NSMutableDictionary dictionary]; //普通图片
    
    //获取包含CTRunDelegate属性的分段
    [attrText enumerateAttribute:(id)kCTRunDelegateAttributeName inRange:NSMakeRange(0, attrText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        CTRunDelegateRef runDelegate = (__bridge CTRunDelegateRef)value;
        SETextAttachment *attachment = (__bridge SETextAttachment *)CTRunDelegateGetRefCon(runDelegate);
        if(attachment) {
            //转换并暂存
            NSString* rangeStr = NSStringFromRange(range);
            [attachRanges addObject:rangeStr];
            NSDictionary* customData = attachment.customData;
            if (customData) {
                if ([customData objectForKey:STAMP_CUSTOM_DATA_EMOTION_NAME]) { //表情图片
                    EBEmotion* emotion = customData[STAMP_CUSTOM_DATA_EMOTION_NAME];
                    emotions[rangeStr] = emotion;
                    NSLog(@"data:%@, range:%@",emotion.resourceString , rangeStr);
                } else if ([customData objectForKey:COMMON_CUSTOM_DATA_MESSAGE_NAME]) { //普通图片
                    pictures[rangeStr] = (UIImage*)customData[COMMON_CUSTOM_DATA_MESSAGE_NAME];
                    NSLog(@"data:picture, range:%@" ,rangeStr);
                }
            }
        }
    }];
    
    //排序
    [attachRanges sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSRange range1 = NSRangeFromString(obj1);
        NSRange range2 = NSRangeFromString(obj2);
        
        NSUInteger maxRange1 = NSMaxRange(range1);
        NSUInteger maxRange2 = NSMaxRange(range2);
        
        if (maxRange1 > maxRange2)
            return NSOrderedDescending;
        if (maxRange1 < maxRange2)
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
    
    //----------------------分析结果转换为SDK的EBMessage格式------------------------
    //生成信息实例
    EBMessage* message = [[EBMessage alloc] initWithFromUid:[ENTBoostKit sharedToolKit].accountInfo.uid callId:callId];
    
    //一般字符内容与非字符内容合并
    NSUInteger currentIndex = 0;
    if (attachRanges.count) { //有非字符内容(例如表情图标)
        for (int i=0; i < attachRanges.count; i++) {
            NSString* rangeStr = [attachRanges objectAtIndex:i];
            NSRange range = NSRangeFromString(rangeStr);
            
            //前面还有文本内容未加入消息
            if (range.location > currentIndex) {
                NSString* tmpText = [text substringWithRange:NSMakeRange(currentIndex, range.location - currentIndex)];
                EBChatText* chatText = [[EBChatText alloc] initWithText:tmpText];
                [message addChatDot:chatText];
            }
            
            //===处理非字符类内容===
            //表情资源加入消息
            EBEmotion* emotion = emotions[rangeStr];
            if (emotion) {
//                EBChatResource* chatResource = [[EBChatResource alloc] initWithResource:emotion.resId];
                EBChatResource* chatResource = [[EBChatResource alloc] initWithResourceStr:emotion.resourceString];
                [message addChatDot:chatResource];
            }
            //普通图片加入消息
            UIImage* image = pictures[rangeStr];
            if (image) {
//                EBChatImage* chatImage = [[EBChatImage alloc] initWithImage:image];
                NSData *data = UIImageJPEGRepresentation(image, 1.0);
                EBChatImage* chatImage = [[EBChatImage alloc] initWithData:data];
                [message addChatDot:chatImage];
            }
            
            currentIndex = NSMaxRange(range);
        }
    }
    
    //遍历未完成,把剩余的字符内容加入到消息
    if (currentIndex < text.length) {
        EBChatText* chatText = [[EBChatText alloc] initWithText:[text substringWithRange:NSMakeRange(currentIndex, text.length - currentIndex)]];
        [message addChatDot:chatText];
    }
    
    message.customField = [SeedUtility uuid];
    message.isReaded = YES;
    message.isSent = NO;
    message.isSentFailure = NO;
    message.talkId = self.talkId;
    
    return message;
}

#pragma mark - sendPhoto
//显示图片选择界面
- (IBAction)showImagePicker:(id)sender
{
    //    [self.talkTextView resignFirstResponder];
    
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.mediaTypes = @[(NSString*)kUTTypeImage];
    controller.allowsEditing = NO;
    
    [self presentViewController:controller animated:YES completion:NULL];
}

//选择图片完成回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(!image)
        image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    //检查是否有超过最大分辨率限制，如超过就缩小至最大限制
    CGSize realSize;
    CGSize originSize = image.size;
    if ([UIImage decreaseUnderSize:EB_CHAT_MAX_PICTRUE_SIZE originSize:originSize realSize:&realSize]) {
        image = [image scaleToSize:realSize];
        NSLog(@"image origin size = %@ scale to real size = %@", NSStringFromCGSize(originSize), NSStringFromCGSize(realSize));
    }
    
    //图片对象转换为二进制数据对象
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    if (!data) {
        data = UIImagePNGRepresentation(image);
    } else {
        NSLog(@"image format is JPEG");
    }
    
    if(!data) {
        NSLog(@"选中的图片读取异常");
        return;
    }
    
    //判断图片是否超过最大限制
    if (data.length>1024*1024*5) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"图片错误" message:@"图片太大了，不能超过5MB" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [self sendImageData:data];
}

//发送富文本图片
- (void)sendImageData:(NSData*)data
{
    //生成信息实例
    EBMessage* message = [[EBMessage alloc] initWithFromUid:[ENTBoostKit sharedToolKit].accountInfo.uid callId:0];
    message.customField = [SeedUtility uuid];
    message.isReaded = YES;
    message.isSent = NO;
    message.isSentFailure = NO;
    EBChatImage* chatImage = [[EBChatImage alloc] initWithData:data];
    [message addChatDot:chatImage];
    
    _sendingMessages[[NSString stringWithFormat:@"%p", message]] = message;
    [self showMessageToInterface:message clearInputField:NO];

    __weak typeof(self) safeSelf = self;
    [self checkCallWithMessage:message onReadyBlock:^(uint64_t callId) {
//        [safeSelf executeSendImageMessage:message forCallId:callId];
        [safeSelf executeSendMessage:message forCallId:callId];
    } onFailure:^{
        [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") resetSendButton:NO forMessage:message];
    }];
    
//    //检测会话状态
//    BOOL waittingResult = NO, result = NO;
//    EBCallInfo* existCallInfo = [self detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:message];
//    
//    __weak typeof(self) safeSelf = self;
//    if(result && existCallInfo) { //会话就绪
//        [safeSelf executeSendImageMessage:message forCallId:existCallInfo.callId];
//    } else if(waittingResult) { //等待呼叫结果
//        [safeSelf waittingSendWithExecuteBlock:^(uint64_t callId){
//            [safeSelf executeSendImageMessage:message forCallId:callId];
//        } onFailure:^{
//            [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") messageType:@"图片" resetSendButton:NO forMessage:message];
//        }];
//    }
}

//- (void)executeSendImageMessage:(EBMessage*)message forCallId:(uint64_t)callId
//{
//    message.callId = callId;
//    
//    //调用SDK发送富文本消息
//    __weak typeof(self) safeSelf = self;
//    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//    [[ENTBoostKit sharedToolKit] sendMessage:message forCallId:callId onBegin:^(uint64_t msgId, uint64_t tagId) {
//        [BlockUtility performBlockInMainQueue:^{
//            message.msgId = msgId;
//            message.tagId = tagId;
//            //更新tableView的相关Cell
//            [safeSelf updateCellWithMessage:message reload:YES];
//        }];
//        dispatch_semaphore_signal(sem);
//    } onCompletion:^(uint64_t msgId, uint64_t tagId){
//        [BlockUtility performBlockInMainQueue:^{
//            message.msgId = msgId;
//            message.tagId = tagId;
//            
//            //从正在发送缓存里删除
//            [_sendingMessages removeObjectForKey:[NSString stringWithFormat:@"%p", message]];
//            //更新tableView的相关Cell
//            [safeSelf updateCellWithMessage:message reload:YES];
//            //更新talks相关cell
//            [safeSelf.talksController updateBadgeWithTalkId:message.talkId];
//        }];
//    } onFailure:^(NSError *error, uint64_t tagId) {
//        NSLog(@"发送信息失败, code = %li, msg = %@", (long)error.code, error.localizedDescription);
//        [safeSelf sendMessageFailure:error resetSendButton:NO forMessage:message];
//    }];
//    
//    long result = dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, 1.0f * NSEC_PER_SEC));
//    if (result!=0) {
//        //延迟刷新聊天记录界面(否则，当网络异常时，进度动态图不能正常显示)
//        [self performSelector:@selector(delayUpdateMessageCell:) withObject:message afterDelay:1.0];
//    }
//}


#pragma mark - AudioRecorder

- (IBAction)voiceButtonDown:(id)sender
{
    self.isCancelVoice = NO;
    
    AudioToolkit* audioToolkit = [AudioToolkit sharedInstance];
    [audioToolkit setRecorderDelegate:self];
    
//    EBChat_Audio_File_Format audioFileFormat = EBChat_Audio_File_Format_WAV;
//    NSURL* tmpFileUrl = [audioToolkit generateTempFilePathWithFileFormat:audioFileFormat]; //生成临时文件URL
    [audioToolkit prepareToRecordWithFormat:EBChat_Audio_File_Format_WAV maxTime:60*1]; //准备录音环境
    [_voiceRecordImageView setHidden:NO];
    [audioToolkit setImageView:_voiceRecordImageView];
    [audioToolkit startRecord];//开始录音
    
//    //5秒后停止录音
//    [self performSelector:@selector(stopAndPlayerAudio) withObject:nil afterDelay:5.0f];
    
}

- (IBAction)voiceButtonUp:(id)sender
{
    self.isCancelVoice = NO;
    //停止录音
    [[AudioToolkit sharedInstance] stopRecord];
    
    [_voiceRecordImageView setHidden:YES];
}

- (IBAction)voiceButtonDragUp:(id)sender
{
    self.isCancelVoice = YES;
    //停止录音
    [[AudioToolkit sharedInstance] stopRecord];
    
    [_voiceRecordImageView setHidden:YES];
}

////停止录音并播放
//- (void)stopAndPlayerAudio
//{
//    [[AudioToolkit sharedInstance] stopRecord];
//}

//录音结束事件
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (self.isCancelVoice) {
        //删除录制文件
        [recorder deleteRecording];
        NSLog(@"取消发送语音");
        return;
    }
    
    if (flag) {
        NSTimeInterval cTime = [[AudioToolkit sharedInstance] recordTime];
        if (cTime > 1) {
            NSLog(@"发送语音");
//            [[AudioToolkit sharedInstance] playFile:recorder.url];
            NSString* filePath = [recorder.url absoluteString];
            NSString* newFilePath = [NSString stringWithFormat:@"%@.1", filePath];
            int len1 = [MultimediaUtility translateIOSWav:filePath toStandardWav:newFilePath];
            int len = [MultimediaUtility timeLengthWithWaveFile:newFilePath];
            NSLog(@"len = %@, len1 = %@", @(len), @(len1));
            [self sendAudioData:[NSData dataWithContentsOfFile:newFilePath]];
        } else { //如果录制时间<1 不发送
            NSLog(@"录音时间过短(%.1f)，不发送", cTime);
            //删除录制文件
            [recorder deleteRecording];
        }
    } else {
        NSLog(@"录音失败，临时文件：%@", recorder.url);
        //删除录制文件
        [recorder deleteRecording];
    }
}

////播放录音停止
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
//{
//    
//}

- (void)sendAudioData:(NSData*)data
{
    //生成信息实例
    EBMessage* message = [[EBMessage alloc] initWithFromUid:[ENTBoostKit sharedToolKit].accountInfo.uid callId:0];
    message.customField = [SeedUtility uuid];
    message.isReaded = YES;
    message.isSent = NO;
    message.isSentFailure = NO;
    
    EBChatAudio* chatAudio = [[EBChatAudio alloc] initWithData:data audioType:EB_CHAT_ENTITY_AUDIO_WAV];
    [message addChatDot:chatAudio];
    
    _sendingMessages[[NSString stringWithFormat:@"%p", message]] = message;
    [self showMessageToInterface:message clearInputField:NO];
    
    __weak typeof(self) safeSelf = self;
    [self checkCallWithMessage:message onReadyBlock:^(uint64_t callId) {
        [safeSelf executeSendMessage:message forCallId:callId];
//        [safeSelf executeSendAudioMessage:message forCallId:callId];
    } onFailure:^{
        [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") resetSendButton:NO forMessage:message];
    }];
    
//    //检测会话状态
//    BOOL waittingResult = NO, result = NO;
//    EBCallInfo* existCallInfo = [self detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:message];
//    
//    __weak typeof(self) safeSelf = self;
//    if(result && existCallInfo) { //会话就绪
//        [safeSelf executeSendAudioMessage:message forCallId:existCallInfo.callId];
//    } else if(waittingResult) { //等待呼叫结果
//        [safeSelf waittingSendWithExecuteBlock:^(uint64_t callId){
//            [safeSelf executeSendAudioMessage:message forCallId:callId];
//        } onFailure:^{
//            [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") messageType:@"语音" resetSendButton:NO forMessage:message];
//        }];
//    }
}

//- (void)executeSendAudioMessage:(EBMessage*)message forCallId:(uint64_t)callId
//{
//    message.callId = callId;
//    
//    __weak typeof(self) safeSelf = self;
//    [[ENTBoostKit sharedToolKit] sendMessage:message forCallId:callId onBegin:^(uint64_t msgId, uint64_t tagId) {
//        [BlockUtility performBlockInMainQueue:^{
//            message.msgId = msgId;
//            message.tagId = tagId;
//            //更新tableView的相关Cell
//            [safeSelf updateCellWithMessage:message reload:YES];
//        }];
//    } onCompletion:^(uint64_t msgId, uint64_t tagId){
//        [BlockUtility performBlockInMainQueue:^{
//            message.msgId = msgId;
//            message.tagId = tagId;
//            
//            //从正在发送缓存里删除
//            [_sendingMessages removeObjectForKey:[NSString stringWithFormat:@"%p", message]];
//            //更新tableView的相关Cell
//            [safeSelf updateCellWithMessage:message reload:YES];
//            
//            //更新talks相关cell
//            [safeSelf.talksController updateBadgeWithTalkId:message.talkId];
//        }];
//    } onFailure:^(NSError *error, uint64_t tagId) {
//        NSLog(@"发送信息失败, code = %li, msg = %@", (long)error.code, error.localizedDescription);
//        [safeSelf sendMessageFailure:error resetSendButton:NO forMessage:message];
//    }];
//}

#pragma mark - sendFile

//定义尝试选择文件界面确认框的Tag
const NSInteger tagOfShowFloderAlertView = 201;

//尝试选择发送文件
- (IBAction)showFolderView:(id)sender
{
    Reachability* rby = [Reachability reachabilityForInternetConnection];
    if ([rby isReachableViaWWAN]) {
        [self showAlertViewWithTag:tagOfShowFloderAlertView title:@"真的要发送文件吗？" message:@"设备当前使用3G/4G网络，发送文件将会使用比较多的流量，请留意！"];
    } else
        [self executeShowFolderView];
}

//显示选择文件的界面
- (void)executeShowFolderView
{
    FilesBrowserController* vc = [_otherStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_FILES_CONTROLLER];
    vc.delegate = self;
    vc.isPresent = NO;
    vc.actionType = FilesBrowserActionTypeSingleSelect;
    
    //    UINavigationController* navigationController = [[PublicUI sharedInstance] navigationControllerWithRootViewController:vc];
    
    //    [self presentViewController:navigationController animated:YES completion:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

//点选文件事件
- (void)filesBrowserController:(FilesBrowserController *)filesBrowser didSelectedFiles:(NSArray *)selectedfiles
{
    NSLog(@"selectedfiles %@", selectedfiles);
    if (selectedfiles.count>0)
        [self sendFile:selectedfiles[0]];
}

//发送文件消息
- (void)sendFile:(NSString*)filePath
{
    //    _sendingMessages[[NSString stringWithFormat:@"%p", message]] = message;
    
    __weak typeof(self) safeSelf = self;
    [self checkCallWithMessage:nil onReadyBlock:^(uint64_t callId) {
        [safeSelf executeSendFile:filePath forCallId:callId offChat:NO];
    } onFailure:^{
        [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") resetSendButton:NO forMessage:nil];
    }];
    
    //    //检测会话状态
    //    BOOL waittingResult = NO, result = NO;
    //    EBCallInfo* existCallInfo = [self detectAndLaunchCallWithWaitting:&waittingResult result:&result forMessage:nil];
    //
    //    __weak typeof(self) safeSelf = self;
    //    if(result && existCallInfo) { //会话就绪
    //        [safeSelf executeSendFile:filePath forCallId:existCallInfo.callId offChat:NO];
    //    } else if(waittingResult) { //等待呼叫结果
    //        [safeSelf waittingSendWithExecuteBlock:^(uint64_t callId){
    //            [safeSelf executeSendFile:filePath forCallId:callId offChat:NO];
    //        } onFailure:^{
    //            [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") resetSendButton:NO forMessage:nil];
    //        }];
    //    }
}

- (void)executeSendFile:(NSString*)filePath forCallId:(uint64_t)callId offChat:(BOOL)offChat
{
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    __weak typeof(self) safeSelf = self;
    __block uint64_t localMsgId = 0;
    
    //刷新消息界面处理模块
    void(^updateCellBlock)(EBMessage* message, BOOL reload) = ^(EBMessage* message, BOOL reload){
        if (message) {
            [BlockUtility performBlockInMainQueue:^{
                [safeSelf updateCellWithMessage:message reload:reload];
            }];
        }
    };
    
    //执行发送API
    [ebKit sendFileAtPath:filePath usingFileName:[filePath lastPathComponent] forCallId:callId offChat:offChat useMd5:YES onRequest:^(uint64_t msgId) { //发起请求成功
        localMsgId = msgId;
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            //            message.isWaittingAck = YES;
            message.isWorking = NO;
            [safeSelf showMessageToInterface:message clearInputField:NO];
            
            [BlockUtility performBlockInMainQueue:^{
                //更新talks相关cell
                [safeSelf.talksController updateBadgeWithTalkId:message.talkId];
            }];
        }
    } onBegin:^(uint64_t msgId) { //开始传输
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            //            message.isWaittingAck = NO;
            message.isWorking = YES;
            updateCellBlock(message, YES);
        }
    } onProcessing:^(double_t percent, double_t speed, uint64_t callId, uint64_t msgId) { //传输百分比
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            //            message.isWaittingAck = NO;
            message.isWorking = YES;
            //            message.percentCompletion = percent;
            updateCellBlock(message, NO);
        }
    } onCompletion:^(uint64_t msgId) { //传输
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            //            message.isWaittingAck = NO;
            message.isWorking = NO;
            updateCellBlock(message, YES);
        }
    } onOffFileExists:^(uint64_t msgId) { //离线文件已存在
        localMsgId = msgId;
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            //            message.isWaittingAck = NO;
            message.isWorking = NO;
            [self showMessageToInterface:message clearInputField:NO];
        }
    } onCancel:^(uint64_t msgId, BOOL initiative) { //取消或拒绝
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            //            message.isWaittingAck = NO;
            message.isWorking = NO;
            updateCellBlock(message, YES);
        }
    } onFailure:^(NSError *error) { //失败
        NSLog(@"发送文件失败, code = %@, msg = %@", @(error.code), error.localizedDescription);
        EBMessage* message = [ebKit messageWithMessageId:localMsgId];
        if (message) {
            //            message.isWaittingAck = NO;
            message.isWorking = NO;
            updateCellBlock(message, YES);
        } else {
            NSLog(@"executeSendFile->no found message for msgId:%@", @(localMsgId));
        }
        
        [safeSelf sendMessageFailure:error resetSendButton:NO forMessage:message];
    }];
}


#pragma mark - AudioVideo

//定义进行音视频通话确认框的Tag
const NSInteger tagOfShowAudioVideoAlertView = 202;

//处理点击音视频通话按钮的事件
- (IBAction)showAudioVideoView:(id)sender
{
    Reachability* rby = [Reachability reachabilityForInternetConnection];
    if ([rby isReachableViaWWAN]) {
        [self showAlertViewWithTag:tagOfShowAudioVideoAlertView title:@"真的要进行实时语音通话吗？" message:@"设备当前使用3G/4G网络，实时语音通话将会使用比较多的流量，请留意！"];
    } else
        [self presentAudioVideoViewControllerCompletion:nil];
}

//显示音视频通话界面
- (void)presentAudioVideoViewControllerCompletion:(void(^)(void))completionBlock
{
    EBTalk* talk = [[ENTBoostKit sharedToolKit] talkWithTalkId:self.talkId];
    if (!talk) {
        NSLog(@"presentAudioVideoViewController error, talk is not found for talkId = %@", self.talkId);
        return;
    }
    
    UIViewController* vc = [self currentViewController];
    if (vc==_aqsController) {
        if (completionBlock)
            completionBlock();
        return;
    }
    
    if (!_aqsNavigationController) {
        //创建aqsController和navigationController
        _aqsController = [_talkStoryobard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_AQS_VIEW_CONTROLLER];
        _aqsController.delegate = self;
        _aqsNavigationController = [[PublicUI sharedInstance] navigationControllerWithRootViewController:_aqsController];
//        _aqsNavigationController = [[UINavigationController alloc] initWithRootViewController:_aqsController];
//        
//        //设置导航栏颜色
//        if (IOS7)
//            _aqsNavigationController.navigationBar.barTintColor = NAVIGATION_BAR_TINT_COLOR;
//        else
//            _aqsNavigationController.navigationBar.tintColor = NAVIGATION_BAR_TINT_COLOR;
//        
//        //    [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
//        //半透明
//        _aqsNavigationController.navigationBar.translucent = NO;
//        
//        //设置标题字体及颜色
//        NSDictionary* titleTextAttrs = @{UITextAttributeTextColor:[UIColor whiteColor], UITextAttributeFont:[UIFont boldSystemFontOfSize:18.0]};
//        [_aqsNavigationController.navigationBar setTitleTextAttributes:titleTextAttrs];
    }
    
    _aqsController.callId = talk.currentCallId;
    _aqsController.targetUid = self.otherUid;
    _aqsController.depCode = self.depCode;
//    _aqsController.workState = AV_WORK_STATE_IDLE;
    
    if (self.depCode)
        _aqsController.targetName = self.groupInfo.depName;
    if (self.otherUid)
        _aqsController.targetName = self.otherUserName;
    if (self.otherAccount)
        _aqsController.targetName2 = self.otherAccount;
    
    [self presentViewController:_aqsNavigationController animated:YES completion:completionBlock];
}

- (void)dismissAQSViewControllerIfIdle
{
    if (_aqsNavigationController && _aqsController && ![self isAVBusying]) {
        [_aqsController goBack];
    }
}

- (void)aqsViewController:(AQSViewController *)aqsViewController exitWithWorkState:(AV_WORK_STATE)workState
{
    _aqsController = nil;
    _aqsNavigationController = nil;
}

#pragma mark 处理音视频事件

- (void)handleAVRequest:(uint64_t)callId fromUid:(uint64_t)fromUid includeVideo:(BOOL)includeVideo
{
    NSLog(@"handleAVRequest callId=%llu, fromUid = %llu, includeVideo = %i", callId, fromUid, includeVideo);
    [self presentAudioVideoViewControllerCompletion:^{
           [_aqsController handleAVRequest:fromUid includeVideo:includeVideo];
    }];
}

- (void)handleAVAccept:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    NSLog(@"handleAVAccept callId=%llu, fromUid = %llu", callId, fromUid);
    [_aqsController handleAVAccept:fromUid];
}

- (void)handleAVReject:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    NSLog(@"handleAVReject callId=%llu, fromUid = %llu", callId, fromUid);
    [_aqsController handleAVReject:fromUid];
}

- (void)handleAVTimeout:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    NSLog(@"handleAVTimeout callId=%llu, fromUid = %llu", callId, fromUid);
    [_aqsController handleAVTimeout:fromUid];
}

- (void)handleAVClose:(uint64_t)callId fromUid:(uint64_t)fromUid
{
    NSLog(@"handleAVClose callId=%llu, fromUid = %llu", callId, fromUid);
    [_aqsController handleAVClose:fromUid];
}

- (void)handleAVRecevieFirstFrame:(uint64_t)callId
{
    NSLog(@"handleAVRecevieFirstFrame callId=%llu", callId);
    [_aqsController handleAVRecevieFirstFrame];
}

#pragma mark - Keyboard

////处理左右滑动手势
//- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
//{
//    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
//        NSLog(@"左边");
//    }
//    
//    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
//        NSLog(@"右边");
//    }
//}

//键盘显示事件
- (void)keyboardWasShown:(NSNotification *)notif
{
    NSLog(@"keyboardWasShown->talkViewController notification's name:%@", notif.name);
    NSDictionary *info = [notif userInfo];
    CGRect keyboardBounds;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    _curentKeyboardHeight = keyboardBounds.size.height;
    
    NSLog(@"_curentKeyboardHeight = %.2f", _curentKeyboardHeight);
    
//    NSNumber *duration = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSNumber *curve = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];

    //创建表情选择视图
    if (_curentKeyboardHeight!=0 && (!self.stampInputView /*|| self.stampInputView.bounds.size.height<_curentKeyboardHeight*/)) {
        self.stampInputView = [[StampInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, _curentKeyboardHeight)];
        self.stampInputView.delegate = self;
        self.stampInputView.textView = self.talkTextView;
        [self.stampInputView fillStamps];
        
//        //添加左右滑动手势事件
//        self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
//        self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
//        self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
//        self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//        [self.stampInputView addGestureRecognizer:self.leftSwipeGestureRecognizer];
//        [self.stampInputView addGestureRecognizer:self.rightSwipeGestureRecognizer];
        
        //显示图标表情
        if(_isWaittingStampView) {
            _isWaittingStampView = NO;
            [self showStampInputView:nil];
        }
    }
    
    //toolbar往上升
    NSLayoutConstraint* constraint = [self constraintForToolbarBottom];
    if(constraint)
        constraint.constant = _curentKeyboardHeight;
    else
        NSLog(@"error, not found the toolbar's constraint!!!");
    
    //表视图往上移动一个键盘的高度
    if (!_isKeyboardShow) {
        CGPoint offset = self.talkTableView.contentOffset;
        [self.talkTableView setContentOffset:CGPointMake(0, offset.y + _curentKeyboardHeight/*keyboardBounds.size.height*/) animated:NO];
    }
    if (_curentKeyboardHeight)
        _isKeyboardShow = YES;
}

//键盘即将隐藏事件
- (void)keyboardWillHidden:(NSNotification *)notif
{
    NSLog(@"keyboardWillHidden->talkViewController notification's name:%@", notif.name);
    
    NSDictionary *info = [notif userInfo];
    CGRect keyboardBounds;
    [[info valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    _curentKeyboardHeight = keyboardBounds.size.height;
    
    NSLog(@"_curentKeyboardHeight = %.2f", _curentKeyboardHeight);
    
    NSLayoutConstraint* constraint = [self constraintForToolbarBottom];
    //toolbar往下降
    if(constraint)
        constraint.constant = 0;//_curentKeyboardHeight;
    else
        NSLog(@"error, not found the toolbar's constraint!!!");
    
    //表视图往下移动一个键盘的高度
    if(_isKeyboardShow) {
        CGPoint offset = self.talkTableView.contentOffset;
        [self.talkTableView setContentOffset:CGPointMake(0, offset.y - _curentKeyboardHeight/*keyboardBounds.size.height*/) animated:NO];
    }
    if (_curentKeyboardHeight)
        _isKeyboardShow =NO;
}

- (void)keyboardDidHidden:(NSNotification *)notif
{
    NSLog(@"keyboardDidHidden->talkViewController notification's name:%@", notif.name);
}

#pragma mark - UIScrollViewDelegate
static NSString *LCellIdentifier = @"chatCellL";                //左边头像样式的Cell
static NSString *RCellIdentifier = @"chatCellR";                //右边头像样式的Cell
static NSString *SeparatorCellIdentifier = @"chatSeparatorCell";//对聊天记录进行分段的Cell

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if([self.talkTextView isFirstResponder])
        [self.talkTextView resignFirstResponder];
}

#pragma mark - UITableView

-(void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]]; //设置Cell背景透明
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.messages objectAtIndex:indexPath.row];
    
    UITableViewCell* returnCell;
    if (![obj isMemberOfClass:[EBMessage class]]) { //显示分段Cell
        ChatSeparatorCell* cell = [tableView dequeueReusableCellWithIdentifier:SeparatorCellIdentifier];
        returnCell = cell;
        cell.contentLabel.text = nil;
        
        if (indexPath.row > 0) { //非第一行记录
            id obj1 = [self.messages objectAtIndex:indexPath.row-1];
            if ([obj1 isMemberOfClass:[EBMessage class]]) {
                EBMessage* message = obj1;
                cell.contentLabel.text = [NSString stringWithFormat:@" %@ ", [message.msgTime stringByFlexibleFormat]];
            } else {
                cell.contentLabel.text = @"无1.....";
            }
        } else { //第一行记录
            if (self.messages.count>1) {
                id obj1 = [self.messages objectAtIndex:1];
                if ([obj1 isMemberOfClass:[EBMessage class]]) {
                    EBMessage* message = obj1;
                    cell.contentLabel.text = [NSString stringWithFormat:@" %@ ", [message.msgTime stringByFlexibleFormat]];
                } else {
                    cell.contentLabel.text = @"无2.....";
                }
            } else {
                cell.contentLabel.text = @"无3.....";
            }
        }
    } else { //显示消息内容
        EBMessage* message = obj;
        uint64_t myUid = [ENTBoostKit sharedToolKit].accountInfo.uid;
        BOOL fromSelf = message.fromUid==myUid?YES:NO;
        NSString* key = [CTFrameParser keyForMessage:message];
        
//        ChatCell* cell = [tableView dequeueReusableCellWithIdentifier:fromSelf?RCellIdentifier:LCellIdentifier];
        ChatCell* cell = self.chatCellMap[key];     //从缓存中获取cell
        [self.chatCellMap removeObjectForKey:key];  //删除缓存中cell
        if (!cell) {
//            //如果找不到缓存记录，尝试倒转顺序再查找一遍
//            if (message.msgId>0) {
//                cell = self.chatCellMap[[NSString stringWithFormat:@"%@", @(message.msgId)]];
//            } else if (message.tagId>0) {
//                cell = self.chatCellMap[[NSString stringWithFormat:@"%@", @(message.tagId)]];
//            } else if (message.customField.length>0) {
//                cell = self.chatCellMap[message.customField];
//            }
//            
//            //找不到缓存记录，重新生成
//            if (!cell) {
//                NSLog(@"miss cell in chatCellMap for key=%@", key);
            cell = [self cellWithMessage:message fromSelf:fromSelf isGroup:self.isGroup inTableView:tableView];
//            }
        }
        
        returnCell = cell;
        
//        cell.delegate = self;
//        cell.talkTableView = self.talkTableView;
//        //清空消息发送方名称
//        [cell updateMemberNameLabel:nil];
//        
//        //显示消息内容
//        [cell setContent:message fromSelf:fromSelf];
        
        //设置正在发送状态
        if (_sendingMessages[[NSString stringWithFormat:@"%p", message]])
            [cell setMessageState:CHAT_CELL_MESSAGE_STATE_LOADING];
        
        //设置头像图片圆角边框
        EBCHAT_UI_SET_CORNER_VIEW_CLEAR(cell.headImageView);
        
        //设置头像图片
        
        static UIImage* defaultOfflineHeadPhoto; //默认离线头像图标
        static UIImage* defaultOnlineHeadPhoto; //默认在线头像图标
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            defaultOnlineHeadPhoto = [UIImage imageNamed:[ResourceKit defaultImageNameOfUser]];
            defaultOfflineHeadPhoto = [defaultOnlineHeadPhoto convertToGrayscale];
        });
        
        //设置在线情况
        BOOL isOffline = YES;
        NSNumber* stateNum = _onlineStateOfMembers[@(message.fromUid)];
        if (stateNum && [stateNum intValue] != EB_LINE_STATE_OFFLINE && [stateNum intValue] != EB_LINE_STATE_UNKNOWN) {
            isOffline = NO;
        }
        
        //显示默认头像的代码模块
        void(^showDefaultHeadPhoto)(void) = ^ {
            [BlockUtility performBlockInMainQueue:^{
                if (fromSelf)
                    cell.headImageView.image = defaultOnlineHeadPhoto;
                else {
                    if (isOffline)
                        cell.headImageView.image = defaultOfflineHeadPhoto;
                    else
                        cell.headImageView.image = defaultOnlineHeadPhoto;
                }
            }];
        };
        
        //清除旧的手势事件
        if (cell.headPhotoTapRecognizer) {
            [cell.headImageView removeGestureRecognizer:cell.headPhotoTapRecognizer];
        }
        
        __weak typeof(self) safeSelf = self;
        
        //定义图片文件加载失败后的处理模块
        void(^loadedFailureBlock)(uint64_t uid) = ^(uint64_t uid) {
            [BlockUtility performBlockInMainQueue:^{
                safeSelf.headPhotoLoadedCache[@(uid)] = @NO;
                showDefaultHeadPhoto();
            }];
        };
        
        //定义图片文件加载完毕后的处理模块
        void(^loadedSuccessBlock)(uint64_t uid, NSString* filePath, BOOL isOffline) = ^(uint64_t uid, NSString* filePath, BOOL isOffline) {
            if (filePath) {
                [BlockUtility performBlockInMainQueue:^{
                    UIImage* image = isOffline?[[[UIImage alloc] initWithContentsOfFile:filePath] convertToGrayscale]:[[UIImage alloc] initWithContentsOfFile:filePath];
                    safeSelf.headPhotoLoadedCache[@(uid)] = image;
                    cell.headImageView.image = image;
                }];
            } else {
                loadedFailureBlock(uid);
            }
        };
        
        //智能显示头像的处理模块
        void(^showPhotoBlock)(id headPhoto) = ^(id headPhoto) {
            if ([headPhoto isMemberOfClass:[UIImage class]])
                cell.headImageView.image = headPhoto;
            else
                showDefaultHeadPhoto();
        };
        
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        if (fromSelf) { //自己
            __block id myHeadPhoto = self.headPhotoLoadedCache[@(myUid)];
            if (myHeadPhoto!=nil)
                showPhotoBlock(myHeadPhoto);
            else {
                if (self.depCode) {
                    EBMemberInfo* memberInfo = self.memberInfoDict[@(myUid)];
                    if (memberInfo) {
                        [ebKit loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
                            loadedSuccessBlock(myUid, filePath, NO);
                        } onFailure:^(NSError *error) {
                            loadedFailureBlock(myUid);
                        }];
                    }
                } else {
                    [ebKit loadMyDefaultHeadPhotoOnCompletion:^(NSString *filePath) {
                        loadedSuccessBlock(myUid, filePath, NO);
                    } onFailure:^(NSError *error) {
                        loadedFailureBlock(myUid);
                    }];
                }
            }
        } else if (!self.depCode) { //一对一会话
            //添加点击头像的手势事件
            cell.headPhotoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headPhotoTap:)];
            [cell.headImageView addGestureRecognizer:cell.headPhotoTapRecognizer];
            objc_setAssociatedObject(cell.headPhotoTapRecognizer , @"uid", @(message.fromUid), OBJC_ASSOCIATION_RETAIN); //关联数据
            
            uint64_t otherUid = self.otherUid;
            __block id headPhoto = self.headPhotoLoadedCache[@(otherUid)];
            if (headPhoto!=nil)
                showPhotoBlock(headPhoto);
            else {
                [ebKit loadHeadPhotoWithTalkId:self.talkId onCompletion:^(NSString *filePath) {
                    loadedSuccessBlock(otherUid, filePath, isOffline);
                } onFailure:^(NSError *error) {
                    loadedFailureBlock(otherUid);
                }];
            }
        } else { //群组会话
            //添加点击头像的手势事件
            cell.headPhotoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headPhotoTap:)];
            [cell.headImageView addGestureRecognizer:cell.headPhotoTapRecognizer];
            objc_setAssociatedObject(cell.headPhotoTapRecognizer , @"uid", @(message.fromUid), OBJC_ASSOCIATION_RETAIN); //关联数据
            
            //显示消息发送方名称
            [cell updateMemberNameLabel:message.fromName?[NSString stringWithFormat:@"%@:", message.fromName]:@" "];
            
            __block id headPhoto = self.headPhotoLoadedCache[@(message.fromUid)];
            if (headPhoto!=nil) {
                showPhotoBlock(headPhoto);
            } else {
                EBMemberInfo* memberInfo = self.memberInfoDict[@(message.fromUid)];
                if (memberInfo) {
                    [ebKit loadHeadPhotoWithMemberInfo:memberInfo onCompletion:^(NSString *filePath) {
                        loadedSuccessBlock(message.fromUid, filePath, isOffline);
                    } onFailure:^(NSError *error) {
//                        if (error.code!=EB_STATE_RES_NOT_EXIST)
//                            NSLog(@"loadHeadPhotoWithMemberInfo error, code = %@, msg = %@", @(error.code), error.localizedDescription);
                        loadedFailureBlock(message.fromUid);
                    }];
                }
            }
        }
    }
    
    return returnCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static ChatCell* leftCell;
//    static ChatCell* rightCell;
//    static dispatch_once_t pred = 0;
//    dispatch_once(&pred, ^{
//        leftCell = [tableView dequeueReusableCellWithIdentifier:LCellIdentifier];
//        rightCell = [tableView dequeueReusableCellWithIdentifier:RCellIdentifier];
//    });
    
    id obj = [self.messages objectAtIndex:indexPath.row];
    if ([obj isMemberOfClass:[EBMessage class]]) {
        EBMessage* message = (EBMessage*)obj;
        NSString* key = [CTFrameParser keyForMessage:message];
        
        ChatCell* cell = self.chatCellMap[key];
        if (!cell) {
            //判断信息是否由自己发出
            uint64_t myUid = [ENTBoostKit sharedToolKit].accountInfo.uid;
            BOOL fromSelf = (message.fromUid==myUid?YES:NO);
            
            cell = [self cellWithMessage:message fromSelf:fromSelf isGroup:self.isGroup inTableView:tableView];
            
//            //文件比较特殊，不实施缓存
//            if (!message.isFile)
//                self.chatCellMap[key] = cell;
            //缓存问题比较多，暂不使用
        }
        
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        return size.height;
    } else {
        return 24.0;
    }
}

//创建新的Cell
- (ChatCell*)cellWithMessage:(EBMessage*)message fromSelf:(BOOL)fromSelf isGroup:(BOOL)isGroup inTableView:(UITableView*)tableView
{
    ChatCell* cell = fromSelf?[tableView dequeueReusableCellWithIdentifier:RCellIdentifier]:[tableView dequeueReusableCellWithIdentifier:LCellIdentifier];
    
    cell.isGroup = isGroup;
    cell.delegate = self;
    cell.talkTableView = self.talkTableView;
    
    //显示消息内容
    [cell setContent:message fromSelf:fromSelf];
    
    return cell;
}

//处理点击头像图标事件
- (void)headPhotoTap:(UITapGestureRecognizer*)recognizer
{
    if (self.depCode) {
        uint64_t uid = [objc_getAssociatedObject(recognizer, @"uid") unsignedLongLongValue]; //取出关联数据
        EBMemberInfo* memberInfo = self.memberInfoDict[@(uid)];
        EBMemberInfo* myMemberInfo = self.memberInfoDict[@([ENTBoostKit sharedToolKit].accountInfo.uid)];
        if (memberInfo) {
            __weak typeof(self) safeSelf = self;
            [[ControllerManagement sharedInstance] fetchUserControllerWithUid:uid orAccount:memberInfo.empAccount checkVCard:NO onCompletion:^(UserInformationViewController *uvc) {
                uvc.targetMemberInfo = memberInfo;
                uvc.targetGroupInfo = safeSelf.groupInfo;
                uvc.delegate = safeSelf;
                uvc.dataObject = nil;
                uvc.myMemberInfo = myMemberInfo;
                
                [safeSelf.navigationController pushViewController:uvc animated:YES];
            } onFailure:nil];
        }
    } else {
        __weak typeof(self) safeSelf = self;
        [[ControllerManagement sharedInstance] fetchUserControllerWithUid:self.otherUid orAccount:self.otherAccount checkVCard:YES onCompletion:^(UserInformationViewController *uvc) {
            uvc.delegate = safeSelf;
            uvc.dataObject = nil;
            
            [safeSelf.navigationController pushViewController:uvc animated:YES];
        } onFailure:nil];
    }
}

#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}
*/

#pragma mark - SECoreTextView

- (BOOL)textView:(SETextView *)textView paste:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (pasteboard.string) {
        [textView insertText:pasteboard.string];
    }
    if (pasteboard.image) {
        UIImage* image = pasteboard.image;
        [self.talkTextView insertObject:image size:image.size customData:@{COMMON_CUSTOM_DATA_MESSAGE_NAME: image}];
    }
//    if (pasteboard.images.count>0) {
//        NSArray* images = pasteboard.images;
//        for (NSUInteger i=0; i<images.count; i++) {
//            UIImage* image = images[i];
//            [self.talkTextView insertObject:image size:image.size customData:@{COMMON_CUSTOM_DATA_MESSAGE_NAME: image}];
//        }
//    }
    
    return NO;
}

- (void)textView:(SETextView *)textView customPasteMessage:(id)sender
{
    UIPasteboard * pasteBoard = [UIPasteboard pasteboardWithName:ENTBOOST_PASTE_BOARD_NAME create:NO];
    id data = [pasteBoard valueForPasteboardType:ENTBOOST_PASTE_BOARD_TYPE_MESSAGE_KEY];
    
    if (data) {
        NSDictionary* msgKey = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        uint64_t messageId = [msgKey[@"messageId"] unsignedLongLongValue];
        uint64_t tagId = [msgKey[@"tagId"] unsignedLongLongValue];
        
        EBMessage* message;
        if (messageId) {
            message = [[ENTBoostKit sharedToolKit] messageWithMessageId:messageId];
        } else if (tagId) {
            message = [[ENTBoostKit sharedToolKit] messageWithTagId:tagId];
        }
        
        if (message) {
            [self pasteMessageToInputField:message];
        }
    }
}

//1.粘贴消息内容到输入框
//2.或直接发送文件
- (void)pasteMessageToInputField:(EBMessage*)message
{
    if (message.isFile) { //文件
        NSString* filePath = message.filePath;
        NSLog(@"filePath:%@", message.filePath);
        
        if (message.isSent && filePath.length>0) {
            if ([FileUtility isReadableFileAtPath:filePath]) {
                [self sendFile:filePath];
            }
        }
    } else { //富文本信息
        //获取信息内容
        NSArray* chats = message.chats;
        
        for (int idx = 0; idx<chats.count; idx++) {
            EBChat* chatDot = chats[idx];
            switch (chatDot.type) {
                case EB_CHAT_ENTITY_TEXT:
                {
                    NSString* text = ((EBChatText*)chatDot).text;
                    [self.talkTextView insertText:text];
                }
                    break;
                case EB_CHAT_ENTITY_RESOURCE:
                {
                    EBChatResource* resDot = (EBChatResource*)chatDot;
                    EBEmotion* emotion = resDot.expression;
                    
                    //获取表情图片文件并插入输入框
                    UIImage *image;
                    if (emotion.dynamicFilepath)
                        image = [UIImage imageWithContentsOfFile:emotion.dynamicFilepath];
                    else
                        image = [UIImage imageNamed:@"loading_emotion"];
                    image = [image scaleToSize:CGSizeMake(20, 20)];
                    [self.talkTextView insertObject:image size:image.size customData:@{STAMP_CUSTOM_DATA_EMOTION_NAME: emotion}];
                }
                    break;
                case EB_CHAT_ENTITY_IMAGE:
                {
                    EBChatImage* imageDot = (EBChatImage*)chatDot;
                    UIImage* image = imageDot.image;
                    
                    [self.talkTextView insertObject:image size:image.size customData:@{COMMON_CUSTOM_DATA_MESSAGE_NAME: image}];
                }
                    break;
                case EB_CHAT_ENTITY_AUDIO:
                {
//                    EBChatAudio* chatAudio = (EBChatAudio*)chatDot;
                    [self.talkTextView insertText:@"[语音]"];
                }
                    break;
            }
        }
    }
}

//- (void)textViewDidBeginEditing:(SETextView *)textView
//{
//    self.doneButton.enabled = YES;
//}
//
//- (void)textViewDidEndEditing:(SETextView *)textView
//{
//    self.doneButton.enabled = NO;
//}

//- (void)textViewDidChangeSelection:(SETextView *)textView
//{
//    NSRange selectedRange = textView.selectedRange;
//    if (selectedRange.location != NSNotFound && selectedRange.length > 0) {
//        self.inputAccessoryView.boldButton.enabled = YES;
//        self.inputAccessoryView.nomalButton.enabled = YES;
//    } else {
//        self.inputAccessoryView.boldButton.enabled = NO;
//        self.inputAccessoryView.nomalButton.enabled = NO;
//    }
//}

//拦截换行符
- (BOOL)textView:(SETextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
        
        //发送信息
        [self sendTextFieldTaped:nil];
        
        return NO;
    }
    return YES;
}

//处理显示图标表情按钮事件
- (IBAction)showStampInputView:(id)sender
{
    if (!self.stampInputView)
        _isWaittingStampView = YES;
    
    //设置输入框焦点
    [self.talkTextView beginEditing];
    
    if (!_isWaittingStampView) {
        UIButton* button = (UIButton*)[self.view viewWithTag:131];
        
        if (!self.talkTextView.inputView) { //未显示表情图标视图
            self.talkTextView.inputView = self.stampInputView;
            [button setImage:_keyboardImage forState:UIControlStateNormal];
            
    //        [UIView beginAnimations:@"show stamp view" context:nil];
    //        [UIView setAnimationDuration:0.3];
    //        [UIView setAnimationDelegate:self];
    //        [UIView  setAnimationCurve: UIViewAnimationCurveEaseInOut];
            
            CGRect frame = self.stampInputView.frame;
            frame.origin.y = frame.size.height;
            self.stampInputView.frame = frame;
            [self.talkTextView reloadInputViews];
            
    //        //提交UIView动画
    //        [UIView commitAnimations];
            
        } else { //当前已显示表情图标视图
            self.talkTextView.inputView = nil;
            [button setImage:_emotionImage forState:UIControlStateNormal];
            
            [self.talkTextView reloadInputViews];
        }
    }
    //        self.inputAccessoryView.keyboardButton.enabled = YES;
    //        self.inputAccessoryView.stampButton.enabled = NO;
    //    NSLog(@"stampInputView %@", NSStringFromRect(self.stampInputView.bounds));
}

- (void)textViewDidChange:(SETextView *)textView
{
    [self updateLayout];
}

- (void)updateLayout
{
    //计算内容变更后的显示大小
    CGSize containerSize = self.talkScrollView.frame.size;
    CGSize contentSize = [self.talkTextView sizeThatFits:containerSize];
    CGRect frame = self.talkTextView.frame;
    frame.size.height = MAX(contentSize.height, containerSize.height);
    
    //更新滚动视图的内容显示大小
    self.talkScrollView.contentSize = frame.size;
    
    //通过更新约束的方式设置textView高度
    //self.talkTextView.frame = frame;
    NSArray* arry = [self.talkTextView constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
    for (NSLayoutConstraint* constraint in arry) {
        if(constraint.firstItem == self.talkTextView && constraint.secondItem == nil && constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = frame.size.height;
            break;
        }
    }
    
//    NSLog(@"tv:%@, sv:%@, cv:%@", NSStringFromSize(self.talkTextView.frame.size),  NSStringFromSize(self.talkScrollView.frame.size), NSStringFromSize(self.talkScrollView.contentSize));
    //滚动至输入光标处
    [self.talkScrollView scrollRectToVisible:self.talkTextView.caretRect animated:YES];
}

#pragma mark - StampInputView
//表情图标点击事件
- (void)stampInputView:(StampInputView *)stampInputView stampTaped:(StampButton *)button
{
    //获取表情图片文件并插入输入框
    UIImage *image;
    EBEmotion* emotion = button.data[STAMP_CUSTOM_DATA_EMOTION_NAME];
    if (emotion.dynamicFilepath)
        image = [UIImage imageWithContentsOfFile:emotion.dynamicFilepath];
    else
        image = [UIImage imageNamed:@"loading_emotion"];
    image = [image scaleToSize:CGSizeMake(20, 20)];
    [self.talkTextView insertObject:image size:image.size customData:button.data];
}

//退格键被点击事件
- (void)stampInputView:(StampInputView *)stampInputView deleteBackwordTaped:(UIButton *)button
{
    [self.talkTextView deleteBackward];
}

//自定义按钮被点击事件(这里指"发送"按钮)
- (void)stampInputView:(StampInputView *)stampInputView customButton1Taped:(UIButton *)button
{
    [self sendTextFieldTaped:button];
}

#pragma mark - ChatCellDelegate

- (void)chatCell:(ChatCell *)cell linkClick:(NSString *)url
{
    NSLog(@"click url:%@", url);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[url URLEncodedString]]];
}

- (void)chatCell:(ChatCell*)cell imageClick:(UIImage *)image
{
    ImageViewController* ivc =[_imageViewStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_IMAGE_VIEW_CONTROLLER];
    ivc.image = image;
    [self presentViewController:ivc animated:YES completion:nil];
}

- (void)chatCell:(ChatCell*)cell resendFileOffChat:(uint64_t)msgId forCallId:(uint64_t)callId
{
    __weak typeof(self) safeSelf = self;
    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
    //执行取消发送文件
    [ebKit cancelSendingFileWithMsgId:msgId forCallId:callId onCompletion:^{
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        if (message) {
            
            //再次发送文件
            [safeSelf executeSendFile:message.filePath forCallId:callId offChat:YES];
            
            //删除旧消息记录
            [ebKit deleteMessageWithMessageId:msgId];
            [BlockUtility performBlockInMainQueue:^{
                int idx = -1;
                for (int i=0; i <safeSelf.messages.count; i++) {
                    id obj = safeSelf.messages[i];
                    if ([obj isMemberOfClass:[EBMessage class]]) {
                        EBMessage* innerMessage = obj;
                        if (innerMessage.msgId == msgId) {
                            idx = i;
                            break;
                        }
                    }
                }
                
                if (idx>=0) {
                    [safeSelf.messages removeObjectAtIndex:idx];
                    [safeSelf.talkTableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        }
    } onFailure:^(NSError *error) {
        NSLog(@"取消发送文件失败， msgId = %llu, code = %@, msg = %@", msgId, @(error.code), error.localizedDescription);
    }];
}

- (void)chatCell:(ChatCell *)cell ackReceiveFile:(uint64_t)msgId accept:(BOOL)accept
{
    NSDictionary* blockDict = self.receiveFileBlockCache[@(msgId)];
    EB_RECEIVE_FILE_ACK_BLOCK ackBlock = blockDict[RECEIVE_FILE_ACK_BLOCK_NAME];
    if (ackBlock) {
        if (accept) {
            EBMessage* message = [[ENTBoostKit sharedToolKit] messageWithMessageId:msgId];
            if (message) {
                //生成合适的文件名，用于保存接收的文件
                uint64_t uid = [ENTBoostKit sharedToolKit].accountInfo.uid;
                NSString* filePath;
                NSString* ckFilePath;
                NSString* fileName = message.fileName;
                NSString* fileFirstName = [message.fileName stringByDeletingPathExtension];
                NSString* fileExtension = [message.fileName pathExtension];
                int count = 0;
                
                do {
                    filePath = [FileUtility relativeFilePathWithFileName:fileName floderName:[NSString stringWithFormat:@"%llu", uid]];
                    ckFilePath = [NSString stringWithFormat:@"%@/%@", [FileUtility homeDirectory], filePath];
                    if (![FileUtility fileExistAtPath:ckFilePath]) {
                        NSLog(@"file will save to path:%@", filePath);
                        ackBlock(accept, filePath); //响应接收文件
                        [self updateCellWithFileName:fileName forMessage:message]; //更新界面文件名
                        
                        return;
                    }
                    
                    count++;
                    fileName = [NSString stringWithFormat:@"%@(%i).%@", fileFirstName, count, fileExtension];
                } while (count<10000);
                
                //无法正常生成文件路径，拒绝接受文件
                ackBlock(NO, nil);
            }
        } else
            ackBlock(accept, nil); //拒绝接受文件
    } else { //非正常文件消息
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        [ebKit cancelWaittingAckWithMessageId:msgId]; //取消等待接收文件状态
        EBMessage* message = [ebKit messageWithMessageId:msgId];
        [self updateCellWithMessage:message reload:YES];
    }
}

- (void)chatCell:(ChatCell*)cell cancelReceivingFile:(uint64_t)msgId
{
    NSDictionary* blockDict = self.receiveFileBlockCache[@(msgId)];
    EB_RECEIVE_FILE_CANCEL_BLOCK cancelBlock = blockDict[RECEIVE_FILE_CANCEL_BLOCK_NAME];
    if (cancelBlock)
        cancelBlock();
}

- (void)chatCell:(ChatCell *)cell fileClick:(uint64_t)msgId
{
    EBMessage* message = [[ENTBoostKit sharedToolKit] messageWithMessageId:msgId];
    if (message.isFile && message.fileName && message.filePath) {
        [FilesBrowserController openFileWithPath:message.filePath onParentViewController:self];
    }
}

//定义删除本地聊天记录确认框的Tag
const NSInteger tagOfDeleteOneMessage = 203;

- (void)chatCell:(ChatCell *)cell deletedMessage:(uint64_t)msgId tagId:(uint64_t)tagId
{
    //关联数据
    UIAlertView* alertView = [self showAlertViewWithTag:tagOfDeleteOneMessage title:@"删除聊天记录" message:@"真得要删除这一条聊天记录吗?"];
    objc_setAssociatedObject(alertView, @"msgId", @(msgId), OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(alertView, @"tagId", @(tagId), OBJC_ASSOCIATION_COPY);
//    NSLog(@"want to delete indexPath:%@, alertView:%@", cell.currentIndexPath, alertView);
}

- (void)chatCell:(ChatCell *)cell resendMessageWithTagId:(uint64_t)tagId
{
    EBMessage* message = [[ENTBoostKit sharedToolKit] messageWithTagId:tagId];
    
    if (message) {
        _sendingMessages[[NSString stringWithFormat:@"%p", message]] = message;
    //    [self showMessageToInterface:message clearInputField:NO];
        
        __weak typeof(self) safeSelf = self;
        [self checkCallWithMessage:message onReadyBlock:^(uint64_t callId) {
            [safeSelf executeSendMessage:message forCallId:callId];
        } onFailure:^{
            [safeSelf sendMessageFailure:EBERR(EB_STATE_ERROR, @"等待超时，建立会话失败") resetSendButton:NO forMessage:message];
        }];
    }
}

- (BOOL)chatCell:(ChatCell *)cell isSendingMessage:(EBMessage *)message
{
    return _sendingMessages[[NSString stringWithFormat:@"%p", message]]?YES:NO;
}

@end

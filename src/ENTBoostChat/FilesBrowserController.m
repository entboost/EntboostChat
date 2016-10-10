//
//  FilesViewBrowserController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/2/10.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "FilesBrowserController.h"
#import "DocumentViewController.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"
#import "FileUtility.h"
#import "ButtonKit.h"
#import "ENTBoost.h"
#import "PublicUI.h"

#define FB_FILE_NAME @"fileName"
#define FB_FILE_PATH @"filePath"
#define FB_FILE_SIZE @"fileSize"

@interface FilesBrowserController ()
{
    NSString* _absolutePath;
    NSFileManager* _fileManager;
    NSMutableArray* _files;
}

@end

@implementation FilesBrowserController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _fileManager = [NSFileManager defaultManager];
        _files = [[NSMutableArray alloc] init];
        self.actionType = FilesBrowserActionTypeBrowseOnly;
        
        if (!self.rootFolderRelativePath) { //默认路径
            _absolutePath = [NSString stringWithFormat:@"%@/files/%llu", [FileUtility ebChatDocumentDirectory], [ENTBoostKit sharedToolKit].accountInfo.uid];
        } else { //指定路径
            _absolutePath = [NSString stringWithFormat:@"%@/%@", [FileUtility ebChatDocumentDirectory], self.rootFolderRelativePath];
        }
        
        if(![_fileManager fileExistsAtPath:_absolutePath]) {
            NSLog(@"尝试创建目录:%@", _absolutePath);
            NSError* pError;
            [_fileManager createDirectoryAtPath:_absolutePath withIntermediateDirectories:YES attributes:nil error:&pError];
            if(pError)
                NSLog(@"创建目录失败, code = %@, msg = %@", @(pError.code), pError.localizedDescription);
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //定义返回按钮
    self.navigationItem.leftBarButtonItem   = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem  = [ButtonKit refreshBarButtonWithTarget:self action:@selector(refresh)];
    
//    //右边按钮1
//    CGRect btnFrame = CGRectMake(0, 0, 30, 24);
//    UIButton* rbtn1 = [[UIButton alloc] initWithFrame:btnFrame];
//    [rbtn1 addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
//    [rbtn1 setImage:[UIImage imageNamed:@"navigation_refresh"] forState:UIControlStateNormal];
//    UIBarButtonItem * rightButton1 = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:nil action:nil];
//    rightButton1.customView = rbtn1;
//    self.navigationItem.rightBarButtonItems = @[rightButton1];
    
    //加载文件清单
    [self loadFileList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//返回上一层
- (void)goBack
{
    if (self.isPresent)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

//加载文件清单
- (void)loadFileList
{
    //查询获取目录下文件清单
    BOOL isDir;
    if ([_fileManager fileExistsAtPath:_absolutePath isDirectory:&isDir] && isDir) {
        NSError* error;
        NSArray* fileNames = [_fileManager contentsOfDirectoryAtPath:_absolutePath error:&error];
        if (!error) {
            for (NSString* fileName in fileNames) {
                NSString* filePath =  [NSString stringWithFormat:@"%@/%@", _absolutePath, fileName];
                if ([_fileManager fileExistsAtPath:filePath isDirectory:&isDir] && !isDir) {
                    unsigned long long fileSize = [[_fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
                    [_files addObject:@{FB_FILE_NAME:fileName, FB_FILE_PATH:filePath, FB_FILE_SIZE:@(fileSize)}];
                }
            }
        }
    }
}

//刷新界面
- (void)refresh
{
    [_files removeAllObjects];
    [self loadFileList];
    [self.tableView reloadData];
}

+ (void)openFileWithPath:(NSString*)filePath onParentViewController:(UIViewController*)parentViewController
{
    //支持打开的文件类型
    static NSArray* AllowedFileTypes;
    static UIStoryboard* OtherStoryboard;
    static dispatch_once_t pre;
    dispatch_once(&pre, ^{
        AllowedFileTypes = @[@"txt", @"rtf", @"pdf", @"doc", @"docx", @"xls", @"xlsx", @"ppt", @"html", @"htm", @"png", @"gif", @"jpg", @"jpeg"];
        OtherStoryboard = [UIStoryboard storyboardWithName:EBCHAT_STORYBOARD_NAME_OTHER bundle:nil];
    });
    
    NSString* pathExtension = [[filePath pathExtension] lowercaseString]; //获取扩展名并转换为小写字母
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@", pathExtension];
    NSArray *results = [AllowedFileTypes filteredArrayUsingPredicate:predicate];
    
    //打开文件
    if (results.count>0 && [FileUtility isReadableFileAtPath:filePath]) {
        DocumentViewController* docVC = [OtherStoryboard instantiateViewControllerWithIdentifier:EBCHAT_STORYBOARD_ID_DOCUMENT_CONTROLLER];
        
        docVC.filePath = filePath;
        docVC.pathExtension = pathExtension;
        UINavigationController* navigationController = [[PublicUI sharedInstance] navigationControllerWithRootViewController:docVC];
//        UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:docVC];
//        
//        //设置导航栏颜色
//        if (IOS7)
//            navigationController.navigationBar.barTintColor = NAVIGATION_BAR_TINT_COLOR;
//        else
//            navigationController.navigationBar.tintColor = NAVIGATION_BAR_TINT_COLOR;
//        
//        //    [navigationController.navigationBar setBarStyle:UIBarStyleDefault];
//        //半透明
//        navigationController.navigationBar.translucent = NO;
//        
//        //设置标题字体及颜色
//        NSDictionary* titleTextAttrs = @{UITextAttributeTextColor:[UIColor whiteColor], UITextAttributeFont:[UIFont boldSystemFontOfSize:18.0]};
//        [navigationController.navigationBar setTitleTextAttributes:titleTextAttrs];
        
        [parentViewController presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* FileCell1 = @"FileCell_1";
    
    NSDictionary* value = _files[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCell1 forIndexPath:indexPath];
    cell.textLabel.text = value[FB_FILE_NAME];
//    [cell.textLabel setTextColor:[UIColor colorWithHexString:@"#194E62"]];
    [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14.f]];
    
    uint64_t fileSize = [value[FB_FILE_SIZE] unsignedLongLongValue];
    double formatSize = (double)fileSize/1024;
    if (formatSize/1024 >= 1) {
        formatSize = (double)fileSize/(1024*1024);
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fM", formatSize];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fk", formatSize];
    }
//    [cell.detailTextLabel setTextColor:[UIColor colorWithHexString:@"#60B1CE"]];
    [cell.detailTextLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#define HEIGHT_FOR_HEADER_FOOTER 20.0f

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return HEIGHT_FOR_HEADER_FOOTER;
//}
//
//- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
//    [view setBackgroundColor:[UIColor clearColor]];
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return HEIGHT_FOR_HEADER_FOOTER;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEIGHT_FOR_HEADER_FOOTER)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO]; //取消选中
    
    NSDictionary* file = _files[indexPath.row];
    if (self.actionType == FilesBrowserActionTypeSingleSelect) {
        //触发回调事件
        if ([self.delegate respondsToSelector:@selector(filesBrowserController:didSelectedFiles:)])
            [self.delegate filesBrowserController:self didSelectedFiles:@[file[FB_FILE_PATH]]];
        
        //退出当前界面
        [self goBack];
    } else if (self.actionType == FilesBrowserActionTypeOpen) {
        //打开文件
        [FilesBrowserController openFileWithPath:file[FB_FILE_PATH] onParentViewController:self];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary* file = _files[indexPath.row];
        NSString* filePath = file[FB_FILE_PATH];
        
        //删除文件
        [FileUtility deleteFileAtPath:filePath];
        //更新视图数据及视图
        [_files removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end

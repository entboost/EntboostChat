//
//  FilesBrowserViewController.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/2/10.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

///文件浏览器界面操作类型
typedef enum FilesBrowserActionType : NSUInteger {
    FilesBrowserActionTypeBrowseOnly    = 1    //浏览
    ,FilesBrowserActionTypeSingleSelect        //单选
    ,FilesBrowserActionTypeMultiSelect         //多选
    ,FilesBrowserActionTypeEdit                //编辑
    ,FilesBrowserActionTypeOpen                //打开
} FilesBrowserActionType;

@interface FilesBrowserController : UITableViewController

@property(nonatomic, weak) id delegate; //回调代理

@property(nonatomic, strong) NSString* rootFolderRelativePath; //根目录相对路径
@property(nonatomic) FilesBrowserActionType actionType; //界面操作类型
@property(nonatomic) BOOL isPresent; //是否以present方式进入本界面

/**打开常见文件
 * @param filePath 文件绝对路径
 * @param parentViewController 上级viewController
 */
+ (void)openFileWithPath:(NSString*)filePath onParentViewController:(UIViewController*)parentViewController;

@end


///文件浏览器代理定义类
@protocol FilesBrowserDelegate
@optional

/**选中文件
 * @param filesBrowser 文件浏览器
 * @param selectedfiles 选中的文件列表
 */
- (void)filesBrowserController:(FilesBrowserController*)filesBrowser didSelectedFiles:(NSArray*)selectedfiles;

@end
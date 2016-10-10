//
//  CaptionEditViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/10/23.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "CaptionEditViewController.h"
#import "ButtonKit.h"
#import "ENTBoost+Utility.h"
#import "ENTBoostChat.h"

@interface CaptionEditViewController () <UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, strong) IBOutlet UITextField*  nameTextField;
@property(nonatomic, strong) IBOutlet UITextView*   descriptionTextView;

@end

@implementation CaptionEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.navigationItem.title = @"编辑名称和备注";
    
    //导航栏左边返回按钮
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    //导航栏右边保存按钮1
    self.navigationItem.rightBarButtonItem = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(save)];
    
    //最左边插入一个空白视图，产生文字缩进效果
    self.nameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 1)];
    self.nameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    self.descriptionTextView.scrollEnabled = YES; //是否可以拖动
    self.descriptionTextView.keyboardType = UIKeyboardTypeDefault; //键盘类型
    self.descriptionTextView.returnKeyType = UIReturnKeyDefault; //返回键的类型
    
    //设置边框
    EBCHAT_UI_SET_DEFAULT_BORDER(self.nameTextField);
    EBCHAT_UI_SET_DEFAULT_BORDER(self.descriptionTextView);
    //边框
//    self.nameTextField.layer.borderColor = [[UIColor colorWithHexString:@"#60B1CE"] CGColor];
//    self.nameTextField.layer.borderWidth = 0.5;
//    self.nameTextField.layer.backgroundColor = [[UIColor clearColor] CGColor];
//    self.nameTextField.layer.cornerRadius = 2.0f;
//    [self.nameTextField.layer setMasksToBounds:YES];
//    
//    self.descriptionTextView.layer.borderColor = [[UIColor colorWithHexString:@"#60B1CE"] CGColor];
//    self.descriptionTextView.layer.borderWidth = 0.5;
//    self.descriptionTextView.layer.backgroundColor = [[UIColor clearColor] CGColor];
//    self.descriptionTextView.layer.cornerRadius = 2.0f;
//    [self.descriptionTextView.layer setMasksToBounds:YES];
    
    //设置默认内容
    self.nameTextField.text = self.customName;
    self.nameTextField.delegate = self;
    self.descriptionTextView.text = self.customDescription;
    self.descriptionTextView.delegate = self;
    
    //设置输入框焦点
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//处理点击背景事件
- (IBAction)backgroundTap:(id)sender
{
    [self.nameTextField resignFirstResponder];
    [self.descriptionTextView resignFirstResponder];
}

//返回上一页
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//执行保存
- (void)save
{
    if ([self.delegate respondsToSelector:@selector(captionEditViewController:wantToSaveInputName:inputDescription:)]) {
        [self.delegate captionEditViewController:self wantToSaveInputName:self.nameTextField.text inputDescription:self.descriptionTextView.text];
    }
    
    [self goBack];
}

@end

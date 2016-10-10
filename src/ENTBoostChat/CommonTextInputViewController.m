//
//  TextInputViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/7/18.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "CommonTextInputViewController.h"
#import "ButtonKit.h"
#import "ENTBoostChat.h"
#import "ENTBoost+Utility.h"

@interface CommonTextInputViewController () <UITextViewDelegate>

@property(nonatomic, strong) IBOutlet UITextView* textView; //文本输入框

@end

@implementation CommonTextInputViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.keyboardType   = UIKeyboardTypeDefault;
        self.returnKeyType  = UIReturnKeyDefault;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.navigationItem.title = self.navigationTitle?self.navigationTitle:@"无标题";
    
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = [ButtonKit saveBarButtonItemWithTarget:self action:@selector(save)];
    
    //设置边框
    EBCHAT_UI_SET_DEFAULT_BORDER(self.textView);
    
    //设置风格
    self.textView.scrollEnabled = YES; //是否可以拖动
    self.textView.keyboardType = self.keyboardType; //键盘类型
    self.textView.returnKeyType = self.returnKeyType; //返回键的类型
    
    //设置默认内容
    self.textView.text = self.defaultText;
    self.textView.delegate = self;
    
    //设置输入框高度
    if (self.textInputViewHeight>0) {
        NSArray* constrains = [self.textView constraints]; //constraintsAffectingLayoutForAxis:UILayoutConstraintAxisVertical];
        for (NSLayoutConstraint* constraint in constrains) {
            if (constraint.firstItem==self.textView && constraint.firstAttribute==NSLayoutAttributeHeight) {
                constraint.constant = self.textInputViewHeight;
                break;
            }
        }
    }
    
    //设置输入框为焦点
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save
{
    if ([self.delegate respondsToSelector:@selector(commonTextInputViewController:wantToSaveInputText:)]) {
        [self.delegate commonTextInputViewController:self wantToSaveInputText:self.textView.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"] && self.returnKeyType!=UIReturnKeyDefault) { //判断输入的字是否是回车，即按下return
        [textView resignFirstResponder];
        [self save];
        
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

@end

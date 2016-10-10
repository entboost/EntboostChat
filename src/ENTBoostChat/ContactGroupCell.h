//
//  ContactGroupCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/1/30.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface ContactGroupCell : CustomCell

@property(nonatomic, strong) IBOutlet UILabel* customLabel; //名称显示控件
@property(nonatomic, strong) IBOutlet UIButton* tickButton; //勾选按钮
//@property(nonatomic, strong) IBOutlet UIButton* propertyButton; //属性按钮

@end

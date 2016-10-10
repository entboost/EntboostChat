//
//  ApplicationsCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/11/28.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface ApplicationsCell : CustomCell

@property(nonatomic, strong) IBOutlet UIImageView* customImageView; //自定义头像视图
@property(nonatomic, strong) IBOutlet UILabel* customTextLabel; //自定义标题Label
@property(nonatomic, strong) IBOutlet UILabel* customDetailTextLabel; //自定义详细Label

@end

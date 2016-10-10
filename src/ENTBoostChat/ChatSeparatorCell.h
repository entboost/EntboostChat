//
//  ChatSeparatorCell.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/9/14.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatSeparatorCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UILabel* contentLabel;
@property(nonatomic, strong) NSIndexPath* currentIndexPath; //当前行

@end

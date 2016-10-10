//
//  EBChatText.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-23.
//
//

#import "EBChat.h"

///文本信息
@interface EBChatText : EBChat

/**初始化方法
 * @param text 文本内容
 * @return 本实例对象
 */
- (id)initWithText:(NSString*)text;

///获取文本内容
- (NSString*)text;

/**设置文本内容
 * @param text 文本内容
 */
- (void)setText:(NSString*)text;

@end

//
//  EBChatImage.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-23.
//
//

#import <UIKit/UIKit.h>
#import "EBChat.h"

/////图片格式
//typedef enum EB_CHAT_ENTITY_IMAGE_TYPE
//{
//    EB_CHAT_ENTITY_IMAGE_PNG,    //PNG文件
//    EB_CHAT_ENTITY_IMAGE_JPG    //JPG 文件
//    
//} EB_CHAT_ENTITY_IMAGE_TYPE;


///图片信息
@interface EBChatImage : EBChat

/////截图数据格式
//@property(nonatomic) EB_CHAT_ENTITY_IMAGE_TYPE imageType;

///**初始化方法
// * @param imageType 图片格式类型
// * @return 本实例对象
// */
//- (id)initWithImageType:(EB_CHAT_ENTITY_IMAGE_TYPE)imageType;

/**初始化方法
 * @param image UIImage对象
 * @return 本实例对象
 */
- (id)initWithImage:(UIImage*)image;

/**初始化方法
 * @param path 图片文件绝对路径
 * @return 本实例对象
 */
- (id)initWithPath:(NSString*)path;

/**初始化方法
 * @param data 二进制数据对象
 * @return 本实例对象
 */
- (id)initWithData:(NSData*)data;

/**初始化方法
 * @param data 二进制数组
 * @param length 二进制数组长度(字节数)
 * @return 本实例对象
 */
- (id)initWithBytes:(const void*)bytes length:(NSInteger)length;

///获取图片对象
- (UIImage*)image;

@end

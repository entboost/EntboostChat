//
//  EBRichInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-7.
//
//

#import "EBChat.h"

///富文本信息颗粒类型
typedef enum EB_RICH_ENTITY_TYPE
{
    EB_RICH_OBJECT_TEXT = 0,    //文本
    EB_RICH_OBJECT_RESOURCE,    //资源
    EB_RICH_OBJECT_OBJECT       //对象
} EB_RICH_ENTITY_TYPE;

///富文本信息颗粒
@interface EBRichEntity : NSObject

@property(nonatomic) EB_RICH_ENTITY_TYPE type;  //类型
@property(nonatomic) uint64_t size;  //内容的长度(字节数)
@property(nonatomic) NSData* data;   //内容

- (id)initWithText:(NSString*)text;
- (id)initWithResourceStr:(NSString*)resourceStr;
- (id)initWithBinary:(NSData*)data;
- (id)initWithType:(EB_RICH_ENTITY_TYPE)type size:(uint64_t)size data:(NSData*)data;

///富文本信息内容类型转换为富文本内部传输格式类型
+ (EB_RICH_ENTITY_TYPE)richTypeFromChatType:(EB_CHAT_ENTITY_TYPE)chatType;

@end


///富文本信息
@interface EBRichInfo : NSObject

///追加一个内部实例
- (void)addEntity:(EBRichEntity*)entity;

/**获取发送信息分包
 * @param packLen 单个数据包大小(字节数)
 * @return NSData对象数组,最大字节数为packLen
 */
- (NSArray*)packageWithPackLen:(int32_t)packLen;

/**转换为richEntity数组
 * @param data 二进制数据对象
 * @return EBRichEntity实例数组
 */
+ (NSArray*)richEntitiesWithData:(NSData*)data;

@end

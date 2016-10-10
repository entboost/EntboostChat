//
//  EBChatResource.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-23.
//
//

#import "EBChat.h"

///资源内容类型
typedef enum EB_CHAT_ENTITY_RESOURCE_TYPE
{
    EB_CHAT_ENTITY_RESOURCE_EXPRESSION    //表情
    
} EB_CHAT_ENTITY_RESOURCE_TYPE;

@class EBEmotion;

///资源信息(表情等)
@interface EBChatResource : EBChat

@property(nonatomic) uint64_t resourceId; //资源编号
@property(nonatomic) EB_CHAT_ENTITY_RESOURCE_TYPE resourceType; //资源内容类型

///**初始化方法,默认资源内容类型是表情资源(EB_CHAT_ENTITY_RESOURCE_EXPRESSION)
// * @param resourceId 资源编号
// */
//- (id)initWithResource:(uint64_t)resourceId;

/**初始化方法,默认资源内容类型是表情资源(EB_CHAT_ENTITY_RESOURCE_EXPRESSION)
 * @param resourceStr 资源字符串，用户登录时自动加载的表情资源；例如：1230045;xxxx.entboost.com:18012;POPChatManager;微笑
 */
- (id)initWithResourceStr:(NSString*)resourceStr;

///**初始化方法
// * @param resourceId 资源编号
// * @param resourceType 资源内容类型
// */
//- (id)initWithResource:(uint64_t)resourceId resourceType:(EB_CHAT_ENTITY_RESOURCE_TYPE)resourceType;

///获取表情,如果本资源不是表情，将返回nil
- (EBEmotion*)expression;

@end

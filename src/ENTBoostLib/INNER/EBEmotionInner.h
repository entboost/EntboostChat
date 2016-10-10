//
//  EBEmotionInner.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-23.
//
//

#import "EBEmotion.h"
#import "SOTP_defines.h"

@class EBServerInfo;
@class TBEmotion;

@interface EBEmotionInner : EBEmotion

@property(nonatomic) EB_RESOURCE_TYPE resourceType; //资源类型
@property(nonatomic) uint64_t entCode; //所属企业

@property(strong, nonatomic) EBServerInfo* cmServer; //资源所在CM服务器信息
@property(strong, nonatomic) NSString* httpServer; //可访问资源的http服务器信息
@property(strong, nonatomic) NSString* realFilepath; //本地文件保存相对路径(相对于 沙盒根路径 或 应用main-bundle根路径，参考isFileInCache作判断)
@property(nonatomic) BOOL isFileInCache; //文件是否保存在缓存(沙盒)；NO=保存在沙盒Cache,YES=保存在应用打包
@property(nonatomic) BOOL isReceivedComplete; //文件内容已经接收完毕
@property(strong, nonatomic) NSString* md5; //MD5校验码
//@property(nonatomic) int32_t TYPE;

/**初始化方法
 * @param msgContent 加载表情资源里的通知内容
 */
- (id)initWithMsgContent:(NSString*)msgContent;

///初始化方法
- (id)initWithTBEmotion:(TBEmotion*)tbEmotion;

///使用本实例字段值填充到一个TBEmotion实例字段值
- (void)parseToTBEmotion:(TBEmotion*)tbEmotion;

@end

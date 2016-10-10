//
//  ServerInfo.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-6-23.
//
//

@interface EBServerInfo : NSObject

///scoket udp 访问地址
@property(strong, nonatomic) NSString* address;
///http 访问地址
@property(strong, nonatomic) NSString* httpAddress;
///应用名
@property(strong, nonatomic) NSString* appName;
///动态令牌
//@property(strong, nonatomic) NSString* onlineKey;

/** 初始化
 * @param appName 应用名
 * @param address udp socket访问地址
 * @param httpAddress http访问地址
 */
- (id)initWithAppName:(NSString*)appName address:(NSString*)address httpAddress:(NSString*)httpAddress;// onlineKey:(NSString*)onlineKey;

/**使用包含SOTPParameter对象的dictionary进行初始化
 * @param dict
 */
- (id)initWithDictionary:(NSDictionary*)dict;

@end

//用于音视频服务
@interface EBAVServerInfo : EBServerInfo

@property(nonatomic) uint64_t vParam;

/** 初始化
 * @param appName 应用名
 * @param address udp socket访问地址
 * @param httpAddress http访问地址
 * @param vParam 音视频参数
 */
- (id)initWithAppName:(NSString*)appName address:(NSString*)address httpAddress:(NSString*)httpAddress vParam:(uint64_t)vParam;

@end

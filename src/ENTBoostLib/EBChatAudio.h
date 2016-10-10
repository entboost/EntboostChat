//
//  EBChatVoice.h
//  ENTBoostKit
//
//  Created by zhong zf on 14-7-23.
//
//

#import "EBChat.h"

///语音文件格式类型
typedef enum EB_CHAT_ENTITY_AUDIO_TYPE
{
    EB_CHAT_ENTITY_AUDIO_WAV,   //WAV格式
    EB_CHAT_ENTITY_AUDIO_AMR    //AMR格式
    
} EB_CHAT_ENTITY_AUDIO_TYPE;

///声音消息
@interface EBChatAudio : EBChat

///语音文件格式
@property(nonatomic) EB_CHAT_ENTITY_AUDIO_TYPE audioType;

/**初始化方法
 * @param audioType 语音文件格式
 * @return 本实例对象
 */
- (id)initWithAudioType:(EB_CHAT_ENTITY_AUDIO_TYPE)audioType;

/**初始化方法
 * @param absolutePath 语音文件绝对路径
 * @param audioType 语音文件格式
 * @return 本实例对象
 */
- (id)initWithAbsolutePath:(NSString*)absolutePath audioType:(EB_CHAT_ENTITY_AUDIO_TYPE)audioType;

/**初始化方法
 * @param data 二进制数据对象
 * @param audioType 语音文件格式
 * @return 本实例对象
 */
- (id)initWithData:(NSData*)data audioType:(EB_CHAT_ENTITY_AUDIO_TYPE)audioType;

/**初始化方法
 * @param data 二进制数组
 * @param length 二进制数组长度(字节数)
 * @param audioType 语音文件格式
 * @return 本实例对象
 */
- (id)initWithBytes:(const void*)bytes andLength:(NSInteger)length audioType:(EB_CHAT_ENTITY_AUDIO_TYPE)audioType;

@end

//
//  Audio.h
//  ENTBoostChat
//
//  Created by zhong zf on 14/12/30.
//  Copyright (c) 2014年 EB. All rights reserved.
//
//  录音放音

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//录音文件格式
typedef enum EBChat_Audio_File_Format
{
    EBChat_Audio_File_Format_WAV = 0,
    EBChat_Audio_File_Format_AMR = 1
} EBChat_Audio_File_Format;


//录音工具集代理
@protocol AudioToolkitDelegate

@optional
/**录音完毕事件
 * @param recoder 录音实例
 * @param flag 结果；YES=录音成功，NO=录音失败
 */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag;

/**录音失败事件
 * @param recoder 录音实例
 * @param error 失败原因
 */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error;

/**播放完毕事件
 * @param player 播放实例
 * @param flag 结果；YES=播放成功，NO=播放失败
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;

/**播放失败事件
 * @param player 播放实例
 * @param error 失败原因
 */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;

@end


@interface AudioToolkit : NSObject <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

///录音事件回调代理
@property(nonatomic, weak) id recorderDelegate;
///播音事件回调代理
@property(nonatomic, weak) id playerDelegate;
///录音时长
@property(nonatomic) NSTimeInterval recordTime;
///录音音量图标视图
@property(nonatomic, weak) UIImageView* imageView;

//录音实例
@property(nonatomic, strong) AVAudioRecorder *recorder;
//播放实例
@property(nonatomic, strong) AVAudioPlayer *player;

///是否正在录音
@property(nonatomic) BOOL recording;
///是否正在播放
@property(nonatomic) BOOL playing;
///特殊标记
@property(nonatomic) uint64_t tag;

//@property(nonatomic, strong) NSURL *tmpFile;

////是否正在录音
//@property(atomic) BOOL recording;

///获取全局单例
+ (id)sharedInstance;

///**产生临时文件路径
// * @param fileFormat 录音文件格式
// * @return 文件URL
// */
//- (NSURL*)generateTempFilePathWithFileFormat:(EBChat_Audio_File_Format)fileFormat;

///设置音频环境激活状态
- (BOOL)setAudioSessionActive:(BOOL)beActive;

/**准备录音环境
 * @param fileFormat 录音文件格式
 * @parma maxTime 录音时长最大限制(单位：秒)
 * @return 执行结果
 */
- (BOOL)prepareToRecordWithFormat:(EBChat_Audio_File_Format)fileFormat maxTime:(NSTimeInterval)maxTime;

///开始录音
- (BOOL)startRecord;

///结束录音
- (void)stopRecord;

/////删除当前录音实例关联的文件
//- (BOOL)deleteRecordFile;

///**播放音频文件
// * @param fileURL 文件URL
// * @param delegate 事件代理
// */
//- (void)playFile:(NSURL*)fileURL delegate:(id)delegage;

/**播放音频数据
 * @param data 音频数据
 * @param tag 标记
 * @param delegate 事件代理
 */
- (void)playData:(NSData*)data tag:(uint64_t)tag delegate:(id)delegage;

///停止正在进行的语音播放
- (void)stopPlaying;

@end
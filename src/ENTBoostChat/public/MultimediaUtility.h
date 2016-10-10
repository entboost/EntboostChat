//
//  MultimediaUtility.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/5.
//  Copyright © 2015年 EB. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __YXXDC__PCM2Wav__
#define __YXXDC__PCM2Wav__

#include <stdio.h>
#include <string.h>



typedef uint32_t DWORD;
typedef unsigned char BYTE;
typedef unsigned short WORD;

int a_law_pcm_to_wav(const char *pcm_file, const char *wav);


#endif


@interface MultimediaUtility : NSObject

/**IOS录制的WAV文件转换为标准WAV格式文件
 * @param iosWavFilePath 源wav文件路径
 * @param standardwavFilePath 目标Wav文件路径
 * @return 播放时长(秒)
 */
+ (int)translateIOSWav:(NSString*)iosWavFilePath toStandardWav:(NSString*)standardwavFilePath;

/**计算WAV文件播放时长
 * @param filePath WAV文件路径
 * @return 播放时长(秒)
 */
+ (int)timeLengthWithWaveFile:(NSString*)filePath;

/**计算WAV文件播放时长
 * @param data WAV格式数据
 * @return 播放时长(秒)
 */
+ (int)timeLengthWithWaveData:(NSData*)data;

@end

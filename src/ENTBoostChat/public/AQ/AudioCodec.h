//
//  AudioCodec.h
//  ENTBoostChat
//
//  Created by zhong zf on 15/6/17.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#include <AudioToolbox/AudioToolbox.h>
#include <Foundation/Foundation.h>

#include "CAStreamBasicDescription.h"
#include "CAXException.h"

typedef struct _tagConvertContext {
    AudioConverterRef converter; //AudioConverter引用实例
    int samplerate; //采样率
    int channels;   //声道数
} ConvertContext;

//编解码器初始化
extern void* AudioConvertInit(Float64 sampleRate, UInt32 channelCount);

//执行音频数据转换
extern void AudioConvert(void* convertContext, void* srcdata, UInt32 srclen, UInt32 inNumPackets, void** outdata, UInt32* outlen, UInt32* outNumPackets, AudioStreamPacketDescription*outputPacketDescriptions);
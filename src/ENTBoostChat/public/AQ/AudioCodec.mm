//
//  AudioCodec.cpp
//  ENTBoostChat
//
//  Created by zhong zf on 15/6/17.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#include "AudioCodec.h"

//源音频输入结构定义
typedef struct
{
    void *source;           //源音频数据
    UInt32 sourceSize;      //源音频数据长度(字节)
    UInt32 inNumPackets;    //源音频分包数量
    UInt32 channelCount;    //声道数
    AudioStreamPacketDescription *packetDescriptions; //分包描述(用于VBA)
} FillComplexInputParam;


void* AudioConvertInit(Float64 sampleRate, UInt32 channelCount)
{
    //设置源音频参数
    AudioStreamBasicDescription sourceDes;
    memset(&sourceDes, 0, sizeof(sourceDes));
    
    sourceDes.mSampleRate = sampleRate;
    sourceDes.mFormatID = kAudioFormatLinearPCM;
    sourceDes.mFormatFlags = kLinearPCMFormatFlagIsPacked | kLinearPCMFormatFlagIsSignedInteger;
    sourceDes.mChannelsPerFrame = channelCount;
    sourceDes.mBitsPerChannel = 16;
    sourceDes.mBytesPerFrame = sourceDes.mBitsPerChannel/8*sourceDes.mChannelsPerFrame;
    sourceDes.mBytesPerPacket = sourceDes.mBytesPerFrame;
    sourceDes.mFramesPerPacket = 1;
    sourceDes.mReserved = 0;
    
    //设置目标音频参数
    AudioStreamBasicDescription targetDes;
    memset(&targetDes, 0, sizeof(targetDes));
    
    targetDes.mFormatID = kAudioFormatMPEG4AAC;
    targetDes.mSampleRate = sampleRate;
    targetDes.mChannelsPerFrame = channelCount;
    UInt32 size = sizeof(targetDes);
    AudioFormatGetProperty(kAudioFormatProperty_FormatInfo, 0, NULL, &size, &targetDes);
    
    //获取操作系统内可用编码器
    AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders, sizeof(targetDes.mFormatID), &targetDes.mFormatID, &size);
    
    int encoderCount = size / sizeof(AudioClassDescription);
    AudioClassDescription descriptions[encoderCount];
    AudioFormatGetProperty(kAudioFormatProperty_Encoders, sizeof(targetDes.mFormatID), &targetDes.mFormatID, &size, descriptions);
    
    AudioClassDescription audioClassDes;
    memset(&audioClassDes, 0, sizeof(AudioClassDescription));
    for (int pos=0; pos<encoderCount; pos++) {
        if (targetDes.mFormatID == descriptions[pos].mSubType && descriptions[pos].mManufacturer == kAppleSoftwareAudioCodecManufacturer) {
            memcpy(&audioClassDes, &descriptions[pos], sizeof(AudioClassDescription));
            break;
        }
    }
    
    ConvertContext *convertContex = (ConvertContext*)malloc(sizeof(ConvertContext)); //如果不再使用convertContex，外部调用程序负责释放内存
//    OSStatus ret = AudioConverterNew(&sourceDes, &targetDes, &convertContex->converter);
    OSStatus ret = AudioConverterNewSpecific(&sourceDes, &targetDes, 1, &audioClassDes, &convertContex->converter);
    if (ret == noErr) {
        convertContex->samplerate = sampleRate;
        convertContex->channels = channelCount;
        
        //设置比特率
//        AudioConverterRef converter = convertContex->converter;
//        UInt32 tmp = kAudioConverterQuality_High;
//        AudioConverterSetProperty(converter, kAudioConverterCodecQuality, sizeof(tmp), &tmp);
//        UInt32 bitRate = 96000;
//        UInt32 size = sizeof(bitRate);
//        ret = AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate, size, &bitRate);
    } else {
        free(convertContex);
        convertContex = NULL;
    }

    return convertContex;
}


//- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {

//char* newAdtsDataForPacketLength(int packetLength, int samplerate, int channelCount, int* ioHeaderLen) {
//    
//    int adtsLength = 7;
//    
//    char *packet = (char*)malloc(sizeof(char) * adtsLength);
//    
//    // Variables Recycled by addADTStoPacket
//    
//    int profile = 2;  //AAC LC
//    
//    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
//    
//    int freqIdx = freqIdxForAdtsHeader(samplerate);
//    
//    int chanCfg = channelIdxForAdtsHeader(channelCount);  //MPEG-4 Audio Channel Configuration.
//    
//    NSUInteger fullLength = adtsLength + packetLength;
//    
//    // fill in ADTS data
//    
//    packet[0] = (char)0xFF;
//    // 11111111  = syncword
//    
//    packet[1] = (char)0xF9;
//    // 1111 1 00 1  = syncword MPEG-2 Layer CRC
//    
//    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
//    
//    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
//    
//    packet[4] = (char)((fullLength&0x7FF) >> 3);
//    
//    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
//    
//    packet[6] = (char)0xFC;
//    
//    //    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
//    
//    //    return data;
//    
//    *ioHeaderLen = adtsLength;
//    
//    return packet;
//    
//}


OSStatus audioConverterComplexInputDataProc(AudioConverterRef               inAudioConverter,
                                            UInt32*                         ioNumberDataPackets,
                                            AudioBufferList*                ioData,
                                            AudioStreamPacketDescription**  outDataPacketDescription,
                                            void*                           inUserData)
{
    FillComplexInputParam* param = (FillComplexInputParam*)inUserData;
    if (param->sourceSize <= 0) {
        *ioNumberDataPackets = 0;
        return -1;
    }
    
    ioData->mBuffers[0].mData = param->source;
    ioData->mBuffers[0].mNumberChannels = param->channelCount;
    ioData->mBuffers[0].mDataByteSize = param->sourceSize;
    
    *ioNumberDataPackets = param->inNumPackets;//1;
    param->sourceSize = 0;
    param->source = NULL;
    param->inNumPackets = 0;
    param->channelCount = 0;
    return noErr;
}

void AudioConvert(void* convertContext, void* srcdata, UInt32 srclen, UInt32 inNumPackets, void** outdata, UInt32* outlen, UInt32* outNumPackets, AudioStreamPacketDescription*outputPacketDescriptions)
{
    ConvertContext* convertCxt = (ConvertContext*)convertContext;
    if (convertCxt && convertCxt->converter) {
        
        UInt32 theOuputBufSize = srclen;
//        UInt32 packetSize = 10; //1;
        
//        AudioStreamPacketDescription *outputPacketDescriptions = NULL;
//        outputPacketDescriptions = (AudioStreamPacketDescription*)malloc(sizeof(AudioStreamPacketDescription) * packetSize);
        
        FillComplexInputParam userParam;
        userParam.source = srcdata;
        userParam.sourceSize = srclen;
        userParam.inNumPackets = inNumPackets;
        userParam.channelCount = convertCxt->channels; //1
        userParam.packetDescriptions = NULL;
        
        OSStatus ret = noErr;
        
        void *outBuffer = malloc(theOuputBufSize);
        //        memset(outBuffer, 0, theOuputBufSize);
        
//        AudioBufferList* bufferList = (AudioBufferList*)malloc(sizeof(AudioBufferList));
        AudioBufferList outputBuffers;// = *bufferList;
        outputBuffers.mNumberBuffers = 1;
        outputBuffers.mBuffers[0].mNumberChannels = convertCxt->channels;
        outputBuffers.mBuffers[0].mData = outBuffer;
        outputBuffers.mBuffers[0].mDataByteSize = theOuputBufSize;
        
        try {
            ret = AudioConverterFillComplexBuffer(convertCxt->converter, audioConverterComplexInputDataProc, &userParam, outNumPackets, &outputBuffers, outputPacketDescriptions);
        } catch (CAXException e) {
            *outNumPackets = 0;
            char buf[256];
            fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//            ret = e.mError;
        }
        
//        char buf[256];
//        memset(buf, 0, sizeof(buf));
//        CAXException::FormatError(buf, ret);
//        printf("%s\n", buf);
//        
//        if (ret == noErr) {
//        *outNumPackets = packetSize;
        if (*outNumPackets > 0/*outputBuffers.mBuffers[0].mDataByteSize > 0*/) {
//            NSData* rawAAC = [NSData dataWithBytes:outputBuffers.mBuffers[0].mData length:outputBuffers.mBuffers[0].mDataByteSize];
            
//            *outdata = malloc([rawAAC length]);
//            memset(*outdata, 0, sizeof(*outdata));
            memcpy(*outdata, outputBuffers.mBuffers[0].mData, outputBuffers.mBuffers[0].mDataByteSize);
//            memcpy(*outdata, [rawAAC bytes], [rawAAC length]);
            *outlen = outputBuffers.mBuffers[0].mDataByteSize;
//            *outlen = (int)[rawAAC length];
            
//#if 1
//                
//                int headerLength = 0;
//                
//                char* packetHeader = newAdtsDataForPacketLength((int)[rawAAC length], convertCxt->samplerate, convertCxt->channels, &headerLength);
//                
//                NSData* adtsPacketHeader = [NSData dataWithBytes:packetHeader length:headerLength];
//                
//                free(packetHeader);
//                
//                NSMutableData* fullData = [NSMutableData dataWithData:adtsPacketHeader];
//                
//                [fullData appendData:rawAAC];
//                
//                
//                
//                NSFileManager *fileMgr = [NSFileManager defaultManager];
//                
//                NSString *filepath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/test%p.aac", convertCxt->converter];
//                
//                NSFileHandle *file = nil;
//                
//                if (![fileMgr fileExistsAtPath:filepath]) {
//                    
//                    [fileMgr createFileAtPath:filepath contents:nil attributes:nil];
//                    
//                }
//                
//                file = [NSFileHandle fileHandleForWritingAtPath:filepath];
//                
//                [file seekToEndOfFile];
//                
//                [file writeData:fullData];
//                
//                [file closeFile];
//                
//#endif
            
        }
//        }
        free(outBuffer);
//        if (outputPacketDescriptions) {
//            free(outputPacketDescriptions);
//        }
        
    }
    
}

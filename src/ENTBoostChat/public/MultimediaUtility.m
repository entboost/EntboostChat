//
//  MultimediaUtility.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/12/5.
//  Copyright © 2015年 EB. All rights reserved.
//

#import "MultimediaUtility.h"

#pragma push //保存一下当前的对齐值
#pragma pack(1)

//=====IOS录制的PCM文件格式转换为标准WAV文件格式=====

struct tagHXD_WAVFLIEHEAD
{
    char RIFFNAME[4];
    DWORD nRIFFLength;
    char WAVNAME[4];
    char FMTNAME[4];
    DWORD nFMTLength;
    WORD nAudioFormat;
    
    WORD nChannleNumber;
    DWORD nSampleRate;
    DWORD nBytesPerSecond;
    WORD nBytesPerSample;
    WORD    nBitsPerSample;
    char    DATANAME[4];
    DWORD   nDataLength;
};

typedef struct tagHXD_WAVFLIEHEAD HXD_WAVFLIEHEAD;

int ios_wav_to_standard_wav2(const char *ios_wav_file, const char *standard_wav_file)
{
    HXD_WAVFLIEHEAD DestionFileHeader;
    
    // 文件头的基本部分
    int nFileLen = 0;
    size_t nSize = sizeof(DestionFileHeader);
    
    FILE *fp_s = NULL;
    FILE *fp_d = NULL;
    
    //打开源文件
    fp_s = fopen(ios_wav_file, "rb");
    if (fp_s == NULL)
        return -1;
    
    //打开目标文件
    fp_d = fopen(standard_wav_file, "wb+");
    if (fp_d == NULL)
        return -2;
    
    //将文件头写入wav文件
    size_t nWrite = fwrite(&DestionFileHeader, 1, nSize, fp_d);
    if (nWrite != nSize) {
        fclose(fp_s);
        fclose(fp_d);
        return -3;
    }
    
    uint32_t size = 0;
    
    //读取源文件头
    fread(&DestionFileHeader, 1, nSize, fp_s);
    
    char style[4];
    memcpy(style, DestionFileHeader.DATANAME, 4);
    
    //遇到大段空白数据标记，跳过
    if (style[0]=='F' && style[1]=='L'&& style[2]=='L' && style[3]=='R') { //FLLR
        size = DestionFileHeader.nDataLength;
        fseek(fp_s, size, SEEK_CUR);
    }
    
    fread(style, 1, 4, fp_s); //读取"data"字符串
    fread((char*)&size, 1, 4, fp_s); //读取录音数据长度

    //写入录音数据到目标文件
    while(!feof(fp_s)) {
        char readBuf[4096];
        size_t nRead = fread(readBuf, 1, 4096, fp_s);    //将pcm文件读到readBuf
        if (nRead > 0) {
            fwrite(readBuf, 1, nRead, fp_d);      //将readBuf文件的数据写到wav文件
        }
        
        nFileLen += nRead;
    }
    
    DestionFileHeader.DATANAME[0] = 'd';
    DestionFileHeader.DATANAME[1] = 'a';
    DestionFileHeader.DATANAME[2] = 't';
    DestionFileHeader.DATANAME[3] = 'a';
    DestionFileHeader.nRIFFLength = nFileLen - 8 + (int)nSize;
    DestionFileHeader.nDataLength = nFileLen;
    
    fseek(fp_d, 0L, SEEK_SET);   //将读写位置移动到文件开头
    nWrite = fwrite(&DestionFileHeader, 1, nSize, fp_d);   //重新将文件头写入到wav文件
    if (nWrite != nSize)
    {
        fclose(fp_s);
        fclose(fp_d);
        return -4;
    }
    
    fclose(fp_s);
    fclose(fp_d);
    
    return nFileLen;
}

int ios_wav_to_standard_wav(const char *pcm_file, const char *wav)
{
    // 开始准备WAV的文件头
    HXD_WAVFLIEHEAD DestionFileHeader;
    DestionFileHeader.RIFFNAME[0] = 'R';
    DestionFileHeader.RIFFNAME[1] = 'I';
    DestionFileHeader.RIFFNAME[2] = 'F';
    DestionFileHeader.RIFFNAME[3] = 'F';
    
    DestionFileHeader.WAVNAME[0] = 'W';
    DestionFileHeader.WAVNAME[1] = 'A';
    DestionFileHeader.WAVNAME[2] = 'V';
    DestionFileHeader.WAVNAME[3] = 'E';
    
    DestionFileHeader.FMTNAME[0] = 'f';
    DestionFileHeader.FMTNAME[1] = 'm';
    DestionFileHeader.FMTNAME[2] = 't';
    DestionFileHeader.FMTNAME[3] = 0x20;
    DestionFileHeader.nFMTLength = 0x10;  //  表示 FMT 的长度
    DestionFileHeader.nAudioFormat = 1; //这个表示linear PCM
    
    DestionFileHeader.DATANAME[0] = 'd';
    DestionFileHeader.DATANAME[1] = 'a';
    DestionFileHeader.DATANAME[2] = 't';
    DestionFileHeader.DATANAME[3] = 'a';
    DestionFileHeader.nBitsPerSample = 8;
    DestionFileHeader.nBytesPerSample = 1;    //
    DestionFileHeader.nSampleRate = 8000.0;    //
    DestionFileHeader.nBytesPerSecond = 8000.0;
    DestionFileHeader.nChannleNumber = 1;
    
    // 文件头的基本部分
    int nFileLen = 0;
    size_t nSize = sizeof(DestionFileHeader);
    
    FILE *fp_s = NULL;
    FILE *fp_d = NULL;
    
    fp_s = fopen(pcm_file, "rb");
    if (fp_s == NULL)
        return -1;
    
    fp_d = fopen(wav, "wb+");
    if (fp_d == NULL)
        return -2;
    
    size_t nWrite = fwrite(&DestionFileHeader, 1, nSize, fp_d);     //将文件头写入wav文件
    if (nWrite != nSize) {
        fclose(fp_s);
        fclose(fp_d);
        return -3;
    }
    
    uint32_t size = 0;
    fseek(fp_s, 36, SEEK_SET); //将读取位置移动36个字节
    
    char style[4];
    fread(style, 1, 4, fp_s);
    //遇到大段空白数据标记，跳过
    if (style[0]=='F' && style[1]=='L'&& style[2]=='L' && style[3]=='R') { //FLLR
        fread((char*)&size, 1, 4, fp_s);
        fseek(fp_s, size, SEEK_CUR);
    }
    
//    char aa[200];
//    fread(aa, 1, 200, fp_s);
//    fseek(fp_s, 4, SEEK_CUR); //跳过"data"字符串
    fread(style, 1, 4, fp_s); //读取"data"字符串
    fread((char*)&size, 1, 4, fp_s); //读取录音数据长度
//    fseek(fp_s, 4, SEEK_CUR); //跳过数量字符串
    
    while( !feof(fp_s)) {
        char readBuf[4096];
        size_t nRead = fread(readBuf, 1, 4096, fp_s);    //将pcm文件读到readBuf
        if (nRead > 0) {
            fwrite(readBuf, 1, nRead, fp_d);      //将readBuf文件的数据写到wav文件
        }
        
        nFileLen += nRead;
    }
    
    fseek(fp_d, 0L, SEEK_SET);   //将读写位置移动到文件开头
    DestionFileHeader.nRIFFLength = nFileLen - 8 + (int)nSize;
    DestionFileHeader.nDataLength = nFileLen;
    nWrite = fwrite(&DestionFileHeader, 1, nSize, fp_d);   //重新将文件头写入到wav文件
    if (nWrite != nSize)
    {
        fclose(fp_s);
        fclose(fp_d);
        return -4;
    }
    
    fclose(fp_s);
    fclose(fp_d);
    
    return nFileLen;
}

//=====获取WAV文件播放时长=====

typedef struct eb_waveformat_tag {
    unsigned short	wFormatTag;        /* format type */
    unsigned short	nChannels;         /* number of channels (i.e. mono, stereo, etc.) */
//    unsigned long	nSamplesPerSec;    /* sample rate */
    uint32_t        nSamplesPerSec;
//    unsigned long	nAvgBytesPerSec;   /* for buffer estimation */
    uint32_t        nAvgBytesPerSec;
    unsigned short	nBlockAlign;       /* block size of data */
} EB_WAVEFORMAT;

typedef struct eb_pcmwaveformat_tag {
    EB_WAVEFORMAT	wf;
    unsigned short	wBitsPerSample;
} EB_PCMWAVEFORMAT;

//读取Wav文件播放时长
int GetWaveTimeLength(const char* lpszWavFilePath)
{
    FILE * f = fopen(lpszWavFilePath,"rb");
    if (f==NULL)
        return -1;
    
//    char aaa[128];
//    fread(aaa,1,128,f);
//    fseek(f,0,SEEK_SET);
    
    char style[4];//定义一个四字节的数据，用来存放文件的类型；
    fseek(f,8,SEEK_SET);
    fread(style,1,4,f);
    if(style[0]!='W'||style[1]!='A'||style[2]!='V'||style[3]!='E')//判断该文件是否为"WAVE"文件格式
    {
        fclose(f);
        return -2;
    }
    // WAV格式文件所占容量（KB) = （取样频率X 量化位数X 声道）X 时间/ 8 (字节= 8bit) ，每一分钟WAV格式的音频文件的大小为MB，其大小不随音量大小及清晰度的
    EB_PCMWAVEFORMAT format; //定义PCMWAVEFORMAT结构对象，用来判断WAVE文件格式；
    fseek(f,20,SEEK_SET);
    fread((char*)&format,1,sizeof(EB_PCMWAVEFORMAT),f);//获取该结构的数据；
    // 获取WAVE文件data 数据标识
    fseek(f,36,SEEK_SET);
    fread(style,1,4,f);
    if(style[0]!='d'||style[1]!='a'||style[2]!='t'||style[3]!='a')	//判断是否标准data文件，如果是使用字节文件头，否则使用字节文件头
        fseek(f,42,SEEK_SET);
    //fseek(f,40,SEEK_SET);
    ////获取WAVE文件的声音数据的大小；
    unsigned long size = 0;
    fread((char*)&size,1,4,f);
    //计算文件时长
    const int timeLength = (int)(size/format.wf.nAvgBytesPerSec);
    fclose(f);
    return timeLength;
}

//读取Wav数据播放时长
int GetWavTimeLength2(char* bytes)
{
    char* pCursor = bytes;
    char style[4];//定义一个四字节的数据，用来存放文件的类型；
 
    char aaa[128];
    memcpy(aaa, bytes, 128);
    
    pCursor+=4; //RIFF
    
    //获取WAVE文件的声音数据的大小
    pCursor+=4; //文件总长 size0
    
    memcpy(style, pCursor, 4); //WAVEfmt
    pCursor+=8;
    
    if(style[0]!='W'||style[1]!='A'||style[2]!='V'||style[3]!='E') { //判断该文件是否为"WAVE"文件格式
        return -2;
    }
    
    pCursor+=4; //size1
    
    // WAV格式文件所占容量（KB) = （取样频率X 量化位数X 声道）X 时间/ 8 (字节= 8bit) ，每一分钟WAV格式的音频文件的大小为MB，其大小不随音量大小及清晰度的
    EB_PCMWAVEFORMAT format; //定义PCMWAVEFORMAT结构对象，用来判断WAVE文件格式；
    size_t len = sizeof(EB_PCMWAVEFORMAT);
    memcpy((char*)&format, pCursor, len);
    pCursor+=len;
    
    // 获取WAVE文件data 数据标识
    memcpy(style, pCursor, 4);
    if(style[0]=='d' && style[1]=='a' && style[2]=='t' && style[3]=='a')	//判断是否标准data文件，如果是使用字节文件头，否则使用字节文件头
        pCursor+=4;
    ////获取WAVE文件的声音数据的大小；
    uint32_t size = 0;
    memcpy((char*)&size, pCursor, 4);
    
    //计算文件时长
    int timeLength = 0;
    if (format.wf.nAvgBytesPerSec)
        timeLength = (int)(size/format.wf.nAvgBytesPerSec);
    
    return timeLength;
}

#pragma pop //恢复编译期记忆的对齐值


@implementation MultimediaUtility

+ (int)translateIOSWav:(NSString*)iosWavFilePath toStandardWav:(NSString*)standardwavFilePath
{
    return ios_wav_to_standard_wav2([iosWavFilePath cStringUsingEncoding:NSUTF8StringEncoding], [standardwavFilePath cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (int)timeLengthWithWaveFile:(NSString*)filePath
{
    return GetWaveTimeLength([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
}

+ (int)timeLengthWithWaveData:(NSData*)data
{
    return GetWavTimeLength2((char*)[data bytes]);
}

@end

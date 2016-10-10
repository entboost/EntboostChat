//
//  Audio.m
//  ENTBoostChat
//
//  Created by zhong zf on 14/12/30.
//  Copyright (c) 2014年 EB. All rights reserved.
//

#import "AudioToolkit.h"
#import "SeedUtility.h"
#import "FileUtility.h"

@interface AudioToolkit ()
{
    NSDictionary* _wavSetting;
    NSDictionary* _amrSetting;
    
    //日期格式化
    NSDateFormatter* _dateFormatter;
    
    //录音音量检测定时器
    NSTimer *_voiceDetectTimer;
}

@end

@implementation AudioToolkit

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static AudioToolkit* instance;
    dispatch_once(&pred, ^{
        instance = [[AudioToolkit alloc] init];
    });
    
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        _recording = NO;
        [self initSetting];
    }
    return self;
}

- (void)dealloc
{
    //删除事件监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    NSError* error;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (error) {
        NSLog(@"setActive to (NO) error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
    }
}

- (BOOL)setAudioSessionActive:(BOOL)beActive
{
    NSError* error;
    BOOL result = [[AVAudioSession sharedInstance] setActive:beActive error:&error];
    if (!result) {
        NSLog(@"setAudioSessionActive error, beActive = %i, code = %@, msg = %@", beActive, @(error.code), error.localizedDescription);
        return NO;
    }
    return YES;
}

//创建录音机或者播放器
- (void)initSetting
{
    //注册中断事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(interruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //注册耳机插拔事件监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
//    注册红外感应监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil];
    
    _wavSetting = @{AVSampleRateKey:@(8000.0)/*@(44100.0)*/, AVFormatIDKey:@(kAudioFormatLinearPCM), AVLinearPCMBitDepthKey:@(8), AVNumberOfChannelsKey:@(1), AVLinearPCMIsBigEndianKey:@NO, AVLinearPCMIsFloatKey:@NO, AVEncoderAudioQualityKey:@(AVAudioQualityMedium)};
    
    _amrSetting = @{AVSampleRateKey:@(8000.0)/*@(44100.0)*/, AVFormatIDKey:@(kAudioFormatAMR), AVLinearPCMBitDepthKey:@(8), AVNumberOfChannelsKey:@(1), AVLinearPCMIsBigEndianKey:@NO, AVLinearPCMIsFloatKey:@NO, AVEncoderAudioQualityKey:@(AVAudioQualityMedium)};

    //设置日期格式化实例
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSError *error;
//    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"audioSession setCategory error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        return;
    }
}

//录音中断处理
- (void)interruption:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSUInteger interuptionType = (NSUInteger)[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey];
    
    if(interuptionType == AVAudioSessionInterruptionTypeBegan) {
        NSLog(@"AVAudioSessionInterruptionTypeBegan notification ...");
    } else if (interuptionType == AVAudioSessionInterruptionTypeEnded) {
        NSLog(@"AVAudioSessionInterruptionTypeEnded ...");
    }
}

//耳机等外设备状态改变事件处理
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停播放
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            if (self.player.isPlaying)
                [self.player stop];
        }
    }
    //	[dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //		NSLog(@"%@:%@",key,obj);
    //	}];
}

//处理红外感应触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification;
{
    NSError* error;
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
//        BOOL success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (!success) {
            NSLog(@"setCategory to play and record error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        }
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Device is not close to user");
        //重定向音频输出到扬声器
//        BOOL success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (!success) {
            NSLog(@"setCategory to playback error, code = %@, msg = %@", @(error.code), error.localizedDescription);
        }
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        //关闭红外感应监控
        if (!_playing)
            [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

//产生一个新的临时文件URL
- (NSURL*)generateTempFilePathWithFileFormat:(EBChat_Audio_File_Format)fileFormat
{
    NSString* suffix;
    switch (fileFormat) {
        case EBChat_Audio_File_Format_WAV:
            suffix = @"wav";
            break;
        case EBChat_Audio_File_Format_AMR:
            suffix = @"amr";
            break;
        default:
            break;
    }
    NSString* tmpFile = [[FileUtility tmpDirectory] stringByAppendingPathComponent:[NSString stringWithFormat: @"%@-%@.%@", [SeedUtility uuid], [_dateFormatter stringFromDate:[NSDate date]], suffix]];
    NSLog(@"tmpFile = %@", tmpFile);
    return [NSURL URLWithString:tmpFile];
}

//准备录音环境
- (BOOL)prepareToRecordWithFormat:(EBChat_Audio_File_Format)fileFormat maxTime:(NSTimeInterval)maxTime
{
    @synchronized(self) {
        if (!_recording) {
            NSDictionary* setting;
            switch (fileFormat) {
                case EBChat_Audio_File_Format_WAV:
                    setting = _wavSetting;
                    break;
                case EBChat_Audio_File_Format_AMR:
                    setting = _amrSetting;
                    break;
                default:
                    setting = _wavSetting;
                    break;
            }
            
            NSError* error;
            _recorder =  [[AVAudioRecorder alloc] initWithURL:[self generateTempFilePathWithFileFormat:fileFormat] settings:setting error:&error];
            if (error) {
                NSLog(@"get recorder error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
                return NO;
            }
            
            [_recorder setDelegate:self];
            //设置录音时长最大限制
            [_recorder recordForDuration:maxTime];
            //开启音量检测
            _recorder.meteringEnabled = YES;
            
            return YES;
        } else {
            NSLog(@"recorder is running");
            return NO;
        }
    }
}

//开始录音
- (BOOL)startRecord
{
    @synchronized(self) {
        if (!_recording) {
            if ([_recorder prepareToRecord]) {
                //设置为录音模式
                NSError* error;
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:&error];
                
                if ([_recorder record]) {
                    [self setAudioSessionActive:YES];
                    
                    _recording = YES;
                    self.recordTime = 0.0;
                    
                    //设置检测录音音量定时器
                    _voiceDetectTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(detectVoice) userInfo:nil repeats:YES];
                    
                    return YES;
                } else {
                    //设置为播放模式
                    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
                }
            }
        } else {
            NSLog(@"startRecord error, recorder is busy");
        }
    }
    return NO;
}

- (void)stopRecord
{
    @synchronized(self) {
        //设置为播放模式
        NSError* error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        _recording = NO;
        [_recorder stop]; //停止录音
        [_voiceDetectTimer invalidate]; //停止定时检测
    }
}

//- (BOOL)deleteRecordFile
//{
//    @synchronized(self) {
//        if (!_recording && _recorder) {
//            return [_recorder deleteRecording];
//        }
//    }
//    return NO;
//}

//- (void)playFile:(NSURL*)fileURL delegate:(id)delegage
//{
//    if (self.player.isPlaying) {
//        [self.player stop];
//        [NSThread sleepForTimeInterval:0.1];
//    }
//    
//    NSLog(@"即将播放文件: %@", fileURL);
//    [self playData:[NSData dataWithContentsOfURL:fileURL] delegate:delegage];
//}

- (void)playData:(NSData*)data tag:(uint64_t)tag delegate:(id)delegage
{
    @synchronized(self) {
        self.tag = tag;
        self.playerDelegate = delegage;
        
        NSError* error;
        self.player = [[AVAudioPlayer alloc]initWithData:data error:&error];
        if (error) {
            NSLog(@"playAudio error, code = %li, msg = %@", (long)error.code, error.localizedDescription);
            return;
        }
        
        [self.player setDelegate:self];
        self.player.volume = 1;
        
        if ([self.player prepareToPlay]) {
            //设置播放模式
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            //打开红外感应
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
//            //模拟一次红外感应动作
//            [self sensorStateChange:nil];
            
            //播放音频
            if ([self.player play]) {
                _playing = YES;
                [self setAudioSessionActive:YES];
                NSLog(@"正在播放文件...");
            }
        }
    }
}

- (void)stopPlaying
{
    if (self.playing) {
        [self.player stop];
        [self audioPlayerDidFinishPlaying:self.player successfully:YES];
    }
}

- (void)detectVoice
{
    self.recordTime = _recorder.currentTime;
    
//    NSLog(@"detectVoice...");
    if (!self.imageView)
        return;
    
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];

    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
//    NSLog(@"%lf",lowPassResults);
    //最大50  0
    //图片 小-》大
    if (0<lowPassResults<=0.06) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
    }else if (0.06<lowPassResults<=0.13) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_02.png"]];
    }else if (0.13<lowPassResults<=0.20) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_03.png"]];
    }else if (0.20<lowPassResults<=0.27) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_04.png"]];
    }else if (0.27<lowPassResults<=0.34) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_05.png"]];
    }else if (0.34<lowPassResults<=0.41) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_06.png"]];
    }else if (0.41<lowPassResults<=0.48) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_07.png"]];
    }else if (0.48<lowPassResults<=0.55) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_08.png"]];
    }else if (0.55<lowPassResults<=0.62) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_09.png"]];
    }else if (0.62<lowPassResults<=0.69) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_10.png"]];
    }else if (0.69<lowPassResults<=0.76) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_11.png"]];
    }else if (0.76<lowPassResults<=0.83) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_12.png"]];
    }else if (0.83<lowPassResults<=0.9) {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_13.png"]];
    }else {
        [self.imageView setImage:[UIImage imageNamed:@"record_animate_14.png"]];
    }
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    NSLog(@"audioRecorderDidFinishRecording 录音结束 url = %@, successfully = %i", recorder.url, flag);
    [self setAudioSessionActive:NO];
    
    if ([self.recorderDelegate respondsToSelector:@selector(audioRecorderDidFinishRecording:successfully:)]) {
        [self.recorderDelegate audioRecorderDidFinishRecording:recorder successfully:flag];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    NSLog(@"audioRecorderEncodeErrorDidOccur 录音出错 code = %li, msg = %@", (long)error.code, error.localizedDescription);
    [self setAudioSessionActive:NO];
    
    if ([self.recorderDelegate respondsToSelector:@selector(audioRecorderEncodeErrorDidOccur:error:)]) {
        [self.recorderDelegate audioRecorderEncodeErrorDidOccur:recorder error:error];
    }
}


#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying 播放结束 url = %@, successfully = %i", player.url, flag);
    _playing = NO;
    
    //重定向音频输出到扬声器
    NSError* error;
//    BOOL success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success) {
        NSLog(@"overrideOutputAudioPort error, code = %@, msg = %@", @(error.code), error.localizedDescription);
    }
    
    //关闭红外感应
    if (![[UIDevice currentDevice] proximityState])
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self setAudioSessionActive:NO];
    
    if ([self.playerDelegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:successfully:)]) {
        [self.playerDelegate audioPlayerDidFinishPlaying:player successfully:flag];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur 播放出错 code = %li, msg = %@", (long)error.code, error.localizedDescription);
    _playing = NO;
    
    //关闭红外感应
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    [self setAudioSessionActive:NO];
    
    if ([self.playerDelegate respondsToSelector:@selector(audioPlayerDecodeErrorDidOccur:error:)]) {
        [self.playerDelegate audioPlayerDecodeErrorDidOccur:player error:error];
    }
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"audioPlayerBeginInterruption");
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    NSLog(@"audioPlayerEndInterruption");
}

@end

//
//  AQSViewController.m
//  ENTBoostChat
//
//  Created by zhong zf on 15/4/27.
//  Copyright (c) 2015年 EB. All rights reserved.
//

#import "AQSViewController.h"
#import "ButtonKit.h"
#import "AQRecorder.h"
#import "AQPlayer.h"
#import "AudioCodec.h"
#import "ENTBoost.h"
#import "BlockUtility.h"
#import "NSDate+Utility.h"
#import "Reachability.h"
#import "WQPlaySound.h"
#import "PublicUI.h"

@interface AQSViewController ()
{
//    //录音文件临时保存路径
//    CFStringRef _recordFilePath;
    //音视频通话开始时间
//    NSDate* _startTime;
    WQPlaySound *_sound; //通话邀请铃声
    
//    //暂存待发送的音频数据的队列
//    NSMutableArray* _waittingQueue;
//    //音频数据队列操作锁
//    NSObject* _queueLock;
    
    ConvertContext* _convertContext;
}

//@property(nonatomic, strong) IBOutlet UIButton *btn_stopTalk;     //停止通话按钮
//@property(nonatomic, strong) IBOutlet UIButton *btn_request;      //发起通话邀请按钮
@property(nonatomic, strong) IBOutlet UILabel *targetLabel;         //目标显示框
@property(nonatomic, strong) IBOutlet UILabel *targetLabel2;        //目标显示框
@property(nonatomic, strong) IBOutlet UILabel *stateLabel;          //状态显示框
@property(nonatomic, strong) IBOutlet UIButton *btn_phoneCall;      //通话(开始/停止)按钮
@property(nonatomic, strong) IBOutlet UIButton *btn_rejectRequest;  //拒绝通话按钮
@property(nonatomic, strong) IBOutlet UIButton *btn_speaker;        //免提按钮

//@property(nonatomic, strong) IBOutlet UILabel *escapeTimeLabel; //通话时间长度

//@property(nonatomic, strong) IBOutlet UIButton *btn_replay;

@property(readonly) AQRecorder	*recorder; //录音管理器
@property(readonly) AQPlayer *player; //播音管理器

@property(nonatomic) AV_WORK_STATE workState; //通话状态
@property(atomic) BOOL playbackWasInterrupted; //播音被打断
@property(atomic) BOOL playbackWasPaused; //播音被暂停

@property(nonatomic, strong) NSDate* requestTime; //请求发起时间
@property(nonatomic, strong) NSDate* talkStartTime; //通话开始时间
@property(nonatomic, strong) NSTimer* timer; //定时器

//@property(atomic) BOOL queueWorking; //标记正在进行通话
//@property(atomic) BOOL firstSend; //标记本次通话是否第一次发送数据

////停止通话
//- (IBAction)stopTalk:(id)sender;
//
////开始播音
//- (IBAction)replay:(id)sender;

@end

@implementation AQSViewController

@synthesize workState = _workState;

char *OSTypeToStr(char *buf, OSType t)
{
    char *p = buf;
    char str[4];
    memset(str, 0, sizeof(str));
    char *q = str;
    *(UInt32 *)str = CFSwapInt32(t);
    for (int i = 0; i < 4; ++i) {
        if (isprint(*q) && *q != '\\')
            *p++ = *q++;
        else {
            sprintf(p, "\\x%02x", *q++);
            p += 4;
        }
    }
    *p = '\0';
    return buf;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self =[super initWithCoder:aDecoder]) {
        // Allocate our singleton instance for the recorder & player object
        _recorder = new AQRecorder();
        _recorder->aqsController = self;
        _player = new AQPlayer();
        _player->aqsController = self;
        
//        self.workState = AV_WORK_STATE_IDLE;
//        _sound = [[WQPlaySound alloc]initForPlayingSystemSoundEffectWith:@"Tock" ofType:@"caf"];
//        _startTime = [NSDate date];
//        _queueLock = [[NSObject alloc] init];
//        _waittingQueue = [[NSMutableArray alloc] init];
//        self.queueWorking = NO;
//        self.firstSend = YES;
        
//        [self prepareStartAudio];
//        disable the play button since we have no recording to play yet
//        self.btn_replay.enabled = NO;
        self.playbackWasInterrupted = NO;
        self.playbackWasPaused = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"实时通话";
    self.navigationItem.leftBarButtonItem = [ButtonKit goBackBarButtonItemWithTarget:self action:@selector(goBack)]; //定义返回按钮
    [self setWorkState:AV_WORK_STATE_IDLE]; //设置工作状态
    
    self.targetLabel.text = self.targetName;
    self.targetLabel2.text = self.targetName2;
    self.stateLabel.text = nil;
}

- (void)dealloc
{
    _player->StopQueue();
    _recorder->StopRecord();
    
    delete _player;
    delete _recorder;
}

- (void)goBack
{
    if (_workState>=AV_WORK_STATE_INCOMING) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"退出当前界面将结束通话" message:@"真要退出吗？" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"确认", nil];
        alertView.tag = 102;
        [alertView show];
    } else {
        [self setWorkState:AV_WORK_STATE_IDLE];
        __weak typeof(self) weakSelf = self;
        [self dismissViewControllerAnimated:YES completion:^{
            AQSViewController* safeSelf = weakSelf;
            if ([_delegate respondsToSelector:@selector(aqsViewController:exitWithWorkState:)])
                [_delegate aqsViewController:safeSelf exitWithWorkState:_workState];
        }];
    }
}

//音频通话开始前准备工作
- (void)prepareStartAudio
{
    __block OSStatus error = noErr;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        //设置音频环境
        error = AudioSessionInitialize(NULL, NULL, interruptionListener,  (__bridge void*)self);
        if (error)
            NSLog(@"ERROR INITIALIZING AUDIO SESSION! %@", @(error));
    });
    
//    else {
        UInt32 category;
        UInt32 size = sizeof(category);
//        AudioSessionGetProperty(kAudioSessionProperty_AudioCategory, &size, &category);
//        
//        //1936682095
//        NSLog(@"%@, %@, %@, %@, %@, %@", @(kAudioSessionCategory_AmbientSound), @(kAudioSessionCategory_SoloAmbientSound), @(kAudioSessionCategory_MediaPlayback), @(kAudioSessionCategory_RecordAudio), @(kAudioSessionCategory_PlayAndRecord), @(kAudioSessionCategory_AudioProcessing));
        category = kAudioSessionCategory_PlayAndRecord;
        error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
        if (error) printf("couldn't set audio category!");
        
        //            [session setMode:AVAudioSessionModeVoiceChat error:nil];
        UInt32 mode = kAudioSessionMode_Measurement;
        error = AudioSessionSetProperty(kAudioSessionProperty_Mode, sizeof(mode), &mode);
        if (error) printf("couldn't set audio mode!");
        
//        //混音
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof (audioRouteOverride),&audioRouteOverride);
//
//        //设置扬声器播放
//        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
        
        //设置听筒播放
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
        
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener,  (__bridge void*)self);
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        UInt32 inputAvailable = 0;
        size = sizeof(inputAvailable);
        
        // we do not want to allow recording if input is not available
        error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
        if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
        //            self.btn_record.enabled = (inputAvailable)?YES:NO;
        
        // we also need to listen to see if input availability changes
        error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener,  (__bridge void*)self);
        if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
        
        error = AudioSessionSetActive(YES);
        if (error) printf("AudioSessionSetActive (true) failed");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
//    }
}

//音频通话结束后处理工作
- (void)followStopAudio
{
    OSStatus error = noErr;
//    UInt32 category = kAudioSessionCategory_MediaPlayback;
//    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
//    if (error) NSLog(@"couldn't set audio category!");
    
//    UInt32 mode = kAudioSessionMode_Default;
//    error = AudioSessionSetProperty(kAudioSessionProperty_Mode, sizeof(mode), &mode);
//    if (error) NSLog(@"couldn't set audio mode!");
    
    error = AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void*)self);
    if (error) NSLog(@"couldn't remove audio route change listener!");
    
    error = AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void*)self);
    if (error) NSLog(@"couldn't remove audio input available listener!");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackQueueStopped" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"playbackQueueResumed" object:nil];
    
    error = AudioSessionSetActive(NO);
    if (error) printf("AudioSessionSetActive (false) failed");
}

- (void)printRecordDescriptionForFormat: (CAStreamBasicDescription)format
{
    char buf[5];
    const char *dataFormat = OSTypeToStr(buf, format.mFormatID);
    NSString* description = [[NSString alloc] initWithFormat:@"(%@ ch. %s @ %g Hz)", @(format.NumberChannels()), dataFormat, format.mSampleRate, nil];
    NSLog(@"record description: %@\n", description);
}

//发起邀请通话
- (IBAction)requestTalk:(id)sender
{
//    self.stateLabel.text = @"请求通话......";
    [self setWorkState:AV_WORK_STATE_ALERTING];
    
    [[ENTBoostKit sharedToolKit] avRequestWithCallId:self.callId includeVideo:NO onCompletion:^{
        NSLog(@"请求通话提交成功，正在等待对方接受。。。");
    } onFailure:^(NSError *error) {
        NSLog(@"请求通话提交失败，code =%@, msg = %@", @(error.code), error.localizedDescription);
    }];
}

//结束通话
- (IBAction)stopTalk:(id)sender
{
    [self stopAV];
    
    //结束通话
    if (_workState >=AV_WORK_STATE_INCOMING) {
        [[ENTBoostKit sharedToolKit] avEndWithCallId:self.callId onCompletion:^{
            NSLog(@"结束通话成功");
        } onFailure:^(NSError *error) {
            NSLog(@"结束通话失败，code =%@, msg = %@", @(error.code), error.localizedDescription);
        }];
    }
    
    [self setWorkState:AV_WORK_STATE_HANGUP];
}

//开始播放
- (void)replay
{
    if (self.player->IsRunning()) {
//        if (self.playbackWasPaused) {
//            OSStatus result = self.player->StartQueue();
//            if (result == noErr)
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
//        } else {
        [self stopPlay];
        OSStatus result = self.player->StartQueue();
        if (result == noErr)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
//        }
    } else {
        OSStatus result = self.player->StartQueue();
        if (result == noErr)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
    }
}

-(void)stopPlay
{
    self.player->StopQueue();
    self.player->DisposeQueue();
}

-(void)pausePlayQueue
{
    self.player->PauseQueue();
    self.playbackWasPaused = YES;
}

- (void)stopRecord
{
//    self.queueWorking = NO;
    
    self.recorder->StopRecord();
    
    // dispose the previous playback queue
//    self.player->DisposeQueue(false);
//    self.player->DisposeQueue(true);
    
//    // now create a new queue for the recorded file
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentDirectory = [paths objectAtIndex:0];
//    //        NSTemporaryDirectory()
//    _recordFilePath = (__bridge CFStringRef)[documentDirectory stringByAppendingPathComponent: @"recordedFile.aac"];
//    NSLog(@"recordFilePath = %@\n", (__bridge NSString*)_recordFilePath);
//    self.player->CreateQueueForFile(_recordFilePath);
    
    // Set the button's state back to "record"
//    [self.btn_record setTitle:@"开始通话" forState:UIControlStateNormal];
//    self.btn_replay.enabled = YES;
    
//    if ([self.delegate respondsToSelector:@selector(aqsRecorderStopInTime:)])
//        [self.delegate aqsRecorderStopInTime:[NSDate date]];
}

//开始录音
- (void)record:(BOOL)retry
{
    if (self.recorder->IsRunning()) { // If we are currently recording
        [self stopRecord];
        [NSThread sleepForTimeInterval:0.5];
        if (retry)
            [self record:NO];
    } else { // If we're not recording, start.
//        self.btn_replay.enabled = NO;
        
        // Set the button's state to "stop"
//        [self.btn_record setTitle:@"停止通话" forState:UIControlStateNormal];
        
        _convertContext = (ConvertContext*)AudioConvertInit(16000, 1); //设置编码器参数
        
        // Start the recorder
        self.recorder->StartRecord();
        
        [self printRecordDescriptionForFormat:self.recorder->DataFormat()];
        
//        if ([self.delegate respondsToSelector:@selector(aqsRecorderStartInTime:)])
//            [self.delegate aqsRecorderStartInTime:[NSDate date]];
    }
}

- (AV_WORK_STATE)workState
{
    return _workState;
}

//设置通话状态
- (void)setWorkState:(AV_WORK_STATE)workState
{
    if (workState!=AV_WORK_STATE_CONNECTED) {
        //隐藏免提按钮
        self.btn_speaker.hidden = YES;
        
        //停止定时器
        if (self.timer) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    
    switch (workState) {
        case AV_WORK_STATE_IDLE:
        {
            self.stateLabel.text = nil;
//            self.escapeTimeLabel.text = nil;
            self.requestTime = nil;
            self.talkStartTime = nil;
        }
            break;
        case AV_WORK_STATE_HANGUP:
        {
            if (_workState==AV_WORK_STATE_CONNECTED) {
//                self.escapeTimeLabel.text = nil;
                if (self.talkStartTime) {
                    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.talkStartTime];
//                    self.escapeTimeLabel.text = [NSDate timeStringWithSecond:(uint32_t)timeInterval];
                    self.stateLabel.text = [NSString stringWithFormat:@"通话结束 %@", [NSDate timeStringWithSecond:(uint32_t)timeInterval]];
                }
            } else {
                self.stateLabel.text = @"通话结束";
            }
            self.requestTime = nil;
            self.talkStartTime = nil;
        }
            break;
        case AV_WORK_STATE_REJECTED:
        {
            self.stateLabel.text = @"拒绝通话";
            self.requestTime = nil;
        }
            break;
        case AV_WORK_STATE_TIMEOUT:
        {
            self.stateLabel.text = @"通话未能接通";
            self.requestTime = nil;
        }
            break;
        case AV_WORK_STATE_INCOMING:
        {
            self.stateLabel.text = @"收到通话邀请!";
//            self.escapeTimeLabel.text = nil;
            self.requestTime = nil;
        }
            break;
        case AV_WORK_STATE_ALERTING:
        {
            self.stateLabel.text = @"等待对方响应...";
//            self.escapeTimeLabel.text = nil;
            self.requestTime = [NSDate date];
        }
            break;
        case AV_WORK_STATE_CONNECTED:
        {
            //显示免提按钮
            self.btn_speaker.hidden = NO;
            
//            self.stateLabel.text = @"正在通话";
            self.talkStartTime = [NSDate date];
            
            //触发定时刷新显示通话时间
            self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(refreshTalkingTime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
//            [self.timer fire];
        }
            break;
        default:
            break;
    }
    
    _workState = workState;
    
    //设置拒接按钮
    if (workState==AV_WORK_STATE_INCOMING) {
        self.btn_rejectRequest.hidden = NO;
    } else {
        self.btn_rejectRequest.hidden = YES;
    }
    
    if (workState < AV_WORK_STATE_INCOMING) {
//        self.btn_stopTalk.enabled   = NO;
//        self.btn_request.enabled    = YES;
        [self.btn_phoneCall setImage:[UIImage imageNamed:@"phone_call"] forState:UIControlStateNormal];
        [self.btn_phoneCall removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.btn_phoneCall addTarget:self action:@selector(requestTalk:) forControlEvents:UIControlEventTouchUpInside];
        
        //恢复自动锁屏
        [UIApplication sharedApplication].idleTimerDisabled=NO;
    } else if (workState==AV_WORK_STATE_INCOMING) {
//        [_sound play];
        SystemSoundID soundID = 1005;
        AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, SoundFinished, (__bridge void*)self); /*添加音频结束时的回调*/
        AudioServicesPlaySystemSound(soundID);
        
        [self.btn_phoneCall setImage:[UIImage imageNamed:@"phone_call"] forState:UIControlStateNormal];
        [self.btn_phoneCall removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.btn_phoneCall addTarget:self action:@selector(acceptAVRequest:) forControlEvents:UIControlEventTouchUpInside];
        
        //关闭自动锁屏
        [UIApplication sharedApplication].idleTimerDisabled=YES;
    } else {
//        self.btn_stopTalk.enabled   = YES;
//        self.btn_request.enabled    = NO;
        [self.btn_phoneCall setImage:[UIImage imageNamed:@"phone_cancel"] forState:UIControlStateNormal];
        [self.btn_phoneCall removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [self.btn_phoneCall addTarget:self action:@selector(stopTalk:) forControlEvents:UIControlEventTouchUpInside];
        
        //关闭自动锁屏
        [UIApplication sharedApplication].idleTimerDisabled=YES;
    }
}

//当音频播放完毕会调用这个函数
static void SoundFinished(SystemSoundID soundID,void* inClientData){
    AQSViewController* THIS = (__bridge AQSViewController*)inClientData;
    if (THIS->_workState==AV_WORK_STATE_INCOMING)
        AudioServicesPlaySystemSound(soundID); //继续播放声音
    else
        AudioServicesDisposeSystemSoundID(soundID);
}

//刷新显示通话时间
- (void)refreshTalkingTime
{
    if (self.talkStartTime) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.talkStartTime];
        self.stateLabel.text = [NSString stringWithFormat:@"%@", [NSDate timeStringWithSecond:(uint32_t)timeInterval]];
    }
}

//检测当前是否听筒(耳机)播放
- (BOOL)hasHeadset
{
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString*)route;
        NSLog(@"Old AudioRoute: %@", routeStr);
        
        NSRange headphoneRange  = [routeStr rangeOfString : @"Headphone"];  //外置耳机
        NSRange headsetRange    = [routeStr rangeOfString : @"Headset"];    //外置耳机麦克风
        NSRange receiverRange   = [routeStr rangeOfString : @"Receiver"];   //手机听筒
        if (headphoneRange.location!=NSNotFound || headsetRange.location!=NSNotFound || receiverRange.location!=NSNotFound)
            return YES;
    }
    return NO;
#endif
}

//切换(扬声器/听筒)模式
- (IBAction)togglePlayVoiceDevice:(id)sender
{
//    [self hasHeadset];
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
    
    if (sender) {
        //当前是听筒模式
        if ([self hasHeadset]) {
            //设置为扬声器播放
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
            //设置为听筒图标
            [self.btn_speaker setImage:[UIImage imageNamed:@"receiver"] forState:UIControlStateNormal];
        } else {
            //设置听筒播放
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
            //设置为扬声器图标
            [self.btn_speaker setImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
        }
    } else {
        //设置为扬声器播放
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof (audioRouteOverride), &audioRouteOverride);
        //设置为听筒图标
        [self.btn_speaker setImage:[UIImage imageNamed:@"receiver"] forState:UIControlStateNormal];
    }
}

////执行发送等待队列中音频数据
//- (void)executeSendDataInQueue
//{
//    ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
//    NSLog(@"executeSendDataInQueue start");
//    do {
//        NSArray* array;
//        @synchronized(_queueLock) {
//            if (_waittingQueue.count>0) {
//                NSLog(@"=================================queue.size:%@ ===========================", @(_waittingQueue.count));
//                array = [_waittingQueue objectAtIndex:0];
//                [_waittingQueue removeObjectAtIndex:0];
//            }
//        }
//        
//        if (array) {
//            //如果第一次发送数据，延迟1000毫秒
//            if (self.firstSend) {
//                [NSThread sleepForTimeInterval:0.001];
//                self.firstSend = NO;
//            }
//            
////            [BlockUtility performBlockInGlobalQueue:^{
//            [ebKit audioSendData:(NSData*)array[0] samplingTime:[array[1] unsignedIntValue] forCallId:self.callId];
////            }];
//            
//            [NSThread sleepForTimeInterval:0.001];
//            continue;
//        }
//        
//        [NSThread sleepForTimeInterval:0.001];
//    } while (self.queueWorking);
//    NSLog(@"executeSendDataInQueue exit");
//}

- (void)aqsRecorderBufferCallbackWithAudioDataByteSize:(UInt32)audioDataByteSize inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc inStartingPacket:(SInt64)inStartingPacket inNumPackets:(UInt32)inNumPackets audioData:(const void*)audioData inStartTime:(const AudioTimeStamp *)inStartTime
{
    //录音累计时间长度
//    NSTimeInterval seconds = inStartTime->mSampleTime/16000;
    
//    NSLog(@"BufferCallBack=====start=======");
//    NSLog(@"audioDataByteSize:%@", @(audioDataByteSize));
//    
//    NSLog(@"inPacketDesc->mStartOffset:%@", @(inPacketDesc->mStartOffset));
//    NSLog(@"inPacketDesc->mVariableFramesInPacket:%@", @(inPacketDesc->mVariableFramesInPacket));
//    NSLog(@"inPacketDesc->mDataByteSize:%@", @(inPacketDesc->mDataByteSize));
//    
//    NSLog(@"inStartingPacket:%@", @(inStartingPacket));
//    
//    NSLog(@"inNumPackets:%@", @(inNumPackets));
//    
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//    NSLog(@"inStartTime:%@", [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:seconds]]);
//    NSLog(@"BufferCallBack=====end=======");
    
//    [BlockUtility performBlockInGlobalQueue:^{
    NSTimeInterval seconds = inStartTime->mSampleTime/16000;
//        @synchronized(_queueLock) {
//            [_waittingQueue addObject:@[[NSData dataWithBytes:audioData length:audioDataByteSize], @(floor(seconds*1000))]];
//        }
//        NSLog(@"added _waittingQueue.size:%@", @(_waittingQueue.count));
    static const uint32_t MinSampleTime = 10000; //由于协议要求采样时间点大于1，因此每次都加上一个固定值
    unsigned int samplingTime = floor(seconds*1000)+MinSampleTime;
//    [[ENTBoostKit sharedToolKit] audioSendData:[NSData dataWithBytes:audioData length:audioDataByteSize] samplingTime:floor(seconds*1000)+MinSampleTime forCallId:self.callId];
    
//    AudioCodecIO* acio = &(self.converter->mAcio);
//    acio->currNumPackets = 0;//CBR //inNumPackets;
//    acio->currNumBytes = audioDataByteSize;
////    acio->packetDescriptions = xxx; //PCM没有packetDescriptions
//    memcpy(acio->srcBuffer, audioData, audioDataByteSize);
//    //UInt32* outputDataPacketsPtr, AudioStreamPacketDescription** outputPacketDescriptionsPtr, UInt32 theOutputBufSize, char** outputDataPtr
//    
//    UInt32 convertedNumPackets = 0; //inNumPackets;
//    UInt32 convertedNumBytes = 0;
//    AudioStreamPacketDescription* convertedPacketDesc = new AudioStreamPacketDescription[100];
//    char* convertedAudioData = new char[audioDataByteSize];
//    self.converter->DoConvert(&convertedNumPackets, &convertedPacketDesc, audioDataByteSize, &convertedNumBytes, &convertedAudioData);
//    
////    [[ENTBoostKit sharedToolKit] audioSendData:[NSData dataWithBytes:convertedAudioData length:convertedNumBytes] samplingTime:floor(seconds*1000)+MinSampleTime forCallId:self.callId];
//    
//    delete convertedAudioData;
//    delete convertedPacketDesc;

//    NSLog(@"audioDataByteSize=%@, inNumPackets=%@", @(audioDataByteSize), @(inNumPackets));
    
    //PCM数据转编码为AAC数据
    void* convertedAudioData = malloc(sizeof(char)*1024*16); //保存转码后数据
    UInt32 convertedNumBytes = 0;   //转码后数据实际大小(字节)
    UInt32 outNumPackets = 5; //转码前表示输出缓存分包最大数量，转码后表示实际输出分包数量
    AudioStreamPacketDescription *outputPacketDescriptions = (AudioStreamPacketDescription*)malloc(sizeof(AudioStreamPacketDescription) * outNumPackets); //转码后输出的分包描述
    AudioConvert(_convertContext, (void*)audioData, audioDataByteSize, inNumPackets, &convertedAudioData, &convertedNumBytes, &outNumPackets, outputPacketDescriptions); //执行转换
    
    //网络发送每个分包
    if (convertedNumBytes>0 && outNumPackets>0) {
//        static uint32_t logCount = 0;
//        logCount++;
//            if (logCount%10 == 0)
//        NSLog(@"convertedNumBytes = %@, outNumPackets = %@, logCount = %@", @(convertedNumBytes), @(outNumPackets), @(logCount));
        
        ENTBoostKit* ebKit = [ENTBoostKit sharedToolKit];
        for (int i=0; i <outNumPackets; i++) {
            SInt64 offset = outputPacketDescriptions[i].mStartOffset;
            UInt32 dataByteSize = outputPacketDescriptions[i].mDataByteSize;
            char* srcPtr = ((char*)convertedAudioData) + offset;
            
            char bytes[dataByteSize];
            memcpy(bytes, srcPtr, dataByteSize);
            
            [ebKit audioSendData:[NSData dataWithBytes:bytes length:dataByteSize] samplingTime:samplingTime forCallId:self.callId];
            [NSThread sleepForTimeInterval:0.02]; //设置发送间隔，防止网络端口堵塞
        }
    }
    
    free(convertedAudioData);
    free(outputPacketDescriptions);
//    }];
}

///播音调取数据回调
- (void)aqsPlayerBufferCallbackWithAudioDataByteSize:(UInt32*)pAudioDataByteSize packetDescriptionCount:(UInt32*)packetDescriptionCount outAudioData:(void*)outAudioData packetDescriptions:(AudioStreamPacketDescription*)outPacketDescriptions
{
    *packetDescriptionCount = 0;
    *pAudioDataByteSize = 0;
    
    NSArray* frames = [[ENTBoostKit sharedToolKit] audioFramesInCacheWithTargetUid:self.targetUid forCallId:self.callId limit:1];
    if (frames.count>0) {
        *packetDescriptionCount = (UInt32)frames.count;
        
        UInt32 offset = 0;
        for (NSUInteger i=0; i<frames.count; i++) {
            EBRTPFrame* frame = frames[i];
            *pAudioDataByteSize += frame.totalLength;
            memcpy((char*)outAudioData+offset, [[frame filledData] bytes], frame.totalLength);
            
            outPacketDescriptions[i].mStartOffset = offset;
            outPacketDescriptions[i].mDataByteSize = frame.totalLength;
            outPacketDescriptions[i].mVariableFramesInPacket = 0;
            
            offset+=frame.totalLength;
        }
        
        static uint64_t gotTimes = 0;
        gotTimes++;
        if (gotTimes%10==0)
            NSLog(@"got frames.count = %@, gotTimes = %llu", @(frames.count), gotTimes);
    }
//    else {
//        NSLog(@"no data===");
//    }
    
//    EBRTPFrame* frame = [[ENTBoostKit sharedToolKit] audioFrameInCacheWithTargetUid:self.targetUid forCallId:self.callId];
//    if (frame) {
//        *pAudioDataByteSize = frame.totalLength;
//        *packetDescriptionCount = 1;
//        memcpy(outAudioData, [[frame filledData] bytes], frame.totalLength);
////        (*outPacketDescriptions) = (AudioStreamPacketDescription *)malloc(sizeof(AudioStreamPacketDescription));
//        outPacketDescriptions[0].mStartOffset = 0;
//        outPacketDescriptions[0].mDataByteSize = frame.totalLength;
//        outPacketDescriptions[0].mVariableFramesInPacket = 0;
//        NSLog(@"got frame, totalLength=%@", @(frame.totalLength));
//    } else {
//        NSLog(@"no data===");
//    }
}

//询问和确认
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 101) { //被邀请加入通话的确认框
        if (buttonIndex==1) { //接听
            [self ackAVRequest:1];
        }
    } else if (alertView.tag == 102) { //退出界面的确认框
        if (buttonIndex==1) {
            [self stopTalk:nil];
            [self setWorkState:AV_WORK_STATE_IDLE];
            __weak typeof(self) weakSelf = self;
            [self dismissViewControllerAnimated:YES completion:^{
                AQSViewController* safeSelf = weakSelf;
                if ([_delegate respondsToSelector:@selector(aqsViewController:exitWithWorkState:)])
                    [_delegate aqsViewController:safeSelf exitWithWorkState:_workState];
            }];
        }
    }
}

//响应通话邀请
- (void)ackAVRequest:(int)ackType
{
    __weak typeof(self) safeSelf = self;
    [[ENTBoostKit sharedToolKit] avAckWithCallId:self.callId toUid:self.targetUid ackType:ackType onCompletion:^{
        NSLog(@"回应通话邀请成功，callId = %llu, targetUid = %llu, ackType =%i", safeSelf.callId, safeSelf.targetUid, ackType);
        [BlockUtility performBlockInMainQueue:^{
            if (ackType==1) {
                [safeSelf setWorkState:AV_WORK_STATE_CONNECTED];
                [safeSelf startAV];
//                [safeSelf prepareStartAudio];
//                [safeSelf performSelector:@selector(startAV) withObject:nil afterDelay:1.0]; //推迟1秒
            }
        }];
    } onFailure:^(NSError *error) {
        NSLog(@"回应通话邀请失败，callId = %llu, targetUid = %llu, ackType =%i, code = %@, msg = %@", safeSelf.callId, safeSelf.targetUid, ackType, @(error.code), error.localizedDescription);
    }];
    
    if (ackType==2) {
        [self setWorkState:AV_WORK_STATE_REJECTED];
    }

}

//接受通话邀请
- (IBAction)acceptAVRequest:(id)sender
{
    Reachability* rby = [Reachability reachabilityForInternetConnection];
    if ([rby isReachableViaWWAN]) {
        [[PublicUI sharedInstance] showAlertViewWithTag:101 title:@"真的要接听通话吗？" message:@"设备当前使用3G/4G网络，接听通话将会使用比较多的流量，请留意！" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"接听"];
    } else
        [self ackAVRequest:1];
}

//拒绝通话邀请
- (IBAction)rejectAVRequest:(id)sender
{
    [self ackAVRequest:2];
}

#pragma mark - 事件处理

- (void)handleAVRequest:(uint64_t)fromUid includeVideo:(BOOL)includeVideo
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        safeSelf.targetUid = fromUid;
        [safeSelf setWorkState:AV_WORK_STATE_INCOMING];
    }];
}

- (void)handleAVAccept:(uint64_t)fromUid
{
    __weak typeof(self) safeSelf = self;
    self.targetUid = fromUid;
    [BlockUtility performBlockInMainQueue:^{
        safeSelf.targetUid = fromUid;
        
        [safeSelf setWorkState:AV_WORK_STATE_CONNECTED];
        [safeSelf startAV];
//        [safeSelf prepareStartAudio];
//        [safeSelf performSelector:@selector(startAV) withObject:nil afterDelay:1.0]; //推迟1秒
    }];
}

//处理监听触发事件

-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES) {
        NSLog(@"Device is close to user");
        //设置听筒播放
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        //设置为扬声器图标
        [self.btn_speaker setImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        NSLog(@"Device is not close to user");
        //设置为扬声器播放
        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
        //设置为听筒图标
        [self.btn_speaker setImage:[UIImage imageNamed:@"receiver"] forState:UIControlStateNormal];
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}

- (void)startAV
{
    [self prepareStartAudio];
    [self record:YES]; //开始录音
    [self replay]; //开始播音
    
    //设置免提图标
    if (!self.btn_speaker.hidden) {
        [self togglePlayVoiceDevice:nil];
    }
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES]; //开启红外感应
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:UIDeviceProximityStateDidChangeNotification object:nil]; //添加近距离事件监听
}

- (void)stopAV
{
//    if (self.recorder->IsRunning())
    [self stopRecord]; //停止录音
//    if (self.player->IsRunning())
    [self stopPlay]; //停止播音
    [self followStopAudio];
    
    //删除近距离事件监听
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

- (void)handleAVReject:(uint64_t)fromUid
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
//        safeSelf.stateLabel.text = @"对方拒绝通话";
        [safeSelf setWorkState:AV_WORK_STATE_REJECTED];
    }];
}

- (void)handleAVTimeout:(uint64_t)fromUid
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        [safeSelf setWorkState:AV_WORK_STATE_TIMEOUT];
    }];
}

- (void)handleAVClose:(uint64_t)fromUid
{
    __weak typeof(self) safeSelf = self;
    [BlockUtility performBlockInMainQueue:^{
        [safeSelf setWorkState:AV_WORK_STATE_HANGUP];
        [safeSelf stopAV];
    }];
}

- (void)handleAVRecevieFirstFrame
{
//    __weak typeof(self) safeSelf = self;
//    [BlockUtility performBlockInMainQueue:^{
//        NSLog(@"start player-----------------");
//        [safeSelf replay];
//    }];
}

#pragma mark - AudioSession listeners
void interruptionListener(void *	inClientData,
                          UInt32	inInterruptionState)
{
//    AQSViewController *THIS = (__bridge AQSViewController*)inClientData;
//    if (inInterruptionState == kAudioSessionBeginInterruption) {
//        if (THIS.recorder->IsRunning()) {
//            [THIS stopRecord];
//        }
//        else if (THIS.player->IsRunning()) {
//            //the queue will stop itself on an interruption, we just need to update the UI
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
//            THIS.playbackWasInterrupted = YES;
//        }
//    } else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS.playbackWasInterrupted) {
//        // we were playing back when we were interrupted, so reset and resume now
//        THIS.player->StartQueue();
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
//        THIS.playbackWasInterrupted = NO;
//    }
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
    AQSViewController *THIS = (__bridge AQSViewController*)inClientData;
    if (inID == kAudioSessionProperty_AudioRouteChange) {
        CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
        //CFShow(routeDictionary);
        CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
        SInt32 reasonVal;
        CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
        if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange) {
            CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
             if (oldRoute)
                 NSLog(@"old route:%@", (__bridge NSString*)oldRoute);
             else
                 NSLog(@"ERROR GETTING OLD AUDIO ROUTE!");
             
             CFStringRef newRoute;
             UInt32 size; size = sizeof(CFStringRef);
             OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
            NSString* newRouteStr = (__bridge NSString*)newRoute;
             if (error)
                 NSLog(@"ERROR GETTING NEW AUDIO ROUTE! %@", @(error));
             else
                 NSLog(@"new route:%@", newRouteStr);
            
            NSRange newRouteRange = [newRouteStr rangeOfString:@"Speaker"];
            if (newRouteRange.location==NSNotFound) {
                //设置为扬声器图标
                [THIS->_btn_speaker setImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
            }
            
//            if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable) { //待定
//                if (THIS.player->IsRunning()) {
//                    [THIS pausePlayQueue];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
//                }
//            }
//            
//            // stop the queue if we had a non-policy route change
//            if (THIS.recorder->IsRunning()) {
//                [THIS stopRecord];
//            }
        }
    } else if (inID == kAudioSessionProperty_AudioInputAvailable) {//没用？待定
        if (inDataSize == sizeof(UInt32)) {
//            UInt32 isAvailable = *(UInt32*)inData;
            // disable recording if input is not available
//            THIS.btn_record.enabled = (isAvailable > 0) ? YES : NO;
//            THIS.btn_request.enabled = (isAvailable > 0) ? YES : NO;
        }
    }
}

# pragma mark - Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
//    [self.btn_replay setTitle:@"开始播音" forState:UIControlStateNormal];
//    self.btn_record.enabled = YES;
}

- (void)playbackQueueResumed:(NSNotification *)note
{
//    [self.btn_replay setTitle:@"停止播音" forState:UIControlStateNormal];
//    self.btn_record.enabled = NO;
}

@end

/*
 
    File: AQPlayer.mm
Abstract: n/a
 Version: 2.4

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.

 
*/


#include "AQPlayer.h"
#import "AQSViewController.h"

void AQPlayer::GetAudioData(void *      inUserData,
                            UInt32*     numBytes,
                            UInt32*		nPackets,
                            AudioQueueRef			inAQ,
                            AudioQueueBufferRef		inCompleteAQBuffer,
                            Boolean recursive,
                            UInt16* tryTimes)
{
    AQPlayer *THIS = (AQPlayer *)inUserData;

    [THIS->aqsController aqsPlayerBufferCallbackWithAudioDataByteSize:numBytes packetDescriptionCount:nPackets outAudioData:inCompleteAQBuffer->mAudioData packetDescriptions:inCompleteAQBuffer->mPacketDescriptions];
    if (*nPackets >0) {
        if (THIS->mIsMute) {
            THIS->mIsMute = false;
            if ([NSDate timeIntervalSinceReferenceDate] - THIS->muteTimeStamp > 0.2/*0.1*/) {
                NSLog(@"!!!!!!!!!!!!!!!!!!!!!!clear buffer!!!!!!!!!!!!!!!!!!!!!");
                AudioQueueReset(THIS->mQueue);
            }
        }
        
//        static uint32_t logCount = 0;
//        logCount++;
//        if (logCount%100==0)
//            NSLog(@"nPackets = %@, numBytes = %@\n", @(*nPackets), @(*numBytes));
        
        inCompleteAQBuffer->mAudioDataByteSize = *numBytes;
        inCompleteAQBuffer->mPacketDescriptionCount = *nPackets;
        AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, *nPackets, inCompleteAQBuffer->mPacketDescriptions);
    } else if (recursive && !THIS->mIsMute && *tryTimes<15) { //递归再尝试获取数据
        (*tryTimes)++;
        [NSThread sleepForTimeInterval:0.01]; //休眠
        THIS->GetAudioData(inUserData, numBytes, nPackets, inAQ, inCompleteAQBuffer, YES, tryTimes);
    } else {
        if (!THIS->mIsMute) {
            THIS->muteTimeStamp = [NSDate timeIntervalSinceReferenceDate];
            THIS->mIsMute = true;
            NSLog(@"=================set mute===============");
        }
        
        //构造静音数据
        //        static unsigned char mute[] ={0,180,157,252,59,98,9,143,253,0,43,114,96,150,10,34,102,112,20,182,130,8,144,228,76,192,26,5,33,17,16,109,39,40,191,161,11,130,177,89,27,176,75,171,118,33,64,2,134,0,172,64,201,12,110,117,33,8,5,49,24,75,5,0,34,120,51,144,12,17,0,116,65,86,212,21,162,64,104,141,127};
        
        static unsigned char mute[] ={0,180,155,252,10,144,237,79,252,0,5,189,158,249,152,144,0,0,0,6,183,189,84,195,93,157,221,43,237,190,26,142,157,215,42,233,239,187,250,157,156};
        //        static unsigned char mute[] ={1,24,85,28,40,50,10,8,136,129,32,152,72,162,50,8,145,66,129,32,137,12,66,21,11,132,194,161,16,153,172,153,117,198,83,219,125,241,89,212,172,235,196,87,58,133,226,251,107,95,113,222,201,102,128,248,0,6,128,49,127,217,141,127,171,195,252,188,190,113,175,15,15,182,176,0,81,254,223,111,80,88,248,125,190,223,98,170,53,15,47,159,207,176,37,200,151,200,151,226,59,62,102,228,90,159,211,113,253,32,42,219,152,41,122,249,105,185,131,224,4,127,231,159,127,153,164,183,176,8,179,255,141,4,118,253,195,62,138,127,72,7,207,238,13,191,209,160,232,28,63,249,254,174,0,103,143,222,31,112,96,41,253,51,37,16,5,111,123,222,247,189,138,222,229,215,246,255,143,241,200,192,107,245,127,31,223,248,122,114,185,0,0,14,159,143,160,114,27,142,71,167,253,255,46,134,247,185,0,0,0,168,76,0,224};
        
        UInt32 n = sizeof(mute);
        UInt32 count = 4;
        inCompleteAQBuffer->mAudioDataByteSize = n*count;
        inCompleteAQBuffer->mPacketDescriptionCount = count;
        
        unsigned char* adata = (unsigned char*)inCompleteAQBuffer->mAudioData;
        for (int i=0; i <count; i++) {
            memcpy(adata + n*i, mute, n);
            
            inCompleteAQBuffer->mPacketDescriptions[i].mStartOffset = i*n;
            inCompleteAQBuffer->mPacketDescriptions[i].mDataByteSize = n;
            inCompleteAQBuffer->mPacketDescriptions[i].mVariableFramesInPacket = 0;
        }
        //        printf("%d", inCompleteAQBuffer->mPacketDescriptions[0].mDataByteSize);
        
        AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, inCompleteAQBuffer->mPacketDescriptionCount, inCompleteAQBuffer->mPacketDescriptions);
    }
}

void AQPlayer::AQBufferCallback(void *					inUserData,
								AudioQueueRef			inAQ,
								AudioQueueBufferRef		inCompleteAQBuffer) 
{
	AQPlayer *THIS = (AQPlayer *)inUserData;

	if (THIS->mIsDone) return;

	UInt32 numBytes = 0;
    UInt32 nPackets = 0;
    UInt16 nTryTimes = 0;
//    UInt32 nPackets = THIS->GetNumPacketsToRead();
//	OSStatus result = AudioFileReadPackets(THIS->GetAudioFileID(), false, &numBytes, inCompleteAQBuffer->mPacketDescriptions, THIS->GetCurrentPacket(), &nPackets,
//										   inCompleteAQBuffer->mAudioData);
    
//    [THIS->aqsController aqsPlayerBufferCallbackWithAudioDataByteSize:&numBytes packetDescriptionCount:&nPackets outAudioData:inCompleteAQBuffer->mAudioData packetDescriptions:inCompleteAQBuffer->mPacketDescriptions];
    
    //        unsigned char * audioData = (unsigned char *)inCompleteAQBuffer->mAudioData;
    //        for (int i=0; i<nPackets; i++) {
    //            AudioStreamPacketDescription aspd = inCompleteAQBuffer->mPacketDescriptions[i];
    //            for (int j=0; j<aspd.mDataByteSize;j++) {
    //                printf("%d,", audioData[aspd.mStartOffset+j]);
    //            }
    //            printf("====\n");
    //        }
    
//    NSLog(@"%d", [NSThread isMainThread]);
    
    THIS->GetAudioData(inUserData, &numBytes, &nPackets, inAQ, inCompleteAQBuffer, YES, &nTryTimes);
    

//    else {
//        inCompleteAQBuffer->mAudioDataByteSize = 1024;
//        inCompleteAQBuffer->mPacketDescriptionCount = 1;
//        memset(inCompleteAQBuffer->mAudioData, 0, inCompleteAQBuffer->mAudioDataByteSize);
//        AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
////        THIS->mCurrentPacket = (THIS->GetCurrentPacket() + 9);
//    }
    
//	if (result)
//		NSLog(@"AudioFileReadPackets failed: %@", @(result));
//	if (nPackets > 0) {
//		inCompleteAQBuffer->mAudioDataByteSize = numBytes;		
//		inCompleteAQBuffer->mPacketDescriptionCount = nPackets;		
//		AudioQueueEnqueueBuffer(inAQ, inCompleteAQBuffer, 0, NULL);
//		THIS->mCurrentPacket = (THIS->GetCurrentPacket() + nPackets);
//	} else {
//		if (THIS->IsLooping()) {
//			THIS->mCurrentPacket = 0;
//			AQBufferCallback(inUserData, inAQ, inCompleteAQBuffer);
//		} else {
//			// stop
//			THIS->mIsDone = true;
//			AudioQueueStop(inAQ, false);
//		}
//	}
}

void AQPlayer::isRunningProc (  void *              inUserData,
								AudioQueueRef           inAQ,
								AudioQueuePropertyID    inID)
{
	AQPlayer *THIS = (AQPlayer *)inUserData;
	UInt32 size = sizeof(THIS->mIsRunning);
	OSStatus result = AudioQueueGetProperty (inAQ, kAudioQueueProperty_IsRunning, &THIS->mIsRunning, &size);
	
	if ((result == noErr) && (!THIS->mIsRunning))
		[[NSNotificationCenter defaultCenter] postNotificationName: @"playbackQueueStopped" object: nil];
}

//void AQPlayer::CalculateBytesForTime (CAStreamBasicDescription & inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets)
//{
//	// we only use time here as a guideline
//	// we're really trying to get somewhere between 16K and 64K buffers, but not allocate too much if we don't need it
//	static const int maxBufferSize = 0x10000; // limit size to 64K
//	static const int minBufferSize = 0x4000; // limit size to 16K
//	
//	if (inDesc.mFramesPerPacket) {
//		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
//		*outBufferSize = numPacketsForTime * inMaxPacketSize;
//	} else {
//		// if frames per packet is zero, then the codec has no predictable packet == time
//		// so we can't tailor this (we don't know how many Packets represent a time period
//		// we'll just return a default buffer size
//		*outBufferSize = maxBufferSize > inMaxPacketSize ? maxBufferSize : inMaxPacketSize;
//	}
//	
//	// we're going to limit our size to our default
//	if (*outBufferSize > maxBufferSize && *outBufferSize > inMaxPacketSize)
//		*outBufferSize = maxBufferSize;
//	else {
//		// also make sure we're not too small - we don't want to go the disk for too small chunks
//		if (*outBufferSize < minBufferSize)
//			*outBufferSize = minBufferSize;
//	}
//	*outNumPackets = *outBufferSize / inMaxPacketSize;
//}

AQPlayer::AQPlayer() :
	mQueue(0),
//	mAudioFile(0),
//	mFilePath(NULL),
	mIsRunning(false),
	mIsInitialized(false),
//	mNumPacketsToRead(0),
//	mCurrentPacket(0),
	mIsDone(false),
	mIsLooping(false),
    mIsMute(false),
    muteTimeStamp(0) { }

AQPlayer::~AQPlayer() 
{
	DisposeQueue();
}

OSStatus AQPlayer::StartQueue(/*BOOL inResume*/)
{
//    mFilePath = (__bridge CFStringRef)[NSString stringWithFormat:@"%@", @"/Users/zhongzf/Documents/abc.aac"];
//    mFilePath = (__bridge CFStringRef)[NSString stringWithFormat:@"%@/head.aac", [[NSBundle mainBundle] resourcePath]];
    
	// if we have a file but no queue, create one now
//	if ((mQueue == NULL) && (mFilePath != NULL))
//		CreateQueueForFile(mFilePath);
    if (mQueue == NULL) {
        SetupAudioFormat(kAudioFormatMPEG4AAC);
        SetupNewQueue();
    }
        
	mIsDone = false;
	
	// if we are not resuming, we also should restart the file read index
//	if (!inResume)
//		mCurrentPacket = 0;	

	// prime the queue with some data before starting
	for (int i = 0; i < kNumberBuffers; ++i) {
        UInt32 numBytes = 0;
        UInt32 nPackets = 0;
        UInt16 nTryTimes = 0;
        this->GetAudioData(this, &numBytes, &nPackets, mQueue, mBuffers[i], NO, &nTryTimes);
//		AQBufferCallback (this, mQueue, mBuffers[i]);
	}
	return AudioQueueStart(mQueue, NULL);
}

OSStatus AQPlayer::StopQueue()
{
    OSStatus result = noErr;
    try {
        result = AudioQueueStop(mQueue, true);
        if (result)
            printf("error stop queue!\n");
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

	return result;
}

OSStatus AQPlayer::PauseQueue()
{
	OSStatus result = noErr;
    try {
        result = AudioQueuePause(mQueue);
        if (result)
            printf("error stop queue!\n");
    } catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
    
	return result;
}

//void AQPlayer::CreateQueueForFile(CFStringRef inFilePath) 
//{	
//	CFURLRef sndFile = NULL; 
//
//	try {					
//		if (mFilePath == NULL) {
//			mIsLooping = false;
//			
//			sndFile = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, inFilePath, kCFURLPOSIXPathStyle, false);
//			if (!sndFile) { printf("can't parse file path\n"); return; }
//			
//			XThrowIfError(AudioFileOpenURL (sndFile, kAudioFileReadPermission, 0/*inFileTypeHint*/, &mAudioFile), "can't open file");
//		
////			UInt32 size = sizeof(mDataFormat);
////			XThrowIfError(AudioFileGetProperty(mAudioFile, 
////										   kAudioFilePropertyDataFormat, &size, &mDataFormat), "couldn't get file's data format");
//			mFilePath = CFStringCreateCopy(kCFAllocatorDefault, inFilePath);
//        } else {
//            sndFile = (__bridge CFURLRef)[NSURL URLWithString:(__bridge NSString*)mFilePath];
//            
//            XThrowIfError(AudioFileOpenURL (sndFile, kAudioFileReadPermission, 0/*inFileTypeHint*/, &mAudioFile), "can't open file");
//            
////            UInt32 size = sizeof(mDataFormat);
////            XThrowIfError(AudioFileGetProperty(mAudioFile,
////                                               kAudioFilePropertyDataFormat, &size, &mDataFormat), "couldn't get file's data format");
//        }
//		SetupNewQueue();		
//	}
//	catch (CAXException e) {
//		char buf[256];
//		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//	}
//	if (sndFile)
//		CFRelease(sndFile);
//}

void AQPlayer::SetupAudioFormat(UInt32 inFormatID)
{
    memset(&mDataFormat, 0, sizeof(mDataFormat));
    mDataFormat.mFormatID = inFormatID;
    
    if (inFormatID == kAudioFormatLinearPCM) {
//        mDataFormat.mSampleRate = 16000.0;
//        mDataFormat.mBitsPerChannel = 16;
//        mDataFormat.mChannelsPerFrame = 1;
//        mDataFormat.mFramesPerPacket = 1;
//        mDataFormat.mBytesPerFrame = (mDataFormat.mBitsPerChannel / 8) * mDataFormat.mChannelsPerFrame;
//        mDataFormat.mBytesPerPacket = mDataFormat.mBytesPerFrame * mDataFormat.mFramesPerPacket;
//        mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    } else if (inFormatID == kAudioFormatMPEG4AAC /*1633772320*/) {
        mDataFormat.mSampleRate = 16000;
        mDataFormat.mChannelsPerFrame = 1;
        mDataFormat.mFramesPerPacket = 1024;
    }
}

void AQPlayer::SetupNewQueue()
{
	XThrowIfError(AudioQueueNewOutput(&mDataFormat, AQPlayer::AQBufferCallback, this, 
										NULL/*CFRunLoopGetCurrent()*/, kCFRunLoopCommonModes, 0, &mQueue), "AudioQueueNew failed");
    UInt32 numPacketsToRead = 64;
    UInt32 bufferByteSize = 1024*numPacketsToRead;
    
//    mNumPacketsToRead = 16;
//    UInt32 bufferByteSize;
	// we need to calculate how many packets we read at a time, and how big a buffer we need
	// we base this on the size of the packets in the file and an approximate duration for each buffer
	// first check to see what the max size of a packet is - if it is bigger
	// than our allocation default size, that needs to become larger
//	UInt32 maxPacketSize;
//	UInt32 size = sizeof(maxPacketSize);
//	XThrowIfError(AudioFileGetProperty(mAudioFile,
//									   kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize), "couldn't get file's max packet size");
	
	// adjust buffer size to represent about a half second of audio based on this format
//	CalculateBytesForTime (mDataFormat, maxPacketSize, kBufferDurationSeconds, &bufferByteSize, &mNumPacketsToRead);

		//printf ("Buffer Byte Size: %d, Num Packets to Read: %d\n", (int)bufferByteSize, (int)mNumPacketsToRead);
	
	// (2) If the file has a cookie, we should get it and set it on the AQ
//	UInt32 size = sizeof(UInt32);
//	OSStatus result = AudioFileGetPropertyInfo (mAudioFile, kAudioFilePropertyMagicCookieData, &size, NULL);
//	
//	if (!result && size) {
//		unsigned char* cookie = new unsigned char [size];
//		XThrowIfError (AudioFileGetProperty (mAudioFile, kAudioFilePropertyMagicCookieData, &size, cookie), "get cookie from file");
//        for(int i=0; i<size; i++) {
//            printf("%d,", cookie[i]);
//        }
//		XThrowIfError (AudioQueueSetProperty(mQueue, kAudioQueueProperty_MagicCookie, cookie, size), "set cookie on queue");
//		delete [] cookie;
//	}
    UInt32 size = 39;
    unsigned char cookie[] = {3,128,128,128,34,0,0,0,4,128,128,128,20,64,21,0,24,0,0,0,0,0,0,0,0,0,5,128,128,128,2,20,8,6,128,128,128,1,2};
    XThrowIfError (AudioQueueSetProperty(mQueue, kAudioQueueProperty_MagicCookie, cookie, size), "set cookie on queue");
    
	// channel layout?
//	OSStatus result = AudioFileGetPropertyInfo(mAudioFile, kAudioFilePropertyChannelLayout, &size, NULL);
//	if (result == noErr && size > 0) {
//		AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
//		XThrowIfError(AudioFileGetProperty(mAudioFile, kAudioFilePropertyChannelLayout, &size, acl), "get audio file's channel layout");
//		XThrowIfError(AudioQueueSetProperty(mQueue, kAudioQueueProperty_ChannelLayout, acl, size), "set channel layout on queue");
//		free(acl);
//	}
    size = sizeof(AudioChannelLayout);
    AudioChannelLayout *acl = (AudioChannelLayout *)malloc(size);
    memset(acl, 0, size);
    acl->mChannelLayoutTag = kAudioChannelLayoutTag_Mono;// 6553601;
    XThrowIfError(AudioQueueSetProperty(mQueue, kAudioQueueProperty_ChannelLayout, acl, size), "set channel layout on queue");
    
	//property listener
	XThrowIfError(AudioQueueAddPropertyListener(mQueue, kAudioQueueProperty_IsRunning, isRunningProc, this), "adding property listener");
	
    //allocate buffer
	bool isFormatVBR = (mDataFormat.mBytesPerPacket == 0 || mDataFormat.mFramesPerPacket == 0);
	for (int i = 0; i < kNumberBuffers; ++i) {
		XThrowIfError(AudioQueueAllocateBufferWithPacketDescriptions(mQueue, bufferByteSize, (isFormatVBR ? numPacketsToRead/*mNumPacketsToRead*/ : 0), &mBuffers[i]), "AudioQueueAllocateBuffer failed");
	}	

	// set the volume of the queue
	XThrowIfError (AudioQueueSetParameter(mQueue, kAudioQueueParam_Volume, 1.0), "set queue volume");
	
	mIsInitialized = true;
}

void AQPlayer::DisposeQueue(/*Boolean inDisposeFile*/)
{
	if (mQueue) {
        try {
            OSStatus result = AudioQueueDispose(mQueue, true);
            if (result)
                printf("error dispose queue!\n");
        } catch (CAXException e) {
            char buf[256];
            fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        }
        
//		AudioQueueDispose(mQueue, true);
		mQueue = NULL;
	}
//	if (inDisposeFile) {
////		if (mAudioFile) {
////			AudioFileClose(mAudioFile);
////			mAudioFile = 0;
////		}
////		if (mFilePath) {
////			CFRelease(mFilePath);
////			mFilePath = NULL;
////		}
//	}
	mIsInitialized = false;
}
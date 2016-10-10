/*
 
    File: AQRecorder.mm
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

#include "AQRecorder.h"
#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AQSViewController.h"
#import "BlockUtility.h"

// ____________________________________________________________________________________
// Determine the size, in bytes, of a buffer necessary to represent the supplied number
// of seconds of audio data.
int AQRecorder::ComputeRecordBufferSize(const AudioStreamBasicDescription *format, float seconds)
{
	int packets = 0, frames = 0, bytes = 0;
	try {
		frames = (int)ceil(seconds * format->mSampleRate);
		
		if (format->mBytesPerFrame > 0)
			bytes = frames * format->mBytesPerFrame;
		else {
			UInt32 maxPacketSize;
			if (format->mBytesPerPacket > 0)
				maxPacketSize = format->mBytesPerPacket;	// constant packet size
			else {
				UInt32 propertySize = sizeof(maxPacketSize);
				XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
												 &propertySize), "couldn't get queue's maximum output packet size");
			}
			if (format->mFramesPerPacket > 0)
				packets = frames / format->mFramesPerPacket;
			else
				packets = frames;	// worst-case scenario: 1 frame in a packet
			if (packets == 0)		// sanity check
				packets = 1;
			bytes = packets * maxPacketSize;
		}
	} catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
		return 0;
	}	
	return bytes;
}

// ____________________________________________________________________________________
// AudioQueue callback function, called when an input buffers has been filled.
void AQRecorder::MyInputBufferHandler(	void *								inUserData,
										AudioQueueRef						inAQ,
										AudioQueueBufferRef					inBuffer,
										const AudioTimeStamp *				inStartTime,
										UInt32								inNumPackets,
										const AudioStreamPacketDescription*	inPacketDesc)
{
	AQRecorder *aqr = (AQRecorder *)inUserData;
    
//    NSLog(@"input buffer size:%@", @(inNumPackets));
    
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    
//	try {
//		if (inNumPackets > 0) {
////			// write packets to file
////			XThrowIfError(AudioFileWritePackets(aqr->mRecordFile, FALSE, inBuffer->mAudioDataByteSize,
////											 inPacketDesc, aqr->mRecordPacket, &inNumPackets, inBuffer->mAudioData),
////					   "AudioFileWritePackets failed");
//			aqr->mRecordPacket += inNumPackets;
//            
            //回调上层
            [aqr->aqsController aqsRecorderBufferCallbackWithAudioDataByteSize:inBuffer->mAudioDataByteSize inPacketDesc:inPacketDesc inStartingPacket:0/*aqr->mRecordPacket*/ inNumPackets:inNumPackets audioData:inBuffer->mAudioData inStartTime:inStartTime];
//		}
//		
//		// if we're not stopping, re-enqueue the buffe so that it gets filled again
//		if (aqr->IsRunning())
//			XThrowIfError(AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL), "AudioQueueEnqueueBuffer failed");
//	} catch (CAXException e) {
//		char buf[256];
//		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//	}
}

AQRecorder::AQRecorder()
{
	mIsRunning = false;
//	mRecordPacket = 0;
    mFileName = NULL;
    
    mRecorderOperationQueue = dispatch_queue_create("com.entboost.recorderQueue", NULL);
    mThreadRunLoop = NULL;
}

AQRecorder::~AQRecorder()
{
	AudioQueueDispose(mQueue, TRUE);
	AudioFileClose(mRecordFile);
	if (mFileName) CFRelease(mFileName);
}

// ____________________________________________________________________________________
// Copy a queue's encoder's magic cookie to an audio file.
void AQRecorder::CopyEncoderCookieToFile()
{
	UInt32 propertySize;
	// get the magic cookie, if any, from the converter		
	OSStatus err = AudioQueueGetPropertySize(mQueue, kAudioQueueProperty_MagicCookie, &propertySize);
	
	// we can get a noErr result and also a propertySize == 0
	// -- if the file format does support magic cookies, but this file doesn't have one.
	if (err == noErr && propertySize > 0) {
		Byte *magicCookie = new Byte[propertySize];
		UInt32 magicCookieSize;
		XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_MagicCookie, magicCookie, &propertySize), "get audio converter's magic cookie");
		magicCookieSize = propertySize;	// the converter lies and tell us the wrong size
		
		// now set the magic cookie on the output file
		UInt32 willEatTheCookie = false;
		// the converter wants to give us one; will the file take it?
		err = AudioFileGetPropertyInfo(mRecordFile, kAudioFilePropertyMagicCookieData, NULL, &willEatTheCookie);
		if (err == noErr && willEatTheCookie) {
			err = AudioFileSetProperty(mRecordFile, kAudioFilePropertyMagicCookieData, magicCookieSize, magicCookie);
			XThrowIfError(err, "set audio file's magic cookie");
		}
		delete[] magicCookie;
	}
}

void AQRecorder::SetupAudioFormat(UInt32 inFormatID)
{
	memset(&mRecordFormat, 0, sizeof(mRecordFormat));

	UInt32 size = sizeof(mRecordFormat.mSampleRate);
	XThrowIfError(AudioSessionGetProperty(	kAudioSessionProperty_CurrentHardwareSampleRate,
										&size, 
										&mRecordFormat.mSampleRate), "couldn't get hardware sample rate");

	size = sizeof(mRecordFormat.mChannelsPerFrame);
	XThrowIfError(AudioSessionGetProperty(	kAudioSessionProperty_CurrentHardwareInputNumberChannels, 
										&size, 
										&mRecordFormat.mChannelsPerFrame), "couldn't get input channel count");
			
	mRecordFormat.mFormatID = inFormatID;
	if (inFormatID == kAudioFormatLinearPCM) {
        mRecordFormat.mSampleRate = 16000.0;
		mRecordFormat.mBitsPerChannel = 16;
        mRecordFormat.mChannelsPerFrame = 1;
		mRecordFormat.mFramesPerPacket = 1;
        mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
		mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame * mRecordFormat.mFramesPerPacket;
        mRecordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    } else if (inFormatID == kAudioFormatMPEG4AAC) {
        mRecordFormat.mSampleRate = 16000.0;
//        mRecordFormat.mBitsPerChannel = 16;
        mRecordFormat.mChannelsPerFrame = 1;
//        mRecordFormat.mFramesPerPacket = 1;
//        mRecordFormat.mBytesPerFrame = (mRecordFormat.mBitsPerChannel / 8) * mRecordFormat.mChannelsPerFrame;
//        mRecordFormat.mBytesPerPacket = mRecordFormat.mBytesPerFrame * mRecordFormat.mFramesPerPacket;
//        mRecordFormat.mFormatFlags = 0;
    }
    
    
//    AudioClassDescription requestedCodecs[2] = {
//        {
//            kAudioEncoderComponentType,
//            kAudioFormatMPEG4AAC, //kAudioFormatAAC,
//            kAppleHardwareAudioCodecManufacturer
//        },
//        {
//            kAudioDecoderComponentType,
//            kAudioFormatMPEG4AAC, //kAudioFormatAAC,
//            kAppleHardwareAudioCodecManufacturer
//        }
//    };

    
//    UInt32 successfulCodecs = 0;
//    size = sizeof (successfulCodecs);
////    AudioFormatGetProperty
//    OSStatus result = AudioFormatGetProperty (
//                                                kAudioFormatProperty_Encoders, //kAudioFormatProperty_HardwareCodecCapabilities,
//                                                requestedCodecs,
//                                                sizeof(requestedCodecs),
//                                                &size,
//                                                &successfulCodecs
//                                                );
//    switch (successfulCodecs) {
//        case 0:
//            // aac hardware encoder is unavailable. aac hardware decoder availability
//            // is unknown; could ask again for only aac hardware decoding
//        case 1:
//            // aac hardware encoder is available but, while using it, no hardware
//            // decoder is available.
//        case 2:
//            // hardware encoder and decoder are available simultaneously
//            break;
//    }
}

void AQRecorder::StartRecord(/*CFStringRef inRecordFile*/)
{
//	UInt32 size;
//	CFURLRef url;
	
	try {		
//		mFileName = CFStringCreateCopy(kCFAllocatorDefault, inRecordFile);

		// specify the recording format
		SetupAudioFormat(kAudioFormatLinearPCM); //kAudioFormatMPEG4AAC
        
        __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        dispatch_barrier_async(mRecorderOperationQueue, ^{
            mIsRunning = true;
            [BlockUtility performBlockInGlobalQueue:^{
                mThreadRunLoop = CFRunLoopGetCurrent();
                // create the queue
                 OSStatus osStatus = AudioQueueNewInput(
                                                  &mRecordFormat,
                                                  MyInputBufferHandler,
                                                  this,
                                                  mThreadRunLoop, //NULL
                                                  kCFRunLoopDefaultMode, //kCFRunLoopCommonModes,
                                                  0,
                                                  &mQueue);

                //        kAudioFormatUnsupportedDataFormatError
                //        NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                //                                             code:osStatus
                //                                         userInfo:nil];
                //        NSLog(@"Error: %@", [error description]);
                
                XThrowIfError(osStatus, "AudioQueueNewInput failed");
                
                // get the record format back from the queue's audio converter --
                // the file may require a more specific stream description than was necessary to create the encoder.
                //		mRecordPacket = 0;
                
                //		size = sizeof(mRecordFormat);
                //		XThrowIfError(AudioQueueGetProperty(mQueue, kAudioQueueProperty_StreamDescription,
                //										 &mRecordFormat, &size), "couldn't get queue's format");
                
                //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                //        NSString* documentDirectory = [paths objectAtIndex:0];
                ////        NSTemporaryDirectory()
                //		NSString *recordFile = [documentDirectory stringByAppendingPathComponent: (__bridge NSString*)inRecordFile];
                //
                //		url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)recordFile, NULL);
                //
                //		// create the audio file
                //		XThrowIfError(AudioFileCreateWithURL(url, kAudioFileAAC_ADTSType, &mRecordFormat, kAudioFileFlags_EraseFile,
                //										  &mRecordFile), "AudioFileCreateWithURL failed");
                //		CFRelease(url);
                //
                //		// copy the cookie first to give the file object as much info as we can about the data going in
                //		// not necessary for pcm, but required for some compressed audio
                //		CopyEncoderCookieToFile();
                
                int i, bufferByteSize;
                
                // allocate and enqueue buffers
                bufferByteSize = ComputeRecordBufferSize(&mRecordFormat, kBufferDurationSeconds);	// enough bytes for half a second
                
                //        int maxPacketSize = 0;
                //        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
                //        AudioQueueGetProperty (mQueue, kAudioQueueProperty_MaximumOutputPacketSize,
                //                               &maxPacketSize, &maxVBRPacketSize );
                //
                //        bufferByteSize = 1024*4;
                for (i = 0; i < kNumberRecordBuffers; ++i) {
                    XThrowIfError(AudioQueueAllocateBuffer(mQueue, bufferByteSize, &mBuffers[i]), "AudioQueueAllocateBuffer failed");
                    XThrowIfError(AudioQueueEnqueueBuffer(mQueue, mBuffers[i], 0, NULL), "AudioQueueEnqueueBuffer failed");
                }
                // start the queue
                osStatus = AudioQueueStart(mQueue, NULL);
                XThrowIfError(osStatus, "AudioQueueStart failed");
                
                dispatch_semaphore_signal(sem);
                
    //            BOOL isRunLoopRunning = NO;
    //            do {
    //                isRunLoopRunning = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    //                NSLog(@"isRunLoopRunning = %@, this->IsRunning()=%@", @(isRunLoopRunning), @(this->IsRunning()));
    //            } while (isRunLoopRunning && this->IsRunning());
                CFRunLoopRun();
                NSLog(@"AQRecorder runloop exit");
            }];
        });
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
	} catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	} catch (...) {
		fprintf(stderr, "An unknown error occurred\n");
	}	
}

void AQRecorder::StopRecord()
{
//    //立即执行该runloop的事件，如果没有这句话系统会在空闲的时候执行runloopSource相关的事件
//    if (mThreadRunLoop!=NULL)
//        CFRunLoopWakeUp(mThreadRunLoop) ;
    
    //设置结束状态
    if (!mThreadRunLoop)
        return;
    
    //停止AudioQueue录音
    dispatch_async(mRecorderOperationQueue, ^{ //dispatch_barrier_async
        NSLog(@"execute to stop record queue...");
        
        OSStatus result = noErr;
        
        try {
            result = AudioQueueStop(mQueue, true);
            if (result)
                printf("AudioQueueStop failed!\n");
        } catch (CAXException e) {
            char buf[256];
            fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        }
        
//        try {
//            result = AudioQueueReset(mQueue);
//            if (result)
//                printf("AudioQueueReset failed!\n");
//        } catch (CAXException e) {
//            char buf[256];
//            fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
//        }
        
        try {
            result = AudioQueueDispose(mQueue, true);
            if (result)
                printf("AudioQueueDispose failed!\n");
        } catch (CAXException e) {
            char buf[256];
            fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
        }
        NSLog(@"stop record queue end");
        
        mIsRunning = false;
        CFRunLoopStop(mThreadRunLoop);
        mThreadRunLoop = nil;
        NSLog(@"stop..................");
        
//        XThrowIfError(AudioQueueReset(mQueue), "AudioQueueReset failed");
//        XThrowIfError(AudioQueueStop(mQueue, true), "AudioQueueStop failed");
//        XThrowIfError(AudioQueueDispose(mQueue, true), "AudioQueueDispose failed");
        
        // a codec may update its cookie at the end of an encoding session, so reapply it to the file now
    //	CopyEncoderCookieToFile();
    //	if (mFileName) {
    //		CFRelease(mFileName);
    //		mFileName = NULL;
    //	}

    //	AudioFileClose(mRecordFile);
    });
}

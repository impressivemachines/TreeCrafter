//
//  IMVideoSavingViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMVideoSavingViewController.h"
#import "IMImageSavingView.h"
#import "IMAppDelegate.h"
#import "IMTreeRender.h"

@interface IMVideoSavingViewController ()

@end

@implementation IMVideoSavingViewController

#define VIDEO_WIDTH     640
#define VIDEO_HEIGHT    480

- (id)init
{
    DEBUG_LOG(@"IMVideoSavingViewController init");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        m_render = app.render;
        
        m_videoQueue = dispatch_queue_create("com.impressivemachines.videoQueue", NULL);
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMImageSavingView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    DEBUG_LOG(@"IMVideoSavingViewController viewDidLoad");
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DEBUG_LOG(@"IMVideoSavingViewController viewWillAppear");
    
    IMImageSavingView *v = (IMImageSavingView *)self.view;
    v.titleLabel.text = NSLS_SAVING_VIDEO__;
    [v.cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUG_LOG(@"IMVideoSavingViewController viewDidAppear");
    
    self.progress = 0;
    self.userCancel = NO;

    if(![self generateVideo])
    {
        // animate away the progress box
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.view.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self failAlert];
                             [self.delegate videoSaveDidSucceed:NO];
                         }];
    }
}

- (void)deleteVideoFile:(NSString *)videoFilePath
{
    if(videoFilePath)
    {
        NSFileManager *manager = [NSFileManager defaultManager];
        if([manager fileExistsAtPath:videoFilePath])
        {
            DEBUG_LOG(@"deleting video file");
            [manager removeItemAtPath:videoFilePath error:nil];
        }
    }
}

- (BOOL)generateVideo
{
    CGSize videoSize = CGSizeMake(VIDEO_WIDTH, VIDEO_HEIGHT);
    
    self.videoFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"temp.mov"];
    DEBUG_LOG(@"new video file: %@", self.videoFilePath);
    
    [self deleteVideoFile:self.videoFilePath]; // remove an old version, especially if debug or crash session leaves it behind, otherwise nothing works

    NSError *error = nil;
    AVAssetWriter *assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:self.videoFilePath] fileType:AVFileTypeQuickTimeMovie error:&error];
    if(!assetWriter || error)
    {
        DEBUG_LOG(@"Error: Failed to create asset writer %@", error);
        [assetWriter release];
        return NO;
    }
    
    NSDictionary *videoOutputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                         AVVideoCodecH264, AVVideoCodecKey,
                                         [NSNumber numberWithInt:(int)videoSize.width], AVVideoWidthKey,
                                         [NSNumber numberWithInt:(int)videoSize.height], AVVideoHeightKey,
                                         nil];
    
    AVAssetWriterInput *videoWriterInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoOutputSettings] retain];
    if(!videoWriterInput)
    {
        DEBUG_LOG(@"Error: could not create video writer input");
        [assetWriter release];
        return NO;
    }
    
    videoWriterInput.expectsMediaDataInRealTime = NO;
    //videoWriterInput.transform = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f);
    //videoWriterInput.transform = CGAffineTransformMake(1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f);
    
    // desired type of pixel buffer to produce
    // annoyingly the only working option is BGRA so we have to reverse the R/B components
    NSDictionary *pbaSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], (id)kCVPixelBufferPixelFormatTypeKey,
                                 [NSNumber numberWithInt:(int)videoSize.width], (id)kCVPixelBufferWidthKey,
                                 [NSNumber numberWithInt:(int)videoSize.height], (id)kCVPixelBufferHeightKey,
                                 [NSNumber numberWithInt:4], (id)kCVPixelBufferBytesPerRowAlignmentKey,
                                 (id)kCFBooleanTrue, (id)kCVPixelBufferOpenGLCompatibilityKey,
                                 nil];
    
    AVAssetWriterInputPixelBufferAdaptor *videoWriterPBA = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:videoWriterInput sourcePixelBufferAttributes:pbaSettings];
    
    if(!videoWriterPBA)
    {
        DEBUG_LOG(@"Error: could not create video writer PBA");
        [videoWriterInput release];
        [assetWriter release];
        return NO;
    }
    
    int timescale = 15; // frames per second
    __block int frame = 0;
    int maxframes = timescale * self.duration;
    //int maxframes = 10;
    
    if(![assetWriter canAddInput:videoWriterInput])
    {
        DEBUG_LOG(@"Error: cannot add videoWriterInput");
        [videoWriterPBA release];
        [videoWriterInput release];
        [assetWriter release];
        return NO;
    }
    
    [assetWriter addInput:videoWriterInput];
    
    //assetWriter.movieTimeScale = (CMTimeScale)timescale;
    
    if(![assetWriter startWriting])
    {
        DEBUG_LOG(@"Error: cannot start writing %@", assetWriter.error);
        [videoWriterPBA release];
        [videoWriterInput release];
        [assetWriter release];
        return NO;
    }
    
    [assetWriter startSessionAtSourceTime:CMTimeMake(0, timescale)];
    
    __block BOOL finished = NO;
    
    m_render.drawOrigin = self.drawOrigin;
    m_render.drawScale = self.drawScale;
    m_render.useRelativeTime = NO;
    m_render.lineWidth = 0;
    m_render.backgroundImage = nil;
    m_render.backgroundIsTransparent = NO;
    
    [videoWriterInput requestMediaDataWhenReadyOnQueue:m_videoQueue usingBlock:^{
        DEBUG_LOG(@"Media data request");
        
        while(!finished && [videoWriterInput isReadyForMoreMediaData])
        {
            @autoreleasepool {
                if(frame<maxframes && !self.userCancel)
                {
                    CVPixelBufferRef pixelBuffer = NULL;
                    CVPixelBufferPoolCreatePixelBuffer(NULL, videoWriterPBA.pixelBufferPool, &pixelBuffer);
                    if(pixelBuffer==NULL)
                    {
                        finished = YES;
                        
                        DEBUG_LOG(@"Error: we got a null pixelBuffer");
                        [videoWriterInput markAsFinished];
                        
                        dispatch_async(m_videoQueue, ^{
                            [assetWriter cancelWriting];
                            [videoWriterPBA release];
                            [videoWriterInput release];
                            [assetWriter release];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self completeOperationWithStatus:AVAssetWriterStatusFailed];
                            });
                        });
                    }
                    else
                    {
                        float time = frame / (float)timescale;
                        
                        DEBUG_LOG(@"Drawing frame %d for time %f", frame, time);
                        
                        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
                        
                        m_render.time = time;
                        
                        [m_render renderToBuffer:CVPixelBufferGetBaseAddress(pixelBuffer) width:CVPixelBufferGetWidth(pixelBuffer) height:CVPixelBufferGetHeight(pixelBuffer)];
                        
                        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
                        
                        DEBUG_LOG(@"Writing frame %d", frame);
                        [videoWriterPBA appendPixelBuffer:pixelBuffer withPresentationTime:CMTimeMake(frame, timescale)];
                        
                        CVPixelBufferRelease(pixelBuffer);
                    }
                    
                    frame++;
                    
                    self.progress = frame/(float)maxframes;
                    
                    if(!self.userCancel)
                    {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            IMImageSavingView *v = (IMImageSavingView *)self.view;
                            [v.progressBar setProgress:self.progress animated:NO];
                        });
                    }
                }
                else
                {
                    finished = YES;
                    
                    DEBUG_LOG(@"Marking as finished");
                    [videoWriterInput markAsFinished];

                    // dispatch ensures it happens after we are finished with this block
                    dispatch_async(m_videoQueue, ^{
                        if(self.userCancel)
                        {
                            DEBUG_LOG(@"User cancel detected");
                            [assetWriter cancelWriting];
                        }
                        else
                        {
                            // this is a fix because there is always a retain loop if I reference anything in the finish completion block
                            // emulates deprecated function [assetWriter finishWriting]
                            __block BOOL writingDone = NO;
                            
                            DEBUG_LOG(@"Finish writing");
                            
                            [assetWriter finishWritingWithCompletionHandler:^{
                                DEBUG_LOG(@"done!");
                                writingDone = YES;
                            }];
                            
                            int timeout = 0;
                            while(!writingDone)
                            {
                                DEBUG_LOG(@"sleeping");
                                [NSThread sleepForTimeInterval:0.1];
                                timeout++;
                                if(timeout>50) // wait up to 5 seconds then give up
                                    break;
                            }
                        }

                        DEBUG_LOG(@"Finish writing releasing");
                        
                        AVAssetWriterStatus status = assetWriter.status;
                        
                        [videoWriterPBA release];
                        [videoWriterInput release];
                        [assetWriter release];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self completeOperationWithStatus:status];
                        });
                    });
                }
            }
        }
        
        if(finished)
        {
            DEBUG_LOG(@"Video writing finished flag set");
        }
    }];
    
    DEBUG_LOG(@"Video writing has started");
    
    return YES;
}

- (void)completeOperationWithStatus:(AVAssetWriterStatus)status
{
    DEBUG_LOG(@"IMVideoSavingViewController completeOperationWithStatus");

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // animate away the progress box
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if(status==AVAssetWriterStatusCompleted && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath))
                         {
                             DEBUG_LOG(@"IMVideoSavingViewController moveVideoToCameraRoll actual work");
                             UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, self,
                                                                 @selector(videoSaveCleanup:didFinishSavingWithError:contextInfo:),
                                                                 nil);
                             
                             [self.delegate videoSaveDidSucceed:YES];
                         }
                         else
                         {
                             DEBUG_LOG(@"Error: Can't move to saved album - user cancel?");
                             [self deleteVideoFile:self.videoFilePath];
                             
                             if(status!=AVAssetWriterStatusCancelled)
                                 [self failAlert];
                             
                             [self.delegate videoSaveDidSucceed:NO];
                         }
                     }];
}

- (void)videoSaveCleanup:(NSString *)videoPath
didFinishSavingWithError:(NSError *)error
             contextInfo:(void *)contextInfo
{
    // this happens some seconds after the dialog closes - too late to show error really
    DEBUG_LOG(@"IMVideoSavingViewController videoSaveCleanup error=%@", error);
    
    [self deleteVideoFile:videoPath];
}

- (void)failAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLS_UNABLE_TO_SAVE_VIDEO
                                                    message:NSLS_EITHER_CAMERA__
                                                   delegate:nil
                                          cancelButtonTitle:NSLS_OK
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DEBUG_LOG(@"IMVideoSavingViewController didReceiveMemoryWarning");
}

- (void)cancelButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMVideoSavingViewController cancelButtonPress");
    self.userCancel = YES;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    DEBUG_LOG(@"IMVideoSavingViewController resigning active");
    self.userCancel = YES; // its very difficult to unwind this saving thread hairball, this is just a half-assed approach
    [NSThread sleepForTimeInterval:0.1]; // buy us a little time
}

- (void)dealloc
{
    DEBUG_LOG(@"IMVideoSavingViewController dealloc");
    
    [_videoFilePath release];
    
    dispatch_release(m_videoQueue);
    
    [super dealloc];
}


@end

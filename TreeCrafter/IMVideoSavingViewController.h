//
//  IMVideoSavingViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "fractaltrees.h"
#import "IMTreeModel.h"

@protocol IMVideoSavingViewControllerDelegate
- (void)videoSaveDidSucceed:(BOOL)success;
@end

@class IMTreeRender;

@interface IMVideoSavingViewController : UIViewController
{
    dispatch_queue_t m_videoQueue;
    IMTreeRender *m_render;
}

@property (assign, nonatomic) id <IMVideoSavingViewControllerDelegate> delegate;

@property (assign, atomic) BOOL userCancel;
@property (assign, atomic) float progress;
@property (assign, atomic) BOOL finished;

@property (assign, nonatomic) float drawScale;
@property (assign, nonatomic) CGPoint drawOrigin;
@property (assign, nonatomic) int duration;
@property (retain, nonatomic) NSString *videoFilePath;

@end

//
//  IMVideoAdjusterViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMVideoAdjusterView.h"
#import "IMVideoDurationViewController.h"
#import "IMVideoSavingViewController.h"

@protocol IMVideoAdjusterViewControllerDelegate
- (void)videoAdjusterVCDidSucceed:(BOOL)success;
@end

@interface IMVideoAdjusterViewController : UIViewController <IMVideoDurationViewControllerDelegate, UIPopoverControllerDelegate, IMVideoSavingViewControllerDelegate>
{
    int m_currentDuration;
    BOOL m_playing;
    NSTimer *m_timer;
    double m_t;
}

@property (assign, nonatomic) id <IMVideoAdjusterViewControllerDelegate> delegate;
@property (nonatomic, retain) UIPopoverController *videoDurationPopover;

@property (nonatomic, retain) IMVideoSavingViewController *savingViewController;

@end

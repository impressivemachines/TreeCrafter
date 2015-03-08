//
//  IMRootViewController.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 6/9/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"
#import "IMTreeViewController.h"
#import "IMImageSavingViewController.h"
#import "IMImageAdjusterViewController.h"
#import "IMPDFAdjusterViewController.h"
#import "IMVideoAdjusterViewController.h"
#import "IMSettingsMenuViewController.h"

@class IMAppDelegate;

@interface IMRootViewController : UIViewController <IMPresentationProtocol, IMTreeParamProtocol, IMImageSavingViewControllerDelegate, IMImageAdjusterViewControllerDelegate, IMPDFAdjusterViewControllerDelegate, IMVideoAdjusterViewControllerDelegate, IMSettingsMenuViewControllerDelegate>
{
    IMAppDelegate *m_app;
    int m_currentControlID;
    NSTimer *m_timeout;
    int m_timeoutCounter;
    BOOL m_pinned;
    BOOL m_top_menu_hidden;
    BOOL m_user_wants_animation;
    BOOL m_sharing;
    BOOL m_started;
    int m_timer_state;
}

@property (nonatomic, retain) UIViewController<IMMenuProtocol> *currentMenu;
@property (nonatomic, retain) IMSettingsMenuViewController *settingsMenu;

@property (nonatomic, retain) IMTreeViewController *treeViewController;
@property (nonatomic, retain) UIView <IMControlProtocol> *controlView;

@property (nonatomic, retain) IMImageSavingViewController *savingViewController;

- (BOOL)userAnimationState;
- (void)setUserAnimationState:(BOOL)shouldanimate;

- (void)disableDisplayUpdatesWithRedraw:(BOOL)redraw; // suspends further access to tree model
- (void)enableDisplayUpdatesWithRedraw:(BOOL)redraw; // allows access to tree model

- (void)appPause;
- (void)appResume;

@end

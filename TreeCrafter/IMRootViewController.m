//
//  IMRootViewController.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 6/9/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMRootViewController.h"
#import "IMAppDelegate.h"
#import "IMRootView.h"
#import "IMSharingMenuViewController.h"
#import "IMShapeMenuViewController.h"
#import "IMOrganizeMenuViewController.h"
#import "IMAnimationMenuViewController.h"
#import "IMColorMenuViewController.h"
#import "IMSliderView.h"
#import "IMStepperView.h"
#import "IMAnimTargetView.h"
#import "IMColorView.h"
#import "IMSelectorView.h"

@interface IMRootViewController ()

@end

@implementation IMRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        m_app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        m_currentControlID = ID_NONE;
#ifdef SUPPORT_PINNING
        m_pinned = NO;
#else
        m_pinned = YES;
#endif
        m_started = NO;
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMRootView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DEBUG_LOG(@"IMRootVC viewDidLoad (%f x %f)", self.view.bounds.size.width, self.view.bounds.size.height);
    
    IMRootView *rv = (IMRootView *)self.view;
    
    [rv.settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rv.organizeButton addTarget:self action:@selector(organizeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rv.shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rv.colorButton addTarget:self action:@selector(colorButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rv.animationButton addTarget:self action:@selector(animationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [rv.shapeButton addTarget:self action:@selector(shapeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    DEBUG_LOG(@"IMRootVC viewWillAppear (%f x %f)", self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self presentTreeViewController]; // presents only if not already there
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUG_LOG(@"IMRootVC viewDidAppear (%f x %f)", self.view.bounds.size.width, self.view.bounds.size.height);
    
    [self startTimer];
    
    if(!m_started)
    {
        [self settingsButtonPressed:nil];
        [self performSelector:@selector(animateOnStartup) withObject:nil afterDelay:0.5];
    }
    
    m_started = YES;
}

- (void)animateOnStartup
{
    self.userAnimationState = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DEBUG_LOG(@"IMRootVC viewWillDisappear");
    
    [self killTimer];
}

// pauses app when app is interrupted
- (void)appPause
{
    [self disableDisplayUpdatesWithRedraw:NO];
    [self killTimer];
}

// resumes app when app resumes
- (void)appResume
{
    if(m_started)
    {
        [self enableDisplayUpdatesWithRedraw:YES];
        [self startTimer];
    }
}

- (void)didReceiveMemoryWarning
{
    DEBUG_LOG(@"IMRootVC didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    
#ifdef DEBUG_LOGGING
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory Warning"
                                                    message:@"DEBUG memory warning!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
#endif
    
    //[self dismissCurrentMenuWithCompletion:^{}];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DEBUG_LOG(@"IMRootVC will rotate");
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DEBUG_LOG(@"IMRootVC did rotate");
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(!m_pinned && self.controlView)
    {
        // stop control from going off the bottom after interface rotation
        UIViewController<IMMenuProtocol> *vc = self.currentMenu;
        float menu_width = [vc widthForMenu];
        CGRect rct = self.controlView.frame;
        float top = rct.origin.y;
        if(top + rct.size.height > vc.view.frame.origin.y + vc.view.frame.size.height)
            top = vc.view.frame.origin.y + vc.view.frame.size.height - rct.size.height;
        self.controlView.frame = CGRectMake(self.view.bounds.size.width - rct.size.width - menu_width - 10,
                                            top,
                                            rct.size.width,
                                            rct.size.height);
    }
}

- (void)presentTreeViewController
{
    if(!self.treeViewController)
    {
        DEBUG_LOG(@"IMRootVC presentTreeVC (%f x %f)", self.view.bounds.size.width, self.view.bounds.size.height);
        self.treeViewController = [[[IMTreeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
        self.treeViewController.view.frame = self.view.bounds;
        self.treeViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.treeViewController.delegate = self;
        [self addChildViewController:self.treeViewController];
        [self.view addSubview:self.treeViewController.view];
        [self.view sendSubviewToBack:self.treeViewController.view];
        [self.treeViewController didMoveToParentViewController:self];
    }
}

- (void)dismissTreeViewController
{
    if(self.treeViewController)
    {
        DEBUG_LOG(@"IMRootVC dismissTreeVC");
        [self.treeViewController willMoveToParentViewController:nil];
        [self.treeViewController.view removeFromSuperview];
        [self.treeViewController removeFromParentViewController];
        self.treeViewController = nil;
    }
}

- (void)killTimer
{
    [m_timeout invalidate];
    [m_timeout release];
    m_timeout = nil;
    
    m_timer_state++;
}

- (void)startTimer
{
    m_timeoutCounter = 0;
    
    if(m_timer_state>0)
        m_timer_state--;
    
    if(m_timer_state==0 && m_timeout==nil)
        m_timeout = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(checkMenuTimeout) userInfo:nil repeats:YES] retain];
}

- (void)checkMenuTimeout
{
    if(m_top_menu_hidden || self.controlView!=nil || self.currentMenu!=nil || self.settingsMenu!=nil)
        m_timeoutCounter = 0;
    else
    {
        //DEBUG_LOG(@"check time %d", m_timeoutCounter);
        m_timeoutCounter++;
        if(m_timeoutCounter>50)
            [self hideTopMenu];
    }
}

- (void)hideTopMenu
{
    IMRootView *rv = (IMRootView *)self.view;
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         rv.leftButtonPane.alpha = 0;
                         rv.rightButtonPane.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
    m_top_menu_hidden = YES;
}

- (void)showTopMenu
{
    IMRootView *rv = (IMRootView *)self.view;
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         rv.leftButtonPane.alpha = 1;
                         rv.rightButtonPane.alpha = 1;
                     }
                     completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
    m_top_menu_hidden = NO;
}

- (void)dismissCurrentMenuWithCompletion:(void (^)(void))completion
{
    DEBUG_LOG(@"start of dismiss");
    IMRootView *rv = (IMRootView *)self.view;
    
    if(self.currentMenu==nil)
    {
        if(self.settingsMenu)
        {
            [rv.settingsButton setImage:[UIImage imageNamed:@"cog"] forState:UIControlStateNormal];
            
            [self.settingsMenu willMoveToParentViewController:nil];
            
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                self.settingsMenu.view.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 [self.settingsMenu.view removeFromSuperview];
                                 [self.settingsMenu removeFromParentViewController];
                                 self.settingsMenu = nil;
                                 [self.treeViewController enableTouches];
                                 self.view.userInteractionEnabled = YES;
                                 DEBUG_LOG(@"end of dismiss (settings)");
                                 completion();
                             }];
            return;
        }
        else
        {
            DEBUG_LOG(@"end of dismiss (NULL)");
            completion();
            return;
        }
    }
    
    if([self.currentMenu isKindOfClass:[IMOrganizeMenuViewController class]])
        [rv.organizeButton setImage:[UIImage imageNamed:@"folderbutton"] forState:UIControlStateNormal];
    else if([self.currentMenu isKindOfClass:[IMColorMenuViewController class]])
        [rv.colorButton setImage:[UIImage imageNamed:@"colorbutton"] forState:UIControlStateNormal];
    else if([self.currentMenu isKindOfClass:[IMSharingMenuViewController class]])
        [rv.shareButton setImage:[UIImage imageNamed:@"sharebutton"] forState:UIControlStateNormal];
    else if([self.currentMenu isKindOfClass:[IMShapeMenuViewController class]])
        [rv.shapeButton setImage:[UIImage imageNamed:@"shapebutton"] forState:UIControlStateNormal];
    else if([self.currentMenu isKindOfClass:[IMAnimationMenuViewController class]])
        [rv.animationButton setImage:[UIImage imageNamed:@"animbutton"] forState:UIControlStateNormal];
    
    CGRect rctFinal = self.currentMenu.view.frame;
    
    if([self.currentMenu isRightSide])
        rctFinal.origin.x += rctFinal.size.width;
    else
        rctFinal.origin.x -= rctFinal.size.width;
    
    // dismiss menu
    [self.currentMenu willMoveToParentViewController:nil];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.currentMenu.view.frame = rctFinal;
                         if(!m_pinned && self.controlView)
                             self.controlView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if(!m_pinned && self.controlView)
                             [self dismissControlAnimated:NO];
                         [self.currentMenu.view removeFromSuperview];
                         [self.currentMenu removeFromParentViewController];
                         self.currentMenu = nil;
                         self.view.userInteractionEnabled = YES;
                         DEBUG_LOG(@"dismiss completion");
                         completion();
                     }];
    DEBUG_LOG(@"end of dismiss");
}

- (void)presentMenu
{
    if(self.currentMenu==nil)
        return;
    
    DEBUG_LOG(@"IMRootVC start of present menu");
    float width = [self.currentMenu widthForMenu];
    
    CGRect rctFinal;
    if([self.currentMenu isRightSide])
    {
        rctFinal = CGRectMake(self.view.bounds.size.width, 120, width, self.view.bounds.size.height - 20 - 120);
        self.currentMenu.view.frame = rctFinal;
        self.currentMenu.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
        rctFinal.origin.x = self.view.bounds.size.width - width;
    }
    else
    {
        rctFinal = CGRectMake(-width, 120, width, self.view.bounds.size.height - 20 - 120);
        self.currentMenu.view.frame = rctFinal;
        self.currentMenu.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
        rctFinal.origin.x = 0;
    }
    
    [self addChildViewController:self.currentMenu];
    [self.view addSubview:self.currentMenu.view];
    
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.currentMenu.view.frame = rctFinal;
                     }
                     completion:^(BOOL finished) {
                        [self.currentMenu didMoveToParentViewController:self];
                        self.view.userInteractionEnabled = YES;
                        IMRootView *rv = (IMRootView *)self.view;
                        if([self.currentMenu isKindOfClass:[IMOrganizeMenuViewController class]])
                            [rv.organizeButton setImage:[UIImage imageNamed:@"folderbutton_h"] forState:UIControlStateNormal];
                        if([self.currentMenu isKindOfClass:[IMColorMenuViewController class]])
                            [rv.colorButton setImage:[UIImage imageNamed:@"colorbutton_h"] forState:UIControlStateNormal];
                        if([self.currentMenu isKindOfClass:[IMSharingMenuViewController class]])
                            [rv.shareButton setImage:[UIImage imageNamed:@"sharebutton_h"] forState:UIControlStateNormal];
                        if([self.currentMenu isKindOfClass:[IMShapeMenuViewController class]])
                            [rv.shapeButton setImage:[UIImage imageNamed:@"shapebutton_h"] forState:UIControlStateNormal];
                        if([self.currentMenu isKindOfClass:[IMAnimationMenuViewController class]])
                            [rv.animationButton setImage:[UIImage imageNamed:@"animbutton_h"] forState:UIControlStateNormal];
                         DEBUG_LOG(@"present completion");
                     }];
	
    DEBUG_LOG(@"IMRootVC end of present menu");
}

- (void)dismissStartHere
{
    IMRootView *rv = (IMRootView *)self.view;
    
    if(rv.startHereView)
    {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             rv.startHereView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [rv.startHereView removeFromSuperview];
                             rv.startHereView = nil;
                         }];
    }
}

- (void)settingsButtonPressed:(UIButton *)sender
{
    if(!self.view.userInteractionEnabled)
        return;
    
    if(self.settingsMenu)
    {
        [self dismissCurrentMenuWithCompletion:^{}];
    }
    else
    {
        [self.treeViewController disableTouches];
        [self dismissControlAnimated:NO];
        [self dismissCurrentMenuWithCompletion:^{
            self.settingsMenu = [[[IMSettingsMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.settingsMenu.delegate = self;
            self.settingsMenu.view.frame = CGRectMake(self.view.bounds.size.width/2 - 300,
                                                      self.view.bounds.size.height/2 - 250,
                                                      600, 500);
            self.settingsMenu.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [self addChildViewController:self.settingsMenu];
            [self.view addSubview:self.settingsMenu.view];
            
            self.settingsMenu.view.alpha = 0;
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.settingsMenu.view.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                 [self.settingsMenu didMoveToParentViewController:self];
                                 IMRootView *rv = (IMRootView *)self.view;
                                 [rv.settingsButton setImage:[UIImage imageNamed:@"cog_s"] forState:UIControlStateNormal];
                                 self.view.userInteractionEnabled = YES;
                             }];
        }];
    }
    
    DEBUG_LOG(@"IMRootVC Settings menu");
}

- (void)organizeButtonPressed:(UIButton *)sender
{
    if(!self.view.userInteractionEnabled)
        return;
    
    DEBUG_LOG(@"IMRootVC Organize menu");
    if(self.currentMenu && [self.currentMenu isKindOfClass:[IMOrganizeMenuViewController class]])
    {
        [self dismissCurrentMenuWithCompletion:^{}];
    }
    else
    {
        [self dismissCurrentMenuWithCompletion:^{
            self.currentMenu = [[[IMOrganizeMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.currentMenu.delegate = self;
            [self presentMenu];
        }];
    }
}

- (void)shareButtonPressed:(UIButton *)sender
{
    if(!self.view.userInteractionEnabled)
        return;
    
    DEBUG_LOG(@"IMRootVC Share menu");
    if(self.currentMenu && [self.currentMenu isKindOfClass:[IMSharingMenuViewController class]])
    {
        [self dismissCurrentMenuWithCompletion:^{}];
    }
    else
    {
        [self dismissCurrentMenuWithCompletion:^{
            self.currentMenu = [[[IMSharingMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.currentMenu.delegate = self;
            [self presentMenu];
        }];
    }
}

- (void)colorButtonPressed:(UIButton *)sender
{
    if(!self.view.userInteractionEnabled)
        return;
    
    DEBUG_LOG(@"IMRootVC Color menu %d", self.view.userInteractionEnabled);
    
    [self dismissStartHere];
    
    if(self.currentMenu && [self.currentMenu isKindOfClass:[IMColorMenuViewController class]])
    {
        [self dismissCurrentMenuWithCompletion:^{}];
    }
    else
    {
        [self dismissCurrentMenuWithCompletion:^{
            self.currentMenu = [[[IMColorMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.currentMenu.delegate = self;
            [self presentMenu];
        }];
    }
}

- (void)animationButtonPressed:(UIButton *)sender
{
    if(!self.view.userInteractionEnabled)
        return;
    
    DEBUG_LOG(@"IMRootVC Animation menu");
    
    [self dismissStartHere];
    
    if(self.currentMenu && [self.currentMenu isKindOfClass:[IMAnimationMenuViewController class]])
    {
        [self dismissCurrentMenuWithCompletion:^{}];
    }
    else
    {
        [self dismissCurrentMenuWithCompletion:^{
            self.currentMenu = [[[IMAnimationMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.currentMenu.delegate = self;
            [self presentMenu];
        }];
    }
}

- (void)shapeButtonPressed:(UIButton *)sender
{
    if(!self.view.userInteractionEnabled)
        return;
    
    DEBUG_LOG(@"IMRootVC Shape menu ");
    
    [self dismissStartHere];
    
    if(self.currentMenu && [self.currentMenu isKindOfClass:[IMShapeMenuViewController class]])
    {
        [self dismissCurrentMenuWithCompletion:^{}];
    }
    else
    {
        [self dismissCurrentMenuWithCompletion:^{
            self.currentMenu = [[[IMShapeMenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
            self.currentMenu.delegate = self;
            [self presentMenu];
        }];
        
    }
}

- (void)settingsMenuDidRequestDismissal;
{
    [self dismissCurrentMenuWithCompletion:^{}];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    DEBUG_LOG(@"touch!");
    if(!m_sharing) // lock out changes during sharing dialogs
    {
        if(self.currentMenu)
        {
            UITouch *touch = [touches anyObject];
            if(![self.currentMenu.view pointInside:[touch locationInView:self.currentMenu.view] withEvent:nil])
            {
                if(self.controlView)
                {
                    if(![self.controlView pointInside:[touch locationInView:self.controlView] withEvent:nil])
                        [self dismissCurrentMenuWithCompletion:^{}];
                }
                else
                    [self dismissCurrentMenuWithCompletion:^{}];
            }
        }
        else if(self.settingsMenu)
        {
            UITouch *touch = [touches anyObject];
            if(![self.settingsMenu.view pointInside:[touch locationInView:self.settingsMenu.view] withEvent:nil])
                [self dismissCurrentMenuWithCompletion:^{}];
        }
    
        if(m_top_menu_hidden)
            [self showTopMenu];
        m_timeoutCounter = 0;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (int)currentControl
{
    return m_currentControlID;
}

- (void)dismissControlAnimated:(BOOL)animated
{
    if(self.controlView)
    {
        m_currentControlID = ID_NONE;
        [self.currentMenu update];
        
        if(animated)
        {
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.controlView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 [self.controlView removeFromSuperview];
                                 self.controlView = nil;
                                 self.view.userInteractionEnabled = YES;
                             }];
        }
        else
        {
            [self.controlView removeFromSuperview];
            self.controlView = nil;
        }
    }
}

- (void)controlPinningAction:(id)sender
{
    if(m_pinned)
    {
        // dismiss
        [self dismissControlAnimated:YES];
        
#ifdef SUPPORT_PINNING
        m_pinned = NO;
#endif
    }
    else
    {
        CGRect rct = self.controlView.frame;

        self.controlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;

        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.controlView.frame = CGRectMake((self.view.bounds.size.width - rct.size.width)/2,
                                                                 self.view.bounds.size.height - rct.size.height - 40,
                                                                 rct.size.width,
                                                                 rct.size.height);
                         }
                         completion:^(BOOL finished) {
                             self.view.userInteractionEnabled = YES;
                         }];
        
        m_pinned = YES;
    }
}

- (NSString *)titleForControl:(int)control
{
    switch(control)
    {
        case ID_ANGLEMODE:
            return NSLS_ANGLE_MODE;
        case ID_INTERVALSTART:
            return NSLS_INTERVALS;
        case ID_INTERVALCOUNT:
            return NSLS_COMPLEXITY;
        case ID_DETAIL:
            return NSLS_LEVEL_OF_DETAIL;
        case ID_SPIKINESS:
            return NSLS_APEX_LENGTH;
        case ID_TRUNKWIDTH:
            return NSLS_TRUNK_WIDTH;
        case ID_RANDOMWIGGLE:
            return NSLS_RANDOM_WIGGLE;
        case ID_RANDOMANGLE:
            return NSLS_RANDOM_ANGLES;
        case ID_RANDOMLENGTH:
            return NSLS_RANDOM_LENGTHS;
        case ID_TRUNKTAPER:
            return NSLS_TRUNK_TAPER;
        case ID_APEXTYPE:
            return NSLS_APEX_MODE;
        case ID_RANDOMINTERVAL:
            return NSLS_RANDOM_INTERVALS;
        case ID_ROOTCOLOR:
            return NSLS_TRUNK_COLOR;
        case ID_LEAFCOLOR:
            return NSLS_LEAF_COLOR;
        case ID_BACKGROUNDCOLOR:
            return NSLS_BACKGROUND_COLOR;
        case ID_COLORSIZE:
            return NSLS_GRADIENT_SATURATION;
        case ID_COLORTRANSITION:
            return NSLS_GRADIENT_SHARPNESS;
        case ID_BRANCHCOUNT:
            return NSLS_BRANCHES_PER_NODE;
        case ID_GEONODES:
            return NSLS_BRANCH_NODES;
        case ID_ANIMWINDRATE:
            return NSLS_WIND_RATE;
        case ID_ANIMWINDDEPTH:
            return NSLS_WIND_DEPTH;
        case ID_ANIMSPREAD_D:
            return NSLS_SPREAD_ANIMATION;
        case ID_SPREAD:
            return NSLS_SPREAD;
        case ID_ANIMBEND_D:
            return NSLS_BEND_ANIMATION;
        case ID_BEND:
            return NSLS_BEND;
        case ID_ANIMSPIN_D:
            return NSLS_SPIN_ANIMATION;
        case ID_SPIN:
            return NSLS_SPIN;
        case ID_ANIMTWIST_D:
            return NSLS_TWIST_ANIMATION;
        case ID_TWIST:
            return NSLS_TWIST;
        case ID_ANIMLENGTHRATIO_D:
            return NSLS_GROWTH_ANIMATION;
        case ID_LENGTHRATIO:
            return NSLS_GROWTH;
        case ID_ANIMGEODELAY_D:
            return NSLS_DELAY_ANIMATION;
        case ID_GEODELAY:
            return NSLS_DELAY;
        case ID_ANIMGEORATIO_D:
            return NSLS_GEORATIO_ANIMATION;
        case ID_GEORATIO:
            return NSLS_GEOMETRIC_RATIO;
        case ID_ANIMASPECT_D:
            return NSLS_ASPECT_RATIO_ANIMATION;
        case ID_ASPECT:
            return NSLS_ASPECT_RATIO;
        case ID_ANIMBALANCE_D:
            return NSLS_BALANCE_ANIMATION;
        case ID_BALANCE:
            return NSLS_BALANCE;
        case ID_ANIMLENGTHBALANCE_D:
            return NSLS_SYMMETRY_ANIMATION;
        case ID_LENGTHBALANCE:
            return NSLS_SYMMETRY;
        case ID_TREETYPE:
            return NSLS_TREE_MODE;
        case ID_ANIMENABLE:
            return NSLS_ANIMATION;
        default:
            return @"?";
    }
}

- (void)showControl:(int)control y:(int)y
{
    DEBUG_LOG(@"showing control #%d at y=%d", control, y);
    
    IMRootView *rv = (IMRootView *)self.view;
    
    if(m_currentControlID==control)
    {
        // [self dismissControlAnimated:YES];
        return;
    }
    else
    {
        float control_width = 300;
        float control_height = 80;
        
        // switch to new control
        switch(control)
        {
            case ID_ANGLEMODE:
            case ID_APEXTYPE:
            case ID_ANIMENABLE:
            case ID_TREETYPE:
                if(!self.controlView || ![self.controlView isKindOfClass:[IMSelectorView class]])
                {
                    [self dismissControlAnimated:NO];
                    self.controlView = [[[IMSelectorView alloc] initWithFrame:CGRectZero] autorelease];
                    self.controlView.delegate = self;
                    [self.controlView.button addTarget:self action:@selector(controlPinningAction:) forControlEvents:UIControlEventTouchUpInside];
                    [rv addSubview:self.controlView];
                }
                
                control_height = 140;
                break;
                
            case ID_ROOTCOLOR:
            case ID_LEAFCOLOR:
            case ID_BACKGROUNDCOLOR:
                if(!self.controlView || ![self.controlView isKindOfClass:[IMColorView class]])
                {
                    [self dismissControlAnimated:NO];
                    self.controlView = [[[IMColorView alloc] initWithFrame:CGRectZero] autorelease];
                    self.controlView.delegate = self;
                    [self.controlView.button addTarget:self action:@selector(controlPinningAction:) forControlEvents:UIControlEventTouchUpInside];
                    [rv addSubview:self.controlView];
                }
                
                control_height = 230;
                break;
                
            case ID_INTERVALSTART:
            case ID_INTERVALCOUNT:
            case ID_BRANCHCOUNT:
            case ID_GEONODES:
                if(!self.controlView || ![self.controlView isKindOfClass:[IMStepperView class]])
                {
                    [self dismissControlAnimated:NO];
                    self.controlView = [[[IMStepperView alloc] initWithFrame:CGRectZero] autorelease];
                    self.controlView.delegate = self;
                    [self.controlView.button addTarget:self action:@selector(controlPinningAction:) forControlEvents:UIControlEventTouchUpInside];
                    [rv addSubview:self.controlView];
                }
                
                control_height = 100;
                break;
                
            case ID_ANIMSPREAD_D:
            case ID_ANIMBEND_D:
            case ID_ANIMSPIN_D:
            case ID_ANIMTWIST_D:
            case ID_ANIMLENGTHRATIO_D:
            case ID_ANIMGEODELAY_D:
            case ID_ANIMGEORATIO_D:
            case ID_ANIMASPECT_D:
            case ID_ANIMBALANCE_D:
            case ID_ANIMLENGTHBALANCE_D:
                if(!self.controlView || ![self.controlView isKindOfClass:[IMAnimTargetView class]])
                {
                    [self dismissControlAnimated:NO];
                    self.controlView = [[[IMAnimTargetView alloc] initWithFrame:CGRectZero] autorelease];
                    self.controlView.delegate = self;
                    [self.controlView.button addTarget:self action:@selector(controlPinningAction:) forControlEvents:UIControlEventTouchUpInside];
                    [rv addSubview:self.controlView];
                }
                
                control_height = 190;
                break;
                
            default:
                if(!self.controlView || ![self.controlView isKindOfClass:[IMSliderView class]])
                {
                    [self dismissControlAnimated:NO];
                    self.controlView = [[[IMSliderView alloc] initWithFrame:CGRectZero] autorelease];
                    self.controlView.delegate = self;
                    [self.controlView.button addTarget:self action:@selector(controlPinningAction:) forControlEvents:UIControlEventTouchUpInside];
                    [rv addSubview:self.controlView];
                }
                break;
        }
        
        if(m_pinned)
        {
            self.controlView.frame = CGRectMake((self.view.bounds.size.width - control_width)/2,
                                                self.view.bounds.size.height - control_height - 40,
                                                control_width,
                                                control_height);
            
            self.controlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
            
            //[self.controlView.button setImage:[UIImage imageNamed:@"XXXX"] forState:UIControlStateNormal];
        }
        else
        {
            UIViewController<IMMenuProtocol> *vc = self.currentMenu;
            
            float top = vc.view.frame.origin.y + y - control_height/2 - 5;
            if(top<vc.view.frame.origin.y)
                top = vc.view.frame.origin.y;
            else if(top + control_height > vc.view.frame.origin.y + vc.view.frame.size.height)
                top = vc.view.frame.origin.y + vc.view.frame.size.height - control_height;
            
            float menu_width = [vc widthForMenu];
            self.controlView.frame = CGRectMake(self.view.bounds.size.width - control_width - menu_width - 10,
                                                top,
                                                control_width,
                                                control_height);
            
            self.controlView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            
            //[self.controlView.button setImage:[UIImage imageNamed:@"XXXX"] forState:UIControlStateNormal];
        }
        
        self.controlView.target = control;
        self.controlView.label.text = [self titleForControl:control];
        [self.controlView update];
        
        m_currentControlID = control;
    }
}

- (double)getParam:(int)paramid
{
    if(paramid==ID_ANIMENABLE)
        return self.userAnimationState ? 1 : 0;
    
    return [m_app.tree getParam:paramid];
}

- (void)setParam:(int)paramid value:(double)value redraw:(BOOL)redraw sender:(id)sender
{
    if(![self.treeViewController allowsDisplayUpdates])
        return;
    
    //DEBUG_LOG(@"set %d %f", paramid, value);
    
    if(paramid==ID_ANIMENABLE)
    {
        self.userAnimationState = value ? YES : NO;
    }
    else
    {    
        [m_app.tree setParam:paramid value:value];
        if(redraw)
            [self.treeViewController drawView];
    }
    
    // update the control if someone else happens to change its value
    if(sender != self.controlView)
        [self.controlView update];
    
    // allow the menu to change with the selected choices
    if(paramid==ID_TREETYPE || paramid==ID_ANGLEMODE || paramid==ID_APEXTYPE || paramid==ID_ANIMENABLE
       || paramid==ID_INTERVALCOUNT || paramid==ID_INTERVALSTART || paramid==ID_GEONODES || paramid==ID_BRANCHCOUNT)
        [self.currentMenu update];
}

- (double)getRawParam:(int)paramid
{
    return [m_app.tree getRawParam:paramid];
}

- (void)setRawParam:(int)paramid value:(double)value redraw:(BOOL)redraw sender:(id)sender
{
    if(![self.treeViewController allowsDisplayUpdates])
        return;
    
    [m_app.tree setRawParam:paramid value:value];
    if(redraw)
        [self.treeViewController drawView];
    
    // update the control if someone else happens to change its value
    if(sender != self.controlView)
        [self.controlView update];
}

- (void)randomSeedRefresh
{
    if(![self.treeViewController allowsDisplayUpdates])
        return;
    
    [m_app.tree randomSeedRefresh];
    [self.treeViewController drawView];
}

- (BOOL)userAnimationState
{
    return m_user_wants_animation;
}

- (void)setUserAnimationState:(BOOL)shouldanimate
{
    m_user_wants_animation = shouldanimate;
    if(m_user_wants_animation)
        [self.treeViewController startAnimating];
    else
        [self.treeViewController stopAnimatingWithRedraw:YES];
}

// suspends further access to tree model
- (void)disableDisplayUpdatesWithRedraw:(BOOL)redraw
{
    DEBUG_LOG(@"IMRootVC disableDisplayUpdates");
    [self.treeViewController disableDisplayUpdatesWithRedraw:redraw];
}

// allows access to tree model
- (void)enableDisplayUpdatesWithRedraw:(BOOL)redraw
{
    DEBUG_LOG(@"IMRootVC enableDisplayUpdates");
    [self.treeViewController enableDisplayUpdatesWithRedraw:redraw];
}

- (void)setTreeParameters:(NSDictionary *)params
{
    [self disableDisplayUpdatesWithRedraw:NO];
    [self dismissControlAnimated:YES];
#ifdef SUPPORT_PINNING
    m_pinned = NO;
#endif
    [m_app.tree setTreeParameters:params];
    [self resetPosition];
    [self enableDisplayUpdatesWithRedraw:YES];
}

- (void)resetPosition
{
    [self.treeViewController resetPosition];
    [self.treeViewController drawView];
}

- (void)performSharingWithOption:(int)option
{
    DEBUG_LOG(@"IMRootVC performSharing %d", option);
 
    //[self stopAnimatingAndHideTree];
    [self disableDisplayUpdatesWithRedraw:NO];
    m_sharing = YES;
    
    switch(option)
    {
        case SHAREMODE_EMAIL:
        case SHAREMODE_TWITTER:
        case SHAREMODE_FACEBOOK:
        case SHAREMODE_WEIBO:
        {
            float w, h;
            int quality;
            if(option==SHAREMODE_EMAIL)
            {
                w = 1024;
                h = 768;
                quality = QUALITY_EMAIL;
            }
            else
            {
                w = 640;
                h = 480;
                quality = QUALITY_SOCIAL;
            }
            
            self.savingViewController = [[[IMImageSavingViewController alloc] init] autorelease];
            
            self.savingViewController.view.frame = self.view.bounds;
            self.savingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            self.savingViewController.delegate = self;
            
            CGRect bounds = [m_app.tree getBoundingBox];
            if(bounds.size.width > bounds.size.height)
                self.savingViewController.drawsize = CGSizeMake(w, h);
            else
                self.savingViewController.drawsize = CGSizeMake(h, w);
            self.savingViewController.shareMode = option;
            self.savingViewController.quality = quality;
            self.savingViewController.addLogo = YES;
            
            [self addChildViewController:self.savingViewController];
            [self.view addSubview:self.savingViewController.view];
            
            self.savingViewController.view.alpha = 0;
            self.view.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.savingViewController.view.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                 [self.savingViewController didMoveToParentViewController:self];
                                 self.view.userInteractionEnabled = YES;
                             }];
        }
            break;
            
        case SHAREMODE_CAMERAROLL:
        {
            IMImageAdjusterViewController *vc = [[IMImageAdjusterViewController alloc] init];
            vc.delegate = self;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:vc];
            [vc release];
            
            [self presentViewController:navcontroller animated:YES completion:^{}];
            [navcontroller release];
        }
            break;
            
        case SHAREMODE_VIDEO:
        {
            IMVideoAdjusterViewController *vc = [[IMVideoAdjusterViewController alloc] init];
            vc.delegate = self;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:vc];
            [vc release];
            
            [self presentViewController:navcontroller animated:YES completion:^{}];
            [navcontroller release];
        }
            break;
            
        case SHAREMODE_YOUTUBE:
            break;
            
        case SHAREMODE_PDF:
        {
            IMPDFAdjusterViewController *vc = [[IMPDFAdjusterViewController alloc] init];
            vc.delegate = self;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            UINavigationController *navcontroller = [[UINavigationController alloc] initWithRootViewController:vc];
            [vc release];
            
            [self presentViewController:navcontroller animated:YES completion:^{}];
            [navcontroller release];
        }
            break;
            
        default:
            [self sharingDidFinish];
            break;
    }
}

- (void)sharingDidFinish
{
    [self enableDisplayUpdatesWithRedraw:YES];
    m_sharing = NO;
}

- (void)imageSaveDidSucceed:(BOOL)success
{
    // dismiss image saving VC
    [self.savingViewController willMoveToParentViewController:nil];
    [self.savingViewController.view removeFromSuperview];
    [self.savingViewController removeFromParentViewController];
    self.savingViewController = nil;
    [self sharingDidFinish];
}

- (void)imageAdjusterVCDidSucceed:(BOOL)success
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self sharingDidFinish];
    }];
}

- (void)pdfAdjusterVCDidSucceed:(BOOL)success
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self sharingDidFinish];
    }];
}

- (void)videoAdjusterVCDidSucceed:(BOOL)success
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self sharingDidFinish];
    }];
}

- (void)dealloc
{
    [_currentMenu release];
    
    [m_timeout invalidate];
    [m_timeout release];
    
    [self dismissTreeViewController];
    
    [_controlView release];
    [_settingsMenu release];
    [_savingViewController release];
    
    [super dealloc];
}

@end

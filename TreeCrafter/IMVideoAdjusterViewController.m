//
//  IMVideoAdjusterViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMVideoAdjusterViewController.h"

@interface IMVideoAdjusterViewController ()

@end

@implementation IMVideoAdjusterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_currentDuration = 15;
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMVideoAdjusterView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    DEBUG_LOG(@"IMVideoAdjusterVC viewDidLoad");
    
    [self setTitle:NSLS_SAVE_VIDEO];
    
    UIBarButtonItem *barButton;
    
    barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(buttonDone:)];
    [[self navigationItem] setRightBarButtonItem:barButton];
    [barButton release];
    
    barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(buttonCancel:)];
    [[self navigationItem] setLeftBarButtonItem:barButton];
    [barButton release];
    
	IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    
    [iv.playButton addTarget:self action:@selector(buttonPlay:) forControlEvents:UIControlEventTouchUpInside];
    [iv.stopButton addTarget:self action:@selector(buttonStop:) forControlEvents:UIControlEventTouchUpInside];
    [iv.lengthButton addTarget:self action:@selector(buttonDuration:) forControlEvents:UIControlEventTouchUpInside];
    [iv.scrubSlider addTarget:self action:@selector(scrubSliderChange:) forControlEvents:UIControlEventValueChanged];
    
    [iv setDurationLabel:NSLS_15_SEC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if(self.videoDurationPopover)
    {
        [self.videoDurationPopover dismissPopoverAnimated:YES];
        self.videoDurationPopover = nil;
        
        IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
        iv.lengthButton.enabled = YES;
    }
}

- (void)startPlaying
{
    IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    if(!m_playing && iv.scrubSlider.value < 1)
    {
        [iv.playButton setButtonPause];
        m_playing = YES;
        
        m_timer = [[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(playTimer:) userInfo:nil repeats:YES] retain];
        m_t = CACurrentMediaTime();
    }
}

- (void)stopPlaying
{
    if(m_playing)
    {
        IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
        [iv.playButton setButtonPlay];
        m_playing = NO;
        
        [m_timer invalidate];
        [m_timer release];
        m_timer = nil;
    }
}

- (void)playTimer:(id)sender
{
    IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    float t = iv.scrubSlider.value  * m_currentDuration;
    
    double tnew = CACurrentMediaTime();
    t +=  (float)(tnew - m_t);
    m_t = tnew;

    float v = t / m_currentDuration;
    if(v>=1)
    {
        v = 1;
        [self stopPlaying];
    }
    
    iv.scrubSlider.value = v;
    iv.treeView.time = v * m_currentDuration;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    DEBUG_LOG(@"IMVideoAdjusterVC resigning active");
    [self stopPlaying];
}

- (void)disableBarButtons
{
    [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
}

- (void)enableBarButtons
{
    [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
}

- (void)buttonCancel:(id)sender
{
    DEBUG_LOG(@"IMVideoAdjusterVC buttonCancel");
    
    [self stopPlaying];
    [self cleanUpOnExit];
    [self.delegate videoAdjusterVCDidSucceed:NO];
}

- (void)buttonDone:(id)sender
{
    DEBUG_LOG(@"IMVideoAdjusterVC buttonDone");
    
    [self stopPlaying];
    [self disableBarButtons];
    
    IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    [iv.treeView destroyResources];
    
    self.savingViewController = [[[IMVideoSavingViewController alloc] init] autorelease];
    self.savingViewController.delegate = self;
    
    self.savingViewController.view.frame = self.view.bounds;
    self.savingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.savingViewController.drawScale = iv.treeView.drawScale;
    self.savingViewController.drawOrigin = iv.treeView.drawOrigin;
    self.savingViewController.duration = m_currentDuration;
    
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

- (void)videoSaveDidSucceed:(BOOL)success
{
    [self.savingViewController willMoveToParentViewController:nil];
    [self.savingViewController.view removeFromSuperview];
    [self.savingViewController removeFromParentViewController];
    self.savingViewController = nil;
    
    [self enableBarButtons];
    
    if(success)
    {
        [self cleanUpOnExit];
        [self.delegate videoAdjusterVCDidSucceed:YES];
    }
}

- (void)buttonPlay:(IMRoundedButton *)sender
{
    DEBUG_LOG(@"IMVideoAdjusterVC buttonPlay");
    if(m_playing)
    {
        [self stopPlaying];
    }
    else
    {
        [self startPlaying];
    }
}

- (void)buttonStop:(IMRoundedButton *)sender
{
    DEBUG_LOG(@"IMVideoAdjusterVC buttonStop");
    IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    iv.scrubSlider.value = 0;
    iv.treeView.time = 0;
    [self stopPlaying];
}

- (void)scrubSliderChange:(UISlider *)sender
{
    IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    
    [self stopPlaying];
    
    float v = sender.value;
    iv.treeView.time = v * m_currentDuration;
}

- (void)buttonDuration:(IMRoundedButton *)sender
{
    DEBUG_LOG(@"IMVideoAdjusterVC buttonDuration");
    
    [self stopPlaying];
    
    if(!self.videoDurationPopover)
    {
        sender.enabled = NO;
        IMVideoDurationViewController *durationVC = [[IMVideoDurationViewController alloc] initWithDuration:m_currentDuration];
        durationVC.delegate = self;
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:durationVC];
        [durationVC release];
        
        self.videoDurationPopover = [[[UIPopoverController alloc] initWithContentViewController:nc] autorelease];
        self.videoDurationPopover.delegate = self;
        [nc release];
        
        [self.videoDurationPopover presentPopoverFromRect:sender.bounds
                                                   inView:sender
                                 permittedArrowDirections:UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? UIPopoverArrowDirectionDown : UIPopoverArrowDirectionRight
                                                 animated:YES];
    }
}

- (void)videoDurationVCDidFinishWithDuration:(int)duration durationLabel:(NSString *)label
{
    DEBUG_LOG(@"IMVideoAdjusterVC videoDurationVCDidFinishWithDuration");
    
    m_currentDuration = duration;
    
    IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
    [iv setDurationLabel:label];
    iv.treeView.time = 0;
    iv.scrubSlider.value = 0;
    
    [self.videoDurationPopover dismissPopoverAnimated:YES];
    self.videoDurationPopover = nil;
    
    iv.lengthButton.enabled = YES;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    DEBUG_LOG(@"IMVideoAdjusterVC popoverControllerDidDismissPopover");
    
    if(popoverController==self.videoDurationPopover)
    {
        self.videoDurationPopover = nil;
        
        IMVideoAdjusterView *iv = (IMVideoAdjusterView *)self.view;
        iv.lengthButton.enabled = YES;
    }
}

- (void)cleanUpOnExit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMVideoAdjusterVC dealloc");
    
    [m_timer invalidate];
    [m_timer release];
    [_videoDurationPopover release];
    [_savingViewController release];
    [super dealloc];
}

@end

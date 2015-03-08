//
//  IMSettingsMenuViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/23/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSettingsMenuViewController.h"
#import "IMSettingsMenuView.h"
#include "IMAppDelegate.h"
#import "IMSettingsGestureView.h"
#import "IMSettingsInfoView.h"

@interface IMSettingsMenuViewController ()

@end

#define NUM_VIEWS 2

@implementation IMSettingsMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_titleNames = [[NSArray arrayWithObjects:
                         NSLS_TOUCH_CONTROLS, NSLS_USAGE_GUIDE, nil] retain];
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMSettingsMenuView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    IMSettingsMenuView *v = (IMSettingsMenuView *)self.view;
    
    [v.cancelButton addTarget:self action:@selector(cancelButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [v.leftButton addTarget:self action:@selector(leftButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [v.rightButton addTarget:self action:@selector(rightButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    
    UISwipeGestureRecognizer *swipeRightGesture = [[[UISwipeGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(gestureSwipeRight:)] autorelease];
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGesture];
    
    UISwipeGestureRecognizer *swipeLeftGesture = [[[UISwipeGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(gestureSwipeLeft:)] autorelease];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];
    
    m_index = 0;
    self.currentView = [self viewForIndex:m_index];
    [v.containerView addSubview:self.currentView];
    
    v.leftButton.enabled = NO;
    v.title.text = m_titleNames[m_index];
}

- (UIView *)viewForIndex:(int)index
{
    if(index==0)
        return [[[IMSettingsGestureView alloc] initWithFrame:CGRectZero] autorelease];
    else if(index==1)
        return [[[IMSettingsInfoView alloc] initWithFrame:CGRectZero] autorelease];
    else
        return nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    DEBUG_LOG(@"IMSettingsMenuVC viewDidLayoutSubviews");
    
    IMSettingsMenuView *v = (IMSettingsMenuView *)self.view;
    float x = self.currentView.frame.origin.x; // preserves x offset in case we rotate mid animation
    self.currentView.frame = CGRectMake(x, 0, v.containerView.bounds.size.width, v.containerView.bounds.size.height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DEBUG_LOG(@"IMSettingsMenuVC viewWillDisappear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animateToViewWithIndex:(int)index
{
    DEBUG_LOG(@"IMSettingsMenuVC animateToViewWithIndex %d", index);
    
    IMSettingsMenuView *v = (IMSettingsMenuView *)self.view;
    
    self.appearingView = [self viewForIndex:index];
    if(index > m_index)
        self.appearingView.frame = CGRectMake(v.containerView.bounds.size.width, 0, v.containerView.bounds.size.width, v.containerView.bounds.size.height);
    else
        self.appearingView.frame = CGRectMake(-v.containerView.bounds.size.width, 0, v.containerView.bounds.size.width, v.containerView.bounds.size.height);
    
    [v.containerView addSubview:self.appearingView];
    v.title.text = m_titleNames[index];
    
    v.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.appearingView.frame = CGRectMake(0, 0, v.containerView.bounds.size.width, v.containerView.bounds.size.height);
                         if(index > m_index)
                             self.currentView.frame = CGRectMake(-v.containerView.bounds.size.width, 0, v.containerView.bounds.size.width, v.containerView.bounds.size.height);
                         else
                             self.currentView.frame = CGRectMake(v.containerView.bounds.size.width, 0, v.containerView.bounds.size.width, v.containerView.bounds.size.height);
                     }
                     completion:^(BOOL b){
                         DEBUG_LOG(@"IMSettingsMenuVC animation ended");
                         [self.currentView removeFromSuperview];
                         self.currentView = self.appearingView; // this releases the previous view
                         self.appearingView = nil; // decrement the retain count on the appearing view
                         v.userInteractionEnabled = YES;
                     }];
}

- (void)cancelButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMSettingsMenuVC cancelButtonPress");
    [self.delegate settingsMenuDidRequestDismissal];
}

- (void)gestureSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    [self rightButtonPress:nil];
}

- (void)gestureSwipeRight:(UISwipeGestureRecognizer *)sender
{
    [self leftButtonPress:nil];
}

- (void)leftButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMSettingsMenuVC leftButtonPress");
    
    IMSettingsMenuView *v = (IMSettingsMenuView *)self.view;
    
    if(m_index==0) // this is for the swipe gestures to work correctly
        return;
    
    [self animateToViewWithIndex:m_index-1];
    
    m_index--;
    if(m_index==0)
        v.leftButton.enabled = NO;
    v.rightButton.enabled = YES;
}

- (void)rightButtonPress:(UIButton *)sender
{
    DEBUG_LOG(@"IMSettingsMenuVC rightButtonPress");
    
    IMSettingsMenuView *v = (IMSettingsMenuView *)self.view;
    
    if(m_index == NUM_VIEWS-1) // this is for the swipe gestures to work correctly
        return;
    
    [self animateToViewWithIndex:m_index+1];
    
    m_index++;
    if(m_index == NUM_VIEWS-1)
        v.rightButton.enabled = NO;
    v.leftButton.enabled = YES;
}

- (void)dealloc
{
    DEBUG_LOG(@"IMSettingsMenuVC dealloc");
    
    [_currentView release];
    [_appearingView release];
    [m_titleNames release];
    
    [super dealloc];
}

@end

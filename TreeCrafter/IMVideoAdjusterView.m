//
//  IMVideoAdjusterView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMVideoAdjusterView.h"
#import <QuartzCore/QuartzCore.h>

@implementation IMVideoAdjusterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        DEBUG_LOG(@"IMVideoAdjusterView initWithFrame");
        
        m_validLayout = NO;
        
        UIColor *bgcolor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"blankbg"]];
        self.backgroundColor = bgcolor;
        [bgcolor release];
        
        self.topview = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        self.topview.backgroundColor = MENU_BG_COLOR;
        self.topview.layer.cornerRadius = 15;
        self.topview.layer.borderWidth = 3;
        self.topview.layer.borderColor = [[UIColor whiteColor] CGColor];
        [self addSubview:self.topview];
        
        self.stopButton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.stopButton];
        
        self.playButton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.playButton];
        
        self.lengthButton = [[[IMRoundedButton alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.lengthButton];
        
        [self setDurationLabel:@"?"];
        
        self.moveandscalelabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.moveandscalelabel.textColor = [UIColor whiteColor];//MENU_LIGHT_COLOR;
        self.moveandscalelabel.text = NSLS_TOUCH_TO_MOVE__;
        self.moveandscalelabel.textAlignment = NSTextAlignmentCenter;
        self.moveandscalelabel.shadowColor = MENU_DARK_COLOR;
        self.moveandscalelabel.shadowOffset = CGSizeMake(0,-1);
        self.moveandscalelabel.font = [UIFont boldSystemFontOfSize:20];
        self.moveandscalelabel.backgroundColor = [UIColor clearColor];
        [self.topview addSubview:self.moveandscalelabel];
        
        self.scrubSlider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.scrubSlider];
        
        self.treeView = [[[IMImageAdjusterTreeView alloc] initWithFrame:CGRectZero] autorelease];
        [self.topview addSubview:self.treeView];
    }
    return self;
}

- (void)layoutSubviews
{
    DEBUG_LOG(@"IMVideoAdjusterView layoutSubviews");
    
    float tw = self.frame.size.width - 40;
    float th = self.frame.size.height - 40;
    float vw = 640;
    float vh = 480;
    
    if(UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        self.topview.frame = CGRectMake(20, 20, tw, th);
        
        float ytop = 140;
        float ybuttons = 780;
        
        float x = tw/2 - 260 + 110;
        self.stopButton.frame = CGRectMake(x, ybuttons, 80, 36);
        self.playButton.frame = CGRectMake(x+100, ybuttons, 80, 36);
        self.lengthButton.frame = CGRectMake(x+220, ybuttons, 80, 36);
        
        self.moveandscalelabel.frame = CGRectMake(0.5f*(tw - vw), ytop - 40, vw, 40);
        self.treeView.frame = CGRectMake(0.5f*(tw - vw), ytop, vw, vh);
        self.scrubSlider.frame = CGRectMake(0.5f*(tw - vw)+40, ytop + vh + 20, vw - 80, 40);
         
    }
    else
    {
        self.topview.frame = CGRectMake(20, 20, tw, th);
        
        float ytop = 50;
        float ybuttons = 132 + 75;
        
        self.stopButton.frame = CGRectMake(tw - 190, ybuttons, 80, 36);
        self.playButton.frame = CGRectMake(tw - 190, ybuttons + 60, 80, 36);
        self.lengthButton.frame = CGRectMake(tw - 190, ybuttons + 140, 80, 36);
        
        self.moveandscalelabel.frame = CGRectMake(110, ytop - 40, vw, 40);
        self.treeView.frame = CGRectMake(110, ytop, vw, vh);
        self.scrubSlider.frame = CGRectMake(150, ytop + vh + 20, vw - 80, 40);
    }
    
    [self.stopButton setButtonStop];
    [self.playButton setButtonPlay];
    [self.lengthButton setButtonText:m_durationLabel];
    
    m_validLayout = YES;
}

- (void)setDurationLabel:(NSString *)label
{
    if(label!=m_durationLabel)
    {
        NSString *tmp = m_durationLabel;
        m_durationLabel = [label retain];
        [tmp release];
        
        if(m_validLayout)
            [self.lengthButton setButtonText:m_durationLabel];
    }
}

- (void)dealloc
{
    DEBUG_LOG(@"IMVideoAdjusterView dealloc");
    
    [m_durationLabel release];
    [_stopButton release];
    [_playButton release];
    [_lengthButton release];
    [_moveandscalelabel release];
    [_scrubSlider release];
    [_treeView release];
    [_topview release];
    
    [super dealloc];
}

@end

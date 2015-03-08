//
//  IMRootView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMRootView.h"

@implementation IMRootView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.leftButtonPane = [[[IMPaneView alloc] initWithFrame:CGRectZero] autorelease];
        self.rightButtonPane = [[[IMPaneView alloc] initWithFrame:CGRectZero] autorelease];
        self.rightButtonPane.isRightSide = YES;
        
        [self addSubview:self.leftButtonPane];
        [self addSubview:self.rightButtonPane];
        
        self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.settingsButton setImage:[UIImage imageNamed:@"cog"] forState:UIControlStateNormal];
        self.organizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.organizeButton setImage:[UIImage imageNamed:@"folderbutton"] forState:UIControlStateNormal];
        self.shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shareButton setImage:[UIImage imageNamed:@"sharebutton"] forState:UIControlStateNormal];
        self.colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.colorButton setImage:[UIImage imageNamed:@"colorbutton"] forState:UIControlStateNormal];
        self.animationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.animationButton setImage:[UIImage imageNamed:@"animbutton"] forState:UIControlStateNormal];
        self.shapeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.shapeButton setImage:[UIImage imageNamed:@"shapebutton"] forState:UIControlStateNormal];
        
        [self.leftButtonPane addSubview:self.settingsButton];
        [self.leftButtonPane addSubview:self.organizeButton];
        [self.leftButtonPane addSubview:self.shareButton];
        
        [self.rightButtonPane addSubview:self.colorButton];
        [self.rightButtonPane addSubview:self.animationButton];
        [self.rightButtonPane addSubview:self.shapeButton];
        
        self.startHereView = [[[IMStartHereView alloc] initWithFrame:CGRectZero] autorelease];
        [self.rightButtonPane addSubview:self.startHereView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    DEBUG_LOG(@"IMRootView layoutSubviews (%f x %f)", self.bounds.size.width, self.bounds.size.height);
    
    float w = 3*80;
    float h = 80;
    
    self.leftButtonPane.frame = CGRectMake(0, 20, w, h);
    self.rightButtonPane.frame = CGRectMake(self.bounds.size.width - w, 20, w, h);

    float xin = 25;
    float dx = 20;
    float s = 50;
    float s1 = 50;
    float y = 40 - s/2;
    float y1 = 40 - s1/2;
    
    self.organizeButton.frame = CGRectMake(xin, y1, s1, s1);
    self.shareButton.frame = CGRectMake(xin + s + dx, y1, s1, s1);
    self.settingsButton.frame = CGRectMake(xin + s + dx + s + dx, y1, s1, s1);
    self.colorButton.frame = CGRectMake(w - xin - s - dx - s - dx - s, y, s, s);
    self.animationButton.frame = CGRectMake(w - xin - s, y, s, s);
    self.shapeButton.frame = CGRectMake(w - xin - s - dx - s, y, s, s);
    
    if(self.startHereView)
        self.startHereView.frame = CGRectMake(-6, self.rightButtonPane.frame.size.height+2, 160, 80);
}

- (void)dealloc
{
    [_settingsButton release];
    [_organizeButton release];
    [_shareButton release];
    [_colorButton release];
    [_animationButton release];
    [_shapeButton release];
    
    [_leftButtonPane release];
    [_rightButtonPane release];
    
    [_startHereView release];
    
    [super dealloc];
}


@end

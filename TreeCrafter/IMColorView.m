//
//  IMColorView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMColorView.h"
#import "IMGlobal.h"

#import <QuartzCore/QuartzCore.h>

@implementation IMColorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.colorWheel = [[[IMColorWheelControl alloc] initWithFrame:CGRectZero] autorelease];
        [self.colorWheel addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        //self.colorWheel.backgroundColor = [UIColor whiteColor];
        self.colorWheel.outlineColor = [UIColor whiteColor];
        self.colorWheel.handleColor = [UIColor whiteColor];
        [self addSubview:self.colorWheel];
        
        self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = @"?";
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.label];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.button.backgroundColor = [UIColor darkGrayColor];
        //self.button.layer.cornerRadius = 8;
        [self.button setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        [self addSubview:self.button];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    float w = self.bounds.size.width;
    self.label.frame = CGRectMake(50, 12, w-80, 20);
    self.colorWheel.frame = CGRectMake(0, 38, w, 170);
    self.button.frame = CGRectMake(18, 18, 24, 24);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawControlContainerWithBounds:self.bounds];
}

- (void)valueChanged:(id)sender
{
    CGFloat r, g, b, a;
    [self.colorWheel.color getRed:&r green:&g blue:&b alpha:&a];
    [self.delegate setParam:self.target value:COLORFROMRGBFLOAT(r, g, b) redraw:YES sender:self];
}

- (void)update
{
    double color = [self.delegate getParam:self.target];
    self.colorWheel.color = [UIColor colorWithRed:REDFROMCOLOR(color) green:GREENFROMCOLOR(color) blue:BLUEFROMCOLOR(color) alpha:1];
}

- (void)dealloc
{
    [_colorWheel release];
    [_label release];
    [_button release];
    
    [super dealloc];
}

@end

//
//  IMSliderView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/13/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSliderView.h"
#import "IMGlobal.h"

#import <QuartzCore/QuartzCore.h>

@implementation IMSliderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.slider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        [self.slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        //self.slider.backgroundColor = [UIColor greenColor];
        [self addSubview:self.slider];
        
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
    self.label.frame = CGRectMake(30, 12, w-60, 20);
    self.slider.frame = CGRectMake(55, 32, w-55-30, 36);
    self.button.frame = CGRectMake(15, self.bounds.size.height / 2 - 12, 24, 24);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawControlContainerWithBounds:self.bounds];
}

- (void)valueChanged:(id)sender
{
    [self.delegate setParam:self.target value:self.slider.value redraw:YES sender:self];
}

- (void)update
{
    self.slider.value = [self.delegate getParam:self.target];
}

- (void)dealloc
{
    DEBUG_LOG(@"IMSliderView dealloc");
    
    [_slider release];
    [_label release];
    [_button release];
    
    [super dealloc];
}

@end

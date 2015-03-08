//
//  IMAnimTargetView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/18/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMAnimTargetView.h"
#import "IMGlobal.h"

#import <QuartzCore/QuartzCore.h>

@implementation IMAnimTargetView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = @"?";
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:15];
        self.label.numberOfLines = 0;
        [self addSubview:self.label];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.button.backgroundColor = [UIColor darkGrayColor];
        //self.button.layer.cornerRadius = 8;
        [self.button setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        [self addSubview:self.button];
        
        self.rateSlider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        [self.rateSlider addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.rateSlider];
        
        self.valueSlider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        [self.valueSlider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.valueSlider];
        
        self.depthSlider = [[[UISlider alloc] initWithFrame:CGRectZero] autorelease];
        [self.depthSlider addTarget:self action:@selector(depthChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.depthSlider];
        
        self.label1 = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label2 = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label3 = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label1.text = NSLS_DEPTH;
        self.label2.text = NSLS_RATE;
        self.label3.text = NSLS_VALUE;
        self.label1.textColor = [UIColor whiteColor];
        self.label2.textColor = [UIColor whiteColor];
        self.label3.textColor = [UIColor whiteColor];
        
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        if([language isEqualToString:@"ru"])
        {
            self.label1.font = [UIFont systemFontOfSize:12];
            self.label2.font = [UIFont systemFontOfSize:12];
            self.label3.font = [UIFont systemFontOfSize:12];
        }
        else
        {
            self.label1.font = [UIFont systemFontOfSize:14];
            self.label2.font = [UIFont systemFontOfSize:14];
            self.label3.font = [UIFont systemFontOfSize:14];
        }
        
        self.label1.backgroundColor = [UIColor clearColor];
        self.label2.backgroundColor = [UIColor clearColor];
        self.label3.backgroundColor = [UIColor clearColor];
        self.label1.numberOfLines = 0;
        self.label2.numberOfLines = 0;
        self.label3.numberOfLines = 0;
        [self addSubview:self.label1];
        [self addSubview:self.label2];
        [self addSubview:self.label3];
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    float w = self.bounds.size.width;
    
    float x = 21;
    float y = 45;

    self.label.frame = CGRectMake(50, 9, w-80, 36);
    self.button.frame = CGRectMake(18, 18, 24, 24);
    
    self.label1.frame = CGRectMake(x, 7+y, 66, 38);
    self.label2.frame = CGRectMake(x, 47+y, 66, 38);
    self.label3.frame = CGRectMake(x, 87+y, 66, 38);
    
    self.depthSlider.frame = CGRectMake(70+x, 10+y, w - 114, 36);
    self.rateSlider.frame = CGRectMake(70+x, 50+y, w - 114, 36);
    self.valueSlider.frame = CGRectMake(70+x, 90+y, w - 114, 36);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawControlContainerWithBounds:self.bounds];
}

- (void)update
{
    self.depthSlider.value = [self.delegate getParam:self.target];
    self.rateSlider.value = [self.delegate getParam:self.target+1];
    self.valueSlider.value = [self.delegate getParam:self.target+2];
}

- (void)depthChanged:(id)sender
{
    [self.delegate setParam:self.target value:self.depthSlider.value redraw:NO sender:self];
}

- (void)rateChanged:(id)sender
{
    [self.delegate setParam:self.target+1 value:self.rateSlider.value redraw:NO sender:self];
}

- (void)valueChanged:(id)sender
{
    [self.delegate setParam:self.target+2 value:self.valueSlider.value redraw:NO sender:self];
}

- (void)dealloc
{
    [_label release];
    [_label1 release];
    [_label2 release];
    [_label3 release];
    [_button release];
    [_rateSlider release];
    [_valueSlider release];
    [_depthSlider release];
    
    [super dealloc];
}

@end

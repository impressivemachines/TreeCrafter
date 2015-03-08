//
//  IMStepperView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMStepperView.h"
#import "IMGlobal.h"

#import <QuartzCore/QuartzCore.h>

@implementation IMStepperView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        
        self.stepper = [[[UIStepper alloc] initWithFrame:CGRectZero] autorelease];
        [self.stepper addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.stepper];
        
        self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.text = @"?";
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.label];
        
        self.value = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.value.textAlignment = NSTextAlignmentCenter;
        self.value.backgroundColor = [UIColor colorWithRed:34.0/255.0 green:97.0/255.0 blue:221.0/255.0 alpha:1];
        self.value.shadowColor = [UIColor colorWithWhite:0.3 alpha:1];
        self.value.shadowOffset = CGSizeMake(0,-1);
        self.value.textColor = [UIColor whiteColor];
        self.value.font = [UIFont systemFontOfSize:18];
        [self.value.layer setBorderWidth:1.0f];
        [self.value.layer setBorderColor:[UIColor colorWithWhite:0.3 alpha:1].CGColor];
        [self.value.layer setCornerRadius:4.0f];
        self.value.text = @"0";
        [self addSubview:self.value];
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        //self.button.backgroundColor = [UIColor darkGrayColor];
        //self.button.layer.cornerRadius = 8;
        [self.button setImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        [self addSubview:self.button];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.stepper.frame = CGRectMake(75, 48, 60, 28);
    self.value.frame = CGRectMake(202, 48, 40, 28);
    self.label.frame = CGRectMake(30, 12, self.bounds.size.width-60, 20);
    self.button.frame = CGRectMake(15, self.bounds.size.height / 2 - 12, 24, 24);
}

- (void)drawRect:(CGRect)rect
{
    [IMGlobal drawControlContainerWithBounds:self.bounds];
}

- (void)valueChanged:(id)sender
{
    int value = (int)self.stepper.value;
    // DEBUG_LOG(@"value change %d", value);
    self.value.text = [NSString stringWithFormat:@"%d", value];
    
    if(self.target==ID_INTERVALSTART)
    {
        // limit the count value
        int countmaxvalue = 6;
        if(value==4)
            countmaxvalue = 5;
        else if(value==5 || value==6)
            countmaxvalue = 4;
        else if(value==7 || value==8)
            countmaxvalue = 3;
        else if(value>8)
            countmaxvalue = 2;
        
        int count = (int)[self.delegate getParam:ID_INTERVALCOUNT];
        if(count>countmaxvalue)
            [self.delegate setParam:ID_INTERVALCOUNT value:countmaxvalue redraw:NO sender:self];
    }
    
    [self.delegate setParam:self.target value:value redraw:YES sender:self];
}

- (void)update
{
    int value = (int)[self.delegate getParam:self.target];
    //DEBUG_LOG(@"update %d", value);
    
    switch (self.target)
    {
        case ID_INTERVALSTART:
            self.stepper.minimumValue = 2;
            self.stepper.maximumValue = 12;
            break;
            
        case ID_INTERVALCOUNT:
        {
            int startvalue = (int)[self.delegate getParam:ID_INTERVALSTART];
            int countmaxvalue = 6;
            if(startvalue==4)
                countmaxvalue = 5;
            else if(startvalue==5 || startvalue==6)
                countmaxvalue = 4;
            else if(startvalue==7 || startvalue==8)
                countmaxvalue = 3;
            else if(startvalue>8)
                countmaxvalue = 2;
            
            self.stepper.minimumValue = 0;
            self.stepper.maximumValue = countmaxvalue;
            break;
        }
            
        case ID_GEONODES:
            self.stepper.minimumValue = 2;
            self.stepper.maximumValue = 12;
            break;
            
        case ID_BRANCHCOUNT:
            self.stepper.minimumValue = 1;
            self.stepper.maximumValue = 6;
            break;
            
        default:
            self.stepper.minimumValue = 0;
            self.stepper.maximumValue = 0;
            break;
    }
    
    self.stepper.value = value;
    self.value.text = [NSString stringWithFormat:@"%d", value];
    
    //DEBUG_LOG(@"%f %f - %f", self.stepper.minimumValue, self.stepper.maximumValue, self.stepper.value);
}

- (void)dealloc
{
    [_stepper release];
    [_label release];
    [_value release];
    [_button release];
    
    [super dealloc];
}
@end

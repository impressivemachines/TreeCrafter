//
//  IMSettingsGestureView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/9/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSettingsGestureView.h"

@implementation IMSettingsGestureView

- (UILabel *)infoLabelWithText:(NSString *)text
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    //label.layer.borderWidth = 2;
    //label.layer.borderColor = [MENU_LIGHT_COLOR CGColor];
    //label.layer.cornerRadius = 10;
    [self addSubview:label];
    return label;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.gesture1 = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.gesture1.image = [UIImage imageNamed:@"touch1"];
        [self addSubview:self.gesture1];
        
        self.gesture2 = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.gesture2.image = [UIImage imageNamed:@"touch2"];
        [self addSubview:self.gesture2];
        
        self.gesture3 = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.gesture3.image = [UIImage imageNamed:@"touch3"];
        [self addSubview:self.gesture3];
        
        self.gesture4 = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.gesture4.image = [UIImage imageNamed:@"touch4"];
        [self addSubview:self.gesture4];
        
        self.label2 = [self infoLabelWithText:NSLS_USE_ONE_FINGER__];
        self.label3 = [self infoLabelWithText:NSLS_USE_TWO_FINGERS__];
        self.label4 = [self infoLabelWithText:NSLS_TURNING_WITH_TWO__];
        self.label5 = [self infoLabelWithText:NSLS_MOVING_TWO_FINGERS__];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    float w = self.frame.size.width;
    //float h = self.frame.size.height;
    
    float s = 140;
    float tw = 180;
    float th = 80;
    
    self.gesture1.frame = CGRectMake(32, 36, s, s);
    self.gesture2.frame = CGRectMake(w-45-s+16, 105-64, s, s);
    self.gesture3.frame = CGRectMake(32, 310-64, s, s);
    self.gesture4.frame = CGRectMake(w-48-s+16, 310-64, s, s);

    float ly = 30;
    float gap = 10;
    
    self.label2.frame = CGRectMake(w/2-tw/2, ly, tw, th);
    self.label3.frame = CGRectMake(w/2-tw/2, ly+th+gap, tw, th);
    self.label4.frame = CGRectMake(w/2-tw/2, ly+200, tw, th);
    self.label5.frame = CGRectMake(w/2-tw/2, ly+200+th+gap, tw, th);
}

- (void)dealloc
{
    DEBUG_LOG(@"IMSettingsGestureView dealloc");
    
    [_gesture1 release];
    [_gesture2 release];
    [_gesture3 release];
    [_gesture4 release];
    [_label2 release];
    [_label3 release];
    [_label4 release];
    [_label5 release];
    
    [super dealloc];
}

@end

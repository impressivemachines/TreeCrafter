//
//  IMSettingsInfoView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/9/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMSettingsInfoView.h"

@implementation IMSettingsInfoView

- (UILabel *)infoLabelWithText:(NSString *)text
{
    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.textAlignment = NSTextAlignmentLeft;
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
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.label1 = [self infoLabelWithText:NSLS__HELPMESSAGE1];
        self.label2 = [self infoLabelWithText:NSLS__HELPMESSAGE2];
        self.label3 = [self infoLabelWithText:NSLS__HELPMESSAGE3];
        self.label4 = [self infoLabelWithText:NSLS__HELPMESSAGE4];
        self.label5 = [self infoLabelWithText:NSLS__HELPMESSAGE5];

        
        self.pic1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shapebutton"]] autorelease];
        [self addSubview:self.pic1];
        self.pic2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"colorbutton"]] autorelease];
        [self addSubview:self.pic2];
        self.pic3 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"animbutton"]] autorelease];
        [self addSubview:self.pic3];
        self.pic4 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folderbutton"]] autorelease];
        [self addSubview:self.pic4];
        self.pic5 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sharebutton"]] autorelease];
        [self addSubview:self.pic5];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //float w = self.frame.size.width;
    //float h = self.frame.size.height;
    
    float tw = self.bounds.size.width-160;
    float th = 70;
    float dy = 75;
    float tx = 120;
    float ty = 22;
    
    self.label1.frame = CGRectMake(tx, ty, tw, th);
    //[self.label1 sizeToFit];
    self.label2.frame = CGRectMake(tx, ty+dy, tw, th);
    //[self.label2 sizeToFit];
    self.label3.frame = CGRectMake(tx, ty+2*dy, tw, th);
    //[self.label3 sizeToFit];
    self.label4.frame = CGRectMake(tx, ty+3*dy, tw, th);
    //[self.label4 sizeToFit];
    self.label5.frame = CGRectMake(tx, ty+4*dy, tw, th);
    //[self.label5 sizeToFit];
    
    float px = 40;
    float py = 30;
    float s = 50;
    
    self.pic1.frame = CGRectMake(px,py,s,s);
    self.pic2.frame = CGRectMake(px,py+dy,s,s);
    self.pic3.frame = CGRectMake(px,py+2*dy,s,s);
    self.pic4.frame = CGRectMake(px,py+3*dy,s,s);
    self.pic5.frame = CGRectMake(px,py+4*dy,s,s);
}


- (void)dealloc
{
    DEBUG_LOG(@"IMSettingsInfoView dealloc");
    
    [_label1 release];
    [_label2 release];
    [_label3 release];
    [_label4 release];
    [_label5 release];
    [_pic1 release];
    [_pic2 release];
    [_pic3 release];
    [_pic4 release];
    [_pic5 release];
    
    [super dealloc];
}

@end

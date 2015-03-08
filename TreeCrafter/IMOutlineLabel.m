//
//  IMOutlineLabel.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/5/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMOutlineLabel.h"

@implementation IMOutlineLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textOutlineColor = [UIColor whiteColor];
        self.textOutlineWidth = 2;
        self.shadowOffset = CGSizeZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    [self.textOutlineColor setStroke];
    [self.textColor setFill];

    CGContextSetShouldSubpixelQuantizeFonts(ctx, false);
    
    CGContextSetLineWidth(ctx, self.textOutlineWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(ctx, kCGTextStroke);
    [self.text drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:self.textAlignment];
    
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    [self.text drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:self.textAlignment];
}

- (void)dealloc
{
    [_textOutlineColor release];
    [super dealloc];
}

@end

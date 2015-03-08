//
//  IMStartHereView.m
//  TreeCrafter
//
//  Created by SIMON WINDER on 7/30/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMStartHereView.h"

@implementation IMStartHereView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.label.text = NSLS_START_HERE;
        self.label.font = [UIFont systemFontOfSize:20];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 1;
        self.label.textColor = [UIColor blackColor];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.shadowColor = [UIColor whiteColor];
        self.label.shadowOffset = CGSizeMake(0, 2);
        
        [self addSubview:self.label];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.label.frame = CGRectMake(10, 30, self.frame.size.width - 20, self.frame.size.height - 40);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float arroww = 6;
    float arrowh = 20;
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    float arrowx = w * 0.8f;
    float r = 20;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIColor colorWithRed:1 green:1 blue:0.6 alpha:1] setFill];
    [[UIColor blackColor] setStroke];
    
    CGContextSetLineWidth(ctx, 2);
    
    float offset = 1;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, r-offset, arrowh + offset);
    CGContextAddArcToPoint(ctx, offset,  arrowh + offset, offset,  arrowh + r-offset, r-offset);
    CGContextAddArcToPoint(ctx, offset, h-offset, r-offset, h-offset, r-offset);
    CGContextAddArcToPoint(ctx, w-offset, h-offset, w-offset, h-r-offset, r-offset);
    CGContextAddArcToPoint(ctx, w-offset,  arrowh + offset, w-r-offset,  arrowh + offset, r-offset);
    CGContextAddLineToPoint(ctx, arrowx + arroww, arrowh + offset);
    CGContextAddLineToPoint(ctx, arrowx, offset);
    CGContextAddLineToPoint(ctx, arrowx - arroww, arrowh + offset);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

- (void)dealloc
{
    [_label release];
    
    [super dealloc];
}

@end

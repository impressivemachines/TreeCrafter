//
//  IMGlobal.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/11/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMGlobal.h"

@implementation IMGlobal

+ (void)drawMenuContainerWithBounds:(CGRect)rct rightSide:(BOOL)rightSide
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    float w = rct.size.width;
    float h = rct.size.height;
    float r = 40;
    
    [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] setStroke];
    if(h>120)
        [MENU_BG_COLOR setFill];
    else
        [MENU_BG_COLOR_T setFill];
    
    CGContextSetLineWidth(ctx, 2);
    
    float offset = 1;
    
    CGContextBeginPath(ctx);
    if(rightSide)
    {
        CGContextMoveToPoint(ctx, w+1, offset);
        CGContextAddLineToPoint(ctx, r-offset, offset);
        CGContextAddArcToPoint(ctx, offset, offset, offset, r-offset, r-offset);
        CGContextAddArcToPoint(ctx, offset, h-offset, r-offset, h-offset, r-offset);
        CGContextAddLineToPoint(ctx, w+1, h-offset);
    }
    else
    {
        CGContextMoveToPoint(ctx, -1, offset);
        CGContextAddLineToPoint(ctx, w-r+offset, offset);
        CGContextAddArcToPoint(ctx, w-offset, offset, w-offset, r-offset, r-offset);
        CGContextAddArcToPoint(ctx, w-offset, h-offset, w-r+offset, h-offset, r-offset);
        CGContextAddLineToPoint(ctx, -1, h-offset);
    }
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] setStroke];
    
    CGContextSetLineWidth(ctx, 3);
    
    offset = 3.5f;
    
    CGContextBeginPath(ctx);
    if(rightSide)
    {
        CGContextMoveToPoint(ctx, w+1.5, offset);
        CGContextAddLineToPoint(ctx, r-offset, offset);
        CGContextAddArcToPoint(ctx, offset, offset, offset, r-offset, r-offset);
        CGContextAddArcToPoint(ctx, offset, h-offset, r-offset, h-offset, r-offset);
        CGContextAddLineToPoint(ctx, w+1.5, h-offset);
    }
    else
    {
        CGContextMoveToPoint(ctx, -1.5, offset);
        CGContextAddLineToPoint(ctx, w-r+offset, offset);
        CGContextAddArcToPoint(ctx, w-offset, offset, w-offset, r-offset, r-offset);
        CGContextAddArcToPoint(ctx, w-offset, h-offset, w-r+offset, h-offset, r-offset);
        CGContextAddLineToPoint(ctx, -1.5, h-offset);
    }
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

+ (void)drawScrollArrowsForScrollView:(UIScrollView *)scrollView offset:(float)offset
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 4);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    if(scrollView.contentOffset.y > 0)
    {
        float a = scrollView.contentOffset.y / 10;
        if(a>1)
            a = 1;
        [[UIColor colorWithRed:0.2 green:0.25 blue:0.35 alpha:a*0.8] set];
        
        float y = scrollView.frame.origin.y - 6;
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, scrollView.frame.origin.x + 12 + offset, y);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 80 + offset, y);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + offset, y-18);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 - 11 + offset, y-6);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + 11 + offset, y-6);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    
    float z = scrollView.contentSize.height - scrollView.contentOffset.y;
    
    if(z>scrollView.frame.size.height)
    {
        float a = (z - scrollView.frame.size.height) / 10;
        if(a>1)
            a = 1;
        
        [[UIColor colorWithRed:0.2 green:0.25 blue:0.35 alpha:a*0.8] set];
        
        float y = scrollView.frame.origin.y + scrollView.frame.size.height + 6;
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, scrollView.frame.origin.x + 12 + offset, y);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 80 + offset, y);
        CGContextDrawPath(ctx, kCGPathStroke);
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + offset, y+18);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 - 11 + offset, y+6);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + 11 + offset, y+6);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathFill);
    }
}

+ (void)drawSmallScrollArrowsForScrollView:(UIScrollView *)scrollView offset:(float)offset
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(ctx, 4);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    if(scrollView.contentOffset.y > 0)
    {
        float a = scrollView.contentOffset.y / 10;
        if(a>1)
            a = 1;
        [[UIColor colorWithRed:0.2 green:0.25 blue:0.35 alpha:a*0.8] set];
        
        float y = scrollView.frame.origin.y - 6;
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + offset, y-12);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 - 11 + offset, y);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + 11 + offset, y);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathFill);
    }
    
    float z = scrollView.contentSize.height - scrollView.contentOffset.y;
    
    if(z>scrollView.frame.size.height)
    {
        float a = (z - scrollView.frame.size.height) / 10;
        if(a>1)
            a = 1;
        
        [[UIColor colorWithRed:0.2 green:0.25 blue:0.35 alpha:a*0.8] set];
        
        float y = scrollView.frame.origin.y + scrollView.frame.size.height + 6;
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + offset, y+12);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 - 11 + offset, y);
        CGContextAddLineToPoint(ctx, scrollView.frame.origin.x + 12 + 34 + 11 + offset, y);
        CGContextClosePath(ctx);
        CGContextDrawPath(ctx, kCGPathFill);
    }
}

+ (void)drawControlContainerWithBounds:(CGRect)rct
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    float x = rct.origin.x;
    float y = rct.origin.y;
    float w = rct.size.width;
    float h = rct.size.height;
    float r = 40;
    
    [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] setStroke];
    [MENU_BG_COLOR_T setFill];
    
    CGContextSetLineWidth(ctx, 2);
    
    float offset = 1;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x+r-offset, y+offset);
    CGContextAddArcToPoint(ctx, x+offset, y+offset, x+offset, y+r-offset, r-offset);
    CGContextAddArcToPoint(ctx, x+offset, y+h-offset, x+r-offset, y+h-offset, r-offset);
    CGContextAddArcToPoint(ctx, x+w-offset, y+h-offset, x+w-offset, y+h-r-offset, r-offset);
    CGContextAddArcToPoint(ctx, x+w-offset, y+offset, x+w-r-offset, y+offset, r-offset);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    [[UIColor colorWithRed:1 green:1 blue:1 alpha:1] setStroke];
    
    CGContextSetLineWidth(ctx, 3);
    
    offset = 3.5f;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, x+r-offset, y+offset);
    CGContextAddArcToPoint(ctx, x+offset, y+offset, x+offset, y+r-offset, r-offset);
    CGContextAddArcToPoint(ctx, x+offset, y+h-offset, x+r-offset, y+h-offset, r-offset);
    CGContextAddArcToPoint(ctx, x+w-offset, y+h-offset, x+w-offset, y+h-r-offset, r-offset);
    CGContextAddArcToPoint(ctx, x+w-offset, y+offset, x+w-r-offset, y+offset, r-offset);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end

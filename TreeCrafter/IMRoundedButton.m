//
//  IMRoundedButton.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMRoundedButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation IMRoundedButton

// This is actually a pretty bad implementation of a button subclass but too much work to fix at present
// really it should use the normal button text field and have a mode field to change the appearance type
// and override the drawing code, not set images on the buttons on demand. The main problem is that it
// doesnt work if the frame is CGRectZero.

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 2;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    }
    
    return self;
}

- (void)setButtonText:(NSString *)text
{
    CGSize size = self.frame.size;
    if(size.width==0 || size.height==0)
        return;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill];
    
    [[UIColor whiteColor] set];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    CGSize textsize = [text sizeWithFont:font constrainedToSize:rect.size lineBreakMode:NSLineBreakByClipping];
    [text drawInRect:CGRectMake(0, 0.5f*(rect.size.height - textsize.height), rect.size.width, textsize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateNormal];
    
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    [path fill];
    
    [[UIColor grayColor] set];
    [text drawInRect:CGRectMake(0, 0.5f*(rect.size.height - textsize.height), rect.size.width, textsize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateDisabled];
}

- (void)setButtonColor:(UIColor *)color
{
    CGSize size = self.frame.size;
    if(size.width==0 || size.height==0)
        return;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill];
    
    [color set];
    CGContextFillRect(context, CGRectMake(10, 10, size.width-20, size.height-20));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setButtonPlay
{
    CGSize size = self.frame.size;
    if(size.width==0 || size.height==0)
        return;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill];
    
    // draw play logo
    [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
    float s = size.height - 20;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0.5f*(size.width - s), 0.5f*(size.height - s));
    CGContextAddLineToPoint(context, 0.5f*(size.width - s) + s, 0.5f*size.height);
    CGContextAddLineToPoint(context, 0.5f*(size.width - s), 0.5f*(size.height - s) + s);
    CGContextClosePath(context);
    CGContextFillPath(context);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setButtonPause
{
    CGSize size = self.frame.size;
    if(size.width==0 || size.height==0)
        return;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill];
    
    // draw pause logo
    [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
    float s = size.height - 20;
    CGContextFillRect(context, CGRectMake(0.5f*(size.width - s), 0.5f*(size.height - s), 0.3f*s, s));
    CGContextFillRect(context, CGRectMake(0.5f*(size.width - s) + 0.666f*s, 0.5f*(size.height - s), 0.333f*s, s));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setButtonStop
{
    CGSize size = self.frame.size;
    if(size.width==0 || size.height==0)
        return;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill];
    
    // draw stop logo
    [[UIColor colorWithWhite:1.0 alpha:1.0] setFill];
    float s = size.height - 20;
    CGContextFillRect(context, CGRectMake(0.5f*(size.width - s), 0.5f*(size.height - s), s, s));
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setButtonAnchorAdd:(BOOL)add
{
    CGSize size = self.frame.size;
    if(size.width==0 || size.height==0)
        return;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    [path fill]; // draws button background
    
    // draw anchor shape
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2);
    
    [[UIColor colorWithWhite:1.0 alpha:1.0] set];

    float s = 0.5f*(size.height - 20);
    float x = size.width * 0.333f;
    float y = 0.5f*(size.height - 2*s);
    float h1 = 6;
    float h2 = 2*s - h1;
    float w = h1;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x+w, y+h1);
    CGContextAddLineToPoint(context, x+w, y+h1+h2);
    CGContextAddLineToPoint(context, x-w, y+h1+h2);
    CGContextAddLineToPoint(context, x-w, y+h1);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetLineWidth(context, 3);
    x = size.width * 0.666f;
    y += 2;
    s -= 2;
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x-s, y+s);
    CGContextAddLineToPoint(context, x+s, y+s);
    if(add)
    {
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x, y+2*s);
    }
    CGContextDrawPath(context, kCGPathStroke);

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateNormal];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    context = UIGraphicsGetCurrentContext();
    
    [MENU_DARK_COLOR set];
    //[[UIColor colorWithWhite:0.2 alpha:1.0] set];
    [path fill]; // draws button background
    
    // draw grayed out anchor shape
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 2);
    
    [[UIColor grayColor] set];
    
    s = 0.5f*(size.height - 20);
    x = size.width * 0.333f;
    y = 0.5f*(size.height - 2*s);
    h1 = 6;
    h2 = 2*s - h1;
    w = h1;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y);
    CGContextAddLineToPoint(context, x+w, y+h1);
    CGContextAddLineToPoint(context, x+w, y+h1+h2);
    CGContextAddLineToPoint(context, x-w, y+h1+h2);
    CGContextAddLineToPoint(context, x-w, y+h1);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextSetLineWidth(context, 3);
    x = size.width * 0.666f;
    y += 2;
    s -= 2;
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x-s, y+s);
    CGContextAddLineToPoint(context, x+s, y+s);
    if(add)
    {
        CGContextMoveToPoint(context, x, y);
        CGContextAddLineToPoint(context, x, y+2*s);
    }
    CGContextDrawPath(context, kCGPathStroke);
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    [self setImage:newImage forState:UIControlStateDisabled];
}

@end

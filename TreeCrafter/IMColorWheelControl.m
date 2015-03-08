//
//  IMColorWheelControl.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMColorWheelControl.h"

@implementation IMColorWheelControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.color = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:1];
        
        // size is 280 x 140
        
        float x = self.bounds.size.width/2 - 140;
        float y = self.bounds.size.height/2 - 70;
        
        m_wheelx = 70+x+4;
        m_wheely = 70+y;
        m_wheelr = 50;
        
        m_mx = 161+x-4;
        m_my = 2+y;
        m_mw = 118;
        m_mh = 136;
        
        m_trackingwheel = false;
        m_trackingsv = false;
        
        m_outlineColor = [[UIColor grayColor] retain];
        m_handleColor = [[UIColor grayColor] retain];
    }
    return self;
}

- (void)dealloc
{
    [m_outlineColor release];
    [m_handleColor release];
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float x = self.bounds.size.width/2 - 140;
    float y = self.bounds.size.height/2 - 70;
    
    m_wheelx = 70+x+4;
    m_wheely = 70+y;
    
    m_mx = 161+x-4;
    m_my = 2+y;

    [self setNeedsDisplay];
}

- (UIColor *)color
{
    return [UIColor colorWithHue:m_hue saturation:m_saturation brightness:m_value alpha:1];
}

- (void)setColor:(UIColor *)color
{
    CGFloat alpha;
    [color getHue:&m_hue saturation:&m_saturation brightness:&m_value alpha:&alpha];
    [self setNeedsDisplay];
}

- (UIColor *)outlineColor
{
    return [[m_outlineColor retain] autorelease];
}

- (void)setOutlineColor:(UIColor *)color
{
    if(m_outlineColor!=color)
    {
        UIColor *oldColor = m_outlineColor;
        m_outlineColor = [color retain];
        [oldColor release];
        
        [self setNeedsDisplay];
    }
}

- (UIColor *)handleColor
{
    return [[m_handleColor retain] autorelease];
}

- (void)setHandleColor:(UIColor *)color
{
    if(m_handleColor!=color)
    {
        UIColor *oldColor = m_handleColor;
        m_handleColor = [color retain];
        [oldColor release];
        
        [self setNeedsDisplay];
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    //DEBUG_LOG(@"begin tracking %f %f", lastPoint.x, lastPoint.y);
    
    float dx = lastPoint.x - m_wheelx;
    float dy = lastPoint.y - m_wheely;
    float r = sqrtf(dx*dx+dy*dy);
    if(r < m_wheelr + 25 && r > m_wheelr - 25)
    {
        m_trackingwheel = true;
        
        float theta = atan2f(dy, dx);
        if(theta>=0)
            m_hue = 0.5f * theta / M_PI;
        else
            m_hue = 0.5f * (theta + 2*M_PI) / M_PI;
        
        [self setNeedsDisplay];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    else
    {
        m_trackingwheel = false;
    
        if(lastPoint.x >= m_mx - 20 && lastPoint.x <= m_mx + m_mw + 20 && lastPoint.y >= m_my - 20 && lastPoint.y <= m_my + m_mh + 20)
        {
            m_trackingsv = true;
            
            m_saturation = (lastPoint.x - m_mx)/m_mw;
            m_value = 1 - (lastPoint.y - m_my)/m_mh;
            
            if(m_saturation<0)
                m_saturation = 0;
            else if(m_saturation>1)
                m_saturation = 1;
            if(m_value<0)
                m_value = 0;
            else if(m_value>1)
                m_value = 1;
            
            [self setNeedsDisplay];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        else
            m_trackingsv = false;
    }
    
    //DEBUG_LOG(@"tracking state %d %d", m_trackingwheel, m_trackingsv);
    
    return (m_trackingwheel || m_trackingsv) ? YES : NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    //DEBUG_LOG(@"continue %f %f %d %d", lastPoint.x, lastPoint.y, m_trackingwheel, m_trackingsv);
    
    if(m_trackingwheel)
    {
        float dx = lastPoint.x - m_wheelx;
        float dy = lastPoint.y - m_wheely;
        float r = sqrtf(dx*dx+dy*dy);
        if(r < m_wheelr + 200 && r > 5)
        {
            float theta = atan2f(dy, dx);
            if(theta>=0)
                m_hue = 0.5f * theta / M_PI;
            else
                m_hue = 0.5f * (theta + 2*M_PI) / M_PI;
            
            [self setNeedsDisplay];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        else
        {
            //DEBUG_LOG(@"quit tracking wheel");
            m_trackingwheel = false;
        }
    }
    else if(m_trackingsv)
    {
        if(lastPoint.x >= m_mx - 50 && lastPoint.x <= m_mx + m_mw + 50 && lastPoint.y >= m_my - 50 && lastPoint.y <= m_my + m_mh + 50)
        {
            m_saturation = (lastPoint.x - m_mx)/m_mw;
            m_value = 1 - (lastPoint.y - m_my)/m_mh;
            
            if(m_saturation<0)
                m_saturation = 0;
            else if(m_saturation>1)
                m_saturation = 1;
            if(m_value<0)
                m_value = 0;
            else if(m_value>1)
                m_value = 1;
            
            [self setNeedsDisplay];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        else
        {
            //DEBUG_LOG(@"quit tracking sv");
            m_trackingsv = false;
        }
    }
    
    return (m_trackingwheel || m_trackingsv) ? YES : NO;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)drawRect:(CGRect)rect
{
    //DEBUG_LOG(@"frame %f %f", self.frame.size.width, self.frame.size.height);
    
    UIColor *controlFGColor = [UIColor colorWithHue:m_hue saturation:0.25f brightness:1 alpha:1];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    CGContextSetLineWidth(ctx, 40);
    [m_outlineColor setStroke];
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, m_wheelx, m_wheely, m_wheelr, 0, M_PI*2, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    CGContextSetLineWidth(ctx, 38);
    int i;
    for(i=0; i<72; i++)
    {
        float hue = i*5;
        //[[self rgbFromHue:hue saturation:1 value:1] setStroke];
        [[UIColor colorWithHue:hue/360.0f saturation:1 brightness:1 alpha:1] setStroke];
        
        CGContextBeginPath(ctx);
        CGContextAddArc(ctx, m_wheelx, m_wheely, m_wheelr, M_PI*(hue-3)/180.0f, M_PI*(hue+3)/180.0f, 0);
        CGContextDrawPath(ctx, kCGPathStroke);
    }

    float huedx = m_wheelr * cosf(m_hue*2*M_PI);
    float huedy = m_wheelr * sinf(m_hue*2*M_PI);
    
    [m_handleColor setStroke];
    CGContextSetLineWidth(ctx, 8);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, m_wheelx + huedx, m_wheely + huedy, 14, 0, M_PI*2, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    [controlFGColor setStroke];
    CGContextSetLineWidth(ctx, 6);
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, m_wheelx + huedx, m_wheely + huedy, 14, 0, M_PI*2, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    [m_outlineColor setFill];
    CGContextFillRect(ctx, CGRectMake(m_mx-1, m_my-1, m_mw+2, m_mh+2));
    
    int j;
    for(i=0; i<20; i++)
        for(j=0; j<15; j++)
        {
            float sat = j/14.0f;
            float val = 1-(i/19.0f);
            
            [[UIColor colorWithHue:m_hue saturation:sat brightness:val alpha:1] setFill];
            
            float dx = 0;
            float dy = 0;
            if(j<14)
                dx = 1;
            if(i<19)
                dy = 1;
            CGContextFillRect(ctx, CGRectMake(m_mx + j*m_mw/15.0f, m_my + i*m_mh/20.0f, m_mw/15.0f + dx, m_mh/20.0f + dy));
        }
    
    float svx = m_mx + m_saturation * m_mw;
    float svy = m_my + (1-m_value) * m_mh;
    
    [m_handleColor setStroke];
    CGContextSetLineWidth(ctx, 8);
    CGContextBeginPath(ctx);
    CGContextClipToRect(ctx, CGRectMake(m_mx, m_my, m_mw, m_mh));
    CGContextAddArc(ctx, svx, svy, 14, 0, M_PI*2, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    [controlFGColor setStroke];
    CGContextSetLineWidth(ctx, 6);
    CGContextBeginPath(ctx);
    CGContextClipToRect(ctx, CGRectMake(m_mx, m_my, m_mw, m_mh));
    CGContextAddArc(ctx, svx, svy, 14, 0, M_PI*2, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
}

@end

//
//  IMColorWheelControl.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "fractaltrees.h"

@interface IMColorWheelControl : UIControl
{
    CGFloat m_hue, m_saturation, m_value;
    
    float m_wheelx;
    float m_wheely;
    float m_wheelr;
    
    float m_mx;
    float m_my;
    float m_mw;
    float m_mh;
    
    bool m_trackingwheel;
    bool m_trackingsv;
    
    UIColor *m_outlineColor;
    UIColor *m_handleColor;
}

- (UIColor *)color;
- (void)setColor:(UIColor *)color;

- (UIColor *)outlineColor;
- (void)setOutlineColor:(UIColor *)color;

- (UIColor *)handleColor;
- (void)setHandleColor:(UIColor *)color;
@end

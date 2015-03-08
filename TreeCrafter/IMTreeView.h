//
//  IMTreeView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@class IMTreeRender;

struct DisplayParams
{
    CGPoint origin;
    float scale;
    float initialSize;
};

@interface IMTreeView : UIView
{
    NSThread *m_animation_thread;
    IMTreeRender *m_render;
    
    double m_t;
    BOOL m_use_multisampling;
}

@property (atomic, assign) struct DisplayParams dp;

- (void)drawView;
- (void)drawBackground;
- (void)destroyResources;
- (void)startAnimationThread;
- (void)stopAnimationThread;
- (BOOL)isAnimating;

@end

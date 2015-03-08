//
//  IMTreeViewController.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMTreeModel.h"
#import "IMProtocol.h"

@interface IMTreeViewController : UIViewController <UIGestureRecognizerDelegate>
{
    IMTreeModel *m_tree;
    CGSize m_oldviewsize;
    BOOL m_init_done;
    int m_drawing_state;
    BOOL m_animation_enable;
    BOOL m_touches_state;
}

@property (nonatomic, assign) id <IMTreeParamProtocol> delegate;

- (void)resetPosition;
- (void)drawView; // gets called when a parameter changed

- (void)startAnimating;
- (void)stopAnimatingWithRedraw:(BOOL)redraw;

- (void)enableDisplayUpdatesWithRedraw:(BOOL)redraw;
- (void)disableDisplayUpdatesWithRedraw:(BOOL)redraw;
- (BOOL)allowsDisplayUpdates;

- (void)enableTouches;
- (void)disableTouches;
- (BOOL)allowsTouches;

@end

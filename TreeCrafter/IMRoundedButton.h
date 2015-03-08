//
//  IMRoundedButton.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//
//  Custom buttons for saving VCs

#import <UIKit/UIKit.h>
#import "fractaltrees.h"

@interface IMRoundedButton : UIButton

- (void)setButtonText:(NSString *)text;
- (void)setButtonColor:(UIColor *)color;
- (void)setButtonPlay;
- (void)setButtonPause;
- (void)setButtonStop;
- (void)setButtonAnchorAdd:(BOOL)add;

@end

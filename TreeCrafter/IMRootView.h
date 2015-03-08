//
//  IMRootView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/10/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMPaneView.h"
#import "IMTreeView.h"
#import "IMStartHereView.h"

@interface IMRootView : UIView

@property (nonatomic, retain) IMPaneView *leftButtonPane;
@property (nonatomic, retain) IMPaneView *rightButtonPane;

@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) UIButton *organizeButton;
@property (nonatomic, retain) UIButton *shareButton;
@property (nonatomic, retain) UIButton *colorButton;
@property (nonatomic, retain) UIButton *animationButton;
@property (nonatomic, retain) UIButton *shapeButton;

@property (nonatomic, retain) IMStartHereView *startHereView;

@end

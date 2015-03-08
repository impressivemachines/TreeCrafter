//
//  IMStepperView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@interface IMStepperView : UIView <IMControlProtocol>

@property (nonatomic, assign) id <IMTreeParamProtocol> delegate;

@property (retain, nonatomic) UIStepper *stepper;
@property (retain, nonatomic) UILabel *label;
@property (retain, nonatomic) UILabel *value;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, assign) int target;

- (void)update;
@end

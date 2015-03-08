//
//  IMAnimTargetView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/18/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMProtocol.h"

@interface IMAnimTargetView : UIView <IMControlProtocol>

@property (nonatomic, assign) id <IMTreeParamProtocol> delegate;

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UILabel *label1;
@property (nonatomic, retain) UILabel *label2;
@property (nonatomic, retain) UILabel *label3;
@property (nonatomic, retain) UIButton *button;
@property (retain, nonatomic) UISlider *depthSlider;
@property (retain, nonatomic) UISlider *rateSlider;
@property (retain, nonatomic) UISlider *valueSlider;
@property (nonatomic, assign) int target;

- (void)update;
@end

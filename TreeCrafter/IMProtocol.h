//
//  IMProtocol.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMPresentationProtocol
- (int)currentControl;
- (void)showControl:(int)control y:(int)y;
- (void)randomSeedRefresh;
- (void)resetPosition;
- (void)performSharingWithOption:(int)option;
@end

@protocol IMMenuProtocol
- (int)widthForMenu;
- (BOOL)isRightSide;
- (void)update;
@property (nonatomic, assign) id <IMPresentationProtocol> delegate;
@end

@protocol IMTreeParamProtocol
- (void)setTreeParameters:(NSDictionary *)params;
- (double)getParam:(int)paramid;
- (void)setParam:(int)paramid value:(double)value redraw:(BOOL)redraw sender:(id)sender;
- (double)getRawParam:(int)paramid;
- (void)setRawParam:(int)paramid value:(double)value redraw:(BOOL)redraw sender:(id)sender;
@end

@protocol IMControlProtocol
- (void)update;
@property (nonatomic, assign) id <IMTreeParamProtocol> delegate;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, assign) int target;
@property (nonatomic, retain) UILabel *label;
@end



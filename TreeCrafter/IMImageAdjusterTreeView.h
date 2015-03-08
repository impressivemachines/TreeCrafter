//
//  IMImageAdjusterTreeView.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/2/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fractaltrees.h"
#import "IMOutlineLabel.h"

@class IMTreeRender;
@class IMTreeModel;

@interface IMImageAdjusterTreeView : UIView
{
    IMTreeRender *m_render;
    IMTreeModel *m_tree;
    
    float m_time;
    float m_lineWidth;
    BOOL m_validLayout;
    BOOL m_use_multisampling;
    
    IMOutlineLabel *m_headerLabel;
    UILabel *m_footerLabel;
}

@property (nonatomic, assign) float drawScale;
@property (nonatomic, assign) float initialScale;
@property (nonatomic, assign) CGPoint drawOrigin;

- (void)setHasBackground:(BOOL)hasBackground;
- (BOOL)hasBackground;
- (void)setBackgroundImage:(UIImage *)image;
- (UIImage *)backgroundImage;
- (void)setTime:(float)time;
- (float)time;
- (void)setHeaderText:(NSString *)headerText;
- (NSString *)headerText;
- (void)setFooterText:(NSString *)footerText;
- (NSString *)footerText;
- (void)setTextColor:(UIColor *)color;
- (UIColor *)textColor;
- (void)setLineWidth:(float)lineWidth;
- (float)lineWidth;

- (void)drawView;
- (void)destroyResources;

@end

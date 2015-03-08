//
//  IMTreeModel.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "fractaltrees.h"

@protocol IMTreeModelDelegate
- (BOOL)callbackForProgress:(float)progress;
@end

@interface IMTreeModel : NSObject
{
    struct ITreeModel *m_tree;
    NSLock *m_treeLock;
}

@property (nonatomic, assign) id<IMTreeModelDelegate> delegate;

- (id)init;
- (void)setTreeParameters:(NSDictionary *)params;
- (NSDictionary *)treeParameters;
- (void)randomSeedRefresh;
- (double)getParam:(int)paramid;
- (void)setParam:(int)paramid value:(double)value;
- (double)getRawParam:(int)paramid;
- (void)setRawParam:(int)paramid value:(double)value;
- (void)drawViewWithShader:(GLuint)shader width:(float)view_w height:(float)view_h x:(float)view_x y:(float)view_y
                     scale:(float)view_scale dt:(float)dt abstime:(BOOL)abstime background:(BOOL)background rbswap:(BOOL)rbswap linewidth:(float)linewidth;
- (void)drawBackgroundOnly;
- (CGRect)getBoundingBox;
- (void)freeMemory;
- (BOOL)scaleOffsetForViewWithBounds:(CGRect)bounds ox:(float *)drawx oy:(float *)drawy scale:(float *)drawscale;
- (int)drawWithContext:(CGContextRef)context bounds:(CGRect)bounds ox:(float)drawx oy:(float)drawy scale:(float)drawscale quality:(int)quality vertextarget:(int)vertextarget drawbackground:(BOOL)db linewidth:(float)linewidth animationtime:(float)time;
- (UIImage *)drawImageWithSize:(CGSize)size ox:(float)drawx oy:(float)drawy scale:(float)drawscale quality:(int)quality adaptForDisplay:(BOOL)adaptForDisplay background:(UIImage *)image header:(NSString *)header footer:(NSString *)footer textcolor:(UIColor *)textcolor logo:(BOOL)addLogo error:(int *)perror;

@end


//
//  IMTreeView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMTreeView.h"
#import "IMAppDelegate.h"
#import "IMTreeRender.h"

@implementation IMTreeView

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    DEBUG_LOG(@"IMTreeView initWithFrame");
    self = [super initWithFrame:frame];
    if (self)
    {
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        m_render = app.render;
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil]; // these are the default values
        
        float scale = [[UIScreen mainScreen] scale];
        if(scale==2)
        {
            self.contentScaleFactor = 2;
            m_use_multisampling = NO;
        }
        else if(scale==1)
        {
            self.contentScaleFactor = 2;
            m_use_multisampling = NO;
        }
        else
            m_use_multisampling = YES;
    }
    return self;
}

- (BOOL)isOpaque
{
    return YES;
}

// called from UI thread only
- (void)destroyResources
{
    DEBUG_LOG(@"IMTreeView destroyResources");
    
    [m_render destroyResources];
}

// called from UI thread only
- (void)layoutSubviews
{
    [super layoutSubviews];
    DEBUG_LOG(@"IMTreeView layoutSubviews (%f x %f)", self.bounds.size.width, self.bounds.size.height);
}

// called from UI thread and animation thread, but never simultaneously
- (void)drawView
{
    float dt;
    if(m_animation_thread)
    {
        double t = CACurrentMediaTime();
        if(m_t==0)
            dt = 0;
        else
            dt = (float)(t - m_t);
        if(dt>1)
            dt = 0;
        m_t = t;
    }
    else
        dt = 0;
    
    DEBUG_LOG(@"IMTreeView drawView with dt = %f", dt);
    
    struct DisplayParams dp = self.dp; // protected by atomic assignment

    m_render.drawOrigin = dp.origin;
    m_render.drawScale = dp.scale * dp.initialSize;
    m_render.time = dt;
    m_render.useRelativeTime = YES;
    m_render.lineWidth = 0;
    m_render.backgroundImage = nil;
    m_render.backgroundIsTransparent = NO;
    
    [m_render renderToView:self showTree:YES multisample:m_use_multisampling];
}

// called from UI thread only, and only while animation is disabled
- (void)drawBackground
{
    DEBUG_LOG(@"IMTreeView drawBackground");

    m_render.backgroundImage = nil;
    m_render.backgroundIsTransparent = NO;
    
    [m_render renderToView:self showTree:NO multisample:m_use_multisampling];
}

- (void)animationThreadMain
{
    @autoreleasepool {
        DEBUG_LOG(@"IMTreeView animation thread begin");
        
        m_t = 0;
        while(![[NSThread currentThread] isCancelled])
        {
            @autoreleasepool {
                [self drawView];
                if(![[NSThread currentThread] isCancelled])
                    [NSThread sleepForTimeInterval:ANIMATION_DELAY];
            }
        }
        
        DEBUG_LOG(@"IMTreeView animation thread end");
    }
}

// called from UI thread only
- (void)startAnimationThread
{
    if(!m_animation_thread)
    {
        DEBUG_LOG(@"IMTreeView starting amimation");
        m_animation_thread = [[NSThread alloc] initWithTarget:self selector:@selector(animationThreadMain) object:nil];
        [m_animation_thread start];
        DEBUG_LOG(@"IMTreeView starting amimation done");
    }
}

// called from UI thread only
- (void)stopAnimationThread
{
    if(m_animation_thread)
    {
        DEBUG_LOG(@"IMTreeView stopping amimation");
        [m_animation_thread cancel];
        
        while(![m_animation_thread isFinished])
            [NSThread sleepForTimeInterval:0.005];
        
        [m_animation_thread release];
        m_animation_thread = nil;
        DEBUG_LOG(@"IMTreeView stopping amimation done");
    }
}

- (BOOL)isAnimating
{
    return m_animation_thread!=nil;
}

// called from UI thread only
- (void)dealloc
{
    DEBUG_LOG(@"IMTreeView dealloc");

    [self stopAnimationThread];

    [m_animation_thread release];
    
    [super dealloc];
}

@end

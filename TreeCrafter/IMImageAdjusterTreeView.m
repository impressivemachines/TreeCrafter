//
//  IMImageAdjusterTreeView.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/2/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMImageAdjusterTreeView.h"
#import "IMAppDelegate.h"
#import "IMTreeModel.h"
#import "IMTreeRender.h"

#import <QuartzCore/QuartzCore.h>

@implementation IMImageAdjusterTreeView

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        DEBUG_LOG(@"IMImageAdjusterTreeView initWithFrame");
        
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 1;
        
        //self.backgroundColor = [UIColor grayColor];
        
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        m_render = app.render;
        m_tree = app.tree;
        
        m_render.backgroundImage = nil;
        m_render.backgroundIsTransparent = NO;
        
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
            self.contentScaleFactor = 1;
            m_use_multisampling = YES;
        }
        else
        {
            m_use_multisampling = YES;
        }
        
        UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(gestureTap:)] autorelease];
        tapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(gesturePan:)] autorelease];
        [self addGestureRecognizer:panGesture];
        
        UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(gesturePinch:)] autorelease];
        [self addGestureRecognizer:pinchGesture];
        
        m_lineWidth = 0;
        
        m_headerLabel = [[IMOutlineLabel alloc] initWithFrame:CGRectZero];
        m_headerLabel.hidden = YES;
        m_headerLabel.textAlignment = NSTextAlignmentCenter;
        m_headerLabel.numberOfLines = 0;
        m_headerLabel.backgroundColor = [UIColor clearColor];
        m_headerLabel.textOutlineColor = [UIColor blackColor];
        m_headerLabel.textColor = [UIColor whiteColor];
        m_headerLabel.text = @"?";
        [self addSubview:m_headerLabel];
        
        m_footerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        m_footerLabel.hidden = YES;
        m_footerLabel.textAlignment = NSTextAlignmentRight;
        m_footerLabel.numberOfLines = 0;
        m_footerLabel.backgroundColor = [UIColor clearColor];
        m_footerLabel.textColor = [UIColor whiteColor];
        m_footerLabel.text = @"?";
        [self addSubview:m_footerLabel];
        
        m_validLayout = NO;
    }
    return self;
}

- (BOOL)isOpaque
{
    return YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    DEBUG_LOG(@"IMImageAdjusterTreeView layoutSubviews");
    
    [self drawView];
    
    [self updateTextFrames];
    
    m_validLayout = YES;
    
    [self performSelector:@selector(drawView) withObject:self afterDelay:0];
}

- (void)updateTextFrames
{
    float minsize = self.bounds.size.width;
    if(self.bounds.size.height < minsize)
        minsize = self.bounds.size.height;
    
    float xborder = minsize * 0.06f;
    float topborder = minsize * 0.06f;
    float bottomborder = minsize * 0.06f;
    
    m_headerLabel.font = [UIFont boldSystemFontOfSize:minsize * 0.0725f];
    m_headerLabel.textOutlineWidth = minsize * 0.0038f;
    
    CGSize headersize = [m_headerLabel.text
                         sizeWithFont:m_headerLabel.font
                         constrainedToSize:CGSizeMake(self.bounds.size.width - 2*xborder , self.bounds.size.height * 0.5f)
                         lineBreakMode:NSLineBreakByWordWrapping];
    
    m_headerLabel.frame = CGRectMake((self.bounds.size.width - headersize.width) * 0.5f,
                                     topborder,
                                     headersize.width,
                                     headersize.height);
    
    
    m_footerLabel.font = [UIFont boldSystemFontOfSize:minsize * 0.0386f];
    
    CGSize footersize = [m_footerLabel.text
                         sizeWithFont:m_footerLabel.font
                         constrainedToSize:CGSizeMake(self.bounds.size.width * 0.4f , self.bounds.size.height * 0.5f)
                         lineBreakMode:NSLineBreakByWordWrapping];
    
    m_footerLabel.frame = CGRectMake(self.bounds.size.width - footersize.width - xborder,
                                     self.bounds.size.height - footersize.height - bottomborder,
                                     footersize.width,
                                     footersize.height);
}

- (void)drawView
{
    DEBUG_LOG(@"IMImageAdjusterTreeView drawView");
    
    if(self.drawScale==0)
    {
        float drawx, drawy, drawscale;
        if(![m_tree scaleOffsetForViewWithBounds:self.bounds ox:&drawx oy:&drawy scale:&drawscale])
            return;
        self.drawScale = drawscale;
        self.initialScale = drawscale;
        self.drawOrigin = CGPointMake(drawx, drawy);
        
        //if(self.delegate)
          //  [self.delegate treeViewScaleOffsetChange:self];
    }
    
    m_render.drawOrigin = self.drawOrigin;
    m_render.drawScale = self.drawScale;
    m_render.time = m_time;
    m_render.useRelativeTime = NO;
    m_render.lineWidth = m_lineWidth * self.drawScale / self.initialScale;
    
    [m_render renderToView:self showTree:YES multisample:m_use_multisampling];
}

- (void)destroyResources
{
    [m_render destroyResources];
}

- (void)gestureTap:(UITapGestureRecognizer *)sender
{
    self.drawScale = 0;
    //if(self.redrawOnInteraction)
     //   [self setNeedsDisplay];
    
    [self drawView];
}


- (void)gesturePan:(UIPanGestureRecognizer *)sender
{
    CGPoint p = [sender translationInView:self];
    [sender setTranslation:CGPointMake(0, 0) inView:self];
    
    if(p.x==0 && p.y==0)
        return;
    
    CGPoint origin = self.drawOrigin;
    origin.x += p.x;
    origin.y += p.y;
    self.drawOrigin = origin;
    
    [self limitOrigin];
    
    //if(self.delegate)
      //  [self.delegate treeViewScaleOffsetChange:self];
    
    //if(self.redrawOnInteraction)
     //   [self setNeedsDisplay];
    
    [self drawView];
}

- (void)gesturePinch:(UIPinchGestureRecognizer *)sender
{
    float scalechange = [sender scale];
    CGPoint p = [sender locationInView:self];
    [sender setScale:1];
    
    if(scalechange==1)
        return;
    
    float oldscale = self.drawScale / self.initialScale;
    float newscale = oldscale * scalechange;
    if(newscale>20.0f)
        newscale = 20.0f;
    else if(newscale<0.1f)
        newscale = 0.1f;
    float truescalechange = newscale / oldscale;
    
    CGPoint origin = self.drawOrigin;
    CGPoint delta;
    delta.x = (p.x - origin.x) * truescalechange;
    delta.y = (p.y - origin.y) * truescalechange;
    origin.x = p.x - delta.x;
    origin.y = p.y - delta.y;
    
    self.drawOrigin = origin;
    self.drawScale = newscale * self.initialScale;
    
    [self limitOrigin];
    
    //if(self.delegate)
      //  [self.delegate treeViewScaleOffsetChange:self];
    
    //if(self.redrawOnInteraction)
        //[self setNeedsDisplay];
    
    [self drawView];
}

- (void)limitOrigin
{
    float s = self.drawScale;
    float dL = 0.8f * s;
    float dR = 0.8f * s;
    float dT = 1.6f * s;
    float dB = 0.1f * s;
    
    CGPoint origin = self.drawOrigin;
    
    if(origin.x < -dR)
        origin.x = -dR;
    else if(origin.x > self.bounds.size.width + dL)
        origin.x = self.bounds.size.width + dL;
    
    if(origin.y < -dB)
        origin.y = -dB;
    else if(origin.y > self.bounds.size.height + dT)
        origin.y = self.bounds.size.height + dT;
    
    self.drawOrigin = origin;
}

- (void)setBackgroundImage:(UIImage *)image
{
    m_render.backgroundImage = image;
    
    [self drawView];
}

- (UIImage *)backgroundImage
{
    return m_render.backgroundImage;
}

- (void)setHasBackground:(BOOL)hasBackground
{
    m_render.backgroundIsTransparent = !hasBackground;
    
    [self drawView];
}

- (BOOL)hasBackground
{
    return !m_render.backgroundIsTransparent;
}

- (void)setTime:(float)time
{
    m_time = time;
    
    DEBUG_LOG(@"set tree time at %f", time);
    
    [self drawView];
}

- (float)time
{
    return m_time;
}

- (void)setHeaderText:(NSString *)headerText
{
    m_headerLabel.hidden = YES;
    
    if(headerText && headerText.length>0)
    {
        m_headerLabel.text = headerText;
        [self updateTextFrames];
        m_headerLabel.hidden = NO;
    }
}

- (NSString *)headerText
{
    if(m_headerLabel.hidden)
        return nil;
    else
        return m_headerLabel.text;
}

- (void)setFooterText:(NSString *)footerText
{
    m_footerLabel.hidden = YES;
    
    if(footerText && footerText.length>0)
    {
        m_footerLabel.text = footerText;
        [self updateTextFrames];
        m_footerLabel.hidden = NO;
    }
}

- (NSString *)footerText
{
    if(m_footerLabel.hidden)
        return nil;
    else
        return m_footerLabel.text;
}

- (void)setTextColor:(UIColor *)color
{
    CGFloat hue, sat, bright, alpha;
    [color getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
    if(bright > 0.5f)
        m_headerLabel.textOutlineColor = [UIColor blackColor];
    else
        m_headerLabel.textOutlineColor = [UIColor colorWithWhite:0.85f alpha:1];
    
    m_headerLabel.textColor = color;
    m_footerLabel.textColor = color;
}

- (UIColor *)textColor
{
    return m_headerLabel.textColor;
}

- (void)setLineWidth:(float)lineWidth
{
    if(m_lineWidth!=lineWidth)
    {
        m_lineWidth = lineWidth;
        //DEBUG_LOG(@"set line width to %f", lineWidth);
        if(m_validLayout)
            [self drawView];
    }
}

- (float)lineWidth
{
    return m_lineWidth;
}

- (void)dealloc
{
    DEBUG_LOG(@"IMImageAdjusterTreeView dealloc");

    m_render.backgroundIsTransparent = NO;
    m_render.backgroundImage = nil;
    
    [m_headerLabel release];
    [m_footerLabel release];

    [super dealloc];
}


@end

//
//  IMTreeViewController.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 6/14/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMTreeViewController.h"
#import "IMTreeView.h"
#import "IMAppDelegate.h"

@interface IMTreeViewController ()

@end

@implementation IMTreeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
        m_tree = app.tree;
        
        m_drawing_state = 0;
        m_animation_enable = NO;
        m_touches_state = 0;
    }
    return self;
}

- (void)loadView
{
    self.view = [[[IMTreeView alloc] initWithFrame:CGRectZero] autorelease];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    DEBUG_LOG(@"IMTreeVC viewDidLoad");
    
    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(gestureTap:)] autorelease];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[[UIPanGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(gesturePan:)] autorelease];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[[UIPinchGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(gesturePinch:)] autorelease];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    
    UIRotationGestureRecognizer *rotateGesture = [[[UIRotationGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(gestureRotate:)] autorelease];
    rotateGesture.delegate = self;
    [self.view addGestureRecognizer:rotateGesture];
    
    m_init_done = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    DEBUG_LOG(@"IMTreeVC viewDidAppear (%f x %f)", self.view.bounds.size.width, self.view.bounds.size.height);

    if(m_init_done)
        [self updateDrawCenter];
    else
        [self resetPosition];
    
    m_init_done = YES;
    
    [self enableDisplayUpdatesWithRedraw:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    DEBUG_LOG(@"IMTreeVC viewWillDisappear");

    m_oldviewsize = self.view.bounds.size;
    
    [self disableDisplayUpdatesWithRedraw:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    DEBUG_LOG(@"IMTreeVC memory warning");
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DEBUG_LOG(@"IMTreeVC willRotateToInterfaceOrientation");
    
    [self stopAnimatingWithRedraw:NO];
    [self drawBackground];
    
    m_oldviewsize = self.view.bounds.size;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    DEBUG_LOG(@"IMTreeVC didRotateFromInterfaceOrientation");
    
    [self updateDrawCenter];
    [self drawView];
    [self startAnimating];
}

- (void)gesturePan:(UIPanGestureRecognizer *)sender
{
    if(![self allowsDisplayUpdates] || ![self allowsTouches])
        return;
    
    CGPoint p = [sender translationInView:self.view];
    [sender setTranslation:CGPointMake(0, 0) inView:self.view];
    
    if(sender.numberOfTouches==1)
    {
        IMTreeView *tv = (IMTreeView *)self.view;
        
        struct DisplayParams dp = tv.dp;
        dp.origin.x += p.x;
        dp.origin.y += p.y;
        tv.dp = dp;
        
        [self limitOrigin];
        [self drawView];
    }
    else if(sender.numberOfTouches==2)
    {
        float startspread = [self.delegate getRawParam:ID_SPREAD];
        float spread = startspread;
        
        spread += 0.002f*p.y;
        if(spread<0)
            spread = 0;
        else if(spread>1)
            spread = 1;
        
        BOOL update = NO;
        if(spread!=startspread)
        {
            [self.delegate setRawParam:ID_SPREAD value:spread redraw:NO sender:self];
            update = YES;
        }
        
        int treetype = [self.delegate getRawParam:ID_TREETYPE];
        if(treetype==0)
        {
            float startbalance = [self.delegate getRawParam:ID_BALANCE];
            float balance = startbalance;
            
            balance += 0.002f*p.x;
            if(balance<0)
                balance = 0;
            else if(balance>1)
                balance = 1;
            
            if(balance!=startbalance)
            {
                [self.delegate setRawParam:ID_BALANCE value:balance redraw:NO sender:self];
                update = YES;
            }
        }
        else
        {
            float startspin = [self.delegate getRawParam:ID_SPIN];
            float spin = startspin;
            
            spin += 0.0005f*p.x;
            if(spin<0)
                spin = 0;
            else if(spin>1)
                spin = 1;
            
            if(spin!=startspin)
            {
                [self.delegate setRawParam:ID_SPIN value:spin redraw:NO sender:self];
                update = YES;
            }
        }
        
        if(update)
            [self drawView];
    }
}

- (void)gesturePinch:(UIPinchGestureRecognizer *)sender
{
    if(![self allowsDisplayUpdates] || ![self allowsTouches])
        return;
    
    float scalechange = [sender scale];
    [sender setScale:1];
    CGPoint p = [sender locationInView:self.view];
    
    IMTreeView *tv = (IMTreeView *)self.view;
    
    struct DisplayParams dp = tv.dp;
    
    float newscale = dp.scale * scalechange;
    if(newscale>20.0)
        newscale = 20.0;
    else if(newscale<0.1)
        newscale = 0.1;
    float truescalechange = newscale / dp.scale;
    
    CGPoint delta;
    delta.x = (p.x - dp.origin.x) * truescalechange;
    delta.y = (p.y - dp.origin.y) * truescalechange;
    dp.origin.x = p.x - delta.x;
    dp.origin.y = p.y - delta.y;
    dp.scale = newscale;
    tv.dp = dp;
    
    [self limitOrigin];
    [self drawView];
}

- (void)gestureTap:(UITapGestureRecognizer *)sender
{
    if(![self allowsDisplayUpdates] || ![self allowsTouches])
        return;
    
    [self resetPosition];
    [self drawView];
}

- (void)gestureRotate:(UIRotationGestureRecognizer *)sender
{
    if(![self allowsDisplayUpdates] || ![self allowsTouches])
        return;
    
    float startbend = [self.delegate getRawParam:ID_BEND];
    float bend = startbend;
    
    float rotation = sender.rotation;
    if(rotation > M_PI)
        rotation -= 2*M_PI;
    else if(rotation < -M_PI)
        rotation += 2*M_PI;
    
    bend += 0.4f * rotation;
    sender.rotation = 0;
    
    if(bend<0)
        bend = 0;
    else if(bend>1)
        bend = 1;
    
    if(bend!=startbend)
    {
        [self.delegate setRawParam:ID_BEND value:bend redraw:NO sender:self];
        [self drawView];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if([gestureRecognizer numberOfTouches]==2 && [otherGestureRecognizer numberOfTouches]==2)
    {
        if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]])
            return YES;
        if([gestureRecognizer isKindOfClass:[UIRotationGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
            return YES;
    }
    
    return NO;
}

- (void)updateDrawCenter
{
    IMTreeView *tv = (IMTreeView *)self.view;
    struct DisplayParams dp = tv.dp;
    dp.origin.x += 0.5f*(self.view.bounds.size.width - m_oldviewsize.width);
    dp.origin.y += 0.5f*(self.view.bounds.size.height - m_oldviewsize.height);
    tv.dp = dp;
}

- (void)resetPosition
{
    IMTreeView *tv = (IMTreeView *)self.view;
    
    float viewheight = tv.bounds.size.height;
    
    CGRect bbox = [m_tree getBoundingBox];
    
    if(bbox.size.width<0.1f)
    {
        bbox.origin.x -= 0.5f * (0.1f - bbox.size.width);
        bbox.size.width = 0.1f;
    }
    if(bbox.size.height<0.1f)
    {
        bbox.origin.y -= 0.5f * (0.1f - bbox.size.height);
        bbox.size.height = 0.1f;
    }
    
    float scalew = tv.bounds.size.width / bbox.size.width;
    float scaleh = viewheight / bbox.size.height;
    float scale = scalew;
    if(scaleh<scale)
        scale = scaleh;
    scale *= 0.95f;
    
    float dx = tv.bounds.size.width - bbox.size.width * scale;
    float dy = viewheight - bbox.size.height * scale;
    
    struct DisplayParams dp;
    dp.origin = CGPointMake(0.5f*dx - bbox.origin.x * scale, tv.bounds.size.height - (0.5f*dy - bbox.origin.y * scale));
    dp.scale = 1;
    dp.initialSize = scale;
    tv.dp = dp;
}

- (void)limitOrigin
{
    IMTreeView *tv = (IMTreeView *)self.view;
    struct DisplayParams dp = tv.dp;
    
    float s = dp.initialSize * dp.scale;
    float dL = 0.8f * s;
    float dR = 0.8f * s;
    float dT = 1.6f * s;
    float dB = 0.1f * s;
    
    CGPoint origin = dp.origin;
    
    if(origin.x < -dR)
        origin.x = -dR;
    else if(origin.x > self.view.bounds.size.width + dL)
        origin.x = self.view.bounds.size.width + dL;
    
    if(origin.y < -dB)
        origin.y = -dB;
    else if(origin.y > self.view.bounds.size.height + dT)
        origin.y = self.view.bounds.size.height + dT;
    
    dp.origin = origin;
    tv.dp = dp;
}

- (void)startAnimating
{
    DEBUG_LOG(@"IMTreeVC startAnimating");

    if([self allowsDisplayUpdates] && [self.delegate getParam:ID_ANIMENABLE])
        [(IMTreeView *)self.view startAnimationThread];
    
    m_animation_enable = YES;
}

- (void)stopAnimatingWithRedraw:(BOOL)redraw
{
    DEBUG_LOG(@"IMTreeVC stopAnimating");
    if(m_animation_enable)
    {
        [(IMTreeView *)self.view stopAnimationThread];
        if(redraw)
            [self drawView];
    }
    
    m_animation_enable = NO;
}

- (void)enableDisplayUpdatesWithRedraw:(BOOL)redraw
{
    DEBUG_LOG(@"IMTreeVC enableDisplayUpdates %d", m_drawing_state);
    if(m_drawing_state>0)
        m_drawing_state--;
    
    if(m_drawing_state==0)
    {
        [self enableTouches];
        [self startAnimating];
        if(redraw)
            [self drawView];
    }
}

- (void)disableDisplayUpdatesWithRedraw:(BOOL)redraw
{
    DEBUG_LOG(@"IMTreeVC disableDisplayUpdates %d", m_drawing_state);
    
    if(m_drawing_state==0)
    {
        [self disableTouches];
        [self stopAnimatingWithRedraw:redraw];
        [self destroyResources];
    }
    
    m_drawing_state++;
}

- (BOOL)allowsDisplayUpdates
{
    return m_drawing_state==0;
}

- (void)enableTouches
{
    if(m_touches_state>0)
        m_touches_state--;
}

- (void)disableTouches
{
    m_touches_state++;
}

- (BOOL)allowsTouches
{
    return m_touches_state==0;
}

- (void)drawView
{
    DEBUG_LOG(@"IMTreeVC drawView");
    IMTreeView *tv = (IMTreeView *)self.view;
    
    // gets called when drawing would be needed when animation is off
    if([self allowsDisplayUpdates] && ![tv isAnimating])
        [tv drawView];
}

- (void)drawBackground
{
    DEBUG_LOG(@"IMTreeVC drawBackground");
    IMTreeView *tv = (IMTreeView *)self.view;
    
    // gets called when drawing would be needed when animation is off
    if([self allowsDisplayUpdates] && ![tv isAnimating])
        [tv drawBackground];
}

- (void)destroyResources
{
    DEBUG_LOG(@"IMTreeVC destroyResources");

    IMTreeView *tv = (IMTreeView *)self.view;
    [tv destroyResources];
}

@end

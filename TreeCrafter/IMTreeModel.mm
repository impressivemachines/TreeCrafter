//
//  IMTreeModel.m
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMTreeModel.h"
#import "TreeModel.h"
#import "IMAppDelegate.h"

@implementation IMTreeModel

- (id)init
{
    if((self = [super init]))
    {
        m_tree = CreateTreeModel();
        if(!m_tree->Init())
        {
            DEBUG_LOG(@"failed to init tree");
            exit(0);
        }
        
        m_treeLock = [[NSLock alloc] init];
        
        DEBUG_LOG(@"IMTreeModel done with init");
    }
    
    return self;
}

-(float)deadBand:(float)value
{
    float band = 0.03f;
    float y = fabs(value - 0.5f);
    
    if(y<band)
        y = 0;
    else
        y = 0.5f * (y - band) / (0.5 - band);
    
    if(value<0.5f)
        return 0.5f - y;
    else
        return 0.5f + y;
}

-(float)invDeadBand:(float)value
{
    if(value==0.5f)
        return 0.5f;
    
    float band = 0.03f;
    if(value>0.5f)
    {
        return 0.5f + band + 2*(value - 0.5f) * (0.5f - band);
    }
    else
    {
        return 0.5f - band - 2*(0.5f - value) * (0.5f - band);
    }
}

- (void)setTreeParameters:(NSDictionary *)params
{
    [m_treeLock lock];
    
    for(id key in params)
    {
        NSString *name = (NSString *)key;
        NSNumber *number = [params objectForKey:key];
        
        if([name isEqualToString:STRING_TREETYPE])
            m_tree->SetParameter(ID_TREETYPE, number.integerValue);
        else if([name isEqualToString:STRING_ANGLEMODE])
            m_tree->SetParameter(ID_ANGLEMODE, number.integerValue);
        else if([name isEqualToString:STRING_SPREAD])
            m_tree->SetParameter(ID_SPREAD, number.floatValue);
        else if([name isEqualToString:STRING_BALANCE])
            m_tree->SetParameter(ID_BALANCE, [self deadBand:number.floatValue]);
        else if([name isEqualToString:STRING_BEND])
            m_tree->SetParameter(ID_BEND, [self deadBand:number.floatValue]);
        else if([name isEqualToString:STRING_INTERVALSTART])
            m_tree->SetParameter(ID_INTERVALSTART, number.integerValue);
        else if([name isEqualToString:STRING_INTERVALCOUNT])
            m_tree->SetParameter(ID_INTERVALCOUNT, number.integerValue);
        else if([name isEqualToString:STRING_DETAIL])
            m_tree->SetParameter(ID_DETAIL, number.floatValue);
        else if([name isEqualToString:STRING_LENGTHRATIO])
            m_tree->SetParameter(ID_LENGTHRATIO, number.floatValue);
        else if([name isEqualToString:STRING_LENGTHBALANCE])
            m_tree->SetParameter(ID_LENGTHBALANCE, [self deadBand:number.floatValue]);
        else if([name isEqualToString:STRING_ASPECT])
            m_tree->SetParameter(ID_ASPECT, [self deadBand:number.floatValue]);
        else if([name isEqualToString:STRING_SPIKINESS])
            m_tree->SetParameter(ID_SPIKINESS, number.floatValue);
        else if([name isEqualToString:STRING_TRUNKWIDTH])
            m_tree->SetParameter(ID_TRUNKWIDTH, number.floatValue);
        else if([name isEqualToString:STRING_RANDOMWIGGLE])
            m_tree->SetParameter(ID_RANDOMWIGGLE, number.floatValue);
        else if([name isEqualToString:STRING_RANDOMANGLE])
            m_tree->SetParameter(ID_RANDOMANGLE, number.floatValue);
        else if([name isEqualToString:STRING_RANDOMLENGTH])
            m_tree->SetParameter(ID_RANDOMLENGTH, number.floatValue);
        else if([name isEqualToString:STRING_TRUNKTAPER])
            m_tree->SetParameter(ID_TRUNKTAPER, number.floatValue);
        else if([name isEqualToString:STRING_RANDOMINTERVAL])
            m_tree->SetParameter(ID_RANDOMINTERVAL, number.floatValue);
        else if([name isEqualToString:STRING_RANDOMSEED])
            m_tree->SetParameter(ID_RANDOMSEED, number.integerValue);
        else if([name isEqualToString:STRING_APEXTYPE])
            m_tree->SetParameter(ID_APEXTYPE, number.integerValue);
        else if([name isEqualToString:STRING_ROOTCOLOR])
            m_tree->SetParameter(ID_ROOTCOLOR, number.unsignedIntegerValue);
        else if([name isEqualToString:STRING_LEAFCOLOR])
            m_tree->SetParameter(ID_LEAFCOLOR, number.unsignedIntegerValue);
        else if([name isEqualToString:STRING_BACKGROUNDCOLOR])
            m_tree->SetParameter(ID_BACKGROUNDCOLOR, number.unsignedIntegerValue);
        else if([name isEqualToString:STRING_COLORSIZE])
            m_tree->SetParameter(ID_COLORSIZE, number.floatValue);
        else if([name isEqualToString:STRING_COLORTRANSITION])
            m_tree->SetParameter(ID_COLORTRANSITION, number.floatValue);
        else if([name isEqualToString:STRING_BRANCHCOUNT])
            m_tree->SetParameter(ID_BRANCHCOUNT, number.integerValue);
        else if([name isEqualToString:STRING_GEONODES])
            m_tree->SetParameter(ID_GEONODES, number.integerValue);
        else if([name isEqualToString:STRING_GEODELAY])
            m_tree->SetParameter(ID_GEODELAY, number.floatValue);
        else if([name isEqualToString:STRING_GEORATIO])
            m_tree->SetParameter(ID_GEORATIO, number.floatValue);
        else if([name isEqualToString:STRING_SPIN])
            m_tree->SetParameter(ID_SPIN, number.floatValue);
        else if([name isEqualToString:STRING_TWIST])
            m_tree->SetParameter(ID_TWIST, [self deadBand:number.floatValue]);
        else if([name isEqualToString:STRING_ANIMWINDRATE])
            m_tree->SetParameter(ID_ANIMWINDRATE, number.floatValue);
        else if([name isEqualToString:STRING_ANIMWINDDEPTH])
            m_tree->SetParameter(ID_ANIMWINDDEPTH, number.floatValue);
        
        else if([name isEqualToString:STRING_ANIMSPREAD_D])
            m_tree->SetParameter(ID_ANIMSPREAD_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMSPREAD_R])
            m_tree->SetParameter(ID_ANIMSPREAD_R, number.floatValue);
        
        else if([name isEqualToString:STRING_ANIMBEND_D])
            m_tree->SetParameter(ID_ANIMBEND_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMBEND_R])
            m_tree->SetParameter(ID_ANIMBEND_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMSPIN_D])
            m_tree->SetParameter(ID_ANIMSPIN_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMSPIN_R])
            m_tree->SetParameter(ID_ANIMSPIN_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMTWIST_D])
            m_tree->SetParameter(ID_ANIMTWIST_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMTWIST_R])
            m_tree->SetParameter(ID_ANIMTWIST_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMLENGTHRATIO_D])
            m_tree->SetParameter(ID_ANIMLENGTHRATIO_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMLENGTHRATIO_R])
            m_tree->SetParameter(ID_ANIMLENGTHRATIO_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMGEODELAY_D])
            m_tree->SetParameter(ID_ANIMGEODELAY_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMGEODELAY_R])
            m_tree->SetParameter(ID_ANIMGEODELAY_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMGEORATIO_D])
            m_tree->SetParameter(ID_ANIMGEORATIO_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMGEORATIO_R])
            m_tree->SetParameter(ID_ANIMGEORATIO_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMASPECT_D])
            m_tree->SetParameter(ID_ANIMASPECT_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMASPECT_R])
            m_tree->SetParameter(ID_ANIMASPECT_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMBALANCE_D])
            m_tree->SetParameter(ID_ANIMBALANCE_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMBALANCE_R])
            m_tree->SetParameter(ID_ANIMBALANCE_R, number.floatValue);

        else if([name isEqualToString:STRING_ANIMLENGTHBALANCE_D])
            m_tree->SetParameter(ID_ANIMLENGTHBALANCE_D, number.floatValue);
        else if([name isEqualToString:STRING_ANIMLENGTHBALANCE_R])
            m_tree->SetParameter(ID_ANIMLENGTHBALANCE_R, number.floatValue);
    }
    
    [m_treeLock unlock];
}

- (NSDictionary *)treeParameters
{
    [m_treeLock lock];
    
    NSDictionary *params = [[[NSDictionary alloc] initWithObjectsAndKeys:
             [NSNumber numberWithInt:m_tree->GetParameter(ID_TREETYPE)], STRING_TREETYPE,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_ANGLEMODE)], STRING_ANGLEMODE,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_SPREAD)], STRING_SPREAD,
             [NSNumber numberWithFloat:[self invDeadBand:m_tree->GetParameter(ID_BALANCE)]], STRING_BALANCE,
             [NSNumber numberWithFloat:[self invDeadBand:m_tree->GetParameter(ID_BEND)]], STRING_BEND,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_INTERVALSTART)], STRING_INTERVALSTART,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_INTERVALCOUNT)], STRING_INTERVALCOUNT,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_DETAIL)], STRING_DETAIL,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_LENGTHRATIO)], STRING_LENGTHRATIO,
             [NSNumber numberWithFloat:[self invDeadBand:m_tree->GetParameter(ID_LENGTHBALANCE)]], STRING_LENGTHBALANCE,
             [NSNumber numberWithFloat:[self invDeadBand:m_tree->GetParameter(ID_ASPECT)]], STRING_ASPECT,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_SPIKINESS)], STRING_SPIKINESS,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_TRUNKWIDTH)], STRING_TRUNKWIDTH,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_RANDOMWIGGLE)], STRING_RANDOMWIGGLE,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_RANDOMANGLE)], STRING_RANDOMANGLE,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_RANDOMLENGTH)], STRING_RANDOMLENGTH,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_TRUNKTAPER)], STRING_TRUNKTAPER,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_RANDOMINTERVAL)], STRING_RANDOMINTERVAL,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_RANDOMSEED)], STRING_RANDOMSEED,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_APEXTYPE)], STRING_APEXTYPE,
             [NSNumber numberWithUnsignedInt:m_tree->GetParameter(ID_ROOTCOLOR)], STRING_ROOTCOLOR,
             [NSNumber numberWithUnsignedInt:m_tree->GetParameter(ID_LEAFCOLOR)], STRING_LEAFCOLOR,
             [NSNumber numberWithUnsignedInt:m_tree->GetParameter(ID_BACKGROUNDCOLOR)], STRING_BACKGROUNDCOLOR,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_COLORSIZE)], STRING_COLORSIZE,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_COLORTRANSITION)], STRING_COLORTRANSITION,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_BRANCHCOUNT)], STRING_BRANCHCOUNT,
             [NSNumber numberWithInt:m_tree->GetParameter(ID_GEONODES)], STRING_GEONODES,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_GEODELAY)], STRING_GEODELAY,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_GEORATIO)], STRING_GEORATIO,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_SPIN)], STRING_SPIN,
             [NSNumber numberWithFloat:[self invDeadBand:m_tree->GetParameter(ID_TWIST)]], STRING_TWIST,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMWINDRATE)], STRING_ANIMWINDRATE,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMWINDDEPTH)], STRING_ANIMWINDDEPTH,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMSPREAD_D)], STRING_ANIMSPREAD_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMSPREAD_R)], STRING_ANIMSPREAD_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMBEND_D)], STRING_ANIMBEND_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMBEND_R)], STRING_ANIMBEND_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMSPIN_D)], STRING_ANIMSPIN_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMSPIN_R)], STRING_ANIMSPIN_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMTWIST_D)], STRING_ANIMTWIST_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMTWIST_R)], STRING_ANIMTWIST_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMLENGTHRATIO_D)], STRING_ANIMLENGTHRATIO_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMLENGTHRATIO_R)], STRING_ANIMLENGTHRATIO_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMGEODELAY_D)], STRING_ANIMGEODELAY_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMGEODELAY_R)], STRING_ANIMGEODELAY_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMGEORATIO_D)], STRING_ANIMGEORATIO_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMGEORATIO_R)], STRING_ANIMGEORATIO_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMASPECT_D)], STRING_ANIMASPECT_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMASPECT_R)], STRING_ANIMASPECT_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMBALANCE_D)], STRING_ANIMBALANCE_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMBALANCE_R)], STRING_ANIMBALANCE_R,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMLENGTHBALANCE_D)], STRING_ANIMLENGTHBALANCE_D,
             [NSNumber numberWithFloat:m_tree->GetParameter(ID_ANIMLENGTHBALANCE_R)], STRING_ANIMLENGTHBALANCE_R,
             nil] autorelease];
    
    [m_treeLock unlock];
    
    return params;
}

- (void)randomSeedRefresh
{
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.treeSaved = NO;
    
    [m_treeLock lock];
    m_tree->RandomSeedRefresh();
    [m_treeLock unlock];
}

- (double)getParam:(int)paramid
{
    // dont bother locking as UI is the only one who calls get and set
    //[self lockTree];
    
    double val;
    if(paramid==ID_BALANCE || paramid==ID_BEND || paramid==ID_LENGTHBALANCE || paramid==ID_ASPECT || paramid==ID_TWIST)
        val = [self invDeadBand:m_tree->GetParameter(paramid)];
    else
        val = m_tree->GetParameter(paramid);
    
    //[self unlockTree];
    
    //DEBUG_LOG(@"Get %d returned %f", paramid, val);
    
    return val;
}

- (void)setParam:(int)paramid value:(double)value
{
    //DEBUG_LOG(@"Set %d = %f", paramid, value);
    
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.treeSaved = NO;
    
    // need to lock to prevent changes during tree generation
    [m_treeLock lock];
    
    if(paramid==ID_BALANCE || paramid==ID_BEND || paramid==ID_LENGTHBALANCE || paramid==ID_ASPECT || paramid==ID_TWIST)
        m_tree->SetParameter(paramid, [self deadBand:value]);
    else
        m_tree->SetParameter(paramid, value);
    
    [m_treeLock unlock];
}

- (double)getRawParam:(int)paramid
{
    // dont bother locking as UI is the only one who calls get and set
    //[self lockTree];
    
    double val;
    val = m_tree->GetParameter(paramid);
    
    //[self unlockTree];
    
    return val;
}

- (void)setRawParam:(int)paramid value:(double)value
{
    IMAppDelegate *app = (IMAppDelegate *)[[UIApplication sharedApplication] delegate];
    app.treeSaved = NO;
    
    // need to lock to prevent changes during tree generation
    [m_treeLock lock];

    m_tree->SetParameter(paramid, value);
    
    [m_treeLock unlock];
}

- (void)drawViewWithShader:(GLuint)shader width:(float)view_w height:(float)view_h x:(float)view_x y:(float)view_y scale:(float)view_scale dt:(float)dt abstime:(BOOL)abstime background:(BOOL)background rbswap:(BOOL)rbswap linewidth:(float)linewidth;
{
    [m_treeLock lock];
    m_tree->DrawOpenGL(shader, view_w, view_h, view_x, view_y, view_scale, dt,
                       abstime ? true : false,
                       background ? true : false,
                       rbswap ? true : false,
                       linewidth);
    [m_treeLock unlock];
}

- (void)drawBackgroundOnly
{
    [m_treeLock lock]; // locked because clear depends on background color
    m_tree->DrawOpenGLBlankScreen();
    [m_treeLock unlock];
}

- (CGRect)getBoundingBox
{
    [m_treeLock lock];
    CGRect bbox = m_tree->GetBoundingBox();
    //DEBUG_LOG(@"bounding box = %f %f %f %f", bbox.origin.x, bbox.origin.y, bbox.size.width, bbox.size.height);
    [m_treeLock unlock];
    
    return bbox;
}

- (void)freeMemory
{
    [m_treeLock lock];
    m_tree->FreeResources();
    [m_treeLock unlock];
}

bool progress_callback(float progress, void *user)
{
    //DEBUG_LOG(@"progress %f", progress);

    if(user)
    {
        id<IMTreeModelDelegate> del = *((id<IMTreeModelDelegate> *)user);
        if(del!=nil)
            return [del callbackForProgress:progress] ? true : false;
        else
            return true;
    }
    else
        return true;
}

- (UIImage *)drawImageWithSize:(CGSize)size ox:(float)drawx oy:(float)drawy scale:(float)drawscale quality:(int)quality adaptForDisplay:(BOOL)adaptForDisplay background:(UIImage *)bgimage header:(NSString *)header footer:(NSString *)footer textcolor:(UIColor *)textcolor logo:(BOOL)addLogo error:(int *)perror
{
    DEBUG_LOG(@"creating image with size %f x %f", size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, YES, adaptForDisplay ? 0.0f : 1.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(context==nil)
    {
        if(perror)
            *perror = IME_FAIL;
        return nil;
    }
    
    CGRect bounds = CGRectMake(0, 0, size.width, size.height);
    int errorstate = IME_OK;
    
    [m_treeLock lock];
    if(drawscale==0)
    {
        if(!m_tree->ScaleOffsetForView(bounds, drawx, drawy, drawscale))
            errorstate = IME_FAIL;
    }
    
    if(errorstate==IME_OK)
    {
        if(bgimage)
        {
            float scalex = size.width / bgimage.size.width;
            float scaley = size.height / bgimage.size.height;
            float scale = scalex;
            if(scaley > scale)
                scale = scaley;
            
            CGRect drawrect = CGRectMake(
                                         0.5f*(size.width - bgimage.size.width * scale),
                                         0.5f*(size.height - bgimage.size.height * scale),
                                         bgimage.size.width * scale,
                                         bgimage.size.height * scale
                                         );
            [bgimage drawInRect:drawrect];
        }
        
        id del = self.delegate;
        errorstate = m_tree->DrawQuartz(context, bounds, drawx, drawy, drawscale, 0, 0, quality, 0, bgimage==nil ? true : false, progress_callback, &del);
    }
    
    [m_treeLock unlock];
    
    if(perror)
        *perror = errorstate;
    
    if(errorstate!=IME_OK)
    {
        UIGraphicsEndImageContext();
        return nil;
    }
    
    if(textcolor)
    {
        [textcolor setFill];
        CGFloat hue, sat, bright, alpha;
        [textcolor getHue:&hue saturation:&sat brightness:&bright alpha:&alpha];
        if(bright > 0.5f)
            [[UIColor blackColor] setStroke];
        else
            [[UIColor colorWithWhite:0.85f alpha:1] setStroke];
    }
    
    float minsize = size.width;
    if(size.height < minsize)
        minsize = size.height;
    
    float xborder = minsize * 0.06f;
    float topborder = minsize * 0.06f;
    float bottomborder = minsize * 0.06f;
    
    CGContextSetLineWidth(context, minsize * 0.0038f);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    if(header)
    {
        UIFont *font = [UIFont boldSystemFontOfSize:minsize * 0.0725f];
        
        CGSize headersize = [header
                             sizeWithFont:font
                             constrainedToSize:CGSizeMake(size.width - 2*xborder , size.height * 0.5f)
                             lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect headingrect = CGRectMake((size.width - headersize.width) * 0.5f,
                                          topborder,
                                          headersize.width,
                                          headersize.height);
        
        CGContextSetTextDrawingMode(context, kCGTextStroke);
        
        [header drawInRect:headingrect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        [header drawInRect:headingrect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
    }

    if(footer)
    {
        UIFont *font = [UIFont boldSystemFontOfSize:minsize * 0.0386f];
        
        CGSize footersize = [footer
                             sizeWithFont:font
                             constrainedToSize:CGSizeMake(size.width * 0.4f , size.height * 0.5f)
                             lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect footerrect = CGRectMake(size.width - footersize.width - xborder,
                                       size.height - footersize.height - bottomborder,
                                       footersize.width,
                                       footersize.height);

        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        [footer drawInRect:footerrect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentRight];
    }
    
    if(addLogo)
    {
        NSString *logotext = NSLS_CREATED_USING__;
        
        [[UIColor whiteColor] setFill];
        
        UIFont *font = [UIFont boldSystemFontOfSize:minsize * 0.02f];
        
        CGSize logoconstrain = CGSizeMake(size.width * 0.5f , size.height * 0.5f);
        
        CGSize logosize = [logotext sizeWithFont:font constrainedToSize:logoconstrain lineBreakMode:NSLineBreakByWordWrapping];
        
        CGRect logorect = CGRectMake(
                                     minsize * 0.04f,
                                     size.height - logosize.height - minsize * 0.04f,
                                     logosize.width,
                                     logosize.height
                                     );
        
        CGContextSetTextDrawingMode(context, kCGTextFill);
        
        [logotext drawInRect:logorect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentLeft];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(image==nil && perror)
       *perror = IME_FAIL;
    
    return image;
}

- (BOOL)scaleOffsetForViewWithBounds:(CGRect)bounds ox:(float *)drawx oy:(float *)drawy scale:(float *)drawscale
{
    [m_treeLock lock];
    bool ok = m_tree->ScaleOffsetForView(bounds, *drawx, *drawy, *drawscale);
    [m_treeLock unlock];
    
    return ok ? YES : NO;
}

- (int)drawWithContext:(CGContextRef)context bounds:(CGRect)bounds ox:(float)drawx oy:(float)drawy scale:(float)drawscale quality:(int)quality vertextarget:(int)vertextarget drawbackground:(BOOL)db linewidth:(float)linewidth animationtime:(float)time
{
    [m_treeLock lock];
    id del = self.delegate;
    int errorstate = m_tree->DrawQuartz(context, bounds, drawx, drawy, drawscale, time, linewidth, quality, vertextarget, db ? true : false, progress_callback, &del);
    [m_treeLock unlock];
    
    return errorstate;
}

- (void)dealloc
{
    [m_treeLock lock];
    
    if(m_tree)
        DestroyTreeModel(m_tree);
    m_tree = NULL;
    
    [m_treeLock unlock];
    [m_treeLock release];
    
    [super dealloc];
}

@end

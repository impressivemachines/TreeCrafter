//
//  IMTreeRender.m
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/15/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import "IMTreeRender.h"

@implementation IMTreeRender

- (id)initWithTree:(IMTreeModel *)tree
{
    DEBUG_LOG(@"IMTreeRender initWithTree");
    
    self = [super init];
    if (self)
    {
        m_tree = [tree retain];
        m_view = nil;
        
        m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if(m_context==nil || ![EAGLContext setCurrentContext:m_context])
        {
            NSLog(@"Error: Failed to set up OpenGL context");
            exit(0);
        }
        
        NSString *shaderpath = [NSString stringWithFormat:@"%@/",[[NSBundle mainBundle] bundlePath]];
        DEBUG_LOG(@"shader path = %@", shaderpath);
        
        m_shaderpool = [[IMShaderPool alloc] initWithPath:shaderpath];
        
        if(![m_shaderpool loadProgram:@"MainShader" vertexShader:@"Generic.vsh" fragmentShader:@"Generic.fsh"])
        {
            NSLog(@"Error: Failed to load MainShader");
            exit(0);
        }
        
        if(![m_shaderpool loadProgram:@"VideoShader" vertexShader:@"GenericVReflect.vsh" fragmentShader:@"Generic.fsh"])
        {
            NSLog(@"Error: Failed to load VideoShader");
            exit(0);
        }
        
        if(![m_shaderpool loadProgram:@"TextureShader" vertexShader:@"Texture.vsh" fragmentShader:@"Texture.fsh"])
        {
            NSLog(@"Error: Failed to load texture shader");
            exit(0);
        }
        
        m_use_multisampling = YES;

        [EAGLContext setCurrentContext:nil];
        
        m_context_lock = [[NSLock alloc] init];
        
        self.lineWidth = 0;
        self.drawOrigin = CGPointMake(0, 0);
        self.drawScale = 100;
        self.time = 0;
        self.useRelativeTime = YES;
        m_background_transparent = NO;
        m_background_image = nil;
    }
    
    return self;
}

- (void)lockContext
{
    //DEBUG_LOG(@"IMTreeRender lockContext");
    [m_context_lock lock];
    [EAGLContext setCurrentContext:m_context];
}

- (void)unlockContext
{
    //DEBUG_LOG(@"IMTreeRender unlockContext");
    [EAGLContext setCurrentContext:nil];
    [m_context_lock unlock];
}

- (void)createRenderbufferWithView:(UIView *)view width:(int)width height:(int)height
{
    DEBUG_LOG(@"IMTreeRender createRenderbufferWithView");
    
    m_view = view;
    
    glGenFramebuffers(1, &m_view_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, m_view_framebuffer);
    
    glGenRenderbuffers(1, &m_view_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, m_view_renderbuffer);
    
    // storage may or may not be associated with a view
    if(view)
        [m_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)view.layer];
    else
        glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, width, height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_view_renderbuffer);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"Error: Framebuffer not complete");
        exit(0);
    }
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &m_render_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &m_render_height);
    
    DEBUG_LOG(@"Created renderbuffer %d x %d", m_render_width, m_render_height);
    
    if(m_use_multisampling)
    {
        glGenFramebuffers(1, &m_drawing_framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, m_drawing_framebuffer);
        
        glGenRenderbuffers(1, &m_drawing_renderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, m_drawing_renderbuffer);
        
        glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, m_render_width, m_render_height);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_drawing_renderbuffer);
        
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER)!=GL_FRAMEBUFFER_COMPLETE)
        {
            NSLog(@"Error: Multisample framebuffer not complete");
            exit(0);
        }
    }
    
    glGenBuffers(1, &m_vertex_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, m_vertex_buffer);
    
    glViewport(0, 0, m_render_width, m_render_height);
    
#ifdef DEBUG
    if(![m_shaderpool validateProgram:[m_shaderpool getProgram:@"MainShader"]]
       || ![m_shaderpool validateProgram:[m_shaderpool getProgram:@"VideoShader"]]
       || ![m_shaderpool validateProgram:[m_shaderpool getProgram:@"TextureShader"]])
    {
        NSLog(@"Error: Shader validation failed");
        exit(0);
    }
#endif
}

- (void)destroyTexturebuffer
{
    if(m_background_texture)
        glDeleteTextures(1, &m_background_texture);
    m_background_texture = 0;
}

- (void)destroyRenderbuffer
{
    DEBUG_LOG(@"IMTreeRender destroyRenderbuffer");
    
    if(m_view_framebuffer)
        glDeleteFramebuffers(1, &m_view_framebuffer);
    m_view_framebuffer = 0;
    
    if(m_view_renderbuffer)
        glDeleteRenderbuffers(1, &m_view_renderbuffer);
    m_view_renderbuffer = 0;
    
    if(m_drawing_renderbuffer)
        glDeleteRenderbuffers(1, &m_drawing_renderbuffer);
    m_drawing_renderbuffer = 0;
    
    if(m_drawing_framebuffer)
        glDeleteFramebuffers(1, &m_drawing_framebuffer);
    m_drawing_framebuffer = 0;
    
    if(m_vertex_buffer)
        glDeleteBuffers(1, &m_vertex_buffer);
    m_vertex_buffer = 0;
    
    [self destroyTexturebuffer];
    
    m_view = nil;
    m_render_width = 0;
    m_render_height = 0;
    m_use_multisampling = YES;
}

- (void)loadTextureFromImage:(UIImage *)image
{
    GLuint width = (GLuint)CGImageGetWidth(image.CGImage);
    GLuint height = (GLuint)CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    void *imageData = malloc(height * width * 4); // standard specifies at least 4 byte alignment
    if(imageData==NULL)
        return;
    
    CGContextRef context = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    
    glGenTextures(1, &m_background_texture);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_background_texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 4);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(context);
    free(imageData);
}

- (void)renderToView:(UIView *)view showTree:(BOOL)showTree multisample:(BOOL)multisample
{
    DEBUG_LOG(@"IMTreeRender renderToView");
    
    [self lockContext];
    
    if(view==nil || view.bounds.size.width==0 || view.bounds.size.height==0)
    {
        // invalid parameters
        [self destroyRenderbuffer];
        [self unlockContext];
        
        return;
    }

    int width = (int)(view.bounds.size.width * view.contentScaleFactor);
    int height = (int)(view.bounds.size.height * view.contentScaleFactor);
    
    if(view!=m_view || m_render_width != width || m_render_height != height || multisample != m_use_multisampling)
    {
        [self destroyRenderbuffer];
        m_use_multisampling = multisample;
    }
    
    if(m_view_renderbuffer==0)
        [self createRenderbufferWithView:view width:0 height:0];
    
    BOOL draw_texture = NO;
    if(!m_background_transparent && m_background_image != nil)
    {
        if(m_background_texture==0)
        {
            // create background from image
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0f);
            
            float scalex = view.bounds.size.width / m_background_image.size.width;
            float scaley = view.bounds.size.height / m_background_image.size.height;
            float scale = scalex;
            if(scaley > scale)
                scale = scaley;
            
            CGRect drawrect = CGRectMake(
                                         0.5f*(view.bounds.size.width - m_background_image.size.width * scale),
                                         0.5f*(view.bounds.size.height - m_background_image.size.height * scale),
                                         m_background_image.size.width * scale,
                                         m_background_image.size.height * scale
                                         );
            
            [m_background_image drawInRect:drawrect];
            
            UIImage *backingImage = UIGraphicsGetImageFromCurrentImageContext();
            
            UIGraphicsEndImageContext();
            
            [self loadTextureFromImage:backingImage];
        }
        
        draw_texture = YES;
    }
    else if(m_background_transparent)
    {
        if(m_background_texture==0)
        {
            // create checkerboard background
            [self loadTextureFromImage:[UIImage imageNamed:@"checker"]];
            
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        }
        
        draw_texture = YES;
    }
    
    [self startDrawing];
    
    if(draw_texture)
    {
        // clear renderbuffer
        glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT);
        
        GLuint shader = [m_shaderpool getProgram:@"TextureShader"];
        glUseProgram(shader);
        
        float sx = 1;
        float sy = 1;
        
        if(m_background_transparent)
        {
            sx = view.bounds.size.width / 64; // 64 is the size of the checker texture
            sy = view.bounds.size.height / 64;
        }
        
        // x, y, s, t
        GLfloat verts[16];
        verts[0] = -1; verts[1] = 1; verts[2] = 0; verts[3] = sy;
        verts[4] = -1; verts[5] = -1; verts[6] = 0; verts[7] = 0;
        verts[8] = 1; verts[9] = 1; verts[10] = sx; verts[11] = sy;
        verts[12] = 1; verts[13] = -1; verts[14] = sx; verts[15] = 0;
        
        glBindBuffer(GL_ARRAY_BUFFER, 0); // unbind the vertex buffer
        
        GLint attrib_position = glGetAttribLocation(shader, "Position");
        GLint attrib_texturecoord = glGetAttribLocation(shader, "TextureCoord");
        
        // render texture image
        glUniform1i(glGetUniformLocation(shader, "Sampler"), 0);
        glVertexAttribPointer(attrib_position, 2, GL_FLOAT, GL_FALSE, 4*sizeof(GLfloat), &(verts[0]));
        glVertexAttribPointer(attrib_texturecoord, 2, GL_FLOAT, GL_FALSE, 4*sizeof(GLfloat), &(verts[2]));
        
        glEnableVertexAttribArray(attrib_position);
        glEnableVertexAttribArray(attrib_texturecoord);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glDisableVertexAttribArray(attrib_position);
        glDisableVertexAttribArray(attrib_texturecoord);
        
        glBindBuffer(GL_ARRAY_BUFFER, m_vertex_buffer); // re-bind the vertex buffer
    }
    
    if(showTree)
    {
        [m_tree drawViewWithShader:[m_shaderpool getProgram:@"MainShader"]
                             width:view.bounds.size.width
                            height:view.bounds.size.height
                                 x:self.drawOrigin.x
                                 y:self.drawOrigin.y
                             scale:self.drawScale
                                dt:self.time
                           abstime:!self.useRelativeTime
                        background:!draw_texture
                            rbswap:NO
                         linewidth:self.lineWidth];
    }
    else
    {
        if(!draw_texture)
            [m_tree drawBackgroundOnly];
    }
    
    [self endDrawing];
    
    [m_context presentRenderbuffer:GL_RENDERBUFFER];
    
    [self unlockContext];
}

- (void)renderToBuffer:(void *)buffer width:(int)width height:(int)height
{
    DEBUG_LOG(@"IMTreeRender renderToBuffer");
    
    [self lockContext];
    
    if(m_view!=nil || m_render_width != width || m_render_height != height || m_use_multisampling!=YES)
        [self destroyRenderbuffer];
    
    if(m_view_renderbuffer==0)
        [self createRenderbufferWithView:nil width:width height:height];
    
    [self startDrawing];
    
    [m_tree drawViewWithShader:[m_shaderpool getProgram:@"VideoShader"]
                         width:width
                        height:height
                             x:self.drawOrigin.x
                             y:self.drawOrigin.y
                         scale:self.drawScale
                            dt:self.time
                       abstime:!self.useRelativeTime
                    background:YES
                        rbswap:YES
                     linewidth:0];
    
    [self endDrawing];
    
    glBindFramebuffer(GL_FRAMEBUFFER, m_view_framebuffer);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    [self unlockContext];
}

- (void)startDrawing
{
    if(m_use_multisampling)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, m_drawing_framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, m_drawing_renderbuffer);
    }
    else
    {
        glBindFramebuffer(GL_FRAMEBUFFER, m_view_framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, m_view_renderbuffer);
    }
    
    //const GLenum discards[] = {GL_COLOR_ATTACHMENT0};
    //glDiscardFramebufferEXT(GL_FRAMEBUFFER, 1, discards);
}

- (void)endDrawing
{
    if(m_use_multisampling)
    {
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, m_drawing_renderbuffer); // source
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, m_view_framebuffer); // destination
        
        glResolveMultisampleFramebufferAPPLE();
        
        const GLenum discards[] = {GL_COLOR_ATTACHMENT0};
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 1, discards);
        
        glBindRenderbuffer(GL_RENDERBUFFER, m_view_renderbuffer);
    }
}

- (void)destroyResources
{
    DEBUG_LOG(@"IMTreeRender destroyResources");
    
    [self lockContext];
    [self destroyRenderbuffer];
    [self unlockContext];
}

- (void)setBackgroundImage:(UIImage *)image
{
    [self lockContext];
    if(image != m_background_image)
    {
        [image retain];
        [m_background_image release];
        m_background_image = image;
    
        [self destroyTexturebuffer];
    }
    [self unlockContext];
}

- (UIImage *)backgroundImage
{
    return [[m_background_image retain] autorelease];
}

- (void)setBackgroundIsTransparent:(BOOL)transparent
{
    [self lockContext];
    if(transparent != m_background_transparent)
    {
        m_background_transparent = transparent;
    
        [self destroyTexturebuffer];
    }
    [self unlockContext];
}

- (BOOL)backgroundIsTransparent
{
    return m_background_transparent;
}

- (void)dealloc
{
    DEBUG_LOG(@"IMTreeRender dealloc");
    
    [self lockContext];
    [self destroyRenderbuffer];
    [m_shaderpool release];
    [self unlockContext];

    [m_context_lock release];
    [m_context release];
    
    [m_background_image release];
    [m_tree release];
    
    [super dealloc];
}

@end

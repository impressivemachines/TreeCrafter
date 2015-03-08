//
//  IMTreeRender.h
//  Tree Crafter iPad app
//
//  Created by SIMON WINDER on 7/15/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "fractaltrees.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGLDrawable.h>

#import "IMTreeModel.h"
#import "IMShaderPool.h"


@interface IMTreeRender : NSObject
{
    IMTreeModel *m_tree;
    NSLock *m_context_lock;
    
    EAGLContext *m_context;
    
    GLuint m_drawing_renderbuffer;
    GLuint m_drawing_framebuffer;
    GLuint m_view_renderbuffer;
    GLuint m_view_framebuffer;
    GLuint m_vertex_buffer;
    GLuint m_background_texture;
    
    int m_render_width, m_render_height;
    
    IMShaderPool *m_shaderpool;
    
    BOOL m_use_multisampling;
    BOOL m_background_transparent;
    UIImage *m_background_image;
    
    UIView *m_view;
}

@property (atomic, assign) CGPoint drawOrigin;
@property (atomic, assign) float drawScale;
@property (atomic, assign) float time;
@property (atomic, assign) BOOL useRelativeTime;
@property (atomic, assign) float lineWidth;

- (void)setBackgroundImage:(UIImage *)image;
- (UIImage *)backgroundImage;

- (void)setBackgroundIsTransparent:(BOOL)transparent;
- (BOOL)backgroundIsTransparent;

- (id)initWithTree:(IMTreeModel *)tree;
- (void)renderToView:(UIView *)view showTree:(BOOL)showTree multisample:(BOOL)multisample;
- (void)renderToBuffer:(void *)buffer width:(int)width height:(int)height;
- (void)destroyResources;

@end

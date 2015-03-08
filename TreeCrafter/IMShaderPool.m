//
//  IMShaderPool.m
//  


#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "fractaltrees.h"
#import "IMShaderPool.h"


@implementation IMShaderPool

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if(self)
    {
        self.path = path;
        m_dict = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    
    return self;
}

- (BOOL)loadProgram:(NSString *)name vertexShader:(NSString *)vertexFile fragmentShader:(NSString *)fragmentFile
{
    [self unloadProgram:name];
    
    DEBUG_LOG(@"Loading shader %@ / %@\n", vertexFile, fragmentFile);
    
    GLuint vertexShader = [self compileShader:vertexFile type:GL_VERTEX_SHADER];
    if(vertexShader==0)
        return NO;
    
    GLuint fragmentShader = [self compileShader:fragmentFile type:GL_FRAGMENT_SHADER];
    if(fragmentShader==0)
    {
        glDeleteShader(vertexShader);
        return NO;
    }
    
    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    
#ifdef DEBUG_LOGGING
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if(logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        DEBUG_LOG(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if(status==GL_FALSE)
    {
        glDetachShader(program, vertexShader);
        glDeleteShader(vertexShader);
        glDetachShader(program, fragmentShader);
        glDeleteShader(fragmentShader);
        glDeleteProgram(program);
        return NO;
    }
    
    glDetachShader(program, vertexShader);
    glDeleteShader(vertexShader);
    glDetachShader(program, fragmentShader);
    glDeleteShader(fragmentShader);
    
    [m_dict setObject:[NSNumber numberWithInt:(int)program] forKey:name];
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)program
{
    glValidateProgram(program);
    
#ifdef DEBUG_LOGGING
    GLint logLength;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        DEBUG_LOG(@"Program validate log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    
    return status!=GL_FALSE;
}

- (GLuint)compileShader:(NSString *)file type:(GLenum)type
{
    NSString *filepath = [self.path stringByAppendingPathComponent:file];
    NSString *source = [NSString stringWithContentsOfFile:filepath encoding:NSASCIIStringEncoding error:nil];
    
    if(source==nil)
    {
        DEBUG_LOG(@"Error: Cannot open shader file %@\n", filepath);
        return 0;
    }
    
    GLuint shader = glCreateShader(type);
    if(shader==0)
        return 0;
    
    const GLchar *pconstbuf = [source UTF8String];
    glShaderSource(shader, 1, &pconstbuf, NULL);
    glCompileShader(shader);
    
#ifdef DEBUG_LOGGING
    GLint logLength;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if(logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, &logLength, log);
        DEBUG_LOG(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    GLint status;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    if(status==GL_FALSE)
    {
        DEBUG_LOG(@"Error: Shader compile failed.\n");
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

- (GLuint)getProgram:(NSString *)name
{
    id obj = [m_dict objectForKey:name];
    if(obj)
    {
        return (GLuint)[obj intValue];
    }
    else
        return 0;
}

- (void)unloadProgram:(NSString *)name
{
    id obj = [m_dict objectForKey:name];
    if(obj)
    {
        GLuint shader = (GLuint)[obj intValue];
        glDeleteProgram(shader);
        [m_dict removeObjectForKey:name];
    }
}

- (void)unloadAll
{
    for(id obj in [m_dict allKeys])
        [self unloadProgram:(NSString *)obj];
}

- (void)dealloc
{
    [self unloadAll];
    
    [_path release];
    [m_dict release];
    
    [super dealloc];
}

@end

//
//  Generic.vsh
//
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.

attribute vec3 VertexLocation;
attribute vec2 VertexOffset;

uniform lowp vec4 LeafColor;
uniform lowp vec4 RootColor;
uniform mat3 Transform;
uniform float Thickness;
uniform float BaseScale;
uniform float ScaleThresh;
uniform float ScaleToColor;
uniform float ColorTransitionK1;
uniform float ColorTransitionK2;
uniform float ColorTransitionK3;

varying lowp vec4 FragColor;

void main()
{
    float scale = BaseScale * VertexLocation.z;
    lowp float ok = scale >= ScaleThresh ? 1.0 : 0.0;

    float dx = Thickness * VertexOffset.x;
    float dy = Thickness * VertexOffset.y;
    vec3 v = Transform * vec3(VertexLocation.x + dx, VertexLocation.y - dy, 1.0);
    gl_Position = vec4(ok * v.x, ok * v.y, 0.0, 1.0);
    
    float d = ScaleToColor * log(scale + 0.00001);
    d = clamp(d, 0.0, 1.0);
    d = ColorTransitionK1 * d / (d * ColorTransitionK2 + ColorTransitionK3);

    lowp vec4 color = mix(RootColor, LeafColor, d);
    color.a = ok;
    FragColor = color;
}


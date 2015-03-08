//
//  Texture.fsh
//
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.


varying mediump vec2 TextureCoordOut;

uniform sampler2D Sampler;

void main()
{
    gl_FragColor = texture2D(Sampler, TextureCoordOut);
}

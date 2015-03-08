//
//  Texture.vsh
//
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.


attribute vec4 Position;
attribute vec2 TextureCoord;

varying vec2 TextureCoordOut;

void main()
{
    gl_Position = Position;
    TextureCoordOut = TextureCoord;
}

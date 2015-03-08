//
//  TreeModel.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef __Fractal_Trees__TreeModel__
#define __Fractal_Trees__TreeModel__

struct ITreeModel
{
    virtual ~ITreeModel() {}
    
    virtual double GetParameter(int paramid) = 0;
    virtual void SetParameter(int paramid, double val) = 0;
    virtual bool Init() = 0;
    virtual void DrawOpenGL(GLuint shader, float w, float h, float x, float y, float scale, float dt, bool abstime, bool drawbackground, bool rbswap, float linewidth) = 0;
    virtual void DrawOpenGLBlankScreen() = 0;
    virtual void FreeResources() = 0;
    virtual CGRect GetBoundingBox() = 0;
    virtual void RandomSeedRefresh() = 0;
    virtual bool ScaleOffsetForView(const CGRect &bounds, float &drawx, float &drawy, float &drawscale) = 0;
    virtual int DrawQuartz(CGContextRef ctx, const CGRect &bounds, float drawx, float drawy, float drawscale, float time, float linewidth, int quality, int vertextarget, bool drawbackground, bool (*progress)(float val, void *user), void *user) = 0;
    virtual bool DrawQuartz(CGContextRef ctx, const CGRect &bounds, int quality, bool drawbackground) = 0;
    //virtual float FileSizeForVertexBudget(float verts) = 0;
};

ITreeModel *CreateTreeModel();
void DestroyTreeModel(ITreeModel *p);

#endif /* defined(__Fractal_Trees__TreeModel__) */

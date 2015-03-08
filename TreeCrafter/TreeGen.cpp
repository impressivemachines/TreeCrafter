//
//  TreeGen.cpp
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#include <QuartzCore/QuartzCore.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "fractaltrees.h"
#include "random.h"
#include "TreePath.h"
#include "TreeGen.h"


void CTreeGen::GetChildFrame(int i, TreeFrame &frame)
{
    const TreeFrame &child = m_rgframelist[i];
    
    float baseangle = m_curve.m_frame.angle;
    float basescale = m_curve.m_frame.scale;
    float ct = basescale * cosf(baseangle);
    float st = basescale * sinf(baseangle);
    
    frame.angle = baseangle + child.angle;
    frame.scale = basescale * child.scale;
    frame.x = ct * child.x - st * child.y + m_curve.m_frame.x;
    frame.y = st * child.x + ct * child.y + m_curve.m_frame.y;
}

void CTreeGen::SortChildFrameSizes()
{
    int i;
    for(i=0; i<m_childframecount; i++)
        m_rgsortedframeindex[i] = i;
    
    int j;
    for(i=0; i<m_childframecount-1; i++)
    {
        float maxscale = m_rgframelist[m_rgsortedframeindex[i]].scale;
        int bestindex = i;
        for(j=i+1; j<m_childframecount; j++)
        {
            float scale = m_rgframelist[m_rgsortedframeindex[j]].scale;
            if(scale > maxscale)
            {
                bestindex = j;
                maxscale = scale;
            }
        }
        
        if(bestindex!=i)
        {
            int temp = m_rgsortedframeindex[i];
            m_rgsortedframeindex[i] = m_rgsortedframeindex[bestindex];
            m_rgsortedframeindex[bestindex] = temp;
        }
    }
    
}

void CTreeGen::GetVertices(Vertex *p)
{
    TreeFrame frame = m_curve.m_frame;
    
    Vertex v;
    v.scale = frame.scale;
    
    float dline = 0.05f * m_trunkwidth * frame.scale;
    
    float sa = sinf(frame.angle);
    float ca = cosf(frame.angle);
    float dsa = dline * sa;
    float dca = dline * ca;
    
    v.dx = sa;
    v.dy = ca;
    SET_COORD(0.0f, -1.0f);
    *p++ = v; // degenerate triangle to break strip
    *p++ = v;
    
    v.dx = 0;
    v.dy = 0;
    SET_COORD(-0.433f, -0.3f);
    *p++ = v;
    
    v.x = frame.x;
    v.y = frame.y;
    *p++ = v;
    
    SET_COORD(-0.433f, 0.3f);
    *p++ = v;
    
    v.dx = -sa;
    v.dy = -ca;
    SET_COORD(0.0f, 1.0f);
    *p++ = v;
    *p++ = v; // degenerate triangle to break strip
    
    v.dx = sa;
    v.dy = ca;
    v.x = frame.x + dsa;
    v.y = frame.y - dca;
    *p++ = v; // degenerate triangle to break strip
    *p++ = v;
    
    v.dx = -sa;
    v.dy = -ca;
    v.x = frame.x - dsa;
    v.y = frame.y + dca;
    *p++ = v;
    
    int i;
    for(i=0; i<m_nodecount; i++)
    {
        float d = m_rgnodeposition[i];
        float w = v.scale * m_rgwiggleoffset[i];
        
        m_curve.GetLoc(d, frame);
        
        float dd = (1 - m_trunktaper * d) * dline;
        
        sa = sinf(frame.angle);
        ca = cosf(frame.angle);
        
        frame.x -= w * sa;
        frame.y += w * ca;
        
        dsa = dd * sa;
        dca = dd * ca;
        
        v.dx = sa;
        v.dy = ca;
        v.x = frame.x + dsa;
        v.y = frame.y - dca;
        *p++ = v;
        
        v.dx = -sa;
        v.dy = -ca;
        v.x = frame.x - dsa;
        v.y = frame.y + dca;
        *p++ = v;
    }
    
    if(m_apextype==0)
        *p++ = v; // degenerate triangle to break strip
    else if(m_apextype==1 || m_apextype==3)
    {
        // rounded end
        v.dx = 0;
        v.dy = 0;
        
        SET_COORD(0.588f, -0.809f);
        *p++ = v;
        
        SET_COORD(0.588f, 0.809f);
        *p++ = v;
        
        SET_COORD(0.951f, -0.309f);
        *p++ = v;
        
        SET_COORD(0.951f, 0.309f);
        *p++ = v;
        
        *p++ = v;  // degenerate triangle to break strip
    }
    else
    {
        *p++ = v;  // degenerate triangle to break strip
        
        // broken end
        v.dx = 0;
        v.dy = 0;
        SET_COORD(2.0f, 1.0f);
        *p++ = v;
        *p++ = v;
        
        v.dx = -sa;
        v.dy = -ca;
        SET_COORD(0.0f, 1.0f);
        *p++ = v;
        
        v.dx = 0;
        v.dy = 0;
        SET_COORD(1.2f, 0.6f);
        *p++ = v;
        
        SET_COORD(0.0f, -0.2f);
        *p++ = v;
        
        SET_COORD(1.6f, 0.2f);
        *p++ = v;
        *p++ = v;
        
        SET_COORD(0.8f, -0.6f);
        *p++ = v;
        *p++ = v;
        
        SET_COORD(0.0f, -0.2f);
        *p++ = v;
        
        SET_COORD(0.4f, -1.0f);
        *p++ = v;
        
        v.dx = sa;
        v.dy = ca;
        SET_COORD(0.0f, -1.0f);
        *p++ = v;
        *p++ = v;
    }
}

bool CTreeGen::GetPaths(CTreePath &path, int level)
{
    TreeFrame baseframe = m_curve.m_frame;
    
    if(!path.StartPath(baseframe.scale))
        return false;
    
    float dline = 0.05f * m_trunkwidth * baseframe.scale;
    
    float sa = sinf(baseframe.angle);
    float ca = cosf(baseframe.angle);
    float dsa = dline * sa;
    float dca = dline * ca;
    
    CGPoint v;
    TreeFrame frame = baseframe;
    
    SET_COORD(0.0f, -1.0f);
    if(!path.AddPoint(v))
        return false;
    
    //if(level>0)
    {
        SET_COORD(-0.433f, -0.3f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(-0.433f, 0.3f);
        if(!path.AddPoint(v))
            return false;
    }
    
    SET_COORD(0.0f, 1.0f);
    if(!path.AddPoint(v))
        return false;
    
    int i;
    for(i=0; i<m_nodecount; i++)
    {
        float d = m_rgnodeposition[i];
        float w = baseframe.scale * m_rgwiggleoffset[i];
        
        m_curve.GetLoc(d, frame);
        
        float dd = (1 - m_trunktaper * d) * dline;
        
        sa = sinf(frame.angle);
        ca = cosf(frame.angle);
        
        frame.x -= w * sa;
        frame.y += w * ca;
        
        dsa = dd * sa;
        dca = dd * ca;
        
        SET_COORD(0.0f, 1.0f);
        if(!path.AddPoint(v))
            return false;
    }
    
    if(m_apextype==1 || m_apextype==3)
    {
        // rounded
        SET_COORD(0.588f, 0.809f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(0.951f, 0.309f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(0.951f, -0.309f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(0.588f, -0.809f);
        if(!path.AddPoint(v))
            return false;
    }
    else if(m_apextype==2)
    {
        // broken
        SET_COORD(2.0f, 1.0f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(1.2f, 0.6f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(1.6f, 0.2f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(0.0f, -0.2f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(0.8f, -0.6f);
        if(!path.AddPoint(v))
            return false;
        
        SET_COORD(0.4f, -1.0f);
        if(!path.AddPoint(v))
            return false;
    }
    
    for(i=m_nodecount-1; i>=0; i--)
    {
        float d = m_rgnodeposition[i];
        float w = baseframe.scale * m_rgwiggleoffset[i];
        
        m_curve.GetLoc(d, frame);
        
        float dd = (1 - m_trunktaper * d) * dline;
        
        sa = sinf(frame.angle);
        ca = cosf(frame.angle);
        
        frame.x -= w * sa;
        frame.y += w * ca;
        
        dsa = dd * sa;
        dca = dd * ca;
        
        SET_COORD(0.0f, -1.0f);
        if(!path.AddPoint(v))
            return false;
    }
    
    path.EndPath();
    
    return true;
}

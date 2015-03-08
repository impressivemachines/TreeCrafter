//
//  TreeGenGeometric.cpp
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
#include "TreeGenGeometric.h"

bool CTreeGenGeometric::Init(int randomseed, int branchcount, int geonodes, int apextype, int anglemode, float delay, float georatio, float spin, float twist, float bend, float spread, float lengthratio, float spikiness, float trunkwidth, float trunktaper, float randomwiggle, float randomangle, float randomlength, float randominterval, int windseed1, int windseed2, float winddepth, float windalpha)
{
    if(branchcount*geonodes+1 > MAX_TREEGEN_DATA_SIZE)
        return false;
    
    m_trunkwidth = trunkwidth;
    m_trunktaper = trunktaper;
    if(anglemode==3)
        anglemode = 0;
    
    delay = 0.75f*delay;
    georatio = 0.1f + 1.1f*georatio;
    spin *= 2*M_PI;
    randomangle *= 0.5f;
    randomlength *= 0.3f;
    winddepth *= 0.25f;
    //windalpha = 0.5f*(1-cosf(M_PI*windalpha));
    
    twist = 2 * (twist - 0.5f);
    if(twist>=0)
        twist = M_PI*twist*twist;
    else
        twist = -M_PI*twist*twist;
    
    if(spikiness==0)
        apextype = 1; // always a rounded end for zero spikiness
    
    m_apextype = apextype;
    
    CRand rnd(randomseed);
    CRand windrnd1(windseed1);
    CRand windrnd2(windseed2);
    
    bend += 0.04f * winddepth * ((1-windalpha)*windrnd1.Gauss() + windalpha * windrnd2.Gauss());
    bend = (bend<0) ? 0 : ((bend>1) ? 1 : bend);
    
    m_childframecount = branchcount * geonodes;
    m_nodecount = geonodes;
    
    bool hasapexframe = false;
    if(apextype==3 && spikiness>0)
    {
        hasapexframe = true;
        m_childframecount++; // one extra for the apex frame
    }
    
    if(!hasapexframe && spikiness>0)
        m_nodecount++; // one extra node for the non fractal case
    
    float geosum = 0;
    float geonext = 1;
    int i;
    for(i=0; i<geonodes; i++)
    {
        geosum += geonext;
        geonext *= georatio;
    }
    
    TreeFrame frame;
    frame.x = 0;
    frame.y = 0;
    frame.angle = 0;
    frame.scale = 1;
    
    m_curve.Init(bend);
    m_curve.SetFrame(frame);
    
    float base = (1-delay)/geosum;
    float nodepos = delay;
    for(i=0; i<geonodes; i++)
    {
        m_rgnodeposition[i] = nodepos;
        nodepos += base;
        base *= georatio;
    }
    
    if(!hasapexframe && spikiness>0)
    {
        // normal apex with extra node for end of curve
        m_rgnodeposition[geonodes] = spikiness + (1-spikiness)*m_rgnodeposition[geonodes-1];
    }
    
    float rgnewnodeposition[MAX_TREEGEN_DATA_SIZE];
    
    for(i=0; i<m_nodecount-1; i++)
    {
        float prevd = 0;
        if(i>0)
            prevd = m_rgnodeposition[i-1];
        float nextd = m_rgnodeposition[i+1];
        float d = m_rgnodeposition[i];
        float range = d - prevd;
        if(nextd - d < range)
            range = nextd - d;
        range *= 0.45f;
        float doffset = range * rnd.Gauss() * randominterval;
        if(doffset > range)
            doffset = range;
        else if(doffset < -range)
            doffset = -range;
        rgnewnodeposition[i] = d + doffset;
    }
    
    for(i=0; i<m_nodecount-1; i++)
        m_rgnodeposition[i] = rgnewnodeposition[i];
    
    float scalefornode = lengthratio;
    int k=0;
    for(i=0; i<geonodes; i++)
    {
        nodepos = m_rgnodeposition[i];
        
        float w = 0.01f * randomwiggle * rnd.Gauss();
        m_rgwiggleoffset[i] = w;
        
        m_curve.GetLoc(nodepos, frame);
        
        frame.x -= w * sinf(frame.angle);
        frame.y += w * cosf(frame.angle);
        
        frame.scale = expf(randomlength * rnd.Gauss()) * scalefornode;
        if(frame.scale > 0.75f)
            frame.scale = 0.75f;
        
        float tangentangle = frame.angle;
        float anglegain = 1;
        if(anglemode==1)
            anglegain = nodepos;
        else if (anglemode==2)
            anglegain = 1-nodepos;
        
        float branchrotation = spin + twist * i;
        int j;
        for(j=0; j<branchcount; j++)
        {
            frame.angle = tangentangle + anglegain * M_PI * spread * cos(branchrotation) + randomangle * rnd.Gauss()
                + winddepth * ((1-windalpha)*windrnd1.Gauss() + windalpha * windrnd2.Gauss());
            
            m_rgframelist[k++] = frame;
            branchrotation += 2*M_PI/branchcount;
        }
        
        scalefornode *= georatio;
    }
    
    m_rgwiggleoffset[geonodes] = 0;
    
    if(hasapexframe)
    {
        m_curve.GetLoc(m_rgnodeposition[geonodes-1], frame);
        float w = m_rgwiggleoffset[geonodes-1];
        frame.x -= w * sinf(frame.angle);
        frame.y += w * cosf(frame.angle);
        frame.scale = expf(randomlength * rnd.Gauss()) * scalefornode * spikiness / georatio;
        if(frame.scale > 0.75f)
            frame.scale = 0.75f;
        m_rgframelist[k++] = frame;
    }
    
    if(apextype==3)
    {
        // adjust the trunk taper to match width at last node
        float maxscale = 0;
        int lastframesetindex = (geonodes-1)*branchcount;
        int j;
        for(j=0; j<branchcount; j++)
        {
            if(m_rgframelist[lastframesetindex + j].scale > maxscale)
                maxscale = m_rgframelist[lastframesetindex + j].scale;
        }
        
        if(hasapexframe && m_rgframelist[geonodes * branchcount].scale > maxscale)
            maxscale = m_rgframelist[geonodes * branchcount].scale;
        
        m_trunktaper *= (1 - maxscale)/m_rgnodeposition[geonodes-1];
    }
    
    m_vertexcount = 2*m_nodecount + 4 + 7; // 7 for the root end cap
    m_pathpointcount = 2*m_nodecount + 2;
    
    if(apextype==1 || apextype==3)
    {
        m_vertexcount += 4;
        m_pathpointcount += 4;
    }
    else if(apextype==2)
    {
        m_vertexcount += 13;
        m_pathpointcount += 6;
    }
    
    return true;
}



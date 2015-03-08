//
//  TreeGenRational.cpp
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
#include "TreeGenRational.h"

int qsort_compare_ascending(const void *q1, const void *q2)
{
    float v1 = ((const Rational *)q1)->FloatVal();
    float v2 = ((const Rational *)q2)->FloatVal();
    return (v1 > v2) - (v1 < v2);
}

bool CTreeGenRational::Init(int randomseed, int intervalstart, int intervalcount, int apextype, int anglemode, float bend, float balance, float spread, float lengthratio, float lengthbalance, float spikiness, float trunkwidth, float trunktaper, float randomangle, float randomlength, float randomwiggle, float randominterval, int windseed1, int windseed2, float winddepth, float windalpha)
{
    m_trunkwidth = trunkwidth;
    m_trunktaper = trunktaper;
    
    if(spikiness==0)
        apextype = 1; // always a rounded end for zero spikiness
    
    m_apextype = apextype;
    
    randomangle *= 0.5f;
    randomlength *= 0.3f;
    lengthratio *= 2.0f;
    winddepth *= 0.25f;
    //windalpha = 0.5f*(1-cosf(M_PI*windalpha));
    
    CRand rnd(randomseed);
    CRand windrnd1(windseed1);
    CRand windrnd2(windseed2);
    
    bend += 0.04f * winddepth * ((1-windalpha)*windrnd1.Gauss() + windalpha * windrnd2.Gauss());
    bend = (bend<0) ? 0 : ((bend>1) ? 1 : bend);
    
    int divlow = intervalstart;
    int divhigh = divlow + intervalcount;
    
    int rationalcount = 0;
    int i, j;
    for(i=divlow; i<=divhigh; i++)
        for(j=1; j<i; j++)
            rationalcount++;
    
    if(rationalcount>MAX_TREEGEN_DATA_SIZE)
        return false;
    
    Rational rgrational[MAX_TREEGEN_DATA_SIZE];
    
    int k = 0;
    for(i=divlow; i<=divhigh; i++)
        for(j=1; j<i; j++)
            rgrational[k++] = Rational(j, i);
    
    qsort(rgrational, rationalcount, sizeof(Rational), qsort_compare_ascending);
    
    m_childframecount = rationalcount * 2;
    bool hasapexframe = false;
    if(apextype==3 && spikiness>0)
    {
        hasapexframe = true;
        m_childframecount++; // one extra for the apex frame
    }
    
    if(m_childframecount>MAX_TREEGEN_DATA_SIZE)
        return false;
    
    float prev = 0;
    m_nodecount = 0;
    for(i=0; i<rationalcount; i++)
    {
        float d = rgrational[i].FloatVal();
        if(i!=0 && d != prev)
        {
            m_nodecount++;
            prev = d;
        }
        
        m_rgnodemap[i] = m_nodecount;
    }
    
    m_nodecount++;
    
    if(!hasapexframe && spikiness>0)
        m_nodecount++;
    
    if(m_nodecount>MAX_TREEGEN_DATA_SIZE)
        return false;
    
    prev = 0;
    for(i=0, j=0; i<rationalcount; i++)
    {
        float d = rgrational[i].FloatVal();
        if(d != prev)
        {
            m_rgnodeposition[j] = d;
            m_rgwiggleoffset[j] = 0.01f * randomwiggle * rnd.Gauss();
            j++;
            prev = d;
        }
    }
    
    m_rgwiggleoffset[j] = 0; // last node if it exists
    
    if(!hasapexframe && spikiness>0)
    {
        // compute apex end point
        float alpha = (divhigh - 1)/(float)divhigh;
        m_rgnodeposition[j] = (1-spikiness)*alpha + spikiness;
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
        
        //DEBUG_PRINTF("from %f to %f\n", d, d+doffset);
        
        rgnewnodeposition[i] = d + doffset;
    }
    
    for(i=0; i<m_nodecount-1; i++)
        m_rgnodeposition[i] = rgnewnodeposition[i];
    
    TreeFrame frame;
    frame.x = 0;
    frame.y = 0;
    frame.angle = 0;
    frame.scale = 1;
    
    float rot2 = balance * spread * 2.0f * M_PI;
    float rot1 = (1-balance) * spread * 2.0f * M_PI;
    
    m_curve.Init(bend);
    m_curve.SetFrame(frame);
    
    for(i=0, j=0; i<rationalcount; i++)
    {
        int n = m_rgnodemap[i];
        float d = m_rgnodeposition[n];
        float w = m_rgwiggleoffset[n];
        float denom = rgrational[i].denominator;
        
        m_curve.GetLoc(d, frame);
        
        frame.x -= w * sinf(frame.angle);
        frame.y += w * cosf(frame.angle);
        
        float rfactor;
        switch(anglemode)
        {
            case 0:
                rfactor = 1.0f;
                break;
            case 1:
                rfactor = 2.0f * d;
                break;
            case 2:
                rfactor = 2.0f * (1-d);
                break;
            case 3:
            default:
                rfactor = 2.0f/denom;
                break;
        }
        
        float childscale = expf(randomlength * rnd.Gauss()) * lengthratio / denom;
        float tangentangle = frame.angle;
        
        float lb = lengthbalance * 2;
        if(lb > 1)
            lb = 1;
        
        frame.scale = childscale * lb;
        if(frame.scale > 0.75f)
            frame.scale = 0.75f;
        
        frame.angle = tangentangle + rot1 * rfactor + randomangle * rnd.Gauss() + winddepth * ((1-windalpha)*windrnd1.Gauss() + windalpha * windrnd2.Gauss());
        m_rgframelist[j++] = frame;
        
        lb = (1-lengthbalance) * 2;
        if(lb > 1)
            lb = 1;
        
        frame.scale = childscale * lb;
        if(frame.scale > 0.75f)
            frame.scale = 0.75f;
        
        frame.angle = tangentangle - rot2 * rfactor + randomangle * rnd.Gauss() + winddepth * ((1-windalpha)*windrnd1.Gauss() + windalpha * windrnd2.Gauss());
        m_rgframelist[j++] = frame;
    }
    
    i = rationalcount-1;
    float finald = rgrational[i].FloatVal();
    float finaldenom = rgrational[i].denominator;
    
    if(hasapexframe)
    {
        // add apex frame
        m_curve.GetLoc(finald, frame);
        
        int n = m_rgnodemap[i];
        float w = m_rgwiggleoffset[n];
        
        frame.x -= w * sinf(frame.angle);
        frame.y += w * cosf(frame.angle);
        
        frame.scale = expf(randomlength * rnd.Gauss()) * spikiness * lengthratio / finaldenom;
        if(frame.scale > 0.75f)
            frame.scale = 0.75f;
        m_rgframelist[j++] = frame;
    }
    
    if(apextype==3)
    {
        float maxscale = m_rgframelist[j-1].scale;
        if(m_rgframelist[j-2].scale > maxscale)
            maxscale = m_rgframelist[j-2].scale;
        if(hasapexframe && m_rgframelist[j-3].scale > maxscale)
            maxscale = m_rgframelist[j-3].scale;
        
        m_trunktaper *= (1 - maxscale)/finald;
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

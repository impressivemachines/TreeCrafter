//
//  TreePath.cpp
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
#include "TreePath.h"

#define PATH_ALLOC_UNIT     1024
#define POINT_ALLOC_UNIT    16

bool CTreePath::Init()
{
    Free();
    return true;
}

void CTreePath::Free()
{
    if(m_path)
    {
        int i;
        for(i=0; i<m_maxpathcount; i++)
            if(m_path[i].pPoints)
                free(m_path[i].pPoints);
        
        free(m_path);
        m_path = NULL;
    }
    
    m_pathcount = 0;
    m_maxpathcount = 0;
    m_maxpointsinanypath = 0;
    m_pointcount = 0;
}

bool CTreePath::StartPath(float scale)
{
    if(m_path==NULL)
        if(!Init())
            return false;
    
    if(m_pathcount==m_maxpathcount)
    {
        PathInfo *pNew = (PathInfo *)realloc(m_path, (m_maxpathcount + PATH_ALLOC_UNIT) * sizeof(PathInfo));
        if(pNew==NULL)
            return false;
        
        memset(pNew + m_maxpathcount, 0, PATH_ALLOC_UNIT * sizeof(PathInfo));
        
        m_path = pNew;
        m_maxpathcount += PATH_ALLOC_UNIT;
    }

    m_path[m_pathcount].scale = scale;

    return true;
}

bool CTreePath::AddPoint(const CGPoint &p)
{
    int count = m_path[m_pathcount].count;
    if(count==m_path[m_pathcount].maxcount)
    {
        CGPoint *pNew = (CGPoint *)realloc(m_path[m_pathcount].pPoints, (count + POINT_ALLOC_UNIT) * sizeof(CGPoint));
        if(pNew==NULL)
            return false;
        m_path[m_pathcount].pPoints = pNew;
        m_path[m_pathcount].maxcount += POINT_ALLOC_UNIT;
    }
    
    m_path[m_pathcount].pPoints[count] = p;
    m_path[m_pathcount].count++;
    return true;
}

void CTreePath::EndPath()
{
    int count = m_path[m_pathcount].count;
    if(count > m_maxpointsinanypath)
        m_maxpointsinanypath = count;
    m_pointcount += count;
    m_pathcount++;
}

CGPoint *CTreePath::GetPath(int path, int &count, float &scale)
{
    if(path<0 || path>=m_pathcount)
    {
        count = 0;
        scale = 0;
        return NULL;
    }
    
    scale = m_path[path].scale;
    count = m_path[path].count;
    return count>0 ? m_path[path].pPoints : NULL;
}


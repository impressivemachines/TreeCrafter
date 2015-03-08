//
//  TreePath.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef __Fractal_Trees__TreePath__
#define __Fractal_Trees__TreePath__

struct PathInfo
{
    float scale;
    int maxcount;
    int count;
    CGPoint *pPoints;
};

class CTreePath
{
public:
    CTreePath() : m_pathcount(0), m_maxpathcount(0), m_maxpointsinanypath(0), m_pointcount(0), m_path(NULL) {}
    ~CTreePath() { Free(); }
    
    bool Init();
    void Free();
    
    bool StartPath(float scale);
    bool AddPoint(const CGPoint &p);
    void EndPath();
    
    CGPoint *GetPath(int path, int &count, float &scale);
    
    int PathCount() { return m_pathcount; }
    int PointCount() { return m_pointcount; }
    int MaxPointsInAnyPath() { return m_maxpointsinanypath; }
    
private:
    int m_pathcount;
    int m_maxpathcount;
    int m_maxpointsinanypath;
    int m_pointcount;
    
    PathInfo *m_path;
};

#endif /* defined(__Fractal_Trees__TreePath__) */

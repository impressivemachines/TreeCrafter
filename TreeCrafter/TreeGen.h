//
//  TreeGen.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef Fractal_Trees_TreeGen_h
#define Fractal_Trees_TreeGen_h

#define SET_COORD(dx, dy) \
v.x = frame.x + (dx) * dca - (dy) * dsa; \
v.y = frame.y + (dx) * dsa + (dy) * dca;

#define MAX_TREEGEN_DATA_SIZE   256

struct Vertex
{
    float x, y, scale;
    float dx, dy;
};

struct Rational
{
    Rational() {}
    Rational(const Rational &r) { numerator = r.numerator; denominator = r.denominator; }
    Rational(int n, int d) { numerator = n; denominator = d; }
    float FloatVal() const { return numerator/(float)denominator; }
    int numerator, denominator;
};

class CTreeCurve
{
public:
    void Init(float bend)
    {
        m_bend = 2 * M_PI * (bend - 0.5f);
        m_absbend = fabs(m_bend);
    }
    
    void SetFrame(const TreeFrame &frame)
    {
        k1 = 2.0f*frame.scale/m_absbend;
        m_frame = frame;
    }
    
    void GetLoc(float d, TreeFrame &frame)
    {
        float chord;
        if(m_absbend>0.001f)
        {
            chord = k1 * sinf(0.5f * d * m_absbend);
            float theta = d * m_bend;
            float theta2 = 0.5f * theta;
            float turn = m_frame.angle - theta2;
            frame.x = m_frame.x + chord * cosf(turn);
            frame.y = m_frame.y + chord * sinf(turn);
            frame.angle = m_frame.angle - theta;
            frame.scale = m_frame.scale;
        }
        else
        {
            chord = d * m_frame.scale;
            frame.x = m_frame.x + chord * cosf(m_frame.angle);
            frame.y = m_frame.y + chord * sinf(m_frame.angle);
            frame.angle = m_frame.angle;
            frame.scale = m_frame.scale;
        }
    }
    
public:
    TreeFrame m_frame;
private:
    float m_bend, m_absbend;
    float k1;
};

class CTreeGen
{
public:
    CTreeGen() : m_vertexcount(0), m_pathpointcount(0), m_childframecount(0), m_apextype(0), m_nodecount(0) {}
    virtual ~CTreeGen() {}
    
    void SetFrame(const TreeFrame &frame) { m_curve.SetFrame(frame); }
    
    int GetChildFrameCount() { return m_childframecount; }
    void GetChildFrame(int i, TreeFrame &frame);
    
    int GetVertexCount() { return m_vertexcount; }
    void GetVertices(Vertex *p);
    
    int GetPathPointCount() { return m_pathpointcount; }
    bool GetPaths(CTreePath &path, int level);
    
    void SortChildFrameSizes();
    void GetSortedChildFrame(int i, TreeFrame &frame) { GetChildFrame(m_rgsortedframeindex[i], frame); }
    int GetSortedIndex(int i) { return m_rgsortedframeindex[i]; }
    
protected:
    CTreeCurve m_curve;
    TreeFrame m_rgframelist[MAX_TREEGEN_DATA_SIZE];
    float m_rgnodeposition[MAX_TREEGEN_DATA_SIZE];
    float m_rgwiggleoffset[MAX_TREEGEN_DATA_SIZE];
    int m_rgsortedframeindex[MAX_TREEGEN_DATA_SIZE];
    
    int m_vertexcount; // total number of vertices generated for branch
    int m_pathpointcount;
    int m_childframecount; // total number of next level frames

    float m_trunkwidth;
    float m_trunktaper;
    int m_apextype;
    int m_nodecount; // total nodes on branch, not including root
};


#endif

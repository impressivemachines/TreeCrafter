//
//  TreeModel.cpp
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <QuartzCore/QuartzCore.h>

#include <Accelerate/Accelerate.h>

#include "fractaltrees.h"
#include "random.h"
#include "matrix.h"
#include "TreeModel.h"
#include "TreeData2.h"
#include "TreePath.h"
#include "TreeGen.h"
#include "TreeGenRational.h"
#include "TreeGenGeometric.h"

#define BUFFER_BYTE_OFFSET(i) ((unsigned char *)NULL + (i*sizeof(unsigned char)))

double mark_time()
{
    static double start_time = 0;
    double next_time = CACurrentMediaTime();
    double delta_time = next_time - start_time;
    start_time = next_time;
    return 1000*delta_time;
}

class CTreeModel : public ITreeModel
{
public:
    CTreeModel();
    ~CTreeModel();
    
    float Check(float v) { return (v<0) ? 0 : ((v>1) ? 1 : v); }
    int Check(int v, int low, int high) { return (v<low) ? low : ((v>high) ? high : v); }
    
    double GetParameter(int paramid);
    void SetParameter(int paramid, double val);
    
    void RandomSeedRefresh() { m_randomseed = m_seedgen.IRand(1000000000); }
    
    bool Init();
    void DrawOpenGL(GLuint shader, float w, float h, float x, float y, float scale, float dt, bool abstime, bool drawbackground, bool rbswap, float linewidth);
    void DrawOpenGLBlankScreen();
    bool ScaleOffsetForView(const CGRect &bounds, float &drawx, float &drawy, float &drawscale);
    int DrawQuartz(CGContextRef ctx, const CGRect &bounds, float drawx, float drawy, float drawscale, float time, float linewidth, int quality, int vertextarget, bool drawbackground, bool (*progress)(float val, void *user), void *user);
    bool DrawQuartz(CGContextRef ctx, const CGRect &bounds, int quality, bool drawbackground);
    void FreeResources();
    CGRect GetBoundingBox();
    //float FileSizeForVertexBudget(float verts);
    
private:
    bool AllocateResources(int vertexbuffersize);
    void MinscaleFromDetail() { m_minscale = ((m_detail==1.0f) ? 0.0f : 0.5f*expf(-6.9f*m_detail)); }
    //bool InitBranchInfo();
    
    int AddVertex(const Vertex &v)
    {
        int vc = m_vertexcount;
        if(m_vertexcount < m_maxvertexcount)
            m_pvertex[m_vertexcount++] = v;
        return vc;
    }
    
    void BuildFrameData(CTreeGen *pGen, const TreeFrame &startframe, int maxlevels, float minscale);
    bool BuildFrameData3(CTreeGen *pGen, const TreeFrame &startframe, int maxframes);
    bool BuildFrameData4(CTreeGen *pGen, const TreeFrame &startframe, int maxlevels, int maxframes);
    bool BuildFrameData5(CTreeGen *pGen, const TreeFrame &startframe, int maxframes);
    
    CTreeGen *GenerateTree(int vertextarget, bool animating, int &levelcut);
    
    bool GenerateOpenGLData(CTreeGen *pGen);
    bool GeneratePathData(CTreeGen *pGen, CTreePath &path);
    
    void UpdateAnimations(float dt);
    CGRect GetVertexBounds();
    bool rectCollision(const CGRect &boundsA, const Matrix3x3 &mB, const CGRect &boundsB);
    
    float Anival(float value, float depth, float cycle)
    {
        return Check(value + 0.5 * depth * depth * sin(cycle));
    }
    
    void Animupdate(float &cycle, float dt, float rate)
    {
        cycle += dt * 0.1f*expf(4.828f*rate);
        cycle -= 2*M_PI*floorf(cycle/(2*M_PI));
    }
    
    // parameters
    int m_treetype;
    int m_anglemode;
    int m_apextype;
    
    float m_spread;
    float m_balance;
    float m_bend;
    
    int m_intervalstart;
    int m_intervalcount;
    
    float m_detail;
    float m_lengthratio;
    float m_lengthbalance;
    float m_aspect;
    float m_spikiness;
    float m_trunkwidth;
    float m_trunktaper;
    
    float m_randomwiggle;
    float m_randomangle;
    float m_randomlength;
    float m_randominterval;
    
    float m_colorsize;
    float m_colortransition;
    
    unsigned int m_rootcolor;
    unsigned int m_leafcolor;
    unsigned int m_backgroundcolor;
    
    // specific to geometric tree
    int m_branchcount;
    int m_geonodes;
    float m_geodelay;
    float m_georatio;
    float m_spin;
    float m_twist;
    
    float m_animation_windrate;
    float m_animation_winddepth;
    
    float m_animation_spread_d;
    float m_animation_spread_r, m_animation_spread_c;
    
    float m_animation_bend_d;
    float m_animation_bend_r, m_animation_bend_c;
    
    float m_animation_spin_d;
    float m_animation_spin_r, m_animation_spin_c;
    
    float m_animation_twist_d;
    float m_animation_twist_r, m_animation_twist_c;
    
    float m_animation_lengthratio_d;
    float m_animation_lengthratio_r, m_animation_lengthratio_c;
    
    float m_animation_geodelay_d;
    float m_animation_geodelay_r, m_animation_geodelay_c;
    
    float m_animation_georatio_d;
    float m_animation_georatio_r, m_animation_georatio_c;
    
    float m_animation_aspect_d;
    float m_animation_aspect_r, m_animation_aspect_c;
    
    float m_animation_balance_d;
    float m_animation_balance_r, m_animation_balance_c;
    
    float m_animation_lengthbalance_d;
    float m_animation_lengthbalance_r, m_animation_lengthbalance_c;
    
    CRand m_windseedgen;
    int m_windseed1, m_windseed2;
    float m_windalpha;
    float m_winddepth;
    
    CRand m_seedgen;
    int m_randomseed;
    
    CTreeCurve m_treecurve;
    CTreeData2 m_treedata2;
    
    float m_minscale;
    float m_aspectx, m_aspecty;

    Vertex *m_pvertex;
    int m_vertexcount;
    int m_maxvertexcount;
    
    int m_rgdrawcounttolevel[MAX_LEVELS];
    float m_rgmaxscaleatlevel[MAX_LEVELS];
};

double CTreeModel::GetParameter(int paramid)
{
    //DEBUG_PRINTF("get param %d\n", paramid);
    
    switch (paramid)
    {
        case ID_TREETYPE:
            return m_treetype;
        case ID_ANGLEMODE:
            if(m_treetype==1 && m_anglemode==3)
                return 0;
            else
                return m_anglemode;
        case ID_SPREAD:
            return m_spread;
        case ID_BALANCE:
            return m_balance;
        case ID_BEND:
            return m_bend;
        case ID_INTERVALSTART:
            return m_intervalstart;
        case ID_INTERVALCOUNT:
            return m_intervalcount;
        case ID_DETAIL:
            return m_detail;
        case ID_LENGTHRATIO:
            return m_lengthratio;
        case ID_LENGTHBALANCE:
            return m_lengthbalance;
        case ID_ASPECT:
            return m_aspect;
        case ID_SPIKINESS:
            return m_spikiness;
        case ID_TRUNKWIDTH:
            return m_trunkwidth;
        case ID_RANDOMWIGGLE:
            return m_randomwiggle;
        case ID_RANDOMANGLE:
            return m_randomangle;
        case ID_RANDOMLENGTH:
            return m_randomlength;
        case ID_TRUNKTAPER:
            return m_trunktaper;
        case ID_APEXTYPE:
            return m_apextype;
        case ID_RANDOMINTERVAL:
            return m_randominterval;
        case ID_RANDOMSEED:
            return m_randomseed;
        case ID_ROOTCOLOR:
            return m_rootcolor;
        case ID_LEAFCOLOR:
            return m_leafcolor;
        case ID_BACKGROUNDCOLOR:
            return m_backgroundcolor;
        case ID_COLORSIZE:
            return m_colorsize;
        case ID_COLORTRANSITION:
            return m_colortransition;
        case ID_BRANCHCOUNT:
            return m_branchcount;
        case ID_GEONODES:
            return m_geonodes;
        case ID_GEODELAY:
            return m_geodelay;
        case ID_GEORATIO:
            return m_georatio;
        case ID_SPIN:
            return m_spin;
        case ID_TWIST:
            return m_twist;
        case ID_ANIMWINDRATE:
            return m_animation_windrate;
        case ID_ANIMWINDDEPTH:
            return m_animation_winddepth;
        case ID_ANIMSPREAD_D:
            return m_animation_spread_d;
        case ID_ANIMSPREAD_R:
            return m_animation_spread_r;
        case ID_ANIMBEND_D:
            return m_animation_bend_d;
        case ID_ANIMBEND_R:
            return m_animation_bend_r;
        case ID_ANIMSPIN_D:
            return m_animation_spin_d;
        case ID_ANIMSPIN_R:
            return m_animation_spin_r;
        case ID_ANIMTWIST_D:
            return m_animation_twist_d;
        case ID_ANIMTWIST_R:
            return m_animation_twist_r;
        case ID_ANIMLENGTHRATIO_D:
            return m_animation_lengthratio_d;
        case ID_ANIMLENGTHRATIO_R:
            return m_animation_lengthratio_r;
        case ID_ANIMGEODELAY_D:
            return m_animation_geodelay_d;
        case ID_ANIMGEODELAY_R:
            return m_animation_geodelay_r;
        case ID_ANIMGEORATIO_D:
            return m_animation_georatio_d;
        case ID_ANIMGEORATIO_R:
            return m_animation_georatio_r;
        case ID_ANIMASPECT_D:
            return m_animation_aspect_d;
        case ID_ANIMASPECT_R:
            return m_animation_aspect_r;
        case ID_ANIMBALANCE_D:
            return m_animation_balance_d;
        case ID_ANIMBALANCE_R:
            return m_animation_balance_r;
        case ID_ANIMLENGTHBALANCE_D:
            return m_animation_lengthbalance_d;
        case ID_ANIMLENGTHBALANCE_R:
            return m_animation_lengthbalance_r;
        default:
            return 0;
    }
}

void CTreeModel::SetParameter(int paramid, double val)
{
    //DEBUG_PRINTF("param %d set to %f\n", paramid, val);
    
    switch (paramid)
    {
        case ID_TREETYPE:
            m_treetype = Check(val, 0, 1);
            break;
        case ID_ANGLEMODE:
            m_anglemode = Check(val, 0, 3);
            break;
        case ID_SPREAD:
            m_spread = Check(val);
            break;
        case ID_BALANCE:
            m_balance = Check(val);
            break;
        case ID_BEND:
            m_bend = Check(val);
            break;
        case ID_INTERVALSTART:
            m_intervalstart = Check(val, 2, 12);
            break;
        case ID_INTERVALCOUNT:
            m_intervalcount = Check(val, 0, 6);
            break;
        case ID_DETAIL:
            m_detail = Check(val);
            MinscaleFromDetail();
            break;
        case ID_LENGTHRATIO:
            m_lengthratio = Check(val);
            break;
        case ID_LENGTHBALANCE:
            m_lengthbalance = Check(val);
            break;
        case ID_ASPECT:
            m_aspect = Check(val);
            m_aspecty = expf(m_aspect - 0.5f);
            m_aspectx = expf(-m_aspect + 0.5f);
            break;
        case ID_SPIKINESS:
            m_spikiness = Check(val);
            break;
        case ID_TRUNKWIDTH:
            m_trunkwidth = Check(val);
            break;
        case ID_RANDOMWIGGLE:
            m_randomwiggle = Check(val);
            break;
        case ID_RANDOMANGLE:
            m_randomangle = Check(val);
            break;
        case ID_RANDOMLENGTH:
            m_randomlength = Check(val);
            break;
        case ID_TRUNKTAPER:
            m_trunktaper = Check(val);
            break;
        case ID_APEXTYPE:
            m_apextype = Check(val, 0, 3);
            break;
        case ID_RANDOMINTERVAL:
            m_randominterval = Check(val);
            break;
        case ID_RANDOMSEED:
            m_randomseed = Check(val, 0, 1000000000-1);
            break;
        case ID_ROOTCOLOR:
            m_rootcolor = val;
            break;
        case ID_LEAFCOLOR:
            m_leafcolor = val;
            break;
        case ID_BACKGROUNDCOLOR:
            m_backgroundcolor = val;
            break;
        case ID_COLORSIZE:
            m_colorsize = Check(val);
            break;
        case ID_COLORTRANSITION:
            m_colortransition = Check(val);
            break;
        case ID_BRANCHCOUNT:
            m_branchcount = Check(val, 1, 6);
            break;
        case ID_GEONODES:
            m_geonodes = Check(val, 2, 12);
            break;
        case ID_GEODELAY:
            m_geodelay = Check(val);
            break;
        case ID_GEORATIO:
            m_georatio = Check(val);
            break;
        case ID_SPIN:
            m_spin = Check(val);
            break;
        case ID_TWIST:
            m_twist = Check(val);
            break;
        case ID_ANIMWINDRATE:
            m_animation_windrate = Check(val);
            break;
        case ID_ANIMWINDDEPTH:
            m_animation_winddepth = Check(val);
            break;
        case ID_ANIMSPREAD_D:
            m_animation_spread_d = Check(val);
            break;
        case ID_ANIMSPREAD_R:
            m_animation_spread_r = Check(val);
            break;
        case ID_ANIMBEND_D:
            m_animation_bend_d = Check(val);
            break;
        case ID_ANIMBEND_R:
            m_animation_bend_r = Check(val);
            break;
        case ID_ANIMSPIN_D:
            m_animation_spin_d = Check(val);
            break;
        case ID_ANIMSPIN_R:
            m_animation_spin_r = Check(val);
            break;
        case ID_ANIMTWIST_D:
            m_animation_twist_d = Check(val);
            break;
        case ID_ANIMTWIST_R:
            m_animation_twist_r = Check(val);
            break;            
        case ID_ANIMLENGTHRATIO_D:
            m_animation_lengthratio_d = Check(val);
            break;
        case ID_ANIMLENGTHRATIO_R:
            m_animation_lengthratio_r = Check(val);
            break;
        case ID_ANIMGEODELAY_D:
            m_animation_geodelay_d = Check(val);
            break;
        case ID_ANIMGEODELAY_R:
            m_animation_geodelay_r = Check(val);
            break;
        case ID_ANIMGEORATIO_D:
            m_animation_georatio_d = Check(val);
            break;
        case ID_ANIMGEORATIO_R:
            m_animation_georatio_r = Check(val);
            break;
        case ID_ANIMASPECT_D:
            m_animation_aspect_d = Check(val);
            break;
        case ID_ANIMASPECT_R:
            m_animation_aspect_r = Check(val);
            break;
        case ID_ANIMBALANCE_D:
            m_animation_balance_d = Check(val);
            break;
        case ID_ANIMBALANCE_R:
            m_animation_balance_r = Check(val);
            break;
        case ID_ANIMLENGTHBALANCE_D:
            m_animation_lengthbalance_d = Check(val);
            break;
        case ID_ANIMLENGTHBALANCE_R:
            m_animation_lengthbalance_r = Check(val);
            break;
        default:
            break;
    }
}

ITreeModel *CreateTreeModel()
{
    return new CTreeModel();
}

void DestroyTreeModel(ITreeModel *p)
{
    delete p;
}

CTreeModel::CTreeModel()
: m_pvertex(NULL), m_maxvertexcount(0)
{
    m_seedgen.Seed(834576);
}

CTreeModel::~CTreeModel()
{    
    if(m_pvertex)
        delete [] m_pvertex;
}

void CTreeModel::FreeResources()
{
    if(m_pvertex)
        delete [] m_pvertex;
    m_pvertex = NULL;
    m_maxvertexcount = 0;
    
    m_treedata2.Free();
}

bool CTreeModel::AllocateResources(int vertexbuffersize)
{
    if(m_pvertex==NULL || vertexbuffersize > m_maxvertexcount)
    {
        if(m_pvertex)
            delete [] m_pvertex;
        m_maxvertexcount = 0;
        
        m_pvertex = new Vertex [vertexbuffersize];
        if(m_pvertex==NULL)
            return false;
        
        m_maxvertexcount = vertexbuffersize;
    }
    
    return true;
}

bool CTreeModel::Init()
{    
    SetParameter(ID_TREETYPE, 0);
    SetParameter(ID_ANGLEMODE, 3);
    SetParameter(ID_APEXTYPE, 3);
    
    SetParameter(ID_SPREAD, 0.2734375);
    SetParameter(ID_BALANCE, 0.5);
    SetParameter(ID_BEND, 0.5);
    
    SetParameter(ID_INTERVALSTART, 2);
    SetParameter(ID_INTERVALCOUNT, 2);

    SetParameter(ID_DETAIL, 0.79427081346511841);
    SetParameter(ID_LENGTHRATIO, 0.3984375);
    SetParameter(ID_LENGTHBALANCE, 0.5);
    SetParameter(ID_ASPECT, 0.5);
    SetParameter(ID_SPIKINESS, 0.79427081346511841);
    SetParameter(ID_TRUNKWIDTH, 0.1484375);
    SetParameter(ID_TRUNKTAPER, 0.91927081346511841);

    SetParameter(ID_RANDOMWIGGLE, 0);
    SetParameter(ID_RANDOMANGLE, 0);
    SetParameter(ID_RANDOMLENGTH, 0);
    SetParameter(ID_RANDOMINTERVAL, 0);
    
    RandomSeedRefresh();
    
    SetParameter(ID_ROOTCOLOR, 4280585782);
    SetParameter(ID_LEAFCOLOR, 4282851864);
    SetParameter(ID_BACKGROUNDCOLOR, 4291803858);

    SetParameter(ID_COLORSIZE, 0.2057291716337204);
    SetParameter(ID_COLORTRANSITION, 0.75260418653488159);

    SetParameter(ID_BRANCHCOUNT, 2);
    SetParameter(ID_GEONODES, 4);
    
    SetParameter(ID_GEODELAY, 0.2838541567325592);
    SetParameter(ID_GEORATIO, 0.7109375);
    SetParameter(ID_SPIN, 0.51302081346511841);
    SetParameter(ID_TWIST, 0.7109375);
    
    SetParameter(ID_ANIMWINDRATE, 0.4661458432674408);
    SetParameter(ID_ANIMWINDDEPTH, 0.1953125);
    
    SetParameter(ID_ANIMSPREAD_R, 0.3);
    SetParameter(ID_ANIMSPREAD_D, 0);
    
    SetParameter(ID_ANIMBEND_R, 0.31);
    SetParameter(ID_ANIMBEND_D, 0);
    
    SetParameter(ID_ANIMSPIN_R, 0.32);
    SetParameter(ID_ANIMSPIN_D, 0);
    
    SetParameter(ID_ANIMTWIST_R, 0.33);
    SetParameter(ID_ANIMTWIST_D, 0);
    
    SetParameter(ID_ANIMLENGTHRATIO_R, 0.34);
    SetParameter(ID_ANIMLENGTHRATIO_D, 0);
    
    SetParameter(ID_ANIMGEODELAY_R, 0.35);
    SetParameter(ID_ANIMGEODELAY_D, 0);
    
    SetParameter(ID_ANIMGEORATIO_R, 0.36);
    SetParameter(ID_ANIMGEORATIO_D, 0);
  
    SetParameter(ID_ANIMASPECT_R, 0.37);
    SetParameter(ID_ANIMASPECT_D, 0);
    
    SetParameter(ID_ANIMBALANCE_R, 0.38);
    SetParameter(ID_ANIMBALANCE_D, 0);
    
    SetParameter(ID_ANIMLENGTHBALANCE_R, 0.39);
    SetParameter(ID_ANIMLENGTHBALANCE_D, 0);
    
    m_windseedgen.Seed(2434);
    m_windseed1 = m_windseedgen.IRand(1000000);
    m_windseed2 = m_windseedgen.IRand(1000000);
    m_windalpha = 0;
    m_winddepth = 0;
    
    return true;
}

bool CTreeModel::BuildFrameData5(CTreeGen *pGen, const TreeFrame &startframe, int maxframes)
{
    CRand ditherrnd(483756);
    
    if(!m_treedata2.Init(maxframes))
        return false;
    
    m_treedata2.CreateNode(0, 0, startframe); // root frames with startframe
    
    int childframecount = pGen->GetChildFrameCount();
    
    int count_added = 0;
    int count_rejected = 0;
    
    int level;
    for(level = 0; level<MAX_LEVELS; level++)
    {
        // flush prev level
        while(m_treedata2.TransferNode());
        
        int newnodes = m_treedata2.CountAtLevel(level) * childframecount;
        int spaceremaining = m_treedata2.Size() - m_treedata2.Count();
        
        if(newnodes > 2*spaceremaining)
            break;
        else
        {
            if(!m_treedata2.StartLevelEnumeration(level))
                break;
            
            TreeNode2 *pNode;
            while((pNode = m_treedata2.GetNextLevelNode())!=NULL)
            {
                pGen->SetFrame(pNode->frame);
                
                int i;
                for(i=0; i<childframecount; i++)
                {
                    TreeFrame childframe;
                    pGen->GetChildFrame(i, childframe);
                    
                    // dither scale to improve btree balance
                    childframe.scale *= (0.995 + 0.01 * ditherrnd.DRand());
                    
                    int priority = pNode->priority * childframecount + i + 1;
                    
                    if(m_treedata2.CreateNode(level + 1, priority, childframe))
                        count_added++;
                    else
                        count_rejected++;
                }
            }
        }
    }
    
    memset(m_rgmaxscaleatlevel, 0, sizeof(float)*MAX_LEVELS);
    
    for(level = 0; level<MAX_LEVELS; level++)
    {
        if(!m_treedata2.StartLevelEnumeration(level))
            break;
        TreeNode2 *pNode = m_treedata2.GetNextLevelNode();
        m_rgmaxscaleatlevel[level] = pNode->frame.scale;
    }
    
//#ifdef DEBUG_LOGGING
#if 0
    DEBUG_PRINTF(" childframecount = %d\n", childframecount);
    DEBUG_PRINTF(" added = %d rejected = %d\n", count_added, count_rejected);
    
    for(level=0; m_treedata2.CountAtLevel(level) > 0 && level<MAX_LEVELS; level++)
        DEBUG_PRINTF(" level %d count = %d\n", level, m_treedata2.CountAtLevel(level));
    DEBUG_PRINTF(" total = %d/%d frames\n", m_treedata2.Count(), m_treedata2.Size());
    DEBUG_PRINTF(" verts per stamp = %d\n", m_treedata2.Count() * pGen->GetVertexCount());
#endif
    return true;
}

bool CTreeModel::BuildFrameData4(CTreeGen *pGen, const TreeFrame &startframe, int maxlevels, int maxframes)
{
    CRand ditherrnd(483756);
    
    if(!m_treedata2.Init(maxframes))
        return false;
    
    m_treedata2.CreateNode(0, 0, startframe); // root frames with startframe
    
    int childframecount = pGen->GetChildFrameCount();
    
    int count_added = 0;
    int count_rejected = 0;
    
    int level;
    for(level = 0; level<maxlevels; level++)
    {
        // flush prev level
        while(m_treedata2.TransferNode());
        
        if(level+1 < maxlevels)
        {
            if(!m_treedata2.StartLevelEnumeration(level))
                break;
            
            TreeNode2 *pNode;
            while((pNode = m_treedata2.GetNextLevelNode())!=NULL)
            {
                pGen->SetFrame(pNode->frame);
                
                int i;
                for(i=0; i<childframecount; i++)
                {
                    TreeFrame childframe;
                    pGen->GetChildFrame(i, childframe);
                    
                    // dither scale to improve btree balance
                    childframe.scale *= (0.995 + 0.01 * ditherrnd.DRand());
                    
                    int priority = pNode->priority * childframecount + i + 1;
                    
                    if(m_treedata2.CreateNode(level + 1, priority, childframe))
                        count_added++;
                    else
                        count_rejected++;
                }
            }
        }
    }
    
//#ifdef DEBUG_LOGGING
#if 0
    DEBUG_PRINTF(" childframecount = %d\n", childframecount);
    DEBUG_PRINTF(" added = %d rejected = %d\n", count_added, count_rejected);
    
    for(level=0; m_treedata2.CountAtLevel(level) > 0 && level<MAX_LEVELS; level++)
        DEBUG_PRINTF(" level %d count = %d\n", level, m_treedata2.CountAtLevel(level));
    DEBUG_PRINTF(" total = %d/%d frames\n", m_treedata2.Count(), m_treedata2.Size());
    DEBUG_PRINTF(" verts per stamp = %d\n", m_treedata2.Count() * pGen->GetVertexCount());
#endif
    
    return true;
}

bool CTreeModel::BuildFrameData3(CTreeGen *pGen, const TreeFrame &startframe, int maxframes)
{
    CRand ditherrnd(483756);
    
    if(!m_treedata2.Init(maxframes))
        return false;
    
    m_treedata2.CreateNode(0, 0, startframe); // root frames with startframe
    
    int childframecount = pGen->GetChildFrameCount();
    
    pGen->SortChildFrameSizes();
    
    int count_added = 0;
    int count_rejected = 0;
    
    TreeNode2 *pNode;
    while((pNode = m_treedata2.TransferNode())!=NULL)
    {
        pGen->SetFrame(pNode->frame);
        
        int level = pNode->level + 1;
        
        int i;
        for(i=0; i<childframecount; i++)
        {
            TreeFrame childframe;
            pGen->GetSortedChildFrame(i, childframe);
            
            // dither scale to improve btree balance
            childframe.scale *= (0.995 + 0.01 * ditherrnd.DRand());
            
            int priority = pNode->priority * childframecount + pGen->GetSortedIndex(i) + 1;
            
            if(m_treedata2.CreateNode(level, priority, childframe))
                count_added++;
            else
            {
                count_rejected++;
                break;
            }
        }
    }
    
//#ifdef DEBUG_LOGGING
#if 0
    DEBUG_PRINTF(" childframecount = %d\n", childframecount);
    DEBUG_PRINTF(" added = %d rejected = %d\n", count_added, count_rejected);
    
    int level;
    for(level=0; m_treedata2.CountAtLevel(level) > 0 && level<MAX_LEVELS; level++)
        DEBUG_PRINTF(" level %d count = %d\n", level, m_treedata2.CountAtLevel(level));
    DEBUG_PRINTF(" total = %d/%d frames\n", m_treedata2.Count(), m_treedata2.Size());
    DEBUG_PRINTF(" verts per stamp = %d\n", m_treedata2.Count() * pGen->GetVertexCount());
#endif
    
    return true;
}

/*

void CTreeModel::BuildFrameData(CTreeGen *pGen, const TreeFrame &startframe, int maxlevels, float minscale)
{
    CRand ditherrnd(467643);
    
    memset(m_rgmaxscaleatlevel, 0, sizeof(float)*MAX_LEVELS);
    
    m_treedata.CreateNode(0, NULL, 0, startframe); // root frames with startframe
    m_rgmaxscaleatlevel[0] = startframe.scale;
    
    int frames_added = 1;
    
    //DEBUG_PRINTF("level %d added %d frames, ", 0, frames_added);
    
    int childframecount = pGen->GetChildFrameCount();
    
    int level;
    for(level = 1;
        level<maxlevels && m_treedata.StartEnumeration(level-1);
        level++)
    {
        // check its not going to be a crazy number of nodes this level
        int max_frames_this_level = childframecount * frames_added;
        float max_scale = 0;
        
        //DEBUG_PRINTF("next estimate: %d frames\n", max_frames_this_level);
        
        int space = m_treedata.Size() - m_treedata.Count();
        if(max_frames_this_level > 2 * space)
        {
            //DEBUG_PRINTF("  giving up - rapid expansion (space = %d)\n", space);
            break; // give up
        }
        
        frames_added = 0;
        
        TreeNode *pNode;
        while((pNode = m_treedata.GetNextLevelNode())!=NULL)
        {
            pGen->SetFrame(pNode->frame);
            
            int i;
            for(i=0; i<childframecount; i++)
            {
                TreeFrame childframe;
                pGen->GetChildFrame(i, childframe);
                
                if(childframe.scale < minscale)
                    continue;
                
                // dither scale to improve btree balance
                childframe.scale *= (0.995 + 0.01 * ditherrnd.DRand());
                if(childframe.scale > max_scale)
                    max_scale = childframe.scale;
                
                if(m_treedata.CreateNode(level, pNode, i, childframe))
                    frames_added++;
            }
        }
        
        m_rgmaxscaleatlevel[level] = max_scale;
        //DEBUG_PRINTF("level %d: maxscale = %f frames ~= %d\n", level, max_scale, frames_added);
        //DEBUG_PRINTF("level %d added %d frames, ", level, frames_added);
    }
    
    //DEBUG_PRINTF("done\n");
//#ifdef DEBUG_LOGGING
//    for(level=0; m_treedata.CountAtLevel(level) > 0 && level<MAX_LEVELS; level++)
//        DEBUG_PRINTF("level %d count = %d\n", level, m_treedata.CountAtLevel(level));
//    DEBUG_PRINTF("total = %d/%d frames\n", m_treedata.Count(), m_treedata.Size());
//#endif
}

 */

int LevelsForVertexTarget(int vertextarget, int branchfactor, int vertsperbranch, int levelcutbranches)
{
    int level;
    int nextlevelbranches;
    int totalbranches = 0;
    int levelbranches = 1;
    
    for(level=0; level<MAX_LEVELS; level++, levelbranches = nextlevelbranches)
    {
        totalbranches += levelbranches;
        nextlevelbranches = levelbranches * branchfactor;
        
        if((totalbranches + nextlevelbranches) * vertsperbranch * levelcutbranches > vertextarget)
            break;
    }
    
    return level + 1;
}

CTreeGen *CTreeModel::GenerateTree(int vertextarget, bool animating, int &levelcut)
{
    CTreeGen *ptreegen = NULL;
    
    float spread = m_spread;
    float bend = m_bend;
    float spin = m_spin;
    float twist = m_twist;
    float lengthratio = m_lengthratio;
    float geodelay = m_geodelay;
    float georatio = m_georatio;
    float balance = m_balance;
    float lengthbalance = m_lengthbalance;
    float winddepth = 0;
    
    if(animating)
    {
        if(m_animation_spread_d>0)
            spread = Anival(spread, m_animation_spread_d, m_animation_spread_c);
        if(m_animation_bend_d>0)
            bend = Anival(bend, m_animation_bend_d, m_animation_bend_c);
        if(m_animation_spin_d>0)
            spin = Anival(spin, m_animation_spin_d, m_animation_spin_c);
        if(m_animation_twist_d>0)
            twist = Anival(twist, m_animation_twist_d, m_animation_twist_c);
        if(m_animation_lengthratio_d>0)
            lengthratio = Anival(lengthratio, m_animation_lengthratio_d, m_animation_lengthratio_c);
        if(m_animation_geodelay_d>0)
            geodelay = Anival(geodelay, m_animation_geodelay_d, m_animation_geodelay_c);
        if(m_animation_georatio_d>0)
            georatio = Anival(georatio, m_animation_georatio_d, m_animation_georatio_c);
        if(m_animation_balance_d>0)
            balance = Anival(balance, m_animation_balance_d, m_animation_balance_c);
        if(m_animation_lengthbalance_d>0)
            lengthbalance = Anival(lengthbalance, m_animation_lengthbalance_d, m_animation_lengthbalance_c);
        winddepth = m_winddepth*m_winddepth;
    }
    
    if(m_treetype==0)
    {
        CTreeGenRational *ptreegen_r = new CTreeGenRational();
        if(ptreegen_r==NULL)
            return NULL;
        
        if(!ptreegen_r->Init(m_randomseed, m_intervalstart, m_intervalcount, m_apextype, m_anglemode, bend, balance, spread, lengthratio, 1-lengthbalance, m_spikiness, m_trunkwidth, m_trunktaper, m_randomangle, m_randomlength, m_randomwiggle, m_randominterval, m_windseed1, m_windseed2, winddepth, m_windalpha))
        {
            delete ptreegen_r;
            return NULL;
        }
        
        ptreegen = ptreegen_r;
    }
    else
    {
        CTreeGenGeometric *ptreegen_g = new CTreeGenGeometric();
        if(ptreegen_g==NULL)
            return NULL;
        
        if(!ptreegen_g->Init(m_randomseed, m_branchcount, m_geonodes, m_apextype, m_anglemode, geodelay, georatio, spin, twist, bend, spread, lengthratio, m_spikiness, m_trunkwidth, m_trunktaper, m_randomwiggle, m_randomangle, m_randomlength, m_randominterval, m_windseed1, m_windseed2, winddepth, m_windalpha))
        {
            delete ptreegen_g;
            return NULL;
        }
        
        ptreegen = ptreegen_g;
    }
    
    // get level cut and frames per stamp
    int vertsperbranch = ptreegen->GetVertexCount();
    int branchfactor = ptreegen->GetChildFrameCount(); // must be <= MAX_STAMPS
    
    // we can't make a tree less complex than this
    int minvertextarget = (1 + branchfactor) * vertsperbranch * branchfactor;
    if(vertextarget < minvertextarget)
        vertextarget = minvertextarget;
    
    // initial estimate of levelcut
    // tree complexity is limited to branchfactor <= MAX_STAMPS
    int levelcutbranches = branchfactor; // set up for levecut = 1
    for(levelcut=1; levelcutbranches * branchfactor <= MAX_STAMPS; levelcut++)
        levelcutbranches *= branchfactor;
    
    // intial estimate of total levels
    int levels = LevelsForVertexTarget(vertextarget, branchfactor, vertsperbranch, levelcutbranches);
    
    //DEBUG_PRINTF("initial levelcut = %d, initial total levels = %d\n", levelcut, levels);
    
    while(levels <= levelcut && levelcut>1)
    {
        //DEBUG_PRINTF("reducing levelcut...\n");
        levelcut--;
        levelcutbranches /= branchfactor;
        
        assert(levelcut>0);
        
        levels = LevelsForVertexTarget(vertextarget, branchfactor, vertsperbranch, levelcutbranches);
        
        //DEBUG_PRINTF("  levelcut = %d levels = %d\n", levelcut, levels);
    }
    
    int framecount = vertextarget / (levelcutbranches * vertsperbranch);
    
    //DEBUG_PRINTF("  branchfactor = %d\n  vertsperbranch = %d\n  levelcut = %d\n  stamps = %d\n  levels = %d\n  allocation frame count = %d\n",
    //             branchfactor, vertsperbranch, levelcut, levelcutbranches, levels, framecount);
    
    //assert(totalbranches <= framecount);
    
    //DEBUG_PRINTF("allocation frame count = %d\n", framecount);
    
    TreeFrame frame;
    frame.x = 0;
    frame.y = 0;
    frame.scale = 1;
    frame.angle = M_PI_2;
    
#if 0
    //mark_time();
    
    if(!BuildFrameData3(ptreegen, frame, framecount))
    {
        delete ptreegen;
        return NULL;
    }
    
    //DEBUG_PRINTF("build3 took %f ms\n", mark_time());
#else
    //mark_time();
    
    if(!BuildFrameData5(ptreegen, frame, framecount))
    {
        delete ptreegen;
        return NULL;
    }
    
    //DEBUG_PRINTF("build4 took %f ms\n", mark_time());
#endif
    
    return ptreegen;
}

bool CTreeModel::GenerateOpenGLData(CTreeGen *pGen)
{
    memset(m_rgmaxscaleatlevel, 0, sizeof(float)*MAX_LEVELS);
    
    m_vertexcount = 0;
    
    int vertsperframe = pGen->GetVertexCount();
    
    int level;
    for(level=0; m_treedata2.StartLevelEnumeration(level); level++)
    {
        float maxscale = 0;
        
        TreeNode2 *pNode;
        while((pNode = m_treedata2.GetNextLevelNode())!=NULL)
        {
            if(m_vertexcount + vertsperframe > m_maxvertexcount)
                break;
            
            if(pNode->frame.scale > maxscale)
                maxscale = pNode->frame.scale;

            pGen->SetFrame(pNode->frame);
            pGen->GetVertices(m_pvertex + m_vertexcount);
            m_vertexcount += vertsperframe;
        }
        
        //DEBUG_PRINTF("vertex count to level %d = %d\n", level, m_vertexcount);
        m_rgdrawcounttolevel[level] = m_vertexcount;
        m_rgmaxscaleatlevel[level] = maxscale;
    }
    
    for(; level<MAX_LEVELS; level++)
        m_rgdrawcounttolevel[level] = m_vertexcount;
    
    return true;
}

bool CTreeModel::GeneratePathData(CTreeGen *pGen, CTreePath &path)
{
    if(!path.Init())
        return false;
    
    memset(m_rgmaxscaleatlevel, 0, sizeof(float)*MAX_LEVELS);
    
    int level;
    for(level=0; m_treedata2.StartLevelEnumeration(level); level++)
    {
        float maxscale = 0;
        
        TreeNode2 *pNode;
        while((pNode = m_treedata2.GetNextLevelNode())!=NULL)
        {
            if(pNode->frame.scale > maxscale)
                maxscale = pNode->frame.scale;
            
            pGen->SetFrame(pNode->frame);
            if(!pGen->GetPaths(path, level))
                return false;
        }

        //DEBUG_PRINTF("path count to level %d = %d\n", level, path.PathCount());
        m_rgdrawcounttolevel[level] = path.PathCount();
        m_rgmaxscaleatlevel[level] = maxscale;
    }
    
    for(; level<MAX_LEVELS; level++)
        m_rgdrawcounttolevel[level] = path.PathCount();
    
    return true;
}

void CTreeModel::UpdateAnimations(float dt)
{
    if(dt==0)
    {
        m_animation_spread_c = 0;
        m_animation_bend_c = 0;
        m_animation_spin_c = 0;
        m_animation_twist_c = 0;
        m_animation_lengthratio_c = 0;
        m_animation_geodelay_c = 0;
        m_animation_georatio_c = 0;
        m_animation_aspect_c = 0;
        m_animation_balance_c = 0;
        m_animation_lengthbalance_c = 0;
        
        m_windalpha = 0;
        m_winddepth = 0;
        m_windseedgen.Seed(2434);
        m_windseed1 = m_windseedgen.IRand(1000000);
        m_windseed2 = m_windseedgen.IRand(1000000);
    }
    else
    {
        Animupdate(m_animation_spread_c, dt, m_animation_spread_r);
        Animupdate(m_animation_bend_c, dt, m_animation_bend_r);
        Animupdate(m_animation_spin_c, dt, m_animation_spin_r);
        Animupdate(m_animation_twist_c, dt, m_animation_twist_r);
        Animupdate(m_animation_lengthratio_c, dt, m_animation_lengthratio_r);
        Animupdate(m_animation_geodelay_c, dt, m_animation_geodelay_r);
        Animupdate(m_animation_georatio_c, dt, m_animation_georatio_r);
        Animupdate(m_animation_aspect_c, dt, m_animation_aspect_r);
        Animupdate(m_animation_balance_c, dt, m_animation_balance_r);
        Animupdate(m_animation_lengthbalance_c, dt, m_animation_lengthbalance_r);
        
        m_windalpha += dt * 0.2f*expf(4.135f*m_animation_windrate);
        float v = floorf(m_windalpha);
        m_windalpha -= v;
        while(v>=1)
        {
            m_windseed1 = m_windseed2;
            m_windseed2 = m_windseedgen.IRand(1000000);
            v -=1;
        }

        m_winddepth = m_animation_winddepth;
        
        //DEBUG_PRINTF("wind: %d %d %f\n", m_windseed1, m_windseed2, m_windalpha);
    }
}

CGRect CTreeModel::GetVertexBounds()
{
    CGRect rect;
    
    /*
    float xmin2 = 0;
    float xmax2 = 0;
    float ymin2 = 0;
    float ymax2 = 0;
    
    int i;
    for(i=0; i<m_vertexcount; i++)
    {
        float x = m_pvertex[i].x;
        float y = m_pvertex[i].y;
        if(x<xmin2)
            xmin2 = x;
        else if(x>xmax2)
            xmax2 = x;
        if(y<ymin2)
            ymin2 = y;
        else if(y>ymax2)
            ymax2 = y;
    }
    */
    
    float xmin, xmax, ymin, ymax;
    
    vDSP_Stride stride = sizeof(Vertex) / sizeof(float);
    
    vDSP_maxv(&(m_pvertex[0].x), stride, &xmax, m_vertexcount);
    vDSP_maxv(&(m_pvertex[0].y), stride, &ymax, m_vertexcount);
    vDSP_minv(&(m_pvertex[0].x), stride, &xmin, m_vertexcount);
    vDSP_minv(&(m_pvertex[0].y), stride, &ymin, m_vertexcount);
    
    if(xmax<0)
        xmax = 0;
    if(ymax<0)
        ymax = 0;
    if(xmin>0)
        xmin = 0;
    if(ymin>0)
        ymin = 0;

    rect.origin.x = xmin;
    rect.origin.y = ymin;
    rect.size.width = xmax - xmin;
    rect.size.height = ymax - ymin;
    
    return rect;
}

bool CTreeModel::rectCollision(const CGRect &boundsA, const Matrix3x3 &mB, const CGRect &boundsB)
{
    float Axmin = boundsA.origin.x;
    float Axmax = Axmin + boundsA.size.width;
    float Aymin = boundsA.origin.y;
    float Aymax = Aymin + boundsA.size.height;
    
    float Bxmin = boundsB.origin.x;
    float Bxmax = Bxmin + boundsB.size.width;
    float Bymin = boundsB.origin.y;
    float Bymax = Bymin + boundsB.size.height;
    
    float B0x = mB(0,0) * Bxmin + mB(0,1) * Bymin + mB(0,2);
    float B0y = mB(1,0) * Bxmin + mB(1,1) * Bymin + mB(1,2);
    
    float B1x = mB(0,0) * Bxmax + mB(0,1) * Bymin + mB(0,2);
    float B1y = mB(1,0) * Bxmax + mB(1,1) * Bymin + mB(1,2);
    
    float B2x = mB(0,0) * Bxmin + mB(0,1) * Bymax + mB(0,2);
    float B2y = mB(1,0) * Bxmin + mB(1,1) * Bymax + mB(1,2);
    
    float B3x = mB(0,0) * Bxmax + mB(0,1) * Bymax + mB(0,2);
    float B3y = mB(1,0) * Bxmax + mB(1,1) * Bymax + mB(1,2);
    
    if(B0x<Axmin && B1x<Axmin && B2x<Axmin && B3x<Axmin)
        return false;
    if(B0x>Axmax && B1x>Axmax && B2x>Axmax && B3x>Axmax)
        return false;
    if(B0y<Aymin && B1y<Aymin && B2y<Aymin && B3y<Aymin)
        return false;
    if(B0y>Aymax && B1y>Aymax && B2y>Aymax && B3y>Aymax)
        return false;
    
    float det = mB(0,0)*mB(1,1) - mB(0,1)*mB(1,0);
    float dx = mB(1,2)*mB(0,1) - mB(0,2)*mB(1,1);
    float dy = mB(0,2)*mB(1,0) - mB(1,2)*mB(0,0);
    
    float A0x = (mB(1,1) * Axmin - mB(0,1) * Aymin + dx)/det;
    float A0y = (-mB(1,0) * Axmin + mB(0,0) * Aymin + dy)/det;
    
    float A1x = (mB(1,1) * Axmax - mB(0,1) * Aymin + dx)/det;
    float A1y = (-mB(1,0) * Axmax + mB(0,0) * Aymin + dy)/det;
    
    float A2x = (mB(1,1) * Axmin - mB(0,1) * Aymax + dx)/det;
    float A2y = (-mB(1,0) * Axmin + mB(0,0) * Aymax + dy)/det;
    
    float A3x = (mB(1,1) * Axmax - mB(0,1) * Aymax + dx)/det;
    float A3y = (-mB(1,0) * Axmax + mB(0,0) * Aymax + dy)/det;
    
    if(A0x<Bxmin && A1x<Bxmin && A2x<Bxmin && A3x<Bxmin)
        return false;
    if(A0x>Bxmax && A1x>Bxmax && A2x>Bxmax && A3x>Bxmax)
        return false;
    if(A0y<Bymin && A1y<Bymin && A2y<Bymin && A3y<Bymin)
        return false;
    if(A0y>Bymax && A1y>Bymax && A2y>Bymax && A3y>Bymax)
        return false;
    
    return true;
}

void CTreeModel::DrawOpenGLBlankScreen()
{
    glClearColor(REDFROMCOLOR(m_backgroundcolor), GREENFROMCOLOR(m_backgroundcolor), BLUEFROMCOLOR(m_backgroundcolor), 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
}

int qsort_treenode_priority_compare(const void *p1, const void *p2)
{
    const TreeNode2 *t1 = *(const TreeNode2 **)p1;
    const TreeNode2 *t2 = *(const TreeNode2 **)p2;
    return t2->priority - t1->priority;
}

// tbd revisit the issue of pixelscale
void CTreeModel::DrawOpenGL(GLuint shader, float view_width, float view_height, float ox, float oy, float scale, float dt, bool abstime, bool drawbackground, bool rbswap, float linewidth)
{
    mark_time();
    //DEBUG_PRINTF("---\n");
    
    if(abstime)
        UpdateAnimations(0);
    UpdateAnimations(dt);
    
    float pixelsize = 1.0f/scale;
    float minlinewidth = 0.5f * pixelsize;
    if(linewidth>1) // less than 1 gives lots of aliasing
        minlinewidth *= linewidth;
    
    float mindisplayscale = pixelsize;
    if(m_minscale > mindisplayscale)
        mindisplayscale = m_minscale;
    
    int levelcut;
    CTreeGen *ptreegen = GenerateTree(VERTEX_TARGET, dt>0, levelcut);
    if(ptreegen==NULL)
        return;
    
    int vertexbuffersize = m_treedata2.Count() * ptreegen->GetVertexCount();
    
    DEBUG_PRINTF("Vertex buffer size = %d bytes\n", (int)(vertexbuffersize * sizeof(Vertex)));
    if(!AllocateResources(vertexbuffersize))
    {
        DEBUG_PRINTF("Could not allocate resources\n");
        delete ptreegen;
        return;
    }
    
    //DEBUG_PRINTF("done with tree gen nodes (%f)\n", mark_time());
    //DEBUG_PRINTF("levelcut = %d with %d nodes\n", levelcut, m_treedata2.CountAtLevel(levelcut));
    
    // make vertices
    bool ok = GenerateOpenGLData(ptreegen);
    
    delete ptreegen;
    
    if(!ok)
        return;
        
    //DEBUG_PRINTF("done generating vertices %d/%d (%f)\n", m_vertexcount, m_maxvertexcount, mark_time());

    glUseProgram(shader);
    
    GLint shader_attrib_VertexLocation = glGetAttribLocation(shader, "VertexLocation");
    glVertexAttribPointer(shader_attrib_VertexLocation, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_BYTE_OFFSET(0));
    
    GLint shader_attrib_VertexOffset = glGetAttribLocation(shader, "VertexOffset");
    glVertexAttribPointer(shader_attrib_VertexOffset, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), BUFFER_BYTE_OFFSET(12));
    
    GLint uniform_Transform = glGetUniformLocation(shader, "Transform");
    GLint uniform_Thickness = glGetUniformLocation(shader, "Thickness");
    GLint uniform_ScaleThresh = glGetUniformLocation(shader, "ScaleThresh");
    GLint uniform_RootColor = glGetUniformLocation(shader, "RootColor");
    GLint uniform_LeafColor = glGetUniformLocation(shader, "LeafColor");
    GLint uniform_ScaleToColor = glGetUniformLocation(shader, "ScaleToColor");
    GLint uniform_BaseScale = glGetUniformLocation(shader, "BaseScale");
    GLint uniform_ColorTransitionK1 = glGetUniformLocation(shader, "ColorTransitionK1");
    GLint uniform_ColorTransitionK2 = glGetUniformLocation(shader, "ColorTransitionK2");
    GLint uniform_ColorTransitionK3 = glGetUniformLocation(shader, "ColorTransitionK3");
    
    Matrix3x3 mFrame;
    mFrame.MakeSimilarity(1, 0, 0, 0);
    
    Matrix3x3 mViewport;
    mViewport.MakeAspectShift(2 * scale / view_width, 2 * scale / view_height,
                              2 * ox / view_width - 1, 1 - 2 * oy / view_height);
    
    float aspect = m_aspect;
    if(m_animation_aspect_d>0)
        aspect = Anival(aspect, m_animation_aspect_d, m_animation_aspect_c);

    float aspectx = expf(-aspect + 0.5f);
    float aspecty = expf(aspect - 0.5f);
    Matrix3x3 mAspect;
    mAspect.MakeAspectShift(aspectx, aspecty, 0, 0);
    
    mViewport = mViewport * mAspect;
    
    Matrix3x3 mTransform;
    mTransform = mViewport * mFrame;
    Matrix3x3 mTransformT = mTransform.T();
    //mTransform.Dump();
    
    CGRect treebounds = GetVertexBounds();
    
    CGRect viewbounds = CGRectMake(-ox / scale, (oy - view_height) / scale, view_width / scale, view_height / scale);
    
    // DEBUG_PRINTF("tree = {%f %f %f %f} view = {%f %f %f %f}\n",
    //             treebounds.origin.x, treebounds.origin.y, treebounds.size.width, treebounds.size.height,
    //             viewbounds.origin.x, viewbounds.origin.y, viewbounds.size.width, viewbounds.size.height);
    
    glUniformMatrix3fv(uniform_Transform, 1, GL_FALSE, mTransformT.Ptr());
    glUniform1f(uniform_Thickness, minlinewidth);
    glUniform1f(uniform_ScaleThresh, mindisplayscale);
    if(rbswap)
    {
        glUniform4f(uniform_RootColor, BLUEFROMCOLOR(m_rootcolor), GREENFROMCOLOR(m_rootcolor), REDFROMCOLOR(m_rootcolor), 1);
        glUniform4f(uniform_LeafColor, BLUEFROMCOLOR(m_leafcolor), GREENFROMCOLOR(m_leafcolor), REDFROMCOLOR(m_leafcolor), 1);
    }
    else
    {
        glUniform4f(uniform_RootColor, REDFROMCOLOR(m_rootcolor), GREENFROMCOLOR(m_rootcolor), BLUEFROMCOLOR(m_rootcolor), 1);
        glUniform4f(uniform_LeafColor, REDFROMCOLOR(m_leafcolor), GREENFROMCOLOR(m_leafcolor), BLUEFROMCOLOR(m_leafcolor), 1);
    }
    glUniform1f(uniform_ScaleToColor, 1.0f/(5.4f*m_colorsize - 6.0f));
    glUniform1f(uniform_BaseScale, 1.0f);
    
    float alpha = 0.6f*m_colortransition + 0.3f;
    
    glUniform1f(uniform_ColorTransitionK1, (1-alpha)*(1-alpha));
    glUniform1f(uniform_ColorTransitionK2, (1-2*alpha));
    glUniform1f(uniform_ColorTransitionK3, alpha*alpha);
    
    glBufferData(GL_ARRAY_BUFFER, m_vertexcount * sizeof(Vertex), m_pvertex, GL_STATIC_DRAW);
    
    if(drawbackground)
    {
        if(rbswap)
            glClearColor(BLUEFROMCOLOR(m_backgroundcolor), GREENFROMCOLOR(m_backgroundcolor), REDFROMCOLOR(m_backgroundcolor), 1.0f);
        else
            glClearColor(REDFROMCOLOR(m_backgroundcolor), GREENFROMCOLOR(m_backgroundcolor), BLUEFROMCOLOR(m_backgroundcolor), 1.0f);
        
        glClear(GL_COLOR_BUFFER_BIT);
    }
    
    glEnableVertexAttribArray(shader_attrib_VertexLocation);
    glEnableVertexAttribArray(shader_attrib_VertexOffset);
    
    int total_verts = 0;
    assert(levelcut>0);
    int basevertexcount = m_rgdrawcounttolevel[levelcut-1];
    
    //DEBUG_PRINTF("drawing base with %d verts\n", basevertexcount);
    glDrawArrays(GL_TRIANGLE_STRIP, 7, basevertexcount-7);
    total_verts += basevertexcount;
 
    //DEBUG_PRINTF("drawing branches with up to %d verts\n", m_vertexcount);
    m_treedata2.StartLevelEnumeration(levelcut);
    
    assert(m_treedata2.CountAtLevel(levelcut)<=MAX_STAMPS);
    
    TreeNode2 *pNode;
    TreeNode2 *rgpStampNodes[MAX_STAMPS];
    
    int stampcount;
    for(stampcount=0; (pNode = m_treedata2.GetNextLevelNode())!=NULL; stampcount++)
        rgpStampNodes[stampcount] = pNode;
    
    qsort(rgpStampNodes, stampcount, sizeof(TreeNode2 *), qsort_treenode_priority_compare);
    
    int stamp;
    for(stamp = 0; stamp < stampcount; stamp++)
    {
        pNode = rgpStampNodes[stamp];
        //DEBUG_PRINTF("branch %d, priority = %d\n", stamp, pNode->priority);

        float nodescale = pNode->frame.scale;
        
        if(nodescale<mindisplayscale)
            continue; // dont draw any stamps that are too small
        
        float relativescalethresh = mindisplayscale/nodescale;
        
        int vertexcountthisnode = m_vertexcount;
        
        if(relativescalethresh>0)
        {
            // work out how many levels to draw
            int level;
            for(level=0; level<MAX_LEVELS; level++)
                if(m_rgmaxscaleatlevel[level] < relativescalethresh)
                    break;
            
            if(level==0)
                continue;
            
            vertexcountthisnode = m_rgdrawcounttolevel[level-1];
            //DEBUG_PRINTF("  drew %d verts up to level %d\n", vertexcountthisnode, level-1);
        }
        
        mFrame.MakeSimilarity(nodescale, M_PI_2 - pNode->frame.angle, pNode->frame.x, pNode->frame.y);
        
        if(rectCollision(viewbounds, mAspect * mFrame, treebounds))
        {
            mTransform = mViewport * mFrame;
            mTransformT = mTransform.T();
            
            glUniformMatrix3fv(uniform_Transform, 1, GL_FALSE, mTransformT.Ptr());
            glUniform1f(uniform_Thickness, minlinewidth/nodescale);
            glUniform1f(uniform_BaseScale, nodescale);
            //glUniform1f(uniform_ScaleThresh, mindisplayscale);
            //glUniform1f(uniform_ScaleToColor, 1.0f/logf(mindisplayscale + 0.0001f));
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, vertexcountthisnode);
            total_verts += vertexcountthisnode;
        }
    }
    
    glDisableVertexAttribArray(shader_attrib_VertexLocation);
    glDisableVertexAttribArray(shader_attrib_VertexOffset);
    
    //DEBUG_PRINTF("done with submit of %d verts (%f)\n", total_verts, mark_time());
}

CGRect CTreeModel::GetBoundingBox()
{
    float mindisplayscale = 0.001f;
    
    if(m_minscale > mindisplayscale)
        mindisplayscale = m_minscale;
    
    int levelcut;
    CTreeGen *ptreegen = GenerateTree(VERTEX_TARGET, false, levelcut);
    if(ptreegen==NULL)
        return CGRectZero;
    
    int vertexbuffersize = m_treedata2.Count() * ptreegen->GetVertexCount();
    
    if(!AllocateResources(vertexbuffersize))
    {
        DEBUG_PRINTF("Could not allocate resources\n");
        delete ptreegen;
        return CGRectZero;
    }
    
    bool ok = GenerateOpenGLData(ptreegen);
    
    delete ptreegen;
    
    if(!ok)
        return CGRectZero;
    
    float minx = 0;
    float maxx = 0;
    float miny = 0;
    float maxy = 0;
    
    assert(levelcut>0);
    int basevertexcount = m_rgdrawcounttolevel[levelcut-1];
    
    int i;
    for(i=7; i<basevertexcount; i++)
    {
        // does not take into account mindisplayscale
        float x = m_pvertex[i].x;
        float y = m_pvertex[i].y;
        if(x<minx)
            minx = x;
        if(x>maxx)
            maxx = x;
        if(y<miny)
            miny = y;
        if(y>maxy)
            maxy = y;
    }
    
    m_treedata2.StartLevelEnumeration(levelcut);
    
    TreeNode2 *pNode;
    
    while((pNode = m_treedata2.GetNextLevelNode())!=NULL)
    {
        float nodescale = pNode->frame.scale;
        
        if(nodescale<mindisplayscale)
            continue; // dont draw any stamps that are too small
        
        float relativescalethresh = mindisplayscale/nodescale;
        
        int vertexcountthisnode = m_vertexcount;
        
        if(relativescalethresh>0)
        {
            // work out how many levels are worth including
            int level;
            for(level=0; level<MAX_LEVELS; level++)
                if(m_rgmaxscaleatlevel[level] < relativescalethresh)
                    break;
            
            if(level==0)
                continue;
            
            vertexcountthisnode = m_rgdrawcounttolevel[level-1];
        }
        
        float theta = M_PI_2 - pNode->frame.angle;
        float sc = nodescale * cosf(theta);
        float ss = nodescale * sinf(theta);
        
        for(i=0; i<vertexcountthisnode; i++)
        {
            // does not take into account mindisplayscale
            float xo = m_pvertex[i].x;
            float yo = m_pvertex[i].y;
            
            float x = sc * xo + ss * yo + pNode->frame.x;
            float y = -ss * xo + sc * yo + pNode->frame.y;
            
            if(x<minx)
                minx = x;
            if(x>maxx)
                maxx = x;
            if(y<miny)
                miny = y;
            if(y>maxy)
                maxy = y;
        }
    }
    
    minx *= m_aspectx;
    maxx *= m_aspectx;
    miny *= m_aspecty;
    maxy *= m_aspecty;
    
    float w = maxx - minx;
    if(w==0)
    {
        w = 0.01f;
        minx -= 0.005f;
    }
    return CGRectMake(minx, miny, w, maxy-miny);
}

bool CTreeModel::ScaleOffsetForView(const CGRect &bounds, float &drawx, float &drawy, float &drawscale)
{
    CGRect bbox = GetBoundingBox();
    if(bbox.size.width==0)
        return false; // fail
    
    // ensure that we dont shrink to nothing
    if(bbox.size.width<0.1f)
    {
        bbox.origin.x -= 0.5f * (0.1f - bbox.size.width);
        bbox.size.width = 0.1f;
    }
    if(bbox.size.height<0.1f)
    {
        bbox.origin.y -= 0.5f * (0.1f - bbox.size.height);
        bbox.size.height = 0.1f;
    }
    
    // work out overall scale factor
    float drawscalex = bounds.size.width / bbox.size.width;
    float drawscaley = bounds.size.height / bbox.size.height;
    drawscale = drawscalex;
    if(drawscale > drawscaley)
        drawscale = drawscaley;
    drawscale *= 0.95f;
    
    // find origin to draw tree
    float dx = bounds.size.width - bbox.size.width * drawscale;
    float dy = bounds.size.height - bbox.size.height * drawscale;
    drawx = 0.5f*dx - bbox.origin.x * drawscale + bounds.origin.x;
    drawy = bounds.size.height - (0.5f*dy - bbox.origin.y * drawscale) + bounds.origin.y;
    
    return true;
}

int CTreeModel::DrawQuartz(CGContextRef ctx, const CGRect &bounds, float drawx, float drawy, float drawscale, float time, float linewidth, int quality, int vertextarget, bool drawbackground, bool (*progress)(float val, void *user), void *user)
{
    if(progress!=NULL)
        progress(0, user);
    
    float drawscalex = drawscale * m_aspectx;
    float drawscaley = drawscale * m_aspecty;
    
    // deallocate vertex buffer and tree data
    FreeResources();
    
    float pixelsize = 1.0f/drawscale;
    float mindisplayscale = pixelsize;
    if(m_minscale > mindisplayscale)
        mindisplayscale = m_minscale;
    
    float quality_vertex_target = VERTEX_TARGET; // total number to generate
    float quality_min_line_width =  0.0015f * drawscale;
    if(linewidth>0)
        quality_min_line_width *= linewidth;
    float quality_colornorm = 1.0f;
    
    if(quality==QUALITY_ICON)
    {
        quality_vertex_target = 50000;
        quality_min_line_width = 0.5f;
        quality_colornorm = 0.5f;
    }
    else if(quality==QUALITY_HIGHDETAIL)
    {
        quality_vertex_target = 3000000;
        //quality_min_line_width = 1.5f;
        //quality_colornorm = 1.0f;
        
        mindisplayscale = pixelsize; // put it back to minimum
    }
    else if(quality==QUALITY_EMAIL)
    {
        quality_vertex_target = 1000000;
        quality_min_line_width = 0.6f;
        //quality_colornorm = 1.0f;
    }
    else if(quality==QUALITY_SOCIAL)
    {
        quality_vertex_target = 1000000;
        quality_min_line_width = 0.5f;
        //quality_colornorm = 1.0f;
    }
    
    if(vertextarget>0)
        quality_vertex_target = vertextarget;
    
    if(time>0)
    {
        UpdateAnimations(0);
        UpdateAnimations(time);
    }
    
    // generate all the tree data
    int levelcut;
    CTreeGen *ptreegen = GenerateTree(quality_vertex_target, time > 0, levelcut);
    if(ptreegen==NULL)
        return IME_FAIL;
    
    CTreePath path;
    
    bool ok = GeneratePathData(ptreegen, path);
    
    delete ptreegen;
    
    if(!ok)
        return IME_FAIL;

    assert(path.PathCount()>0);
    
    if(path.PathCount()==0)
        return IME_OK;
    
    CGContextSetLineWidth(ctx, quality_min_line_width);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinMiter);
    
    float alpha = 0.6f*m_colortransition + 0.3f;
    
    float colortransitionk1 = (1-alpha)*(1-alpha);
    float colortransitionk2 = (1-2*alpha);
    float colortransitionk3 = alpha*alpha;
    float scaletocolor = 1.0f/(5.4f*m_colorsize - 6.0f);
    
    float leafcolor_r = REDFROMCOLOR(m_leafcolor);
    float leafcolor_g = GREENFROMCOLOR(m_leafcolor);
    float leafcolor_b = BLUEFROMCOLOR(m_leafcolor);
    float rootcolor_r = REDFROMCOLOR(m_rootcolor);
    float rootcolor_g = GREENFROMCOLOR(m_rootcolor);
    float rootcolor_b = BLUEFROMCOLOR(m_rootcolor);
    
    CGFloat rgcolor[4], rgbgcolor[4];
    rgcolor[3] = 1.0f;
    
    rgbgcolor[0] = REDFROMCOLOR(m_backgroundcolor);
    rgbgcolor[1] = GREENFROMCOLOR(m_backgroundcolor);
    rgbgcolor[2] = BLUEFROMCOLOR(m_backgroundcolor);
    rgbgcolor[3] = 1.0f;
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    CGColorRef bgcolorref = CGColorCreate(colorspace, rgbgcolor);
    CGContextSetFillColorWithColor(ctx, bgcolorref);
    CGColorRelease(bgcolorref);
    
    if(drawbackground)
        CGContextFillRect(ctx, bounds);
    
    float progressnorm = 1 + m_treedata2.CountAtLevel(levelcut);
    
    // how many paths in the non-stamp drawing
    assert(levelcut>0);
    int basepathcount = m_rgdrawcounttolevel[levelcut-1];
    
    // draw the main root and leaves up to levelcut
    int i;
    for(i=0; i<basepathcount; i++)
    {
        float pathscale;
        int pointcount;
        CGPoint *p = path.GetPath(i, pointcount, pathscale);
        
        // only draw path if scale is large enough
        if(pathscale >= mindisplayscale)
        {
            // set stroke and fill color
            float d = scaletocolor * log(quality_colornorm * pathscale + 0.00001);
            if(d>1)
                d = 1;
            else if(d<0)
                d = 0;
            d = colortransitionk1 * d / (d * colortransitionk2 + colortransitionk3);
            
            float md = 1 - d;
            rgcolor[0] = d * leafcolor_r + md * rootcolor_r;
            rgcolor[1] = d * leafcolor_g + md * rootcolor_g;
            rgcolor[2] = d * leafcolor_b + md * rootcolor_b;
            
            CGColorRef fgcolorref = CGColorCreate(colorspace, rgcolor);
            CGContextSetFillColorWithColor(ctx, fgcolorref);
            CGContextSetStrokeColorWithColor(ctx, fgcolorref);
            CGColorRelease(fgcolorref);
            
            // draw polygon of path
            int j;
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, drawx + drawscalex * p[0].x, drawy - drawscaley * p[0].y);
            if(i!=0)
            {
                // only draw the rounded bottom if its not the root node - kind of a hack
                CGContextAddLineToPoint(ctx, drawx + drawscalex * p[1].x, drawy - drawscaley * p[1].y);
                CGContextAddLineToPoint(ctx, drawx + drawscalex * p[2].x, drawy - drawscaley * p[2].y);
            }
            for(j=3; j<pointcount; j++)
                CGContextAddLineToPoint(ctx, drawx + drawscalex * p[j].x, drawy - drawscaley * p[j].y);
            CGContextClosePath(ctx);
            CGContextDrawPath(ctx, kCGPathFillStroke);
        }
    }
    
    int progresscount = 1;
    
    if(progress!=NULL && !progress(progresscount/progressnorm, user))
    {
        CGColorSpaceRelease(colorspace);
        return IME_CANCEL;
    }
    
    m_treedata2.StartLevelEnumeration(levelcut);
    
    assert(m_treedata2.CountAtLevel(levelcut)<=MAX_STAMPS);
    
    TreeNode2 *pNode;
    TreeNode2 *rgpStampNodes[MAX_STAMPS];
    
    int stampcount;
    for(stampcount=0; (pNode = m_treedata2.GetNextLevelNode())!=NULL; stampcount++)
        rgpStampNodes[stampcount] = pNode;
    
    qsort(rgpStampNodes, stampcount, sizeof(TreeNode2 *), qsort_treenode_priority_compare);
    
    int stamp;
    for(stamp = 0; stamp < stampcount; stamp++)
    {
        pNode = rgpStampNodes[stamp];
        //DEBUG_PRINTF("branch %d, priority = %d\n", stamp, pNode->priority);

        // each node is a frame for the fractal stamp
        float nodescale = pNode->frame.scale;
        
        if(nodescale<mindisplayscale)
            continue;
        
        // scale threshold relative to the stamp
        float relativescalethresh = mindisplayscale/nodescale;
        
        // determine if we need to draw them all
        int drawcountthisnode = path.PathCount();
        
        if(relativescalethresh>0)
        {
            int level;
            for(level=0; level<MAX_LEVELS; level++)
                if(m_rgmaxscaleatlevel[level] < relativescalethresh)
                    break;
            
            if(level==0)
                continue;
            
            drawcountthisnode = m_rgdrawcounttolevel[level-1];
        }
        
        // stamp frame rotation
        float theta = M_PI_2 - pNode->frame.angle;
        float sc = nodescale * cosf(theta);
        float ss = nodescale * sinf(theta);
        
        for(i=0; i<drawcountthisnode; i++)
        {
            float pathscale;
            int pointcount;
            CGPoint *p = path.GetPath(i, pointcount, pathscale);
            if(pathscale >= relativescalethresh)
            {
                // set stroke and fill color
                float d = scaletocolor * log(quality_colornorm * nodescale * pathscale + 0.00001);
                if(d>1)
                    d = 1;
                else if(d<0)
                    d = 0;
                d = colortransitionk1 * d / (d * colortransitionk2 + colortransitionk3);
                
                float md = 1 - d;
                rgcolor[0] = d * leafcolor_r + md * rootcolor_r;
                rgcolor[1] = d * leafcolor_g + md * rootcolor_g;
                rgcolor[2] = d * leafcolor_b + md * rootcolor_b;
                
                CGColorRef fgcolorref = CGColorCreate(colorspace, rgcolor);
                CGContextSetFillColorWithColor(ctx, fgcolorref);
                CGContextSetStrokeColorWithColor(ctx, fgcolorref);
                CGColorRelease(fgcolorref);
                
                int j;
                CGContextBeginPath(ctx);
                
                float xo = p[0].x;
                float yo = p[0].y;
                float x = sc * xo + ss * yo + pNode->frame.x;
                float y = -ss * xo + sc * yo + pNode->frame.y;
                CGContextMoveToPoint(ctx, drawx + drawscalex * x, drawy - drawscaley * y);
                for(j=1; j<pointcount; j++)
                {
                    xo = p[j].x;
                    yo = p[j].y;
                    x = sc * xo + ss * yo + pNode->frame.x;
                    y = -ss * xo + sc * yo + pNode->frame.y;
                    CGContextAddLineToPoint(ctx, drawx + drawscalex * x, drawy - drawscaley * y);
                }
                CGContextClosePath(ctx);
                CGContextDrawPath(ctx, kCGPathFillStroke);
            }
        }
        
        progresscount++;
        
        if(progress!=NULL && !progress(progresscount/progressnorm, user))
        {
            CGColorSpaceRelease(colorspace);
            return IME_CANCEL;
        }
    }
    
    CGColorSpaceRelease(colorspace);

    return IME_OK;
}

bool CTreeModel::DrawQuartz(CGContextRef ctx, const CGRect &bounds, int quality, bool drawbackground)
{
    float drawx, drawy, drawscale;
    if(!ScaleOffsetForView(bounds, drawx, drawy, drawscale))
        return false;
    
    return DrawQuartz(ctx, bounds, drawx, drawy, drawscale, 0, 0, quality, 0, drawbackground, NULL, NULL);
}

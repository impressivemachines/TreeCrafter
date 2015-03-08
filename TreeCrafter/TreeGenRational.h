//
//  TreeGenRational.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef __Fractal_Trees__TreeGenRational__
#define __Fractal_Trees__TreeGenRational__

class CTreeGenRational : public CTreeGen
{
public:
    CTreeGenRational() {}
    ~CTreeGenRational() {}
    
    bool Init(int randomseed, int intervalstart, int intervalcount, int apextype, int anglemode, float bend, float balance, float spread, float lengthratio, float lengthbalance, float spikiness, float trunkwidth, float trunktaper, float randomangle, float randomlength, float randomwiggle, float randominterval, int windseed1, int windseed2, float winddepth, float windalpha);
    
private:
    int m_rgnodemap[MAX_TREEGEN_DATA_SIZE];
};

#endif /* defined(__Fractal_Trees__TreeGenRational__) */

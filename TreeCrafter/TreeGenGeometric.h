//
//  TreeGenGeometric.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.
//

#ifndef __Fractal_Trees__TreeGenGeometric__
#define __Fractal_Trees__TreeGenGeometric__

class CTreeGenGeometric : public CTreeGen
{
public:
    CTreeGenGeometric() {}
    ~CTreeGenGeometric() {}
    
    bool Init(int randomseed, int branchcount, int geonodes, int apextype, int anglemode, float delay, float georatio, float spin, float twist, float bend, float spread, float lengthratio, float spikiness, float trunkwidth, float trunktaper, float randomwiggle, float randomangle, float randomlength, float randominterval, int windseed1, int windseed2, float winddepth, float windalpha);
    
private:
};

#endif /* defined(__Fractal_Trees__TreeGenGeometric__) */

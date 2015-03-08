//
//  random.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.

#ifndef VideoFX_random_h
#define VideoFX_random_h

#define RAND_TABSIZE 32

class CRand 
{
public:
    CRand() { Seed(1); }
    CRand(int seed) { Seed(seed); }
    
    void Seed(int seed);
    double DRand();	 // 0 to <1
    double URand(double vmin, double vmax)	// vmin to vmax
        { return vmin + (vmax-vmin) * DRand(); }
    int IRand(int m)	 // 0 to m - 1
        { return (int)(m * DRand()); }
    double Gauss();
    
private:
    int m_last;
    int m_state;
    int m_aShuffle[RAND_TABSIZE];
    bool m_gaussok;
    double m_gassval;
};

#endif

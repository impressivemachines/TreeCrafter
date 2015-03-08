//
//  random.cpp
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.

#include <stdlib.h>
#include <math.h>

#include "random.h"

#define RAND_K1 16807
#define RAND_K2 2147483647
#define RAND_K3 (1.0/RAND_K2)
#define RAND_K4 127773
#define RAND_K5 2836
#define RAND_NORM (1 + (RAND_K2-1)/RAND_TABSIZE)
#define RAND_TINY 1.2e-7
#define RAND_RMAX (1.0 - RAND_TINY)

void CRand::Seed(int seed)
{
    seed = abs(seed);
    if(seed==0)
        seed = 1;
    
    int i;
    m_state = seed;
    
    for(i = RAND_TABSIZE+7; i>=0; i--)
    {
        int iK = m_state / RAND_K4;
        m_state = RAND_K1 * (m_state - iK * RAND_K4) - RAND_K5 * iK;
        if(m_state<0)
            m_state += RAND_K2;
        if(i < RAND_TABSIZE)
        {
            m_aShuffle[i] = m_state;
        }
    }
    
    m_last = m_aShuffle[0];
    m_gaussok = false;
}

double CRand::DRand()
{
    int k = m_state / RAND_K4;
    m_state = RAND_K1 * (m_state - k * RAND_K4) - RAND_K5 * k;
    if(m_state<0)
        m_state += RAND_K2;
    
    int i = m_last / RAND_NORM;
    m_last = m_aShuffle[i];
    m_aShuffle[i] = m_state;
    
    double result = RAND_K3 * m_last;
    if(result>RAND_RMAX)
        result = RAND_RMAX;
    
    return result;
}

double CRand::Gauss()
{
    if(!m_gaussok)
    {
        double dV1, dV2, dRsq;
        do {
            dV1 = 2.0 * DRand() - 1.0;
            dV2 = 2.0 * DRand() - 1.0;
            dRsq = dV1 * dV1 + dV2 * dV2;
        } while(dRsq>=1.0 || dRsq==0.0);
        
        double dFac = sqrt(-2.0 * log(dRsq) / dRsq);
        m_gassval = dV1 * dFac;
        m_gaussok = true;
        
        return dV2 * dFac;
    }
    else
    {
        m_gaussok = false;
        return m_gassval;
    }
}


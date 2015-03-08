//
//  matrix.h
//  Tree Crafter iPad App
//
//  Created by SIMON WINDER on 4/4/13.
//  Copyright (c) 2013 Impressive Machines LLC. All rights reserved.

#ifndef Fractal_Trees_matrix_h
#define Fractal_Trees_matrix_h

struct Matrix3x3
{
    Matrix3x3() {}
    Matrix3x3(const Matrix3x3 &x) { operator=(x); }
    
    float &El(int r, int c) { return m[r*3+c]; }
    const float &El(int r, int c) const { return m[r*3+c]; }
    
    float &operator()(int r, int c) { return El(r,c); }
    const float &operator()(int r, int c) const { return El(r,c); }
    
    const float *Ptr() const { return m; }
    float *Ptr() { return m; }
    
    Matrix3x3 &operator=(const Matrix3x3 &x) { memcpy(m, x.m, 9*sizeof(float)); return *this; }
    Matrix3x3 operator*(const Matrix3x3 &x) const
    {
        Matrix3x3 result;
        
        result.m[0] = m[0] * x.m[0] + m[1] * x.m[3] + m[2] * x.m[6];
        result.m[1] = m[0] * x.m[1] + m[1] * x.m[4] + m[2] * x.m[7];
        result.m[2] = m[0] * x.m[2] + m[1] * x.m[5] + m[2] * x.m[8];
        
        result.m[3] = m[3] * x.m[0] + m[4] * x.m[3] + m[5] * x.m[6];
        result.m[4] = m[3] * x.m[1] + m[4] * x.m[4] + m[5] * x.m[7];
        result.m[5] = m[3] * x.m[2] + m[4] * x.m[5] + m[5] * x.m[8];
        
        result.m[6] = m[6] * x.m[0] + m[7] * x.m[3] + m[8] * x.m[6];
        result.m[7] = m[6] * x.m[1] + m[7] * x.m[4] + m[8] * x.m[7];
        result.m[8] = m[6] * x.m[2] + m[7] * x.m[5] + m[8] * x.m[8];

        return result;
    }
    
    void MakeI() { memset(m, 0, 9*sizeof(float)); m[0] = m[4] = m[8] = 1.0f; }
    
    void MakeSimilarity(float scale, float rotation, float dx, float dy)
    {
        float vs = scale * sin(rotation);
        float vc = scale * cos(rotation);
        
        m[0] = vc;  m[1] = vs; m[2] = dx;
        m[3] = -vs; m[4] = vc; m[5] = dy;
        m[6] = 0;   m[7] = 0;  m[8] = 1;
    }
    
    void MakeAspectShift(float sx, float sy, float dx, float dy)
    {
        m[0] = sx; m[1] = 0;  m[2] = dx;
        m[3] = 0;  m[4] = sy; m[5] = dy;
        m[6] = 0;  m[7] = 0;  m[8] = 1;
    }
    
    Matrix3x3 T()
    {
        Matrix3x3 result;
        
        result.m[0] = m[0];
        result.m[1] = m[3];
        result.m[2] = m[6];
        
        result.m[3] = m[1];
        result.m[4] = m[4];
        result.m[5] = m[7];
        
        result.m[6] = m[2];
        result.m[7] = m[5];
        result.m[8] = m[8];
        
        return result;
    }
    
    void Dump()
    {
        DEBUG_PRINTF("[ %f %f %f\n  %f %f %f\n  %f %f %f ]\n", m[0], m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8]);
    }
    
    float m[9];
};

struct Matrix4x4
{
    Matrix4x4() {}
    Matrix4x4(const Matrix4x4 &x) { operator=(x); }
    
    float &El(int r, int c) { return m[r*4+c]; }
    const float &El(int r, int c) const { return m[r*4+c]; }
    
    float &operator()(int r, int c) { return El(r,c); }
    const float &operator()(int r, int c) const { return El(r,c); }
    
    const float *Ptr() const { return m; }
    float *Ptr() { return m; }
    
    Matrix4x4 &operator=(const Matrix4x4 &x) { memcpy(m, x.m, 16*sizeof(float)); return *this; }
    Matrix4x4 operator*(const Matrix4x4 &x) const
    {
        Matrix4x4 result;
        int i,j,k;
        for(i=0; i<4; i++)
            for(j=0; j<4; j++)
            {
                float sum = 0;
                for(k=0; k<4; k++)
                    sum += El(i,k) * x.El(k,j);
                result(i,j) = sum;
            }
        return result;
    }
    
    void MakeI() { memset(m, 0, 16*sizeof(float)); m[0] = m[5] = m[10] = m[15] = 1.0f; }
    
    void MakeSimilarity(float scale, float rotx, float roty, float rotz, float dx, float dy, float dz)
    {
        // TBD
        float vs = scale * sin(rotz);
        float vc = scale * cos(rotz);

        m[0] = vc;  m[1] = vs; m[2] = 0;  m[3] = dx;
        m[4] = -vs; m[5] = vc; m[6] = 0;  m[7] = dy;
        m[8] = 0;   m[9] = 0;  m[10] = scale; m[11] = dz;
        m[12] = 0;  m[13] = 0; m[14] = 0; m[15] = 1;
    }
    
    void MakeAspect(float sx, float sy, float sz)
    {
        MakeI();
        m[0] = sx; m[5] = sy; m[10] = sz;
    }
    
    Matrix4x4 T()
    {
        Matrix4x4 result;
        int i,j;
        for(i=0; i<4; i++)
            for(j=0; j<4; j++)
                result.El(i,j) = El(j,i);
        return result;
    }
    
    float m[16];
};

#endif

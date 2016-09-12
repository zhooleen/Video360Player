//
//  SMTransforms.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/12/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#ifndef SMTransforms_h
#define SMTransforms_h

#import <simd/simd.h>

static inline matrix_float4x4 perspective_projection(float aspect, float fovy, float near, float far)
{
    float yScale = 1 / tan(fovy * 0.5);
    float xScale = yScale / aspect;
    float zRange = far - near;
    float zScale = -(far + near) / zRange;
    float wzScale = -2 * far * near / zRange;
    
    vector_float4 P = { xScale, 0, 0, 0 };
    vector_float4 Q = { 0, yScale, 0, 0 };
    vector_float4 R = { 0, 0, zScale, -1 };
    vector_float4 S = { 0, 0, wzScale, 0 };
    
    matrix_float4x4 mat = { P, Q, R, S };
    return mat;
}


static inline matrix_float4x4 identity()
{
    vector_float4 X = { 1, 0, 0, 0 };
    vector_float4 Y = { 0, 1, 0, 0 };
    vector_float4 Z = { 0, 0, 1, 0 };
    vector_float4 W = { 0, 0, 0, 1 };
    
    matrix_float4x4 identity = { X, Y, Z, W };
    
    return identity;
}

#endif /* SMTransforms_h */

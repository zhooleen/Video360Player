//
//  Types.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#ifndef Types_h
#define Types_h

#import <simd/simd.h>

typedef struct
{
    vector_float4 position;
    vector_float2 textureCoord;
}
SMTextureVertex;


typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 modelViewProjection;
}
SMUniforms;

#endif /* Types_h */

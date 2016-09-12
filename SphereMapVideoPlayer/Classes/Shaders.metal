//
//  Shaders.metal
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float2 textureCoord;
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoord;
};

struct Uniforms {
    float4x4 projectionMatrix;
    float4x4 viewMatrix;
    float4x4 modelViewprojection;
};

vertex VertexOut vertexFunction(device VertexIn *vertices [[ buffer(0) ]],
                             constant Uniforms &uniforms [[ buffer(1) ]],
                             uint vid [[ vertex_id ]])
{
    VertexIn vt = vertices[vid];
    float4 origin = float4(vt.position, 1);
    float4 pos = uniforms.modelViewprojection * origin;
    VertexOut out;
    out.position = pos;
    out.textureCoord = vt.textureCoord;
    return out;
}

fragment float4 fragmentFunction(VertexOut vert [[stage_in]],
                                 texture2d<float, access::sample> sphere [[ texture(0) ]],
                                 sampler sam [[ sampler(0) ]]) {
    return sphere.sample(sam, vert.textureCoord);
}

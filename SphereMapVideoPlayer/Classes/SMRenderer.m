//
//  SMRenderer.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMRenderer.h"

#import <simd/simd.h>
#import <Metal/Metal.h>

#import "SMSphereMesh.h"
#import "SMUniformBufferProvider.h"
#import "SMTextureLoader.h"
#import "SMTransforms.h"

@interface SMRenderer()

@property (strong, nonatomic) id<MTLDevice> device;
@property (strong, nonatomic) id<SMMesh> mesh;

@property (strong, nonatomic) id<MTLBuffer> uniformBuffer;
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
@property (strong, nonatomic) id<MTLRenderPipelineState> renderPipelineState;
@property (strong, nonatomic) id<MTLDepthStencilState> depthStencilState;

@property (strong, nonatomic) SMUniformBufferProvider *provider;

@property (assign, nonatomic) float rotationX, rotationY, time;

@property (strong, nonatomic) id<MTLTexture> depthTexture;
@property (strong, nonatomic) id<MTLSamplerState> sampler;

@end

@implementation SMRenderer

- (instancetype) init {
    self = [super init];
    if(self) {
        _device = MTLCreateSystemDefaultDevice();
        
        [self makeResources];

        [self makePipeline];
    }
    return self;
}

- (void) makePipeline {
    _commandQueue = [_device newCommandQueue];
    
    id<MTLLibrary> library = [_device newDefaultLibrary];
    id<MTLFunction> vertextFunction = [library newFunctionWithName:@"vertexFunction"];
    id<MTLFunction> fragmentFunction = [library newFunctionWithName:@"fragmentFunction"];
    MTLRenderPipelineDescriptor *pipelineDesc = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDesc.vertexFunction = vertextFunction;
    pipelineDesc.fragmentFunction = fragmentFunction;
    pipelineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    pipelineDesc.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    MTLDepthStencilDescriptor *depthDesc = [MTLDepthStencilDescriptor new];
    depthDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthDesc.depthWriteEnabled = YES;
    self.depthStencilState = [_device newDepthStencilStateWithDescriptor:depthDesc];
    
    NSError *error = nil;
    _renderPipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineDesc error:&error];
    if(!_renderPipelineState) {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
}

- (void) makeResources {
    _mesh = [[SMSphereMesh alloc] initWithDevice:_device radius:100.0f rows:360 columns:360];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    float aspect = size.width / size.height;
    float fov = aspect > 1 ? 60 : 90;
    _uniforms.projectionMatrix = perspective_projection(aspect, fov*M_PI/180.0f, 0.1, 100);
    _uniforms.viewMatrix = identity();
    _uniforms.modelViewProjection = matrix_multiply(_uniforms.projectionMatrix, _uniforms.viewMatrix);
    
    _provider = [[SMUniformBufferProvider alloc] initWithDevice:_device uniformBufferSize:sizeof(SMUniforms) count:4];
    
    id<MTLTexture> texture = [SMTextureLoader texture2DWithImageNamed:@"spheremap.png" device:_device];
//    [SMTextureLoader generateMipmapForTexture:texture device:_device completion:^(id<MTLTexture> texture) {
//        _sphereTexture = texture;
//    }];
    _sphereTexture = texture;
    MTLSamplerDescriptor *samplerDesc = [MTLSamplerDescriptor new];
    samplerDesc.minFilter = MTLSamplerMinMagFilterNearest;
    samplerDesc.magFilter = MTLSamplerMinMagFilterLinear;
//    samplerDesc.mipFilter = MTLSamplerMipFilterLinear;
    _sampler = [_device newSamplerStateWithDescriptor:samplerDesc];
    
}

- (void) drawInView:(SMMetalView *)view {

//    if(_sphereTexture == nil) {
//        return;
//    }
    
    view.clearColor = MTLClearColorMake(1, 1, 1.0, 1);
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDesc = [view currentRenderPassDescriptor];
    
    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDesc];
    [encoder setRenderPipelineState:_renderPipelineState];
    [encoder setDepthStencilState:_depthStencilState];
    [encoder setFrontFacingWinding:(MTLWindingCounterClockwise)];
    [encoder setCullMode:(MTLCullModeBack)];
    
    id<MTLBuffer> uniformBuffer = [_provider nextUniformBuffer];
    memcpy(uniformBuffer.contents, &_uniforms, sizeof(_uniforms));
    
    [encoder setVertexBuffer:_mesh.vertexBuffer offset:0 atIndex:0];
    [encoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    
    [encoder setFragmentTexture:_sphereTexture atIndex:0];
    [encoder setFragmentSamplerState:_sampler atIndex:0];
    
    [encoder drawIndexedPrimitives:(MTLPrimitiveTypeTriangleStrip)
                        indexCount:_mesh.indexBuffer.length/sizeof(uint32_t)
                         indexType:(MTLIndexTypeUInt32)
                       indexBuffer:_mesh.indexBuffer
                 indexBufferOffset:0];
    
    [encoder endEncoding];
    
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buf) {
        [_provider giveBackUniformBuffer];
    }];
    [commandBuffer commit];
}

@end

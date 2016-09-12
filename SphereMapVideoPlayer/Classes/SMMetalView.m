//
//  SMMetalView.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMMetalView.h"

@interface SMMetalView() {
    id<CAMetalDrawable> _currentDrawable;
    id<MTLTexture> _depthTexture;
    
    CADisplayLink *_displayLink;
    NSTimeInterval _frameDuration;
}
@end

@implementation SMMetalView

+ (Class) layerClass {
    return [CAMetalLayer class];
}

- (CAMetalLayer*) metalLayer {
    return (CAMetalLayer*)self.layer;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.metalLayer.device = MTLCreateSystemDefaultDevice();
        [self initCommon];
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame device:(id<MTLDevice>)device {
    self = [super initWithFrame:frame];
    if(self) {
        self.metalLayer.device = device;
        [self initCommon];
    }
    return self;
}

- (void) initCommon {
    _preferredFramesPerSecond = 60;
    _clearColor = MTLClearColorMake(1, 1, 1, 1);
    self.metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat scale = [UIScreen mainScreen].scale;
    if(self.window) {
        scale= self.window.screen.scale;
    }
    CGSize size = self.bounds.size;
    size.width *= scale;
    size.height*= scale;
    self.metalLayer.drawableSize = size;
    [self mapDepthTexture];
}

- (void) didMoveToWindow {
    const NSTimeInterval idealFrameDuration = 1.0f / 60.0f;
    const NSTimeInterval targetFrameDuration = 1.0f / self.preferredFramesPerSecond;
    const NSInteger frameInterval = round(targetFrameDuration / idealFrameDuration);
    if(self.window) {
        [_displayLink invalidate];
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        _displayLink.frameInterval = frameInterval;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (void) displayLinkCallback:(CADisplayLink*)link {
    _currentDrawable = self.metalLayer.nextDrawable;
    _frameDuration = _displayLink.duration;
    if(self.delegate) {
        [self.delegate drawInView:self];
    }
}

- (void) mapDepthTexture {
    CGSize size = self.metalLayer.drawableSize;
    if(_depthTexture.width != size.width || _depthTexture.height != size.height) {
        MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:size.width height:size.height mipmapped:NO];
        _depthTexture = [self.metalLayer.device newTextureWithDescriptor:desc];
    }
}


#pragma mark - PROPERTIES

- (void) setColorPixelFormat:(MTLPixelFormat)colorPixelFormat {
    self.metalLayer.pixelFormat = colorPixelFormat;
}
- (MTLPixelFormat) colorPixelFormat {
    return self.metalLayer.pixelFormat;
}

- (MTLRenderPassDescriptor*) currentRenderPassDescriptor {
    MTLRenderPassDescriptor *passDesc = [MTLRenderPassDescriptor renderPassDescriptor];
    passDesc.colorAttachments[0].texture = self.currentDrawable.texture;
    passDesc.colorAttachments[0].clearColor = _clearColor;
    passDesc.colorAttachments[0].storeAction = MTLStoreActionStore;
    passDesc.colorAttachments[0].loadAction = MTLLoadActionDontCare;
    
    passDesc.depthAttachment.texture = _depthTexture;
    passDesc.depthAttachment.clearDepth = 1.0;
    passDesc.depthAttachment.loadAction = MTLLoadActionClear;
    passDesc.depthAttachment.storeAction = MTLStoreActionStore;
    
    return passDesc;
}

@end

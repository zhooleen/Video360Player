//
//  SMMetalViewController.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMMetalViewController.h"
#import "SMMetalView.h"
#import "SMRenderer.h"
#import "SMVideoReader.h"
#import "SMTextureLoader.h"

#import <CoreMotion/CoreMotion.h>

@interface SMMetalViewController()<SMMetalViewDelegate> {
    SMRenderer *renderer;
    CMMotionManager *motionManager;
    SMVideoReader *videoReader;
}

@property (weak, nonatomic) SMMetalView *metalView;
@end


@implementation SMMetalViewController

- (SMMetalView*) metalView {
    return (SMMetalView*)(self.view);
}

- (void) viewDidLoad {
    [super viewDidLoad];
    renderer = [[SMRenderer alloc] init];
    self.metalView.delegate = self;
    motionManager = [[CMMotionManager alloc] init];
    if (motionManager.deviceMotionAvailable)
    {
        motionManager.deviceMotionUpdateInterval = 1 / 60.0;
        CMAttitudeReferenceFrame frame = CMAttitudeReferenceFrameXTrueNorthZVertical;
        [motionManager startDeviceMotionUpdatesUsingReferenceFrame:frame];
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"videoplayback" withExtension:@"mp4"];
    
    videoReader = [[SMVideoReader alloc] initWithURL:url];
}

- (void)updateDeviceOrientation
{
    if (motionManager.deviceMotionAvailable)
    {
        CMDeviceMotion *motion = motionManager.deviceMotion;
        CMRotationMatrix m = motion.attitude.rotationMatrix;
        
        // permute rotation matrix from Core Motion to get scene orientation
        vector_float4 X = { m.m12, m.m22, m.m32, 0 };
        vector_float4 Y = { m.m13, m.m23, m.m33, 0 };
        vector_float4 Z = { m.m11, m.m21, m.m31, 0 };
        vector_float4 W = {     0,     0,     0, 1 };
        
        
        matrix_float4x4 orientation = {X, Y, Z, W };
        
        SMUniforms uni = renderer.uniforms;
        uni.viewMatrix = orientation;
        uni.modelViewProjection = matrix_multiply(uni.projectionMatrix, uni.viewMatrix);
        renderer.uniforms = uni;
    }
}

- (void) drawInView:(SMMetalView *)view {
    [self updateDeviceOrientation];
    if(videoReader) {
        [videoReader requestCurrnetFrame:^(NSInteger width, NSInteger height, uint8_t *rawdata) {
            id<MTLTexture> texture = [SMTextureLoader texture2DWithBytes:rawdata width:width height:height device:self.metalView.metalLayer.device];
//            [SMTextureLoader generateMipmapForTexture:texture device:self.metalView.metalLayer.device completion:^(id<MTLTexture> texture) {
//                renderer.sphereTexture = texture;
//            }];
            renderer.sphereTexture = texture;
        }];
    }
    [renderer drawInView:view];
}


@end

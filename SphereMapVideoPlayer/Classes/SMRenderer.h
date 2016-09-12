//
//  SMRenderer.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMMetalView.h"
#import "Types.h"

@interface SMRenderer : NSObject <SMMetalViewDelegate>

@property (assign, nonatomic) SMUniforms uniforms;

@property (strong, atomic) id<MTLTexture> sphereTexture;

@end

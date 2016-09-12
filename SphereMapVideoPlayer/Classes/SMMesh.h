//
//  SMMesh.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@protocol SMMesh <NSObject>

@property (strong, nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (strong, nonatomic, readonly) id<MTLBuffer> indexBuffer;

@end

//
//  SMSphereMesh.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMMesh.h"

@interface SMSphereMesh : NSObject <SMMesh>

@property (strong, nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (strong, nonatomic, readonly) id<MTLBuffer> indexBuffer;

@property (assign, nonatomic, readonly) double radius;
@property (assign, nonatomic, readonly) NSInteger rows;
@property (assign, nonatomic, readonly) NSInteger columns;

- (instancetype) initWithDevice:(id<MTLDevice>)device radius:(double)radius rows:(NSInteger)rows columns:(NSInteger)columns;

@end

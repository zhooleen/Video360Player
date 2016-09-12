//
//  SMUniformBufferProvider.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface SMUniformBufferProvider : NSObject

- (id<MTLBuffer>) nextUniformBuffer;

- (void) giveBackUniformBuffer;

- (instancetype) initWithDevice:(id<MTLDevice>)device uniformBufferSize:(NSUInteger)size count:(NSUInteger)count;

@end
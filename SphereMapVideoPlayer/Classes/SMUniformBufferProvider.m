//
//  SMUniformBufferProvider.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMUniformBufferProvider.h"

@interface SMUniformBufferProvider () {
    
    NSUInteger count;
    NSUInteger index;
    NSArray<id<MTLBuffer>> *buffers;
    
    dispatch_semaphore_t semaphore;
    
}
@end

@implementation SMUniformBufferProvider

- (instancetype) initWithDevice:(id<MTLDevice>)device uniformBufferSize:(NSUInteger)size count:(NSUInteger)c {
    self = [super init];
    if(self) {
        count = c;
        NSMutableArray *array = [NSMutableArray array];
        for(NSUInteger idx = 0; idx < count; ++idx) {
            id<MTLBuffer> buffer = [device newBufferWithLength:size options:0];
            [array addObject:buffer];
        }
        buffers = [array copy];
        index = 0;
        semaphore = dispatch_semaphore_create(count);
    }
    return self;
}

- (id<MTLBuffer>) nextUniformBuffer {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    id<MTLBuffer> buffer = buffers[index];
    index = (index + 1) % count;
    return buffer;
}

- (void) giveBackUniformBuffer {
    dispatch_semaphore_signal(semaphore);
}

- (void) dealloc {
    for(NSUInteger idx = 0; idx < count; ++index) {
        dispatch_semaphore_signal(semaphore);
    }
}

@end
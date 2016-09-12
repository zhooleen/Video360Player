//
//  SMSphereMesh.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMSphereMesh.h"
#import "Types.h"

@implementation SMSphereMesh

- (instancetype) initWithDevice:(id<MTLDevice>)device radius:(double)radius rows:(NSInteger)rows columns:(NSInteger)columns {
    self = [super init];
    if(self) {
        _radius = radius;
        _rows = rows;
        _columns = columns;
        [self generateVerteces:device];
        [self generateIndices:device];
    }
    return self;
}

- (void) generateVerteces:(id<MTLDevice>)device {
    const float columnInterval = 2.0f * M_PI / _columns;
    const float rowInterval = M_PI / _rows;
    const size_t size = (_rows+1) * (_columns+1) * sizeof(SMTextureVertex);
    SMTextureVertex *vertices = (SMTextureVertex *)malloc(size);
    memset(vertices, 0, size);
    
    for(NSInteger row = 0; row <= _rows; ++row) {
        const float rowRadians = row * rowInterval;
        const float y = _radius * cosf(rowRadians);
        const float tv = (float)row / (float)_rows;
        for(NSInteger col = 0; col <= _columns; ++col) {
            const float colRadians = col * columnInterval;
            const float x = _radius * sinf(rowRadians) * cosf(colRadians);
            const float z = _radius * sinf(rowRadians) * sinf(colRadians);
            const float tu = (float)col / (float)_columns;
            SMTextureVertex vertex;
            vertex.position = vector4(x, y, z, 1.0f);
            vertex.textureCoord = vector2(tu, tv);
//            NSLog(@"Texture Coord <tu, tv> : <%@, %@>", @(tu), @(tv));
            vertices[row*_columns + col] = vertex;
        }
    }
    _vertexBuffer = [device newBufferWithBytes:vertices length:size options:0];
    free(vertices);
}

- (void) generateIndices:(id<MTLDevice>)device {
    const size_t size = 2 * (_rows) * (_columns + 2) * sizeof(uint32_t);
    uint32_t *indices = (uint32_t*)malloc(size);
    memset(indices, 0, size);
    size_t idx = 0;
    for(uint32_t row = 1; row <= _rows; ++row) {
        const uint32_t topRow = row - 1;
        const uint32_t topIndex = (uint32_t)(self.columns + 1) * topRow;
        const uint32_t bottomIndex = topIndex +  (uint32_t)(_columns + 1);
        for(uint32_t col = 0; col < _columns; ++col) {
            indices[idx++] = topIndex + col;
            indices[idx++] = bottomIndex + col;
        }
        indices[idx++] = topIndex;
        indices[idx++] = bottomIndex;
    }
    NSAssert(idx == 2 * (_rows) * (_columns+1), nil);
    _indexBuffer = [device newBufferWithBytes:indices length:size options:0];
    free(indices);
}
@end

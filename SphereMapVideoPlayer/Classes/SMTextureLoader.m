//
//  SMTextureLoader.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/12/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMTextureLoader.h"
#import <UIKit/UIKit.h>

@implementation SMTextureLoader


+ (id<MTLTexture>) texture2DWithImageNamed:(NSString*)name device:(id<MTLDevice>)device {
    UIImage *image = [UIImage imageNamed:name];
    CGSize size = CGSizeMake(image.size.width*image.scale, image.size.height*image.scale);
    uint8_t *data = [self dataForImage:image];
    id<MTLTexture> texture = [self texture2DWithBytes:data width:size.width height:size.height device:device];
    free(data);
    return texture;
}

+ (id<MTLTexture>) texture2DWithBytes:(uint8_t*)bytes width:(NSInteger)width height:(NSInteger)height device:(id<MTLDevice>)device {
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:(MTLPixelFormatBGRA8Unorm) width:width height:height mipmapped:NO];
    id<MTLTexture> texture = [device newTextureWithDescriptor:desc];
    MTLRegion region = MTLRegionMake2D(0, 0, width, height);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * width;
    [texture replaceRegion:region mipmapLevel:0 withBytes:bytes bytesPerRow:bytesPerRow];
    return texture;
}

+ (void) generateMipmapForTexture:(id<MTLTexture>)texture device:(id<MTLDevice>)device completion:(void(^)(id<MTLTexture> texture))block {
    id<MTLCommandQueue> queue = [device newCommandQueue];
    id<MTLCommandBuffer> buffer = [queue commandBuffer];
    id<MTLBlitCommandEncoder> encoder = [buffer blitCommandEncoder];
    [encoder generateMipmapsForTexture:texture];
    [encoder endEncoding];
    [buffer addCompletedHandler:^(id<MTLCommandBuffer> buf) {
        block(texture);
    }];
    [buffer commit];
}

#pragma mark - Private

+ (uint8_t*) dataForImage:(UIImage*)image {
    CGImageRef ref = image.CGImage;
    const NSUInteger width = CGImageGetWidth(ref);
    const NSUInteger height= CGImageGetHeight(ref);
    const NSUInteger bytesPerPixel = 4;
    const NSUInteger bytesPerRow = bytesPerPixel * width;
    const NSUInteger bitsPerComponent = 8;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    uint8_t *rawData = (uint8_t*)malloc(sizeof(uint8_t)*4*height*width);
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(space);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), ref);
    CGContextRelease(context);
    return rawData;
}

@end

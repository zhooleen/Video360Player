//
//  SMTextureLoader.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/12/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface SMTextureLoader : NSObject

+ (id<MTLTexture>) texture2DWithImageNamed:(NSString*)name device:(id<MTLDevice>)device;

+ (id<MTLTexture>) texture2DWithBytes:(uint8_t*)bytes width:(NSInteger)width height:(NSInteger)height device:(id<MTLDevice>)device;

+ (void) generateMipmapForTexture:(id<MTLTexture>)texture device:(id<MTLDevice>)device completion:(void(^)(id<MTLTexture> texture))block;

@end

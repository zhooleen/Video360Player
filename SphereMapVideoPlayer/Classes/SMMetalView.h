//
//  SMMetalView.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/11/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>

@protocol SMMetalViewDelegate;

@interface SMMetalView : UIView

@property (weak, nonatomic) id<SMMetalViewDelegate> delegate;

@property (weak, nonatomic) CAMetalLayer *metalLayer;

@property (nonatomic) NSInteger preferredFramesPerSecond;

@property (nonatomic) MTLPixelFormat colorPixelFormat;

@property (nonatomic, assign) MTLClearColor clearColor;

@property (nonatomic, readonly) NSTimeInterval frameDuration;

@property (nonatomic, readonly) id<CAMetalDrawable> currentDrawable;

@property (nonatomic, readonly) MTLRenderPassDescriptor *currentRenderPassDescriptor;

@end

@protocol SMMetalViewDelegate <NSObject>

- (void) drawInView:(SMMetalView*)view;

@end

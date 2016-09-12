//
//  SMVideoReader.m
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/12/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import "SMVideoReader.h"
#import <AVFoundation/AVFoundation.h>


@interface SMVideoReader()

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVPlayerItemVideoOutput *output;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *item;
@property (strong, nonatomic) dispatch_queue_t queue;

@property (assign, nonatomic) NSTimeInterval interval;

@end

@implementation SMVideoReader

- (instancetype) initWithURL:(NSURL *)url {
    if(self = [super init]) {
        self.videoURL = url;
        self.interval = 0.02f;
        self.queue = dispatch_queue_create("Video.Reader.Queue", NULL);
        [self config];
    }
    return self;
}

- (void) config {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
            if(status == AVKeyValueStatusFailed) {
                NSLog(@"Fail tot load tracks, Reason : %@",  error);
                return;
            }
            id attrs = @{(__bridge NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
            self.output = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:attrs];
            self.item = [[AVPlayerItem alloc] initWithAsset:asset];
            [self.item addOutput:self.output];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.item];
            
            self.player = [[AVPlayer alloc] initWithPlayerItem:self.item];
            [self.player play];
        });
    }];
}


- (void) playerItemDidPlayToEndTime:(NSNotification*)not {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

- (void) requestCurrnetFrame:(SMCurrentFrameBlock)block {
    if(self.item.status != AVPlayerItemStatusReadyToPlay) {
        return;
    }
    CMTime time = self.item.currentTime;
    CVPixelBufferRef pixelBuffer = [self.output copyPixelBufferForItemTime:time itemTimeForDisplay:nil];
    if(pixelBuffer == NULL) {
        return;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    NSInteger width = CVPixelBufferGetWidth(pixelBuffer);
    NSInteger height= CVPixelBufferGetHeight(pixelBuffer);
    uint8_t *address = CVPixelBufferGetBaseAddress(pixelBuffer);
    block(width, height, address);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    CVBufferRelease(pixelBuffer);
}

@end

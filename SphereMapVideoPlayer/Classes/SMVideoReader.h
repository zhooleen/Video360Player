//
//  SMVideoReader.h
//  SphereMapVideoPlayer
//
//  Created by lzhu on 9/12/16.
//  Copyright © 2016 redeight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMVideoReader : NSObject

- (instancetype) initWithURL:(NSURL*)url;

typedef void (^SMCurrentFrameBlock)(NSInteger width, NSInteger height, uint8_t *rawdata);
- (void) requestCurrnetFrame:(SMCurrentFrameBlock)block;

@end

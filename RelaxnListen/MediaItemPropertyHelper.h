//
//  MediaItemPropertyHelper.h
//  RelaxnListen
//
//  Created by Stephen on 1/9/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MediaItemPropertyHelper : NSObject

+ (NSString*) nameForMedia:(MPMediaItem*)mediaItem;
+ (NSTimeInterval) lengthOfMedia:(MPMediaItem*)mediaItem;
+ (NSNumber *) persistentIdForMedia:(MPMediaItem*)mediaItem;
+ (MPMediaItemArtwork*) artForMediaItem:(MPMediaItem*)mediaItem;

@end

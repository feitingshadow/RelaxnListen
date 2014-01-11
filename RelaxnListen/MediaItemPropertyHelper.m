//
//  MediaItemPropertyHelper.m
//  RelaxnListen
//
//  Created by Stephen on 1/9/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import "MediaItemPropertyHelper.h"

@implementation MediaItemPropertyHelper

+ (NSString*) nameForMedia:(MPMediaItem*)mediaItem;
{
    if (mediaItem) {
        return (NSString*)[mediaItem valueForProperty:MPMediaItemPropertyTitle];
    }
    return nil;
}

+ (NSTimeInterval) lengthOfMedia:(MPMediaItem*)mediaItem;
{
    if (mediaItem)
    {
        NSNumber * duration = (NSNumber*)[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
        return duration.doubleValue;
    }
    
    return 0;
}

+ (NSNumber *) persistentIdForMedia:(MPMediaItem*)mediaItem;
{
    if (mediaItem)
    {
        NSNumber * persistId = (NSNumber*)[mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
        return persistId;
    }
    
    return nil;
}

+ (MPMediaItemArtwork*) artForMediaItem:(MPMediaItem*)mediaItem;
{
    return [mediaItem valueForProperty: MPMediaItemPropertyArtwork];
}

@end

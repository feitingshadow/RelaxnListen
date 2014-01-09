//
//  PlayedItem.h
//  RelaxnListen
//
//  Created by Stephen on 1/9/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PlayedItem : NSObject <NSCoding>

+ (PlayedItem*) itemWithMediaItem:(MPMediaItem*)item;

@property MPMediaItem * mediaItem;
@property NSTimeInterval lastInterval;
@property NSDate * lastDate;

@end

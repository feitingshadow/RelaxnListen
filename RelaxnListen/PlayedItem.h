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

@property (nonatomic, strong) MPMediaItem * mediaItem;
@property (nonatomic, strong) NSNumber * persistentNumber;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, assign) NSTimeInterval lastInterval;
@property (nonatomic, strong) NSDate * lastDate;

@end

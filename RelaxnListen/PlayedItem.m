//
//  PlayedItem.m
//  RelaxnListen
//
//  Created by Stephen on 1/9/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import "PlayedItem.h"

#define MEDIAITEM @"item"
#define LASTINTERVAL @"lstIntervl"
#define LASTDATE @"lstDate"

@implementation PlayedItem

 - (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.mediaItem = [aDecoder decodeObjectForKey:MEDIAITEM];
        self.lastInterval = [aDecoder decodeDoubleForKey:LASTINTERVAL];
        self.lastDate = [aDecoder decodeObjectForKey:LASTDATE];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mediaItem forKey:MEDIAITEM];
    [aCoder encodeDouble:self.lastInterval forKey:LASTINTERVAL];
    [aCoder encodeObject:self.lastDate forKey:LASTDATE];
}

+ (PlayedItem*) itemWithMediaItem:(MPMediaItem*)item;
{
    PlayedItem * playedItem = [PlayedItem new];
    playedItem.mediaItem = item;
    playedItem.lastInterval = 0;
    playedItem.lastDate = [NSDate date]; //now.
    return playedItem;
}

@end

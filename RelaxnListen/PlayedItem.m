//
//  PlayedItem.m
//  RelaxnListen
//
//  Created by Stephen on 1/9/14.
//  Copyright (c) 2014 Stephen. All rights reserved.
//

#import "PlayedItem.h"

#define MEDIA_ITEM @"media_item"
#define TITLE @"mediatitle"
#define PERSISTENT_ID @"persistentID"
#define LASTINTERVAL @"lstIntervl"
#define LASTDATE @"lstDate"

@implementation PlayedItem

 - (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.mediaItem = [aDecoder decodeObjectForKey:MEDIA_ITEM];
        self.persistentNumber = [aDecoder decodeObjectForKey:PERSISTENT_ID];
        self.title = [aDecoder decodeObjectForKey:TITLE];
        self.lastInterval = [aDecoder decodeDoubleForKey:LASTINTERVAL];
        self.lastDate = [aDecoder decodeObjectForKey:LASTDATE];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mediaItem forKey:MEDIA_ITEM];
    [aCoder encodeObject:self.title forKey:TITLE];
    [aCoder encodeObject:self.persistentNumber forKey:PERSISTENT_ID];
    [aCoder encodeDouble:self.lastInterval forKey:LASTINTERVAL];
    [aCoder encodeObject:self.lastDate forKey:LASTDATE];
}

+ (PlayedItem*) itemWithMediaItem:(MPMediaItem*)item;
{
    PlayedItem * playedItem = [PlayedItem new];
    playedItem.mediaItem = item;
    playedItem.persistentNumber = [MediaItemPropertyHelper persistentIdForMedia:item];
    playedItem.lastInterval = 0;
    playedItem.lastDate = [NSDate date]; //now.
    playedItem.title = [MediaItemPropertyHelper nameForMedia:item];
    return playedItem;
}

@end

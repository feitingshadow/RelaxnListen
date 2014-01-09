//
//  Settings.m
//  RelaxnListen
//
//  Created by Stephen on 12/28/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import "Settings.h"
#import "Storage.h"

//Settings Constants


@interface Settings()
{
    
}
@end

@implementation Settings

+ (Settings*)sharedSettings {
    static Settings * sharedSettings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[self alloc] init];
    });
    return sharedSettings;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

- (void)dealloc {
}

//Begin instance methods


- (void) setLastCollection:(MPMediaItemCollection*)col;
{
    [[Storage sharedStorage] saveValue:col forKey:SETTINGS_COLLECTION];
}

- (MPMediaItemCollection*) getLastCollection;
{
    return [[Storage sharedStorage] getValueForKey:SETTINGS_COLLECTION];
}


- (void) setLastChunkSizeMinutes:(NSTimeInterval) minutes;
{
    [[Storage sharedStorage] saveValue:@(minutes) forKey:SETTINGS_CHUNK_SIZE];
}

- (NSTimeInterval) getLastChunkSizeInMinutes;
{
    NSNumber * n = [[Storage sharedStorage] getValueForKey:SETTINGS_CHUNK_SIZE defaultingTo:@(5)];
    return (NSTimeInterval)[n doubleValue];
}

- (void) setLastPlayedMediaItem:(MPMediaItem*)m;
{
    [[Storage sharedStorage] saveValue:m forKey:SETTINGS_LAST_MEDIA_ITEM];
}

- (MPMediaItem*) getLastPlayedMediaItem;
{
    return [[Storage sharedStorage] getValueForKey:SETTINGS_LAST_MEDIA_ITEM];
}

- (void) setLastPositionInMediaTime:(NSTimeInterval)secs;
{
    [[Storage sharedStorage] saveValue:@(secs) forKey:SETTINGS_LAST_PLAYED_LOC];
}

- (NSTimeInterval) getLastPositionInMediaTime;
{
    NSNumber * n = [[Storage sharedStorage] getValueForKey:SETTINGS_LAST_PLAYED_LOC];
    return (NSTimeInterval)[n doubleValue];
}


- (void) setNumberOfSectionsToPlay:(int)numSections;
{
    [[Storage sharedStorage] saveValue:@(numSections) forKey:SETTINGS_NUMBER_SECTIONS_BEFORE_BED];
}

- (int) getNumberOfSectionsToPlay;
{
    NSNumber * n = [[Storage sharedStorage] getValueForKey:SETTINGS_NUMBER_SECTIONS_BEFORE_BED  defaultingTo:@(1)];
    return (NSTimeInterval)[n integerValue];
}

- (void) addItemToPlayed:(PlayedItem*)playedItem;
{
    if (playedItem)
    {
        NSMutableDictionary * lasts = [[Storage sharedStorage] getValueForKey:SETTINGS_LAST_PLAYED  defaultingTo:[NSMutableDictionary dictionaryWithCapacity:1]];
        [lasts setObject:playedItem forKey:[MediaItemPropertyHelper nameForMedia:playedItem.mediaItem]];
        [[Storage sharedStorage] saveValue:lasts forKey:SETTINGS_LAST_PLAYED];
    }
}

- (PlayedItem*) getLastPlayedItem;
{
    NSArray * lastPlayedItems = [self lastPlayedItems];
    
    if ([lastPlayedItems count] > 0)
    {
        return lastPlayedItems.firstObject;
    }
    
    return nil;
}

- (NSArray*) lastPlayedItems;
{
    NSMutableDictionary * dict = [[Storage sharedStorage] getValueForKey:SETTINGS_LAST_PLAYED  defaultingTo:[NSMutableDictionary dictionaryWithCapacity:1]];
    
    NSArray * array = [dict allValues];
    
    if ([array count] > 1)
    {
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
        {
            PlayedItem * item = obj1;
            PlayedItem * secondItem = obj2;
            return [item.lastDate compare:secondItem.lastDate];
        }];
    }
    
    return array;
}

@end

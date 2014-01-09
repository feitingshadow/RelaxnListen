//
//  Settings.h
//  RelaxnListen
//
//  Created by Stephen on 12/29/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayedItem.h"

@interface Settings : NSObject

+ (Settings*) sharedSettings;

- (void) setLastCollection:(MPMediaItemCollection*)col;
- (MPMediaItemCollection*) getLastCollection;

- (void) setLastChunkSizeMinutes:(NSTimeInterval) minutes;
- (NSTimeInterval) getLastChunkSizeInMinutes;

- (void) setLastPlayedMediaItem:(MPMediaItem*)m;
- (MPMediaItem*) getLastPlayedMediaItem;

- (void) setLastPositionInMediaTime:(NSTimeInterval)secs;
- (NSTimeInterval) getLastPositionInMediaTime;

- (void) setNumberOfSectionsToPlay:(int)numSections;
- (int) getNumberOfSectionsToPlay;

- (void) addItemToPlayed:(PlayedItem*)playedItem;
- (PlayedItem*) getLastPlayedItem;
- (NSArray*) lastPlayedItems;

@end

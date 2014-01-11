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


- (void) setNumberOfSectionsToPlay:(int)numSections;
- (int) getNumberOfSectionsToPlay;

- (void) setLastPlayedItem:(PlayedItem*)m;
- (PlayedItem*) getLastPlayedItem;
- (NSArray*) lastPlayedItems;

@end

//
//  Constants.h
//  RelaxnListen
//
//  Created by Stephen on 12/29/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#ifndef RelaxnListen_Constants_h
#define RelaxnListen_Constants_h


#pragma mark - Time

#define SECS_PER_MIN 60
#define SEC_PER_HOUR 3600

#pragma mark - Settings Key Values

#define SETTINGS_CHUNK_SIZE @"chunksize"
#define SETTINGS_COLLECTION @"mpmediacollection"
#define SETTINGS_LAST_MEDIA_ITEM @"lastmediaitem"
#define SETTINGS_LAST_PLAYED_LOC @"AudiobookLocation"
#define SETTINGS_NUMBER_SECTIONS_BEFORE_BED @"beforebed"
#define SETTINGS_LAST_PLAYED @"lastPlayedItems"
#define SETTINGS_THEME @"app_theme"
#define SETTINGS_GO_BLACK @"go_dark_when_inactive"
#define SETTINGS_SHAKEPURPOSE @"shake_purpose"

enum shakepurpose {
    shakePurposeResetChunk = 0,
    shakePurposePauseAudioTrack //match the segmented
    //shakePurposeStopInfinitePlay //future feature
    };
//#define SHAKE_PURPOSE_RESET_CHUNK 1
//#define SHAKE_PURPOSE_HALT_INFINITE_PLAY 2

#endif

//
//  Settings.m
//  RelaxnListen
//
//  Created by Stephen on 12/28/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import "Settings.h"

#define DOCUMENTS_DICTIONARY_FILENAME @"documents"

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
    // Should never be called, but just here for clarity really.
}




@end

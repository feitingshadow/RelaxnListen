//
//  Settings.m
//  RelaxnListen
//
//  Created by Stephen on 12/28/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import "Storage.h"

#define DOCUMENTS_DICTIONARY_FILENAME @"documents"

@interface Storage()
{
    
}
@end

static NSString * documentPath;
static NSMutableDictionary * documentDict;


@implementation Storage

+ (Storage*)sharedStorage {
    static Storage * sharedStorage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStorage = [[self alloc] init];
    });
    return sharedStorage;
}

- (NSString*) documentsFullPath
{
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentPath = [directories lastObject];
    return [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",DOCUMENTS_DICTIONARY_FILENAME]] ;
}

- (id)init {
    if (self = [super init]) {
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [directories lastObject];
        
        documentDict = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithFile:[self documentsFullPath]];
        if (!documentDict) {
            documentDict = [NSMutableDictionary dictionary];
        }
        
    }
    [self save];
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}



- (void) saveValue:(id)value forKey:(NSString*)key;
{
    if (value)
    {
        [documentDict setObject:value forKey:key];
    }
}

- (id) valueForKey:(NSString*)key;
{
    return [documentDict objectForKey:key];
}

- (void) save
{
    [NSKeyedArchiver archiveRootObject:documentDict toFile:[self documentsFullPath]];
}


@end

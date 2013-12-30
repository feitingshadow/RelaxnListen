//
//  Settings.m
//  RelaxnListen
//
//  Created by Stephen on 12/28/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import "Storage.h"

#define DOCUMENTS_DICTIONARY_FILENAME @"documents"
#define LIBRARY_DICTIONARY_FILENAME @"library"

@interface Storage()
{
    
}
@end

static NSString * documentPath;
static NSString * libraryPath;
static NSMutableDictionary * documentDict;
static NSMutableDictionary * libraryDict;


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
    if(!documentPath)
    {
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentPath = [directories lastObject];
        documentPath =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",DOCUMENTS_DICTIONARY_FILENAME]] ;
    }
    return documentPath;
}

- (NSString*) libraryFullpath
{
    if (!libraryPath) {
        NSArray *directories = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        libraryPath = [directories lastObject];
        libraryPath =[documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",LIBRARY_DICTIONARY_FILENAME]] ;
    }
    return libraryPath;
}


- (id)init
{
    if (self = [super init])
    {
        [self hydrateDictionary:documentDict fromPath:[self documentsFullPath]];
        [self hydrateDictionary:libraryDict fromPath:[self libraryFullpath]];
    }
    [self save];
    return self;
}

- (void) hydrateDictionary:(NSMutableDictionary*)mutableDictionary fromPath:(NSString*)path;
{
    mutableDictionary = (NSMutableDictionary*)[NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (!mutableDictionary) {
        mutableDictionary = [NSMutableDictionary dictionary];
    }
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void) saveValue:(id)value forKey:(NSString*)key;
{
    if (value)
    {
        [libraryDict setObject:value forKey:key];
        [self save];
    }
}

- (id) getValueForKey:(NSString*)key;
{
   return [self getValueForKey:key defaultingTo:nil];
}

- (id) getValueForKey:(NSString *)key defaultingTo:(id)val;
{
    id object = [libraryDict objectForKey:key];
   
    if (object)
    {
        return object;
    }
    return val;
}
- (void) save
{
    if ([NSKeyedArchiver archiveRootObject:documentDict toFile:[self documentsFullPath]])
    {
        //TODO: Debug log an error (not NSLog)
       //couldn't save the documents dict
    }
    if ( ![NSKeyedArchiver archiveRootObject:libraryDict toFile:[self libraryFullpath]])
    {
       //couldn't save the dictionary
    }
}


@end

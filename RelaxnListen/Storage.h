//
//  Settings.h
//  RelaxnListen
//
//  Created by Stephen on 12/28/13.
//  Copyright (c) 2013 Stephen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Storage : NSObject

+ (Storage*) sharedStorage;

- (void) saveValue:(id)value forKey:(NSString*)key;
- (id) getValueForKey:(NSString *)key defaultingTo:(id)val;
- (id) getValueForKey:(NSString*)key;

@end

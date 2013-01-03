//
//  NSUserDefaults+BMAdditions.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/2/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "NSUserDefaults+BMAdditions.h"

static NSString *const BMPinListStore = @"bm_pinListStore";

@implementation NSUserDefaults (BMAdditions)

/*
 * Retrieves the stored datasource (list of pins)
 */
- (NSArray *)bm_pinList {
    NSArray *pins = [self objectForKey:BMPinListStore];
    if (!pins) {
        pins = [[[NSArray alloc] init] autorelease];
    }
    return pins;
}

/*
 * Stores a datasource
 */
- (void)bm_setPinList:(NSArray *)bm_pinList {
    [self setObject:bm_pinList forKey:BMPinListStore];
    [self synchronize];
}


@end

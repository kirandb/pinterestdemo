//
//  NSUserDefaults+BMAdditions.h
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/2/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (BMAdditions)

@property (assign, getter = bm_pinList, setter=bm_setPinList:) NSArray *bm_pinList;

@end

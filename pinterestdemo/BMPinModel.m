//
//  BMPinModel.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMPinModel.h"
#import "NSUserDefaults+BMAdditions.h"

@implementation BMPinModel

+ (NSArray *)images {
    return @[
        @{@"name": @"550x/9c/0f/e1/9c0fe176ef1f226b24731eb146a3dbac", @"size": @[@406, @550]},
        @{@"name": @"550x/d6/ac/9a/d6ac9a1527726b66a6bf09de58a0bd4d", @"size": @[@550, @366]},
        @{@"name": @"550x/e1/88/c6/e188c6f590a8efec480a89aa43a0fcc5", @"size": @[@525, @700]},
        @{@"name": @"550x/df/16/14/df1614ff36e7a2e8074edc289f183079", @"size": @[@550, @404]},
        @{@"name": @"550x/35/c8/c3/35c8c38bc204c5a4b120e860b00931e6", @"size": @[@434, @531]},
        @{@"name": @"550x/77/cc/a6/77cca60231114f05314c985f1a837f78", @"size": @[@428, @640]},
        @{@"name": @"550x/06/20/90/0620905d435affd71631d65d83e258ae", @"size": @[@504, @662]},
        @{@"name": @"550x/72/0a/db/720adb486511f15ebbd709e56bb5e78c", @"size": @[@550, @550]},
        @{@"name": @"550x/fa/47/7a/fa477a4ecb40aabebb0e4ec1f68c235a", @"size": @[@497, @373]},
        @{@"name": @"550x/d9/f9/59/d9f95927b520d97315e06d318a8d9aad", @"size": @[@500, @750]},
        @{@"name": @"550x/a9/43/e1/a943e14e62ee54a80304c522d13c3c32", @"size": @[@500, @699]},
        @{@"name": @"550x/da/cf/c2/dacfc26accb61c9bcb38ccd8385a606a", @"size": @[@550, @779]},
        @{@"name": @"550x/1f/e3/bf/1fe3bfb69634587faecdf7491d897692", @"size": @[@550, @825]},
        @{@"name": @"550x/9a/8a/51/9a8a51e1ecc2c671169b4ddfc6412cca", @"size": @[@477, @690]},
        @{@"name": @"550x/56/b5/cf/56b5cf7705c32b711ad4098185a1a8a2", @"size": @[@426, @640]},
        @{@"name": @"550x/bb/83/39/bb83391215023c097a39d25394f53e10", @"size": @[@300, @400]},
        @{@"name": @"550x/10/90/9e/10909e8be81baa477803eb37b26a2576", @"size": @[@500, @750]},
        @{@"name": @"550x/ac/35/70/ac3570ec141074f7ab1f1ef03e385082", @"size": @[@550, @803]}
    ];
}

/*  
 * Fetches a list of pin images.
 */
+ (NSArray *)pinImages {
    // Load pins 5x times so we have more images to play with
    NSUInteger multiplier = 5;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[[BMPinModel images] count] * multiplier];
    for (int i = 0; i < multiplier; i++) {
        [tempArray addObjectsFromArray:[[self class] images]];
    }
    return [NSArray arrayWithArray:tempArray];
}

/*
 * Retrieves a list of pin images from NSUserDefaults if it exists.
 * Fetches a new list otherwise.
 */
+ (NSArray *)storedPinImageList {
    NSArray *imageList = [[NSUserDefaults standardUserDefaults] bm_pinList];
    if ([imageList count] == 0) {
        imageList = [[self class] pinImages];
    }
    
    return imageList;
}

/*
 * Store a list of pin images in NSUserDefaults.
 */
+ (void)storePinImageList:(NSArray *)imageList {
    [[NSUserDefaults standardUserDefaults] bm_setPinList:imageList];
}

@end

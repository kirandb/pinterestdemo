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

+ (NSArray *)imageNames {
    return @[
        @"79305643407717031_P5J405yj_f",
        @"122160208612042730_OE9aUKYX_f",
        @"114278909264174511_VKYTKXy0_f",
        @"31666003599584379_Zo93yIid_f",
        @"178173728977437036_GR34TUwr_f",
        @"77124212338354441_f9msUaNw_f",
        @"110901209543642135_0QAzyYCU_f",
        @"72620612710996219_fwuZKUp1_f",
        @"258323728595690846_IO4w7Mgq_f",
        @"200902833346890886_2KUk9BSk_f",
        @"239605642644595710_hgOTCxCE_f",
        @"141370875772580768_on1oxkNW_f",
        @"145311525446514865_gic8YmUs_f",
        @"194499277626738995_JxR3R9NC_f",
        @"235453886738123596_vH1kSHO3_f",
        @"100486635405347983_eg7uBs6c_f",
        @"249809110550356714_E4d673hy_f",
        @"153826143492035874_p9DBATmW_f"
    ];
}

/*
 * Fetches a list of pin images.
 */
+ (NSArray *)pinImageList {
    // Load pins 5x times so we have more images to play with
    NSUInteger multiplier = 5;
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:[[BMPinModel imageNames] count] * multiplier];
    for (int i = 0; i < multiplier; i++) {
        [tempArray addObjectsFromArray:[[self class] imageNames]];
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
        imageList = [[self class] pinImageList];
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

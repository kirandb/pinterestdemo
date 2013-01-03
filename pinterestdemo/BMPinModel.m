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
        @{@"name": @"79305643407717031_P5J405yj_f", @"size": @[@300, @300]},
        @{@"name": @"122160208612042730_OE9aUKYX_f", @"size": @[@420, @420]},
        @{@"name": @"114278909264174511_VKYTKXy0_f", @"size": @[@400, @300]},
        @{@"name": @"31666003599584379_Zo93yIid_f", @"size": @[@300, @296]},
        @{@"name": @"178173728977437036_GR34TUwr_f", @"size": @[@448, @600]},
        @{@"name": @"77124212338354441_f9msUaNw_f", @"size": @[@500, @333]},
        @{@"name": @"110901209543642135_0QAzyYCU_f", @"size": @[@400, @600]},
        @{@"name": @"72620612710996219_fwuZKUp1_f", @"size": @[@500, @624]},
        @{@"name": @"258323728595690846_IO4w7Mgq_f", @"size": @[@501, @750]},
        @{@"name": @"200902833346890886_2KUk9BSk_f", @"size": @[@586, @880]},
        @{@"name": @"239605642644595710_hgOTCxCE_f", @"size": @[@450, @600]},
        @{@"name": @"141370875772580768_on1oxkNW_f", @"size": @[@499, @499]},
        @{@"name": @"145311525446514865_gic8YmUs_f", @"size": @[@500, @333]},
        @{@"name": @"194499277626738995_JxR3R9NC_f", @"size": @[@600, @265]},
        @{@"name": @"235453886738123596_vH1kSHO3_f", @"size": @[@397, @600]},
        @{@"name": @"100486635405347983_eg7uBs6c_f", @"size": @[@300, @250]},
        @{@"name": @"249809110550356714_E4d673hy_f", @"size": @[@300, @448]},
        @{@"name": @"153826143492035874_p9DBATmW_f", @"size": @[@600, @486]}
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

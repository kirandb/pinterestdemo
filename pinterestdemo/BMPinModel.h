//
//  BMPinModel.h
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMPinModel : NSObject

+ (NSArray *)pinImages;
+ (NSArray *)storedPinImageList;
+ (void)storePinImageList:(NSArray *)imageList;

@end

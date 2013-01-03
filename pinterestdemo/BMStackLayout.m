//
//  BMStackLayout.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/2/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMStackLayout.h"

@implementation BMStackLayout

- (id)init {
    self = [super init];
    if (self) {
        self.itemSize = [UIScreen mainScreen].bounds.size;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

@end

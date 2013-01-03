//
//  BMStackLayout.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/3/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMStackLayout.h"
#import "helpers.h"

@implementation BMStackLayout

- (id)init {
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f);
        self.minimumLineSpacing = 1000.f;
        self.minimumInteritemSpacing = 100.f;
    }
    
    return self;
}

/*
 * Softly "Snap" to the center of an image during scrolling.
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.f);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.f, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end

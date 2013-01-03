//
//  BMScrollLayout.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/2/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMScrollLayout.h"

@implementation BMScrollLayout

- (id)init {
    self = [super init];
    if (self) {
        self.itemSize = [UIScreen mainScreen].bounds.size;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.minimumLineSpacing = 50.f;
    }
    
    return self;
}


/*
 * Softly "Snap" to the center of an image during scrolling.
 */
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat verticalCenter = proposedContentOffset.y + (CGRectGetHeight(self.collectionView.bounds) / 2.f);
    
    CGRect targetRect = CGRectMake(0.f, proposedContentOffset.y, self.collectionView.bounds.size.height, self.collectionView.bounds.size.width);
    NSArray *array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes *layoutAttributes in array) {
        CGFloat itemVerticalCenter = layoutAttributes.center.y;
        if (ABS(itemVerticalCenter - verticalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemVerticalCenter - verticalCenter;
        }
    }
    
    return CGPointMake(proposedContentOffset.x, proposedContentOffset.y + offsetAdjustment);
}

@end

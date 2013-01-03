//
//  BMProperStackLayout.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/3/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMProperStackLayout.h"
#import "helpers.h"

@interface BMProperStackLayout ()
- (void)applyTransformToLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes;
@end

@implementation BMProperStackLayout

- (id)initWithRect:(CGRect)viewRect {
    self = [super init];
    if (self) {
        self.viewRect = viewRect;
    }
    
    return self;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    [self applyTransformToLayoutAttributes:attributes];
    return attributes;
}


- (CGSize)collectionViewContentSize {
    return self.viewRect.size;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray* attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    
    // Calculate the new position of each cell based on stackFactor and stackCenter
    for (UICollectionViewLayoutAttributes *attributes in attributesArray) {
        [self applyTransformToLayoutAttributes:attributes];
    }
    
    return attributesArray;
}

- (void)applyTransformToLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes {
    CGSize size = self.viewRect.size;
    CGPoint stackCenter = CGPointMake(size.width / 2.f, size.height / 2.f);

    double rnd = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat xPosition = stackCenter.x + (attributes.center.x - stackCenter.x) * rnd * 0.2;
    CGFloat yPosition = stackCenter.y + (attributes.center.y - stackCenter.y) * rnd * 0.2;
    
    attributes.center = CGPointMake(xPosition, yPosition);
    CGFloat angle = 2 * M_PI * (rnd - 0.5) * 0.1;
    CATransform3D rotation = CATransform3DMakeRotation(angle, 0.f, 0.f, 1.f);
    
    // We need an extra translation to preserve the zIndex (iOS bug): http://stackoverflow.com/questions/12659301/uicollectionview-setlayoutanimated-not-preserving-zindex
    CATransform3D translation = CATransform3DMakeTranslation(0, 0, 1000 - attributes.indexPath.item);
    attributes.transform3D = CATransform3DConcat(rotation, translation);
    
    if (attributes.indexPath.item == 0) {
        attributes.alpha = 1.f;
    } else {
        attributes.alpha = 0.5;
    }
    
    attributes.zIndex = 1000 - attributes.indexPath.item;
}

@end

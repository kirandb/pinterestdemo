//
//  BMGridLayout.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMGridLayout.h"
#import "QuartzCore/QuartzCore.h"

#define EDGE_INSET 15.f

@interface BMGridLayout ()

@property (nonatomic, assign) CGFloat interItemSpacing;
@property (nonatomic, assign) NSUInteger itemCount;
@property (nonatomic, assign) UIEdgeInsets sectionInset;
@property (nonatomic, retain) NSMutableArray *layoutAttributes;
@property (nonatomic, retain) NSMutableArray *columnHeights;

- (NSUInteger)shortestColumnIndex;
- (NSUInteger)longestColumnIndex;

- (void)applyLongPressToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;
- (void)applyPinchToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;

@end


@implementation BMGridLayout

#pragma mark - Memory management

- (id)initWithColumnWidth:(NSUInteger)columnWidth {
    self = [super init];
    if (self) {
        // Sensible defaults
        self.sectionInset = UIEdgeInsetsMake(EDGE_INSET, EDGE_INSET, EDGE_INSET, EDGE_INSET);
        
        self.columnWidth = columnWidth;
    }
    
    return self;
}

- (void)dealloc {
    [_layoutAttributes release];
    [_columnHeights release];
    [_pressedCellPath release];
    [_activeCellView release];
    [_selectedIndexPaths release];
    [_randomFloats release];
    
    [super dealloc];
}

#pragma mark - Required UICollectionView overrides

- (void)prepareLayout {
    [super prepareLayout];
    
    NSUInteger columnCount = self.collectionView.bounds.size.width / self.columnWidth;
    _itemCount = [[self collectionView] numberOfItemsInSection:0];
    
    CGFloat width = self.collectionView.frame.size.width - _sectionInset.left - _sectionInset.right;
    _interItemSpacing = floorf((width - columnCount * _columnWidth) / (columnCount - 1));
    
    self.layoutAttributes = [NSMutableArray arrayWithCapacity:_itemCount];
    self.columnHeights = [NSMutableArray arrayWithCapacity:columnCount];
    for (NSInteger idx = 0; idx < columnCount; idx++) {
        [_columnHeights addObject:@(_sectionInset.top)];
    }
    
    // Item will be put into shortest column.
    for (NSInteger idx = 0; idx < _itemCount; idx++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
        id<BMGridLayoutDelegate> delegate = (id<BMGridLayoutDelegate>)self.collectionView.delegate;
        CGFloat itemHeight = [delegate collectionView:self.collectionView
                                               layout:self
                             heightForItemAtIndexPath:indexPath];
        NSUInteger columnIndex = [self shortestColumnIndex];
        CGFloat xOffset = _sectionInset.left + (_columnWidth + _interItemSpacing) * columnIndex;
        CGFloat yOffset = [(_columnHeights[columnIndex]) floatValue];
        CGPoint itemCenter = CGPointMake(floorf(xOffset + _columnWidth/2), floorf((yOffset + itemHeight/2)));
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.size = CGSizeMake(self.columnWidth, itemHeight);
        attributes.center = itemCenter;
        [_layoutAttributes addObject:attributes];
        _columnHeights[columnIndex] = @(yOffset + itemHeight + _interItemSpacing);
    }

}

- (CGSize)collectionViewContentSize {
    if (self.itemCount == 0) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.collectionView.frame.size;
    NSUInteger columnIndex = [self longestColumnIndex];
    CGFloat height = [self.columnHeights[columnIndex] floatValue];
    contentSize.height = height - self.interItemSpacing + self.sectionInset.bottom;
    return contentSize;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = self.layoutAttributes[indexPath.item];
    [self applyLongPressToLayoutAttributes:attributes];
    [self applyPinchToLayoutAttributes:attributes];
    return attributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    // Return the layoutAttributes for the objects within rect.
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return CGRectIntersectsRect([evaluatedObject frame], rect);
    }];

    NSArray *filteredAttributes = [self.layoutAttributes filteredArrayUsingPredicate:predicate];
    
    for (UICollectionViewLayoutAttributes *cellAttributes in filteredAttributes) {
        [self applyLongPressToLayoutAttributes:cellAttributes];
        [self applyPinchToLayoutAttributes:cellAttributes];
    }
    
    return filteredAttributes;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}
    
#pragma mark - Helper methods

// Find out shortest column.
- (NSUInteger)shortestColumnIndex {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

// Find out longest column.
- (NSUInteger)longestColumnIndex {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}


#pragma mark - Long Press touch methods

- (void)applyLongPressToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {

    if ([layoutAttributes.indexPath isEqual:self.pressedCellPath]) {
        layoutAttributes.hidden = YES;
        self.activeCellView.center = self.pressedCellCenter;
    }
}

- (void)invalidateLayoutIfNecessary {
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:self.activeCellView.center];
    
    if ((![selectedIndexPath isEqual:self.pressedCellPath]) && (selectedIndexPath)) {
        NSIndexPath *previousIndexPath = self.pressedCellPath;
        
        id<BMGridLayoutDelegate> delegate = (id<BMGridLayoutDelegate>)self.collectionView.delegate;
        [delegate collectionView:self.collectionView
                          layout:self
           moveItemFromIndexPath:previousIndexPath
                     toIndexPath:selectedIndexPath];
        
        [self.collectionView moveItemAtIndexPath:previousIndexPath
                                     toIndexPath:selectedIndexPath];
        
        self.pressedCellPath = selectedIndexPath;
    }
}
         
- (void)setPressedCellCenter:(CGPoint)pressedCellCenter {
    _pressedCellCenter = pressedCellCenter;
    [self invalidateLayout];
}

#pragma mark - Pinch touch methods

- (void)applyPinchToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // Apply pinch animation if we have at least 1 selected cell
    if (self.selectedIndexPaths.count) {
        CGSize size = self.collectionView.bounds.size;
        CGFloat heightOffset = self.collectionView.bounds.origin.y;
        CGPoint stackCenter = CGPointMake(size.width / 2.f, size.height / 2.f + heightOffset);

        if ([self.selectedIndexPaths containsObject:layoutAttributes.indexPath]) {
            
            CGFloat xPosition = stackCenter.x + (layoutAttributes.center.x - stackCenter.x) * self.pinchedCellScale;
            CGFloat yPosition = stackCenter.y + (layoutAttributes.center.y - stackCenter.y) * self.pinchedCellScale;
            
            layoutAttributes.center = CGPointMake(xPosition, yPosition);
            CGFloat angle = 2 * M_PI * 0.2 * ([(NSNumber *)[self.randomFloats objectAtIndex:layoutAttributes.indexPath.item] floatValue] - 0.5) * (1 - self.pinchedCellScale);
            CATransform3D rotation = CATransform3DMakeRotation(angle, 0.f, 0.f, 1.f);
            
            // We need an extra translation to preserve the zIndex (iOS bug): http://stackoverflow.com/questions/12659301/uicollectionview-setlayoutanimated-not-preserving-zindex
            CATransform3D translation = CATransform3DMakeTranslation(0, 0, 1000 - layoutAttributes.indexPath.item);
            layoutAttributes.transform3D = CATransform3DConcat(rotation, translation);
            
            if ([layoutAttributes.indexPath isEqual:[self.selectedIndexPaths objectAtIndex:0]]) {
                layoutAttributes.alpha = 1.f;
            } else {
                layoutAttributes.alpha = 1 - (0.5 * (1 - self.pinchedCellScale));
            }
            
            layoutAttributes.zIndex = 1000 - layoutAttributes.indexPath.item;
            
        } else {
            layoutAttributes.alpha = self.pinchedCellScale;
            
            CGFloat xPosition = layoutAttributes.center.x + (layoutAttributes.center.x - stackCenter.x) * (1 - self.pinchedCellScale);
            CGFloat yPosition = layoutAttributes.center.y + (layoutAttributes.center.y - stackCenter.y) * (1 - self.pinchedCellScale);

            layoutAttributes.center = CGPointMake(xPosition, yPosition);
        }
    }
}

- (void)setPinchedCellScale:(CGFloat)pinchedCellScale {
    _pinchedCellScale = pinchedCellScale;
    [self invalidateLayout];
}

@end

//
//  BMGridLayout.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMGridLayout.h"
#import "QuartzCore/QuartzCore.h"

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
        self.numberOfColumns = 3;
        self.columnWidth = 140.f;
        self.sectionInset = UIEdgeInsetsMake(9.f, 9.f, 9.f, 9.f);
        
        self.columnWidth = columnWidth;
    }
    
    return self;
}

- (void)dealloc {
    [_layoutAttributes release];
    [_columnHeights release];
    [_pressedCellPath release];
    [_pinchedCellPath release];
    [_activeCellView release];
    
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
//        layoutAttributes.center = self.pressedCellCenter;
//        layoutAttributes.zIndex = 1;
        
//        id<BMGridLayoutDelegate> delegate = (id<BMGridLayoutDelegate>)self.collectionView.delegate;
        
//        NSLog(@"To index path: %@", toIndexPath);
//        [delegate collectionView:self.collectionView
//                          layout:self
//           moveItemFromIndexPath:layoutAttributes.indexPath
//                     toIndexPath:toIndexPath];

        
//        [self.collectionView performBatchUpdates:^{
//            [self.collectionView deleteItemsAtIndexPaths:@[layoutAttributes.indexPath]];
//            [self.collectionView insertItemsAtIndexPaths:@[toIndexPath]];
//        } completion:^(BOOL finished) {
//            // Pass
//        }];
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
    
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[previousIndexPath]];
            [self.collectionView insertItemsAtIndexPaths:@[selectedIndexPath]];
        } completion:^(BOOL finished) {
            // Pass
        }];
        
        self.pressedCellPath = selectedIndexPath;
    }
}
         
- (void)setPressedCellCenter:(CGPoint)pressedCellCenter {
    _pressedCellCenter = pressedCellCenter;
    [self invalidateLayout];
}

#pragma mark - Pinch touch methods

- (void)applyPinchToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    if ([layoutAttributes.indexPath isEqual:self.pinchedCellPath]) {
        layoutAttributes.transform3D = CATransform3DMakeScale(self.pinchedCellScale, self.pinchedCellScale, 1.0);
        layoutAttributes.center = self.pinchedCellCenter;
        layoutAttributes.zIndex = 1;
    }
}

- (void)setPinchedCellScale:(CGFloat)pinchedCellScale {
    _pinchedCellScale = pinchedCellScale;
    [self invalidateLayout];
}

- (void)setPinchedCellCenter:(CGPoint)pinchedCellCenter {
    _pinchedCellCenter = pinchedCellCenter;
    [self invalidateLayout];
}

@end

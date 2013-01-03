//
//  BMGridLayout.h
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BMGridLayoutDelegate <UICollectionViewDelegate>

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;
@end


@interface BMGridLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat columnWidth;
@property (nonatomic, assign) NSUInteger numberOfColumns;

// Long press ivars
@property (nonatomic, retain) NSIndexPath *pressedCellPath;
@property (nonatomic, assign) CGPoint pressedCellCenter;
@property (nonatomic, retain) UIView *activeCellView;

@property (nonatomic, retain) NSIndexPath *pinchedCellPath;
@property (nonatomic, assign) CGFloat pinchedCellScale;
@property (nonatomic, assign) CGPoint pinchedCellCenter;

- (void)applyLongPressToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;
- (void)applyPinchToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;

- (id)initWithColumnWidth:(NSUInteger)columnWidth;

- (void)invalidateLayoutIfNecessary;

@end
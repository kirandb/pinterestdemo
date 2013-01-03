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

// Long press ivars
@property (nonatomic, retain) NSIndexPath *pressedCellPath;
@property (nonatomic, assign) CGPoint pressedCellCenter;
@property (nonatomic, retain) UIView *activeCellView;

@property (nonatomic, retain) NSIndexPath *pinchedCellPath1;
@property (nonatomic, retain) NSIndexPath *pinchedCellPath2;
@property (nonatomic, assign) CGPoint pinchedCellCenter1;
@property (nonatomic, assign) CGPoint pinchedCellCenter2;
@property (nonatomic, assign) CGFloat pinchedCellScale;

- (void)applyLongPressToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;
- (void)applyPinchToLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes;

- (id)initWithColumnWidth:(NSUInteger)columnWidth;

- (void)invalidateLayoutIfNecessary;

@end
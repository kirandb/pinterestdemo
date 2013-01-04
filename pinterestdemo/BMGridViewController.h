//
//  BMGridViewController.h
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMGridLayout.h"

@interface BMGridViewController : UIViewController <UICollectionViewDataSource, BMGridLayoutDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) BMGridLayout *gridLayout;

@end

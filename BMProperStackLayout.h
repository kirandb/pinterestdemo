//
//  BMProperStackLayout.h
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/3/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMProperStackLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGRect viewRect;

- (id)initWithRect:(CGRect)viewRect;

@end

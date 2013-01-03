//
//  BMGridCell.h
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IMAGE_INSET 15.f

@interface BMGridCell : UICollectionViewCell

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIView *backView;

- (void)setText:(NSString *)text;
- (void)setImage:(NSString *)imageName;

@end

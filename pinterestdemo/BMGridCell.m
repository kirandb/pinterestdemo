//
//  BMGridCell.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMGridCell.h"

#define LABEL_TAG 2
#define COLUMN_WIDTH 130.f

@implementation BMGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.725490 green:0.729412 blue:0.772549 alpha:1];
    
        _imageView = [[UIImageView alloc] initWithFrame:frame];
        [self.contentView addSubview:_imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 25.f)];
        label.tag = LABEL_TAG;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        [label release];
    }
    return self;
}

- (void)dealloc {
    [_imageView release];
    
    [super dealloc];
}

- (void)setText:(NSString *)text {
    UILabel *label = (UILabel *)[self viewWithTag:LABEL_TAG];
    label.text = text;
}

- (void)setImage:(NSString *)imageName {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
    [self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    self.imageView.frame = CGRectMake(0.f, 0.f, layoutAttributes.size.width, layoutAttributes.size.height);
}

- (void)prepareForReuse {
    [self.imageView setImage:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

//
//  BMGridCell.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMGridCell.h"
#import "helpers.h"

#define LABEL_TAG 2
#define COLUMN_WIDTH 130.f

@implementation BMGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.9333f alpha:1.0f];
    
        // Background view
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.backgroundColor = UIColorFromRGB(0xcec6cd);
        [self.contentView addSubview:_backView];
        
        // Main image view
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_imageView];
        
        // Label for debugging purposes (tracks indexPath)
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 100.f, 25.f)];
        label.tag = LABEL_TAG;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
//        [self.contentView addSubview:label];
        [label release];
    }
    return self;
}

- (void)dealloc {
    [_imageView release];
    [_backView release];
    
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
    CGRect imageFrame = CGRectMake(IMAGE_INSET, IMAGE_INSET, layoutAttributes.size.width - 2 * IMAGE_INSET, layoutAttributes.size.height - 2 * IMAGE_INSET);
    self.imageView.frame = imageFrame;
    
    CGFloat o = 1.f;
    CGRect backViewFrame = CGRectMake(IMAGE_INSET - o, IMAGE_INSET - o, layoutAttributes.size.width - (2 * (IMAGE_INSET - o)), layoutAttributes.size.height - (2 * (IMAGE_INSET - o)));
    self.backView.frame = backViewFrame;
}

- (void)prepareForReuse {
    [self.imageView setImage:nil];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.imageView.alpha = highlighted ? 0.70f : 1.f;
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

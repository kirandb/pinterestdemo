//
//  BMGridCell.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMGridCell.h"
#import "helpers.h"
#import "UIImageView+AFNetworking.h"

#define ACTIVITYINDICATORVIEW_TAG 1
#define LABEL_TAG 2
#define COLUMN_WIDTH 130.f
#define BACKCOLOR_WHITE 0.9333f
#define FADEIN_DURATION 0.3f

//#define USE_DEBUG_LABEL

@implementation BMGridCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:BACKCOLOR_WHITE alpha:1.0f];
    
        // Background view
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.backgroundColor = UIColorFromRGB(0xcec6cd);
        [self.contentView addSubview:_backView];
        
        // Activity indicator (image loading progress)
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicatorView.tag = ACTIVITYINDICATORVIEW_TAG;
        activityIndicatorView.hidesWhenStopped = YES;
        CGRect activityIndicatorFrame = activityIndicatorView.frame;
        CGFloat activityIndicatorViewOffsetX = (frame.size.width - activityIndicatorFrame.size.width) / 2.f;
        CGFloat activityIndicatorViewOffsetY = (frame.size.height - activityIndicatorFrame.size.width) / 2.f;
        activityIndicatorFrame.origin = CGPointMake(activityIndicatorViewOffsetX, activityIndicatorViewOffsetY);
        activityIndicatorView.frame = activityIndicatorFrame;
        [self.contentView addSubview:activityIndicatorView];
        [activityIndicatorView release];
        
        // Main image view
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_imageView];
        
        // Label for debugging purposes (tracks indexPath)
        #ifdef USE_DEBUG_LABEL
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, frame.size.width, frame.size.height)];
        label.tag = LABEL_TAG;
        label.textColor = [UIColor redColor];
        label.font = [UIFont boldSystemFontOfSize:48.f];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        [label release];
        #endif
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
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
//    [self.imageView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    
    NSURL *url = [NSURL URLWithString:[[kImageBaseURL stringByAppendingString:imageName] stringByAppendingPathExtension:@"jpg"]];
    
    // Manually create a NSURLRequest so we have pass in a image-loaded completion block to fade-in the loaded image and  stop the activityIndicator.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.f];
    [request setHTTPShouldHandleCookies:NO];
    [request setHTTPShouldUsePipelining:YES];
    
    // Start the activity progress indicator
    UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView *)[self.contentView viewWithTag:ACTIVITYINDICATORVIEW_TAG];
    [activityIndicatorView startAnimating];

    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        [self.imageView setImage:image];
        // If the response is nil, the image comes from the cache.
        // In this case we don't want to fade-in the image, but show it immediately instread.
        if (response == nil) {
            self.imageView.alpha = 1.0f;
        } else {
            [UIView animateWithDuration:FADEIN_DURATION animations:^{
                self.imageView.alpha = 1.0f;
            }];
        }
        [activityIndicatorView stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [activityIndicatorView stopAnimating];
    }];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    // Layout image
    CGRect imageFrame = CGRectMake(IMAGE_INSET, IMAGE_INSET, layoutAttributes.size.width - 2 * IMAGE_INSET, layoutAttributes.size.height - 2 * IMAGE_INSET);
    self.imageView.frame = imageFrame;
    
    // Layout backView
    CGFloat o = 1.f;
    CGRect backViewFrame = CGRectMake(IMAGE_INSET - o, IMAGE_INSET - o, layoutAttributes.size.width - (2 * (IMAGE_INSET - o)), layoutAttributes.size.height - (2 * (IMAGE_INSET - o)));
    self.backView.frame = backViewFrame;
    
    // Layout activityIndicator (if visible)
    UIView *activityIndicatorView = (UIActivityIndicatorView *)[self viewWithTag:ACTIVITYINDICATORVIEW_TAG];
    if (!activityIndicatorView.isHidden) {
        CGRect activityIndicatorFrame = activityIndicatorView.frame;
        CGFloat activityIndicatorViewOffsetX = (layoutAttributes.size.width - activityIndicatorFrame.size.width) / 2.f;
        CGFloat activityIndicatorViewOffsetY = (layoutAttributes.size.height - activityIndicatorFrame.size.width) / 2.f;
        activityIndicatorFrame.origin = CGPointMake(activityIndicatorViewOffsetX, activityIndicatorViewOffsetY);
        activityIndicatorView.frame = activityIndicatorFrame;
    }
    
    // Layout debugging label
    #ifdef USE_DEBUG_LABEL
    UILabel *label = (UILabel *)[self viewWithTag:LABEL_TAG];
    label.frame = CGRectMake(0.f, 0.f, layoutAttributes.size.width, layoutAttributes.size.height);
    #endif
}

- (void)prepareForReuse {
    [self.imageView setImage:nil];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    self.imageView.alpha = highlighted ? 0.70f : 1.f;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    UIColor *selectedColor = [UIColor colorWithWhite:0.5f alpha:1.f];
    self.backgroundColor = selected ? selectedColor : [UIColor colorWithWhite:BACKCOLOR_WHITE alpha:1.f];
    self.alpha = selected ? 0.7f : 1.f;
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

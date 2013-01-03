//
//  UIImage+ImageWithColor.h
//  Tiny Post
//
//  Created by Dick Brouwer on 5/25/12.
//  Copyright (c) 2012 Beeem Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end

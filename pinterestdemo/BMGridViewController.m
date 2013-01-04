//
//  BMGridViewController.m
//  pinterestdemo
//
//  Created by Dick Brouwer on 1/1/13.
//  Copyright (c) 2013 Beeem Inc. All rights reserved.
//

#import "BMGridViewController.h"
#import "BMGridCell.h"
#import "BMPinModel.h"
#import "BMScrollLayout.h"
#import "BMHorizontalScrollLayout.h"
#import "helpers.h"
#import <ImageIO/ImageIO.h> 
#import <QuartzCore/QuartzCore.h>

#define GRID_COLUMN_WIDTH 235.f

static NSString *const BMGRID_CELL_ID = @"BMGridCellID";

@interface BMGridViewController ()
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gr;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gr;
@end

@implementation BMGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [_dataArray release];
    [_collectionView release];
    [_gridLayout release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    // Create collection view layout
    _gridLayout = [[BMGridLayout alloc] initWithColumnWidth:GRID_COLUMN_WIDTH];
    
    // Create collection view
    CGRect screen = [[UIScreen mainScreen] applicationFrame];
    _collectionView = [[UICollectionView alloc] initWithFrame:screen collectionViewLayout:_gridLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];

    [_collectionView registerClass:[BMGridCell class] forCellWithReuseIdentifier:BMGRID_CELL_ID];
                       
    self.view = _collectionView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set navigation title
    self.navigationItem.title = @"Pinterest Grid Demo";
    
    // Add gesture recognizers
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    // IMPORTANT: we need to make the default gesture recognizer wait until our own custom gesture recognizer fails (UICollectionView has a built-in longPressGestureRecognizer used for scrolling).
    for (UIGestureRecognizer *gr in self.collectionView.gestureRecognizers) {
        if ([gr isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gr requireGestureRecognizerToFail:longPressGestureRecognizer];
        }
    }
    [self.view addGestureRecognizer:longPressGestureRecognizer];
    [longPressGestureRecognizer release];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    [pinchGestureRecognizer release];
    
//    self.dataArray = [BMPinModel storedPinImageList];
    self.dataArray = [BMPinModel pinImages];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BMGridLayout delegate/datasource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     * OLD CODE -- used for static images; we switch to dynamic images from a URL.
     */
    //    NSString *imageName = [self.dataArray objectAtIndex:indexPath.item];
    //    NSURL *imageFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"]];
    //    CGFloat width = 0.f;
    //    CGFloat height = 0.f;
    //    
    //    // Get the image dimensions without loading the image into memory
    //    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    //    if (imageSource == NULL) { // Error loading image ...
    //        NSLog(@"Error loading image at URL: %@", imageFileURL);
    //        return height;
    //    }
    //    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    //    
    //    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
    //    if (imageProperties) {
    //        width = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) floatValue];
    //        height = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight) floatValue];
    //        CFRelease(imageProperties);
    //    }
    //    CFRelease(imageSource);
    
    NSArray *imageSize = [[self.dataArray objectAtIndex:indexPath.item] objectForKey:@"size"];
    CGFloat width = [[imageSize objectAtIndex:0] floatValue];
    CGFloat height = [[imageSize objectAtIndex:1] floatValue];

    // Return the image height scaled by the column width to maintain the correct aspect ratio.
    return height * GRID_COLUMN_WIDTH / width;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BMGridCell *cell = (BMGridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:BMGRID_CELL_ID forIndexPath:indexPath];

    [cell setImage:[[self.dataArray objectAtIndex:indexPath.item] objectForKey:@"name"]];
    cell.text = [NSString stringWithFormat:@"%i %i", indexPath.section, indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout moveItemFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    id fromItem = [self.dataArray objectAtIndex:fromIndexPath.item];
    NSMutableArray *data = [self.dataArray mutableCopy];
    [data removeObjectAtIndex:fromIndexPath.item];
    [data insertObject:fromItem atIndex:toIndexPath.item];
    self.dataArray = [NSArray arrayWithArray:data];
    [data release];
}

#pragma mark - UICollectionViewFlowLayout delegate handlers

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    /*
     * OLD CODE -- used for static images; we switch to dynamic images from a URL.
     */
    //    NSString *imageName = [self.dataArray objectAtIndex:indexPath.item];
    //    NSURL *imageFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"]];
    //    CGFloat width = 0.f;
    //    CGFloat height = 0.f;
    //    
    //    // Get the image dimensions without loading the image into memory
    //    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    //    if (imageSource == NULL) { // Error loading image ...
    //        NSLog(@"Error loading image at URL: %@", imageFileURL);
    //        return CGSizeMake(0.f, 0.f);
    //    }
    //    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    //    
    //    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
    //    if (imageProperties) {
    //        width = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) floatValue];
    //        height = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight) floatValue];
    //        CFRelease(imageProperties);
    //    }
    //    CFRelease(imageSource);
    
    
    NSArray *imageSize = [[self.dataArray objectAtIndex:indexPath.item] objectForKey:@"size"];
    CGFloat width = [[imageSize objectAtIndex:0] floatValue];
    CGFloat height = [[imageSize objectAtIndex:1] floatValue];
    
    // Return the image height scaled by the column width to maintain the correct aspect ratio.
    CGSize size;
    if ([collectionViewLayout isKindOfClass:[BMScrollLayout class]]) {
        // For the ScrollLayout, we take 90% of the available screen width as the column width.
        CGFloat column_width = self.view.bounds.size.width * 0.9f;
        size = CGSizeMake(column_width, height * column_width / width);
    } else if ([collectionViewLayout isKindOfClass:[BMHorizontalScrollLayout class]]) {
        // For the ScrollLayout, we take 90% of the available screen height and scale the width accordingly.
        // If the image height is smaller than the screen height, use the actual image height instead.
        CGFloat available_height = self.view.bounds.size.height * 0.9f;
        available_height = MIN(height, available_height);
        size = CGSizeMake(width * available_height / height, available_height);
    }
    
    return size;
}

#pragma mark - Gesture recognizer handlers

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gr {
    // Only handle long press gestures in the grid layout.
    if (![self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
        return;
    }
    
    BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
    CGPoint touchPosition = [gr locationInView:self.collectionView];
    
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:touchPosition];
        UICollectionViewCell *selectedCell = [self.collectionView cellForItemAtIndexPath:selectedIndexPath];
        
        // The most straightforward way to move a cell is to to drag around a visual representation of that cell.
        UIGraphicsBeginImageContextWithOptions(selectedCell.bounds.size, selectedCell.opaque, 0.0f);
        [selectedCell.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *cellImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImageView *cellImageView = [[UIImageView alloc] initWithImage:cellImage];
        cellImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Wrap the cellImage in a UIView, and position/scale it nicely
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(selectedCell.frame), CGRectGetMinY(selectedCell.frame), CGRectGetWidth(cellImageView.frame), CGRectGetHeight(cellImageView.frame))];
        [cellView addSubview:cellImageView];
        [self.collectionView addSubview:cellView];
        [cellImageView release];
        [cellView release];
        
        [UIView animateWithDuration:0.3
         animations:^{
             cellView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
             cellView.center = touchPosition;
         } completion:NULL];

        layout.pressedCellPath = [self.collectionView indexPathForItemAtPoint:touchPosition];
        layout.pressedCellCenter = touchPosition;
        layout.activeCellView = cellView;
        
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        layout.pressedCellCenter = touchPosition;
        [layout invalidateLayoutIfNecessary];
        
    }  else if (gr.state == UIGestureRecognizerStateEnded) {
        UICollectionViewLayoutAttributes *attributes = [layout layoutAttributesForItemAtIndexPath:layout.pressedCellPath];
        
        [UIView animateWithDuration:0.3f animations:^{
            layout.activeCellView.transform = CGAffineTransformMakeScale(1.f, 1.f);
            layout.activeCellView.center = attributes.center;
            layout.pressedCellCenter = attributes.center;
        } completion:^(BOOL finished) {
            [layout.activeCellView removeFromSuperview];
            [self.collectionView reloadData];
            layout.pressedCellPath = nil;
            
            // Persist the current data source
            [BMPinModel storePinImageList:self.dataArray];
        }];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gr {
    // Are we pinching out or in?
    BOOL pinchOut = gr.scale > 1 ? YES : NO;
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        // Filter the datasource if we pinch (2 touches) and if we are currently in grid mode.
        
        if (gr.numberOfTouches == 2 && [self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
            BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
            
            // Get the touch locations
            CGPoint touch1 = [gr locationOfTouch:0 inView:self.collectionView];
            CGPoint touch2 = [gr locationOfTouch:1 inView:self.collectionView];
            
            // Get the indexPaths in between the touchpoints
            NSIndexPath *indexPath1 = [self.collectionView indexPathForItemAtPoint:touch1];
            NSIndexPath *indexPath2 = [self.collectionView indexPathForItemAtPoint:touch2];
            NSRange range;
            range.location = indexPath1.item <= indexPath2.item ? indexPath1.item : indexPath2.item;
            range.length = abs(indexPath1.item - indexPath2.item) + 1;
            
            // Highlight all cells in range
            NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:range.length];
            for (int i = range.location; i < range.length + range.location; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                [indexPaths addObject:path];
                
            /*
             * REMOVED: selection animation
             */
            //                BMGridCell *cell = (BMGridCell *)[self.collectionView cellForItemAtIndexPath:path];
            //                [UIView animateWithDuration:0.25f animations:^{
            //                    cell.highlighted = NO;
            //                    cell.selected = YES;
            //                }];
                
            }
            layout.selectedIndexPaths = [NSArray arrayWithArray:indexPaths];
            [indexPaths release];

            // Generate an array of random floats for each cell. These are used to generate random rotations for the stack.
            NSMutableArray *randomFloats = [[NSMutableArray alloc] initWithCapacity:range.length];
            NSUInteger count = [self.dataArray count];
            for (int i = 0; i < count; i++) {
                [randomFloats addObject:@((double)arc4random() / ARC4RANDOM_MAX)];
            }
            layout.randomFloats = [NSArray arrayWithArray:randomFloats];
            [randomFloats release];
        }
        
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        if (!pinchOut) {
            if (gr.numberOfTouches == 2 && [self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
                BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
                layout.pinchedCellScale = gr.scale;
            }
        }
        
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        /*
         * REMOVED: selection animation
         */

        // Deselect all cells
        //        for (BMGridCell *cell in self.collectionView.visibleCells) {
        //            [UIView animateWithDuration:0.25f animations:^{
        //                cell.selected = NO;
        //            }];
        //        }

        
        // Toggle back-and-forth between grid and stack layout
        if ([self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
            BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
            
            if (!pinchOut) {
                // We're finishing pinching in on the grid layout: finalize the pinch by animating to a fully pinched position.
                [self.collectionView performBatchUpdates:^{
                    layout.pinchedCellScale = 0.f;
                } completion:NULL];
                
            } else {
                // We're pinching out on the grid layout while pinched in: animate back to the original grid layout.
                if (layout.pinchedCellScale < 1.f) {
                    [self.collectionView performBatchUpdates:^{
                        BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
                        layout.pinchedCellScale = 1.f;
                    } completion:NULL];
                }
            }
        } else {
            // Switch back to GridLayout (always cached), only on pinch in
            [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
        }
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if ([collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
        // Show the horizontal scroll layout layout
        BMHorizontalScrollLayout *stackLayout = [[BMHorizontalScrollLayout alloc] init];
        [self.collectionView setCollectionViewLayout:stackLayout animated:YES];
        [stackLayout release];
        
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
    } else {
        // Show the grid layout
        [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
    }
}

@end

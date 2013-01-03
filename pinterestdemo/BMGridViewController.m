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
#import "BMStackLayout.h"
#import <ImageIO/ImageIO.h> 
#import <QuartzCore/QuartzCore.h>

#define GRID_COLUMN_WIDTH 235.f

static NSString *const BMGRID_CELL_ID = @"BMGridCellID";

@interface BMGridViewController ()
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gr;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gr;
- (void)loadData;
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
    [_selectedCells release];
    
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
    
    self.dataArray = [BMPinModel storedPinImageList];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data loading

- (void)loadData {
    self.dataArray = [BMPinModel pinImageList];
    [self.collectionView reloadData];
}

#pragma mark - BMGridLayout delegate/datasource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imageName = [self.dataArray objectAtIndex:indexPath.item];
    NSURL *imageFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"]];
    CGFloat width = 0.f;
    CGFloat height = 0.f;
    
    // Get the image dimensions without loading the image into memory
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL) { // Error loading image ...
        NSLog(@"Error loading image at URL: %@", imageFileURL);
        return height;
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
    if (imageProperties) {
        width = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) floatValue];
        height = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight) floatValue];
        CFRelease(imageProperties);
    }
    CFRelease(imageSource);

    // Return the image height scaled by the column width to maintain the correct aspect ratio.
    return height * GRID_COLUMN_WIDTH / width;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BMGridCell *cell = (BMGridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:BMGRID_CELL_ID forIndexPath:indexPath];

    [cell setImage:[self.dataArray objectAtIndex:indexPath.item]];
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
    NSString *imageName = [self.dataArray objectAtIndex:indexPath.item];
    NSURL *imageFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"]];
    CGFloat width = 0.f;
    CGFloat height = 0.f;
    
    // Get the image dimensions without loading the image into memory
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)imageFileURL, NULL);
    if (imageSource == NULL) { // Error loading image ...
        NSLog(@"Error loading image at URL: %@", imageFileURL);
        return CGSizeMake(0.f, 0.f);
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache, nil];
    
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (CFDictionaryRef)options);
    if (imageProperties) {
        width = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth) floatValue];
        height = [(NSNumber *)CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight) floatValue];
        CFRelease(imageProperties);
    }
    CFRelease(imageSource);
    
    // Return the image height scaled by the column width to maintain the correct aspect ratio.
    // For the StackLayout, we take 95% of the available screen width as the column width.
    CGFloat column_width = self.view.bounds.size.width * 0.95;
    return CGSizeMake(column_width, height * column_width / width);
}

#pragma mark - Gesture recognizer handlers

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gr {
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
    if (gr.state == UIGestureRecognizerStateBegan) {
        // Filter the datasource if we pinch (2 touches) and if we are currently in grid mode.
        if (gr.numberOfTouches == 2 && [self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
            // Get the touch locations
            CGPoint touch1 = [gr locationOfTouch:0 inView:self.collectionView];
            CGPoint touch2 = [gr locationOfTouch:1 inView:self.collectionView];
            
            // Get the indexPaths in between the touchpoints
            NSIndexPath *indexPath1 = [self.collectionView indexPathForItemAtPoint:touch1];
            NSIndexPath *indexPath2 = [self.collectionView indexPathForItemAtPoint:touch2];
            NSRange range;
            range.location = indexPath1.item <= indexPath2.item ? indexPath1.item : indexPath2.item;
            range.length = abs(indexPath1.item - indexPath2.item) + 1;
            self.selectedCells = [NSIndexSet indexSetWithIndexesInRange:range];
            
            BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
            layout.pinchedCellPath1 = indexPath1;
            layout.pinchedCellPath2 = indexPath2;
            
            // Highlight all cells in range
            for (int i = range.location; i < range.length + range.location; i++) {
                NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:0];
                BMGridCell *cell = (BMGridCell *)[self.collectionView cellForItemAtIndexPath:path];
                [UIView animateWithDuration:0.25f animations:^{
                    cell.highlighted = NO;
                    cell.selected = YES;
                }];
            }
        }
        
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        // Disabled pinch animation for now -- looks awkward.
//        if (gr.numberOfTouches == 2 && [self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
//            BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
//            layout.pinchedCellCenter1 = [gr locationOfTouch:0 inView:self.collectionView];
//            layout.pinchedCellCenter2 = [gr locationOfTouch:1 inView:self.collectionView];
//            layout.pinchedCellScale = gr.scale;
//        }
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        // Deselect all cells
        for (BMGridCell *cell in self.collectionView.visibleCells) {
            [UIView animateWithDuration:0.25f animations:^{
                cell.selected = NO;
            }];
        }
        
        // Are we pinching out or in?
        BOOL pinchOut = gr.scale > 1 ? YES : NO;
        
        // Toggle back-and-forth between grid and stack layout
        if ([self.collectionView.collectionViewLayout isKindOfClass:[BMGridLayout class]]) {
            // Switch to StackLayout, only on pinch out
            if (!pinchOut) {
                return;
            }
            
            if (self.selectedCells) {
                self.dataArray = [self.dataArray objectsAtIndexes:self.selectedCells];
            }
            [self.collectionView reloadData];

            BMStackLayout *stackLayout = [[[BMStackLayout alloc] init] autorelease];
            [self.collectionView setCollectionViewLayout:stackLayout animated:YES];
        } else {
            // Switch back to GridLayout (always cached), only on pinch in
            if (pinchOut) {
                return;
            }
            
            [self loadData];
            [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
        }
    }
}

@end

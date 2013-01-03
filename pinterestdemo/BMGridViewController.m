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
#import <ImageIO/ImageIO.h> 
#import <QuartzCore/QuartzCore.h>


#define COLUMN_WIDTH 130.f

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
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)loadView {
    // Create collection view layout
    BMGridLayout *layout = [[BMGridLayout alloc] initWithColumnWidth:COLUMN_WIDTH];
    
    // Create collection view
    CGRect screen = [[UIScreen mainScreen] applicationFrame];
    _collectionView = [[UICollectionView alloc] initWithFrame:screen collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor darkGrayColor];
    [_collectionView registerClass:[BMGridCell class] forCellWithReuseIdentifier:BMGRID_CELL_ID];
                       
    [layout release];
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
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    [pinchGestureRecognizer release];
    
    // Load pins
    self.dataArray = [BMPinModel imageNames];
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
    
    
    NSString *imageName = [self.dataArray objectAtIndex:indexPath.item];
    NSURL *imageFileURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:imageName
                                                                                 ofType:@"jpg"]];
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

    // Return the image height scaled by the column width to maintain the correct aspect ratio.
    return height * COLUMN_WIDTH / width;
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
        
        [UIView
         animateWithDuration:0.3
         animations:^{
             cellView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
             cellView.center = touchPosition;
         }
         completion:^(BOOL finished) {
             // Pass
         }];

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
        }];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gr {
    BMGridLayout *layout = (BMGridLayout *)self.collectionView.collectionViewLayout;
    
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint initialPoint = [gr locationInView:self.collectionView];
        NSIndexPath *pinchedCellPath = [self.collectionView indexPathForItemAtPoint:initialPoint];
        layout.pinchedCellPath = pinchedCellPath;
        
    } else if (gr.state == UIGestureRecognizerStateChanged) {
        layout.pinchedCellScale = gr.scale;
        layout.pinchedCellCenter = [gr locationInView:self.collectionView];
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        
    }
}

@end

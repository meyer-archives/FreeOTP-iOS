//
// FreeOTP
//
// Authors: Nathaniel McCallum <npmccallum@redhat.com>
//
// Copyright (C) 2014  Nathaniel McCallum, Red Hat
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CollectionViewController.h"

#import "AddTokenViewController.h"
#import "QRCodeScanViewController.h"

#import "TokenCell.h"
#import "TokenStore.h"

@interface CollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) UIPopoverController* popover;
@end

@implementation CollectionViewController
{
    TokenStore* store;
    NSIndexPath* lastPath;
    UILongPressGestureRecognizer* longPressGesture;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return store.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width - 10, 140);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

//    (int) collectionView.frame.size.width

    TokenCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MFACard" forIndexPath:indexPath];

//    Reorder cells with a long press
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.minimumPressDuration = 0.5;
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    return [cell bind:[store get:indexPath.row]] ? cell : nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Perform animation.
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];

    // Get the current cell.
    TokenCell* cell = (TokenCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell == nil)
        return;

    // Get the selected token.
    Token* token = [store get:indexPath.row];
    if (token == nil)
        return;

    // Get the token code and save the token state.
    TokenCode* tc = token.code;
    [store save:token];

    // Show the token code.
    cell.state = tc;

    return;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    UICollectionViewCell* cell = nil;

    // Get the current index path.
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *currPath = [self.collectionView indexPathForItemAtPoint:p];

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"Long tap start");
            
            if (currPath != nil)
                cell = [self.collectionView cellForItemAtIndexPath:currPath];
            if (cell == nil)
                return; // Invalid state

            lastPath = currPath;

            // Animate to the "lifted" state.
            cell = [self.collectionView cellForItemAtIndexPath:currPath];
        {[UIView animateWithDuration:0.3f animations:^{
            cell.transform = CGAffineTransformMakeScale(1.03f, 1.03f);
            [self.collectionView bringSubviewToFront:cell];
        }];}

            return;

        case UIGestureRecognizerStateChanged:
            if (lastPath != nil)
                cell = [self.collectionView cellForItemAtIndexPath:lastPath];
            if (cell == nil)
                return; // Invalid state

            if (currPath != nil && lastPath.row != currPath.row) {
                // Move the display.
                [self.collectionView moveItemAtIndexPath:lastPath toIndexPath:currPath];

                // Scroll the display to handle moving tokens up or down.
                if (lastPath.row < currPath.row)
                    [self.collectionView scrollToItemAtIndexPath:currPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
                else
                    [self.collectionView scrollToItemAtIndexPath:currPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];

                // Write changes.
                TokenStore* ts = [[TokenStore alloc] init];
                [ts moveFrom:lastPath.row to:currPath.row];

                // Reset state.
                cell.transform = CGAffineTransformMakeScale(1.03f, 1.03f); // Moving the token resets the size...
                [self.collectionView bringSubviewToFront:cell]; // ... and Z index.
                lastPath = currPath;
            }

            cell.center = [gestureRecognizer locationInView:self.collectionView];
            return;

        case UIGestureRecognizerStateEnded:
            NSLog(@"Long tap end");
            // Animate back to the original state, but in the new location.
            if (lastPath != nil) {
                cell = [self.collectionView cellForItemAtIndexPath:lastPath];
                {[UIView animateWithDuration:0.3f animations:^{
                    UICollectionViewLayout* l = self.collectionView.collectionViewLayout;
                    cell.center = [l layoutAttributesForItemAtIndexPath:lastPath].center;
                    cell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                } completion:^(BOOL c){
                    lastPath = nil;
                }];}
            }

            break;

        default:
            break;
    }

    [self.collectionView reloadData];
}

- (IBAction)addClicked:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self performSegueWithIdentifier:@"addToken" sender:self];
        return;
    }

    AddTokenViewController* c = [self.storyboard instantiateViewControllerWithIdentifier:@"addToken"];
    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:c];

    c.popover = self.popover = [[UIPopoverController alloc] initWithContentViewController:nc];
    self.popover.delegate = self;
    self.popover.popoverContentSize = CGSizeMake(320, 715);
    [self.popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)scanClicked:(id)sender
{
    [self performSegueWithIdentifier:@"scanToken" sender:self];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup store.
    store = [[TokenStore alloc] init];

    // Setup collection view.
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.delegate = self;

    // Setup buttons.
    UIBarButtonItem* add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addClicked:)];
    if ([AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] == nil) {
        self.navigationItem.rightBarButtonItems = @[add];
    } else {
        id icon = [UIImage imageNamed:@"qrcode.png"];
        id scan = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStylePlain target:self action:@selector(scanClicked:)];
        self.navigationItem.rightBarButtonItems = @[add, scan];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

@end

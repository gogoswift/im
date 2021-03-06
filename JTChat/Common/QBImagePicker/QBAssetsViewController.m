//
//  QBAssetsViewController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAssetsViewController.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

// Views
#import "QBImagePickerController.h"
#import "QBAssetCell.h"
#import "QBVideoIndicatorView.h"
#import "UIViewAdditions.h"
#import "HexColor.h"
#import "PreviewPhotoBrowser.h"
#import "UIImage+ResizeMagick.h"
#import "UIImage+imageNamed.h"
#import "JChatObjc.h"

static CGSize CGSizeScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}

@interface QBImagePickerController (Private)

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation NSIndexSet (Convenience)

- (NSArray *)qb_indexPathsFromIndexesWithSection:(NSUInteger)section
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}

@end

@implementation UICollectionView (Convenience)

- (NSArray *)qb_indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@interface QBAssetsViewController () <PHPhotoLibraryChangeObserver, UICollectionViewDelegateFlowLayout>{
    BOOL hasScrollToBottom;
}

@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) PHFetchResult *fetchResult;

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;

@property (nonatomic, assign) BOOL disableScrollToBottom;
@property (nonatomic, strong) NSIndexPath *lastSelectedItemIndexPath;


@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, assign) NSUInteger numberOfAssets;
@property (nonatomic, assign) NSUInteger numberOfPhotos;
@property (nonatomic, assign) NSUInteger numberOfVideos;

@property (nonatomic, strong) UIButton *previewBtn;
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UILabel *selectedNumLabel;


@end

@implementation QBAssetsViewController 

- (NSUInteger) numberOfAssets {
    
    if ([QBImagePickerController usingPhotosLibrary]) {
        
        return self.fetchResult.count;
    }
    else {
        
        return _numberOfAssets;
    }
}

- (NSUInteger) numberOfPhotos {

    if ([QBImagePickerController usingPhotosLibrary]) {
        return [self.fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    }
    else {
    
        return _numberOfPhotos;
    }
}


- (NSUInteger) numberOfVideos {
    
    if ([QBImagePickerController usingPhotosLibrary]) {
        return [self.fetchResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    }
    else {
        
        return _numberOfVideos;
    }
}

- (id) assetAtIndex:(NSUInteger) index {

    if ([QBImagePickerController usingPhotosLibrary]) {
    
        return self.fetchResult[index];
    }
    else {
    
        return self.assets[index];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [self setUpToolbarItems];
    [self resetCachedAssets];
    
    if ([QBImagePickerController usingPhotosLibrary]) {
    
        // Register observer
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        
    }
    else {
        
        // Register observer
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(assetsLibraryChanged:)
                                                     name:ALAssetsLibraryChangedNotification
                                                   object:nil];
    }
        
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Configure navigation item
    self.navigationItem.title = self.assetCollection.localizedTitle;
    self.navigationItem.prompt = self.imagePickerController.prompt;
    
    // Configure collection view
    self.collectionView.allowsMultipleSelection = self.imagePickerController.allowsMultipleSelection;
    
    // Show/hide 'Done' button
    if (self.imagePickerController.allowsMultipleSelection) {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    
    [self updateDoneButtonState];
    [self updateSelectionInfo];
    [self.collectionView reloadData];
    
    // Scroll to bottom  <-- this can't work , comment by zhy..
//    if (self.numberOfAssets > 0 && self.isMovingToParentViewController && !self.disableScrollToBottom) {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.numberOfAssets - 1) inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
//    }
}

/** add by zhy */
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (!hasScrollToBottom && self.numberOfAssets > 0 && !self.disableScrollToBottom) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(self.numberOfAssets - 1) inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        hasScrollToBottom = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.disableScrollToBottom = YES;
    hasScrollToBottom = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.disableScrollToBottom = NO;
    
    [self updateCachedAssets];
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // Save indexPath for the last item
    NSIndexPath *indexPath = [[self.collectionView indexPathsForVisibleItems] lastObject];
    
    // Update layout
    [self.collectionViewLayout invalidateLayout];
    
    // Restore scroll position
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}

- (void)dealloc
{
    if ([QBImagePickerController usingPhotosLibrary]) {

        // Deregister observer
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
    else {
    
        // Remove observer
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:ALAssetsLibraryChangedNotification
                                                      object:nil];
    }
}

- (UIView*)createToolBarAndPreviewButton {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height- 44, self.view.width, 44)];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue]< 9.0f) {
        toolBar.top = self.view.height- 44+20;
    }
    
    toolBar.backgroundColor = [UIColor colorWithHexString:@"0xffffff"];
    
    self.previewBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, toolBar.height)];
    [self.previewBtn setTitle:@"预览" forState:UIControlStateNormal];
    [self.previewBtn setTitleColor:[UIColor colorWithHexString:@"0x282828"] forState:UIControlStateNormal];
    [self.previewBtn setTitleColor:[UIColor colorWithHexString:@"#282828" alpha:0.2] forState:UIControlStateHighlighted];
    self.previewBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [toolBar addSubview:self.previewBtn];
    [self.previewBtn addTarget:self action:@selector(previewBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 60, 0, 60, toolBar.height)];
    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"0xff9d34"] forState:UIControlStateNormal];
    [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"0xff9d34" alpha:0.2] forState:UIControlStateHighlighted];
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"0xff9d34" alpha:0.2] forState:UIControlStateDisabled];
    [toolBar addSubview:self.sendBtn];
    [self.sendBtn addTarget:self action:@selector(sendBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.selectedNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 24, 24)];
    self.selectedNumLabel.right = self.sendBtn.left + 5;
    self.selectedNumLabel.font = [UIFont systemFontOfSize:14];
    self.selectedNumLabel.backgroundColor = [UIColor colorWithHexString:@"0xff9d34"];
    self.selectedNumLabel.textColor = [UIColor colorWithHexString:@"0xffffff"];
    self.selectedNumLabel.textAlignment = NSTextAlignmentCenter;
    self.selectedNumLabel.layer.cornerRadius = 12;
    self.selectedNumLabel.layer.masksToBounds = YES;
    [toolBar addSubview:self.selectedNumLabel];
    self.selectedNumLabel.hidden = YES;
    self.sendBtn.enabled = NO;
    
    
    
    if (self.imagePickerController.selectedAssets.count > 0) {
        self.selectedNumLabel.hidden = NO;
        self.sendBtn.enabled = YES;
        self.selectedNumLabel.text = [@(self.imagePickerController.selectedAssets.count) stringValue];
    }
    return toolBar;
}

#pragma mark - Accessors

- (void)setAssetCollection:(PHAssetCollection *)assetCollection
{
    _assetCollection = assetCollection;
    
    [self updateFetchRequest];
    [self.collectionView reloadData];
}

- (PHCachingImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [PHCachingImageManager new];
    }
    
    return _imageManager;
}

- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    [self updateAssets];
    
    if ([self isAutoDeselectEnabled] && self.imagePickerController.selectedAssets.count > 0) {
        // Get index of previous selected asset
        ALAsset  *previousSelectedAsset = [self.imagePickerController.selectedAssets firstObject];
        NSURL *previousSelectedAssetURL = [previousSelectedAsset valueForProperty:ALAssetPropertyAssetURL];
        
        [self.assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
            
            if ([assetURL isEqual:previousSelectedAssetURL]) {
                self.lastSelectedItemIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
                *stop = YES;
            }
        }];
    }
       
    [self.collectionView reloadData];
}

- (void)assetsLibraryChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSSet *updatedAssetsGroups = notification.userInfo[ALAssetLibraryUpdatedAssetGroupsKey];
        NSURL *assetsGroupURL = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyURL];
        
        for (NSURL *updatedAssetsGroupURL in updatedAssetsGroups) {
            if ([updatedAssetsGroupURL isEqual:assetsGroupURL]) {
                [self updateAssets];
                [self.collectionView reloadData];
            }
        }
    });
}

- (void)updateAssets
{
    NSMutableArray *assets = [NSMutableArray array];
    __block NSUInteger numberOfAssets = 0;
    __block NSUInteger numberOfPhotos = 0;
    __block NSUInteger numberOfVideos = 0;
    
    [self.assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            numberOfAssets++;
            
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            if ([type isEqualToString:ALAssetTypePhoto]) numberOfPhotos++;
            else if ([type isEqualToString:ALAssetTypeVideo]) numberOfVideos++;
            
            [assets addObject:result];
        }
    }];
    
    self.assets = assets;
    self.numberOfAssets = numberOfAssets;
    self.numberOfPhotos = numberOfPhotos;
    self.numberOfVideos = numberOfVideos;
}


- (BOOL)isAutoDeselectEnabled
{
    return (self.imagePickerController.maximumNumberOfSelection == 1
            && self.imagePickerController.maximumNumberOfSelection >= self.imagePickerController.minimumNumberOfSelection);
}


#pragma mark - Actions

- (void)sendBtnAction{
    [self done:nil];
}

- (void)previewBtnAction{
    if ([self.imagePickerController.selectedAssets count] == 0) {
        return;
    }
    if([QBImagePickerController usingPhotosLibrary]){
        [self previewBtnPHAssetAction];
    }else{
        [self previewBtnALAssetAction];
    }
    
}

- (void)previewBtnPHAssetAction {
    __weak typeof (self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PreviewPhotoBrowser *browser = [[PreviewPhotoBrowser alloc] init];
        browser.currentPhotoIndex = 0;
        NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
        
        
        for (id item in weakSelf.imagePickerController.selectedAssets) {
            if([item isKindOfClass:[PHAsset class]]){
                PHAsset *assetItem = (PHAsset *)item;
                
                MJPhoto *photo = [[MJPhoto alloc] init];
                
                photo.phImageAsset = assetItem;
                if ([weakSelf.imagePickerController.originSelectedAssets containsObject:assetItem]) {
                    photo.sendOriginImage = YES;
                }else{
                    photo.sendOriginImage = NO;
                }
                
                [photos addObject:photo];
                
            }
        }
        
        browser.photos = photos;
        browser.originSelectedAssets = weakSelf.imagePickerController.originSelectedAssets;
        [browser show];
        [browser.sendBtn addTarget:weakSelf action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        
    });

}

- (void)previewBtnALAssetAction {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PreviewPhotoBrowser *browser = [[PreviewPhotoBrowser alloc] init];
        browser.currentPhotoIndex = 0;
        NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:10];
        
        for (id item in weakSelf.imagePickerController.selectedAssets) {
            if([item isKindOfClass:[ALAsset class]]){
                ALAsset *assetItem = (ALAsset *)item;
              
                MJPhoto *photo = [[MJPhoto alloc] init];
                
                photo.imageAsset = assetItem;
                if ([weakSelf.imagePickerController.originSelectedAssets containsObject:assetItem]) {
                    photo.sendOriginImage = YES;
                }else{
                    photo.sendOriginImage = NO;
                }
                
                [photos addObject:photo];
            }
        }
        browser.photos = photos;
        browser.originSelectedAssets = weakSelf.imagePickerController.originSelectedAssets;
        [browser show];
        [browser.sendBtn addTarget:weakSelf action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    });

}

- (IBAction)done:(id)sender
{
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didFinishPickingAssets:)]) {
        
        [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController
                                               didFinishPickingAssets:self.imagePickerController.selectedAssets.array];
    }
}


- (void)fetchAssetsFromSelectedAssetURLsWithCompletion:(void (^)(NSArray *assets))completion
{
    // Load assets from URLs
    // The asset will be ignored if it is not found
    ALAssetsLibrary *assetsLibrary = self.imagePickerController.assetsLibrary;
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    
    __block NSMutableArray *assets = [NSMutableArray array];
    
    void (^checkNumberOfAssets)(void) = ^{
        if (assets.count == selectedAssets.count) {
            if (completion) {
                completion([assets copy]);
            }
        }
    };
    
    for (ALAsset* asset in selectedAssets) {

        NSURL *assetURL = [asset valueForProperty: ALAssetPropertyAssetURL];
        
        [assetsLibrary assetForURL:assetURL
                       resultBlock:^(ALAsset *asset) {
                           if (asset) {
                               // Add asset
                               [assets addObject:asset];
                               
                               // Check if the loading finished
                               checkNumberOfAssets();
                           } else {
                               [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                   [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                       if ([result.defaultRepresentation.url isEqual:assetURL]) {
                                           // Add asset
                                           [assets addObject:result];
                                           
                                           // Check if the loading finished
                                           checkNumberOfAssets();
                                           
                                           *stop = YES;
                                       }
                                   }];
                               } failureBlock:^(NSError *error) {
                                   NSLog(@"Error: %@", [error localizedDescription]);
                               }];
                           }
                       } failureBlock:^(NSError *error) {
                           NSLog(@"Error: %@", [error localizedDescription]);
                       }];
    }
}


#pragma mark - Toolbar

- (void)setUpToolbarItems
{
    /*
    // Space
    UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    // Info label
    NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
    UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
    infoButtonItem.enabled = NO;
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
    
    self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
     */
    
    
    
    if (self.showToolBarAndPreview){
        UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIView *toolBarView = [self createToolBarAndPreviewButton];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:toolBarView];
        self.toolbarItems = @[leftSpace,button,rightSpace];
    }
   
    
    
}

- (void)updateSelectionInfo
{
    /*
    NSMutableOrderedSet *selectedAssets = self.imagePickerController.selectedAssets;
    
    if (selectedAssets.count > 0) {
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSString *format;
        if (selectedAssets.count > 1) {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.items-selected", @"QBImagePicker", bundle, nil);
        } else {
            format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.item-selected", @"QBImagePicker", bundle, nil);
        }
        
        NSString *title = [NSString stringWithFormat:format, selectedAssets.count];
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
    } else {
        [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
    }
     */
    //add by zhy
    if (self.imagePickerController.selectedAssets.count > 0) {
        self.selectedNumLabel.hidden = NO;
        self.sendBtn.enabled = YES;
        self.selectedNumLabel.text = [@(self.imagePickerController.selectedAssets.count) stringValue];
    }else{
        self.selectedNumLabel.hidden = YES;
        self.sendBtn.enabled = NO;
        self.selectedNumLabel.text = @"";
    }
}


#pragma mark - Fetching Assets

- (void)updateFetchRequest
{
    if (self.assetCollection) {
        PHFetchOptions *options = [PHFetchOptions new];
        
        switch (self.imagePickerController.mediaType) {
            case QBImagePickerMediaTypeImage:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                break;
                
            case QBImagePickerMediaTypeVideo:
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
                break;
                
            default:
                break;
        }
        
        self.fetchResult = [PHAsset fetchAssetsInAssetCollection:self.assetCollection options:options];
        
        if ([self isAutoDeselectEnabled] && self.imagePickerController.selectedAssets.count > 0) {
            // Get index of previous selected asset
            PHAsset *asset = [self.imagePickerController.selectedAssets firstObject];
            NSInteger assetIndex = [self.fetchResult indexOfObject:asset];
            self.lastSelectedItemIndexPath = [NSIndexPath indexPathForItem:assetIndex inSection:0];
        }
    } else {
        self.fetchResult = nil;
    }
}


#pragma mark - Checking for Selection Limit

- (BOOL)isMinimumSelectionLimitFulfilled
{
   return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
}

- (BOOL)isMaximumSelectionLimitReached
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
   
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
   
    return NO;
}

- (void)updateDoneButtonState
{
    self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
}


#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    if ([QBImagePickerController usingPhotosLibrary]) {
    
        [self.imageManager stopCachingImagesForAllAssets];
    }
    
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets
{
    if ([QBImagePickerController usingPhotosLibrary] == NO) {
    
        return;
    }
    
    BOOL isViewVisible = [self isViewLoaded] && self.view.window != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0) {
        // Compute the assets to start caching and to stop caching
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView qb_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        } removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView qb_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        CGSize itemSize = [(UICollectionViewFlowLayout *)self.collectionViewLayout itemSize];
        CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:targetSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:targetSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect addedHandler:(void (^)(CGRect addedRect))addedHandler removedHandler:(void (^)(CGRect removedRect))removedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < self.numberOfAssets) {
            id asset = [self assetAtIndex:indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}


#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.fetchResult];
        
        if (collectionChanges) {
            // Get the new fetch result
            self.fetchResult = [collectionChanges fetchResultAfterChanges];
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // We need to reload all if the incremental diffs are not available
                [self.collectionView reloadData];
            } else {
                // If we have incremental diffs, tell the collection view to animate insertions and deletions
                [self.collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [self.collectionView deleteItemsAtIndexPaths:[removedIndexes qb_indexPathsFromIndexesWithSection:0]];
                    }
                    
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [self.collectionView insertItemsAtIndexPaths:[insertedIndexes qb_indexPathsFromIndexesWithSection:0]];
                    }
                    
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [self.collectionView reloadItemsAtIndexPaths:[changedIndexes qb_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfAssets;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCell" forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.showsOverlayViewWhenSelected = self.imagePickerController.allowsMultipleSelection;
    
    // Image
    CGSize itemSize = [(UICollectionViewFlowLayout *)collectionView.collectionViewLayout itemSize];
    CGSize targetSize = CGSizeScale(itemSize, [[UIScreen mainScreen] scale]);
    
    BOOL isVideo = NO;
    BOOL isSelected = NO;
    NSTimeInterval duration = 0.0;
    
    if ([QBImagePickerController usingPhotosLibrary]) {
        
        PHAsset* asset = [self assetAtIndex: indexPath.item];
        
        isSelected = [self.imagePickerController.selectedAssets containsObject:asset];
        isVideo = asset.mediaType == PHAssetMediaTypeVideo;
        duration = asset.duration;
        
        if (isVideo) {
    
            if (asset.mediaSubtypes & PHAssetMediaSubtypeVideoHighFrameRate) {
                cell.videoIndicatorView.videoIcon.hidden = YES;
                cell.videoIndicatorView.slomoIcon.hidden = NO;
            }
            else {
                cell.videoIndicatorView.videoIcon.hidden = NO;
                cell.videoIndicatorView.slomoIcon.hidden = YES;
            }
        }
        
        [self.imageManager requestImageForAsset: asset
                                     targetSize:targetSize
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      if (cell.tag == indexPath.item) {
                                          cell.imageView.image = result;
                                      }
                                }];
    }
    else {
    
        ALAsset* asset = [self assetAtIndex: indexPath.item];
        UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
        NSString *assetType = [asset valueForProperty:ALAssetPropertyType];

        isSelected = [self.imagePickerController.selectedAssets containsObject:asset];
        isVideo = [assetType isEqualToString:ALAssetTypeVideo];
        duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        
        cell.imageView.image = image;
    }

    // Video indicator
    if (isVideo) {
        
        cell.videoIndicatorView.hidden = NO;
        
        NSInteger minutes = (NSInteger)(duration / 60.0);
        NSInteger seconds = (NSInteger)ceil(duration - 60.0 * (double)minutes);
        cell.videoIndicatorView.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        
    } else {
        cell.videoIndicatorView.hidden = YES;
    }
    
    //// Selection state
    //NSURL *assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];

    // Selection state
    if (isSelected) {
        [cell setSelected:YES];
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                                  withReuseIdentifier:@"FooterView"
                                                                                         forIndexPath:indexPath];
        
        // Number of assets
        UILabel *label = (UILabel *)[footerView viewWithTag:1];
        
        NSBundle *bundle = self.imagePickerController.assetBundle;
        NSUInteger numberOfPhotos = self.numberOfPhotos;
        NSUInteger numberOfVideos = self.numberOfVideos;
        
        switch (self.imagePickerController.mediaType) {
            case QBImagePickerMediaTypeAny:
            {
                NSString *format;
                if (numberOfPhotos == 1) {
                    if (numberOfVideos == 1) {
                        format = NSLocalizedStringFromTableInBundle(@"assets.footer.photo-and-video", @"QBImagePicker", bundle, nil);
                    } else {
                        format = NSLocalizedStringFromTableInBundle(@"assets.footer.photo-and-videos", @"QBImagePicker", bundle, nil);
                    }
                } else if (numberOfVideos == 1) {
                    format = NSLocalizedStringFromTableInBundle(@"assets.footer.photos-and-video", @"QBImagePicker", bundle, nil);
                } else {
                    format = NSLocalizedStringFromTableInBundle(@"assets.footer.photos-and-videos", @"QBImagePicker", bundle, nil);
                }
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos, numberOfVideos];
            }
                break;
                
            case QBImagePickerMediaTypeImage:
            {
                NSString *key = (numberOfPhotos == 1) ? @"assets.footer.photo" : @"assets.footer.photos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"QBImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfPhotos];
            }
                break;
                
            case QBImagePickerMediaTypeVideo:
            {
                NSString *key = (numberOfVideos == 1) ? @"assets.footer.video" : @"assets.footer.videos";
                NSString *format = NSLocalizedStringFromTableInBundle(key, @"QBImagePicker", bundle, nil);
                
                label.text = [NSString stringWithFormat:format, numberOfVideos];
            }
                break;
        }
        
        return footerView;
    }
    
    return nil;
}


#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self validateMaximumNumberOfSelections:(self.imagePickerController.selectedAssets.count + 1)];
    
    if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:shouldSelectAsset:)]) {
        id asset = [self assetAtIndex: indexPath.item];
        return [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController shouldSelectAsset:asset];
    }
    
    if ([self isAutoDeselectEnabled]) {
        return YES;
    }
    
    return ![self isMaximumSelectionLimitReached];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBImagePickerController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssets = imagePickerController.selectedAssets;
    
    id asset = [self assetAtIndex: indexPath.item];
    
    if (imagePickerController.allowsMultipleSelection) {
        if ([self isAutoDeselectEnabled] && selectedAssets.count > 0) {
            // Remove previous selected asset from set
            [selectedAssets removeObjectAtIndex:0];
            
            // Deselect previous selected asset
            if (self.lastSelectedItemIndexPath) {
                [collectionView deselectItemAtIndexPath:self.lastSelectedItemIndexPath animated:NO];
            }
        }
        
        // Add asset to set
        [selectedAssets addObject:asset];
        
        self.lastSelectedItemIndexPath = indexPath;
        
        [self updateDoneButtonState];
        
        if (imagePickerController.showsNumberOfSelectedAssets) {
            [self updateSelectionInfo];
            
            if (selectedAssets.count == 1 && self.showToolBarAndPreview) {
                // Show toolbar
                [self.navigationController setToolbarHidden:NO animated:YES];
            }
        }
    } else {
        if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didFinishPickingAssets:)]) {
            [imagePickerController.delegate qb_imagePickerController:imagePickerController didFinishPickingAssets:@[asset]];
        }
    }
    
    if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didSelectAsset:)]) {
        [imagePickerController.delegate qb_imagePickerController:imagePickerController didSelectAsset:asset];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.imagePickerController.allowsMultipleSelection) {
        return;
    }
    
    QBImagePickerController *imagePickerController = self.imagePickerController;
    NSMutableOrderedSet *selectedAssets = imagePickerController.selectedAssets;
    
    id asset = [self assetAtIndex: indexPath.item];
    
    // Remove asset from set
    [selectedAssets removeObject:asset];
    
    self.lastSelectedItemIndexPath = nil;
    
    [self updateDoneButtonState];
    
    if (imagePickerController.showsNumberOfSelectedAssets) {
        [self updateSelectionInfo];
        
        if (selectedAssets.count == 0) {
            // Hide toolbar
            [self.navigationController setToolbarHidden:YES animated:YES];
        }
    }
    
    if ([imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didDeselectAsset:)]) {
        [imagePickerController.delegate qb_imagePickerController:imagePickerController didDeselectAsset:asset];
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger numberOfColumns;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        numberOfColumns = self.imagePickerController.numberOfColumnsInPortrait;
    } else {
        numberOfColumns = self.imagePickerController.numberOfColumnsInLandscape;
    }
    
    CGFloat width = (CGRectGetWidth(self.view.frame) - 2.0 * (numberOfColumns - 1)) / numberOfColumns;
    
    return CGSizeMake(width, width);
}

#pragma mark - Validating Selections

- (BOOL)validateMaximumNumberOfSelections:(NSUInteger)numberOfSelections
{
    NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
    
    if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
        if (numberOfSelections > self.imagePickerController.maximumNumberOfSelection) {
            kTipAlert(@"最多只可选择%lu张照片", (unsigned long)self.imagePickerController.maximumNumberOfSelection);
        }
        return (numberOfSelections <= self.imagePickerController.maximumNumberOfSelection);
    }
    
    return YES;
}


- (void)scrollToBottom {
    if(self.numberOfAssets>0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.numberOfAssets-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}


@end

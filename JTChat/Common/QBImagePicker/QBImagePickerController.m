//
//  QBImagePickerController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBImagePickerController.h"

// ViewControllers
#import "QBAlbumsViewController.h"
#import "QBAssetsViewController.h"
#import "DeviceAuthHelper.h"

@interface QBImagePickerController ()

@property (nonatomic, strong) NSBundle *assetBundle;

@end

@implementation QBImagePickerController

+ (BOOL) usingPhotosLibrary {

    return (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_8_0);
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        if ([QBImagePickerController usingPhotosLibrary] == NO) {
    
            self.assetsLibrary = [ALAssetsLibrary new];
        }
        
        self.collectionSubtypes = @[@(QBImagePickerCollectionSubtypeAll)];
//        self.collectionSubtypes = @[@(QBImagePickerCollectionSubtypeLibrary),
//                                    @(QBImagePickerCollectionSubtypeAlbum),
//                                    @(QBImagePickerCollectionSubtypeStream),
//                                    @(QBImagePickerCollectionSubtypePanoramas),
//                                    @(QBImagePickerCollectionSubtypeBursts)];
        
        self.minimumNumberOfSelection = 1;
        self.numberOfColumnsInPortrait = 4;
        self.numberOfColumnsInLandscape = 7;
        
        _selectedAssets = [NSMutableOrderedSet orderedSet];
        
        // Get asset bundle
        self.assetBundle = [NSBundle bundleForClass:[self class]];
        NSString *bundlePath = [self.assetBundle pathForResource:@"QBImagePicker" ofType:@"bundle"];
        if (bundlePath) {
            self.assetBundle = [NSBundle bundleWithPath:bundlePath];
        }
        
        [self setUpAlbumsViewController];
        
        // Set instance
        QBAlbumsViewController *albumsViewController = (QBAlbumsViewController *)self.albumsNavigationController.topViewController;

        albumsViewController.imagePickerController = self;
        
        [DeviceAuthHelper checkPhotoLibraryAuthorizationStatus];
    }
    
    return self;
}

- (void)setUpAlbumsViewController
{
    // Add QBAlbumsViewController as a child
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"QBImagePicker" bundle:self.assetBundle];
    UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"QBAlbumsNavigationController"];
    //[CustomNavigationBar replaceNavigationController:navigationController];
    
    [self addChildViewController:navigationController];
    
    navigationController.view.frame = self.view.bounds;
    [self.view addSubview:navigationController.view];
    
    [navigationController didMoveToParentViewController:self];
    
    self.albumsNavigationController = navigationController;
}

#pragma mark - Accessors

- (NSMutableArray *)originSelectedAssets {
    if(!_originSelectedAssets){
        _originSelectedAssets = [NSMutableArray new];
    }
    return _originSelectedAssets;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark - Actions

- (void)cancel:(id)sender
{
    // Delegate
    if (self.delegate && [self.delegate respondsToSelector:@selector(qb_imagePickerControllerDidCancel:)]) {
        [self.delegate qb_imagePickerControllerDidCancel:self];
    }
}


- (void)done:(id)sender
{
    id subViewController = self.albumsNavigationController.topViewController;
    if([subViewController isKindOfClass:[QBAlbumsViewController class]]){
        QBAlbumsViewController *albums = (QBAlbumsViewController*)subViewController;
        [albums done:sender];
    }else{
        subViewController = [self.albumsNavigationController.viewControllers objectAtIndex:0];
        QBAlbumsViewController *albums = (QBAlbumsViewController *)subViewController;
        [albums done:sender];
    }
}

@end

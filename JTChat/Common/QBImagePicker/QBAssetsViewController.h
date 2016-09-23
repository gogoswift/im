//
//  QBAssetsViewController.h
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBImagePickerController;
@class PHAssetCollection;
@class ALAssetsGroup;

@interface QBAssetsViewController : UICollectionViewController

@property (nonatomic, weak) QBImagePickerController *imagePickerController;
@property (nonatomic, strong) PHAssetCollection *assetCollection;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;

@property (nonatomic, assign) BOOL showToolBarAndPreview;

@end
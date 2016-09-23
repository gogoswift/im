//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ALAsset;
@class PHAsset;

@interface MJPhoto : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *image; // 完整的图片

@property (nonatomic, strong) UIImageView *srcImageView; // 来源view
@property (nonatomic, strong, readonly) UIImage *placeholder;
@property (nonatomic, strong, readonly) UIImage *capture;

@property (nonatomic, strong) ALAsset *imageAsset;
@property (nonatomic, strong) PHAsset *phImageAsset;

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;
@property (nonatomic, assign) int index; // 索引

/////////
@property (nonatomic, strong) NSString *descSize;
@property (nonatomic, assign) BOOL sendOriginImage;
@end
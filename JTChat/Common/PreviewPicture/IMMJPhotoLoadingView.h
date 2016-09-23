//
//  IMMJPhotoLoadingView.h
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinProgress 0.0001

@class IMMJPhotoBrowser;
@class IMMJPhoto;

@interface IMMJPhotoLoadingView : UIView
@property (nonatomic) float progress;

- (void)showLoading;
- (void)showFailure;
@end

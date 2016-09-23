//
//  IMMJPhoto.m
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IMMJPhoto.h"
#import <JTChat/JTChat-Swift.h>

@implementation IMMJPhoto
#pragma mark 截图
- (UIImage *)capture:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setSrcImageView:(UIImageView *)srcImageView
{
    _srcImageView = srcImageView;
    _placeholder = srcImageView.image;
    if (srcImageView.clipsToBounds) {
        _capture = [self capture:srcImageView];
    }
}
@end

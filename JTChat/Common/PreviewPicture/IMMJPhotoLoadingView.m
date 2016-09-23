//
//  IMMJPhotoLoadingView.m
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import "IMMJPhotoLoadingView.h"
#import "IMMJPhotoBrowser.h"
#import <QuartzCore/QuartzCore.h>
#import "IMMJPhotoProgressView.h"

@interface IMMJPhotoLoadingView ()
{
    UILabel *_failureLabel;
    IMMJPhotoProgressView *_progressView;
}

@end

@implementation IMMJPhotoLoadingView

- (void)setFrame:(CGRect)frame
{
    [super setFrame:[UIScreen mainScreen].bounds];
}

- (void)showFailure
{
    [_progressView removeFromSuperview];
    
    if (_failureLabel == nil) {
        _failureLabel = [[UILabel alloc] init];
        _failureLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, 44);
        _failureLabel.textAlignment = NSTextAlignmentCenter;
        _failureLabel.center = self.center;
        _failureLabel.text = @"";
        _failureLabel.font = [UIFont boldSystemFontOfSize:20];
        _failureLabel.textColor = [UIColor whiteColor];
        _failureLabel.backgroundColor = [UIColor clearColor];
        _failureLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    }
    [self addSubview:_failureLabel];
}

- (void)showLoading
{
    [_failureLabel removeFromSuperview];
    
    if (_progressView == nil) {
        _progressView = [[IMMJPhotoProgressView alloc] init];
        _progressView.bounds = CGRectMake( 0, 0, 60, 60);
        _progressView.center = self.center;
    }
    _progressView.progress = kMinProgress;
    [self addSubview:_progressView];
}

#pragma mark - customlize method
- (void)setProgress:(float)progress
{
    _progress = progress;
    _progressView.progress = progress;
    if (progress >= 1.0) {
        [_progressView removeFromSuperview];
    }
}
@end

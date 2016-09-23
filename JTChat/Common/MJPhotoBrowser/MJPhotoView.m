//
//  MJZoomingScrollView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoView.h"
#import "MJPhoto.h"
#import "MJPhotoLoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "YLGIFImage.h"
#import "YLImageView.h"
#import "UIImage+ResizeMagick.h"
#import "JChatObjC.h"
#import <Photos/Photos.h>
#import "UIViewAdditions.h"
#import "SDWebImageManager+MJ.h"
#import "UIImageView+WebCache.h"

//@class PHAsset;
//@class PHCachingImageManager;
//@class PHImageRequestOptions;


@interface MJPhotoView ()
{
    BOOL _zoomByDoubleTap;
    YLImageView *_imageView;
    MJPhotoLoadingView *_photoLoadingView;
}
@end

@implementation MJPhotoView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.clipsToBounds = YES;
		// 图片
		_imageView = [[YLImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
        
        // 进度条
        _photoLoadingView = [[MJPhotoLoadingView alloc] init];
		
		// 属性
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

//设置imageView的图片
- (void)configImageViewWithImage:(UIImage *)image{
    _imageView.image = image;
}


#pragma mark - photoSetter
- (void)setPhoto:(MJPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

#pragma mark 显示图片
- (void)showImage
{
    [self photoStartLoad];

    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad
{
    if (_photo.image) {
        _imageView.image = _photo.image;
        self.scrollEnabled = YES;
    }else if (_photo.imageAsset){
        _imageView.image = nil;
        self.scrollEnabled = NO;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *highQualityImage = [UIImage fullResolutionImageFromALAsset:_photo.imageAsset];
            UIImage *showImage = [highQualityImage resizedImageByWidth:500];
            
            if (!_photo.descSize) {
                NSData * imageData = UIImageJPEGRepresentation(highQualityImage, 1);
                _photo.descSize = [NSString stringWithFormat:@"%0.0fk", [imageData length]/1024.0f];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _imageView.image = showImage;
                self.scrollEnabled = YES;
                self.toolbarTitleLabel.text = [NSString stringWithFormat:@"原图(%@)", _photo.descSize];
                
                [self adjustFrame];
            });
        });
    }else if (_photo.phImageAsset){
        [self showPhImagePreview];
    }
    else {
        _imageView.image = _photo.placeholder;
        self.scrollEnabled = NO;
        // 直接显示进度条
        [_photoLoadingView showLoading];
        [self addSubview:_photoLoadingView];
        
        ESWeakSelf;
        ESWeak_(_photoLoadingView);
        ESWeak_(_imageView);
        
        [SDWebImageManager.sharedManager downloadImageWithURL:_photo.url options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            ESStrong_(_photoLoadingView);
            if (receivedSize > kMinProgress) {
                __photoLoadingView.progress = (float)receivedSize/expectedSize;
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            ESStrongSelf;
            ESStrong_(_imageView);
            __imageView.image = image;
            [_self photoDidFinishLoadWithImage:image];
        }];
    }
}

- (void)showPhImagePreview {
    __weak typeof (self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PHCachingImageManager *imageManager = [[PHCachingImageManager alloc] init];
        
        PHImageRequestOptions *requestOption = [[PHImageRequestOptions alloc] init];
        requestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOption.version = PHImageRequestOptionsVersionCurrent;
        
        [imageManager requestImageForAsset:weakSelf.photo.phImageAsset
                                targetSize:CGSizeMake(1000,1000)
                               contentMode:PHImageContentModeAspectFill
                                   options:requestOption
                             resultHandler:^(UIImage *result, NSDictionary *info) {
                                 
                                 // 得到一张 UIImage，展示到界面上
                                 //                                         UIImage *image = [result compressedImageToUpload];
                                 if(!IM_DICT_IS_NIL(info)){
                                     
                                     if([info[PHImageErrorKey] respondsToSelector:@selector(integerValue)] &&
                                        [info[PHImageErrorKey] integerValue] == 1){
                                         //发生了错误
                                     }else if ([info[PHImageResultIsDegradedKey] respondsToSelector:@selector(integerValue)] &&
                                               [info[PHImageResultIsDegradedKey] integerValue] == 1){
                                         //缩略图
                                     }else{
                                         if(result){
                                             UIImage *showImage = [result resizedImageByWidth:500];
                                             
                                             if (!_photo.descSize) {
                                                 NSData * imageData = UIImageJPEGRepresentation(result, 1);
                                                 _photo.descSize = [NSString stringWithFormat:@"%0.0fk", [imageData length]/1024.0f];
                                                 
                                             }
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 _imageView.image = showImage;
                                                 self.scrollEnabled = YES;
                                                 self.toolbarTitleLabel.text = [NSString stringWithFormat:@"原图(%@)", _photo.descSize];
                                                 
                                                 [self adjustFrame];
                                             });
                                         }
                                     }
                                 }
                                 
                             }];
        
    });
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame
{
	if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGFloat boundsWidth = self.bounds.size.width;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat imageWidth = _imageView.image.size.width;
    CGFloat imageHeight = _imageView.image.size.height;
	
	// 设置伸缩比例
    CGFloat imageScale = boundsWidth / imageWidth;
    CGFloat minScale = MIN(1.0, imageScale);
    
	CGFloat maxScale = 2.0; 
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
    maxScale = MAX(2.0, maxScale);
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, MAX(0, (boundsHeight- imageHeight*imageScale)/2), boundsWidth, imageHeight *imageScale);
    
    self.contentSize = CGSizeMake(CGRectGetWidth(imageFrame), CGRectGetHeight(imageFrame));
    _imageView.frame = imageFrame;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (_zoomByDoubleTap) {
        CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(_imageView.frame))/2;
        insetY = MAX(insetY, 0.0);
        if (ABS(_imageView.frame.origin.y - insetY) > 0.5) {
            //[_imageView setY:insetY];
            _imageView.top = insetY;
        }
    }
	return _imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    _zoomByDoubleTap = NO;
    CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(_imageView.frame))/2;
    insetY = MAX(insetY, 0.0);
    if (ABS(_imageView.frame.origin.y - insetY) > 0.5) {
        [UIView animateWithDuration:0.2 animations:^{
            //[_imageView setY:insetY];
            _imageView.top = insetY;
        }];
    }
}

#pragma mark - 手势处理
//单击隐藏
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    
    // 通知代理
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self];
    }
}
//双击放大
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _zoomByDoubleTap = YES;

	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
        CGPoint touchPoint = [tap locationInView:self];
        CGFloat scale = self.maximumZoomScale/ self.zoomScale;
        CGRect rectTozoom=CGRectMake(touchPoint.x * scale, touchPoint.y * scale, 1, 1);
        [self zoomToRect:rectTozoom animated:YES];
	}
}

- (void)dealloc
{
    // 取消请求
    [_imageView sd_setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
}
@end
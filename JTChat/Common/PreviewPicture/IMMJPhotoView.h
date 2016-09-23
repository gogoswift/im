//
//  IMMJPhotoView.h
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <JMessage/JMessage.h>
@class IMMJPhotoBrowser, IMMJPhoto, IMMJPhotoView;

@protocol IMMJPhotoViewDelegate <NSObject>
- (void)photoViewImageFinishLoad:(IMMJPhotoView *)photoView;
- (void)photoViewSingleTap:(IMMJPhotoView *)photoView;
- (void)photoViewDidEndZoom:(IMMJPhotoView *)photoView;
@end

@interface IMMJPhotoView : UIScrollView <UIScrollViewDelegate>
// 图片
@property (nonatomic, strong) IMMJPhoto *photo;
@property (nonatomic, strong) JMSGConversation *conversation;

// 代理
@property (nonatomic, weak) id<IMMJPhotoViewDelegate> photoViewDelegate;
@end

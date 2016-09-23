//
//  MJPhotoBrowser.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <UIKit/UIKit.h>
#import "MJPhoto.h"
//#import "HtmlMedia.h"
#import "MJPhotoToolbar.h"
#import "MJPhotoView.h"

@protocol MJPhotoBrowserDelegate;
@interface MJPhotoBrowser : NSObject <UIScrollViewDelegate>{
    MJPhotoToolbar *_toolbar;
    UILabel *toolbarTitleLabel;
}
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 保存按钮
@property (nonatomic, assign) NSUInteger showSaveBtn;
@property (strong, nonatomic) MJPhotoToolbar *toolbar;

// 显示
- (void)show;
//+ (void)showHtmlMediaItems:(NSArray *)items originalItem:(HtmlMediaItem *)curItem;
- (void)showPhotoViewAtIndex:(int)index;
- (void)photoViewSingleTap:(MJPhotoView *)photoView;
@end
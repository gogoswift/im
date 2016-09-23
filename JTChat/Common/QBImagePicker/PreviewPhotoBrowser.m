//
//  PreviewPhotoBrowser.m
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/29.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import "PreviewPhotoBrowser.h"
#import "HexColor.h"
#import "UIViewAdditions.h"
#import "UIImage+Bundle.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "QBImagePickerController.h"

@interface PreviewPhotoBrowser(){
    UIButton *selectedOriginBtn;
    UILabel *selectedNumLabel;
}

@end

@implementation PreviewPhotoBrowser

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showSaveBtn = NO;
    }
    return self;
}

- (void)show{
    [super show];
    _toolbar.indexLabel.hidden = YES;
    selectedNumLabel.text = [@([self.photos count]) stringValue];
}

- (MJPhotoToolbar *)toolbar{
    if (!_toolbar) {
        CGFloat barHeight = 44;
        CGFloat barY = [UIScreen mainScreen].bounds.size.height - barHeight;
        _toolbar = [[MJPhotoToolbar alloc] init];
        _toolbar.showSaveBtn = NO;
        _toolbar.frame = CGRectMake(0, barY, [UIScreen mainScreen].bounds.size.width, barHeight);
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        _toolbar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        selectedOriginBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 15+16+15, barHeight)];
        [_toolbar addSubview:selectedOriginBtn];
        
        [selectedOriginBtn setImage:[UIImage imageForCurrentBundleWithName:@"icon-pickit-normal"] forState:UIControlStateNormal];
        [selectedOriginBtn setImage:[UIImage imageForCurrentBundleWithName:@"icon-pickit-act"] forState:UIControlStateSelected];
        [selectedOriginBtn setImage:[UIImage imageForCurrentBundleWithName:@"icon-pickit-act"] forState:UIControlStateSelected|UIControlStateHighlighted];
        
        [selectedOriginBtn addTarget:self action:@selector(selectedOriginBtnAction) forControlEvents:UIControlEventTouchUpInside];
        
        toolbarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(selectedOriginBtn.right - 3, 0, 150, barHeight)];
        [_toolbar addSubview:toolbarTitleLabel];
        toolbarTitleLabel.textAlignment = NSTextAlignmentLeft;
        toolbarTitleLabel.font = [UIFont systemFontOfSize:15];
        toolbarTitleLabel.textColor = [UIColor whiteColor];
        toolbarTitleLabel.text = @"原图";
        
        
        
        self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(_toolbar.width - 60, 0, 60, barHeight)];
        [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"0xff9d34"] forState:UIControlStateNormal];
        [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"0xff9d34" alpha:0.2] forState:UIControlStateHighlighted];
        self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.sendBtn setTitleColor:[UIColor colorWithHexString:@"0xff9d34" alpha:0.2] forState:UIControlStateDisabled];
        [_toolbar addSubview:self.sendBtn];
        [self.sendBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
        //
        
        selectedNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 24, 24)];
        selectedNumLabel.right = self.sendBtn.left+5;
        selectedNumLabel.font = [UIFont systemFontOfSize:14];
        selectedNumLabel.backgroundColor = [UIColor colorWithHexString:@"0xff9d34"];
        selectedNumLabel.textColor = [UIColor colorWithHexString:@"0xffffff"];
        selectedNumLabel.textAlignment = NSTextAlignmentCenter;
        selectedNumLabel.layer.cornerRadius = 12;
        selectedNumLabel.layer.masksToBounds = YES;
        [_toolbar addSubview:selectedNumLabel];
        
    }
    return _toolbar;
}

- (void)selectedOriginBtnAction{
    selectedOriginBtn.selected = !selectedOriginBtn.selected;
    if (self.currentPhotoIndex < [self.photos count]) {
        MJPhoto *photo = self.photos[self.currentPhotoIndex];
        photo.sendOriginImage = selectedOriginBtn.selected;
        
        if (selectedOriginBtn.selected) {
            if([QBImagePickerController usingPhotosLibrary]){
                [self.originSelectedAssets addObject:photo.phImageAsset];
            }else{
                [self.originSelectedAssets addObject:photo.phImageAsset];
            }
        }else{
            if([QBImagePickerController usingPhotosLibrary]){
                [self.originSelectedAssets removeObject:photo.phImageAsset];
            }else{
                [self.originSelectedAssets removeObject:photo.imageAsset];
            }
        }
    }
}

- (void)showPhotoViewAtIndex:(int)index{
    [super showPhotoViewAtIndex:index];
    if (index < [self.photos count]) {
        MJPhoto *photo = self.photos[index];
        //toolbarTitleLabel.text = [NSString stringWithFormat:@"原图(%@)", photo.descSize];
        selectedOriginBtn.selected = photo.sendOriginImage;
    }
    
}

- (void)done:(id)sender{
    [self photoViewSingleTap:nil];
}


@end

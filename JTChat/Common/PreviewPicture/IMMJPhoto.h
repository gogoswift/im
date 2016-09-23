//
//  IMMJPhoto.h
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JChatViewModel;
@interface IMMJPhoto : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *image; // 完整的图片
@property (nonatomic, strong) JChatViewModel * message;

@property (nonatomic, strong) UIImageView *srcImageView; // 来源view
@property (nonatomic, strong, readonly) UIImage *placeholder;
@property (nonatomic, strong, readonly) UIImage *capture;

@property (nonatomic, assign) BOOL firstShow;

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;
@property (nonatomic, assign) int index; // 索引
@end

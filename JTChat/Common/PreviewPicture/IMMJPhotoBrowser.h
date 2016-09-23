//
//  IMMJPhotoBrowser.h
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JMSGConversation;
@protocol IMMJPhotoBrowserDelegate;

@interface IMMJPhotoBrowser : UIViewController<UIScrollViewDelegate>
// 代理
@property (nonatomic, weak) id<IMMJPhotoBrowserDelegate> delegate;
// 所有的图片对象
@property (nonatomic, strong) NSMutableArray * photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property (nonatomic, strong) JMSGConversation * conversation;

// 显示
- (void)show;

- (void)showInViewController:(UIViewController *)vc;
@end

@protocol IMMJPhotoBrowserDelegate <NSObject>

-(void)CellPhotoImageReload;

-(void)NewPostImageReload:(NSInteger)ImageIndex;

@optional
// 切换到某一页图片
- (void)photoBrowser:(IMMJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;
@end

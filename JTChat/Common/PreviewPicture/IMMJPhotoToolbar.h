//
//  IMMJPhotoToolbar.h
//  ZhaoBu
//
//  Created by 姚卓禹 on 15/12/9.
//  Copyright © 2015年 9tong. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol IMMJPhotoToolbarDelegate <NSObject>

-(void)DeleteThisImage:(NSInteger)ThisImageIndex;
-(void)downLoadThisImage:(NSInteger)ThisImageIndex;

@end

@interface IMMJPhotoToolbar : UIView
{
    
}
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;

@property (nonatomic, retain) NSString * DeleteImage;

@property (nonatomic, assign) id<IMMJPhotoToolbarDelegate>Delegate;

@end

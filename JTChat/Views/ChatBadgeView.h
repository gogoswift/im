//
//  ChatBadgeView.h
//  JTChat
//
//  Created by 姚卓禹 on 16/4/29.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatBadgeView : UIView

@property (nonatomic, copy) NSString *badgeValue;
@property (nonatomic) UIFont *badgeTextFont;
@property (strong) UIColor *badgeTextColor;
@property (strong) UIColor *badgeBackgroundColor;

@end

//
//  IMTipMsgLabel.h
//  tranb
//
//  Created by 姚卓禹 on 15/6/1.
//  Copyright (c) 2015年 cmf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMTipMsgLabel : UIView

- (void)setText:(NSString *)text;

+ (CGFloat)heightForText:(NSString *)text maxWidth:(CGFloat)maxWidth;

@end

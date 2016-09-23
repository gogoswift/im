//
//  IMTipMsgLabel.m
//  tranb
//
//  Created by 姚卓禹 on 15/6/1.
//  Copyright (c) 2015年 cmf. All rights reserved.
//

#import "IMTipMsgLabel.h"
#import "UIViewAdditions.h"

#define imTipMsgLabelHPadding       5.0f
#define imTipMsgLabelVPadding       5.0f

#define imTipMsgLabelFont           14

@interface IMTipMsgLabel(){
    UILabel *tipMsgLabel;
}

@end

@implementation IMTipMsgLabel

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0f];
        tipMsgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        tipMsgLabel.numberOfLines = 0;
        tipMsgLabel.font = [UIFont systemFontOfSize:imTipMsgLabelFont];
        tipMsgLabel.textColor = [UIColor whiteColor];
        [self addSubview:tipMsgLabel];
    }
    return self;
}


- (void)setText:(NSString *)text{
    CGFloat maxWidth = self.width;
    CGFloat maxLabelWidth = maxWidth - 2*imTipMsgLabelHPadding;
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:imTipMsgLabelFont]} context:NULL].size;
    tipMsgLabel.text = text;
    
    tipMsgLabel.height = size.height;
    tipMsgLabel.width = size.width;
    
    ///////////
    self.width = size.width + 2*imTipMsgLabelHPadding;
    self.height = size.height + 2*imTipMsgLabelVPadding;
    tipMsgLabel.origin = CGPointMake(imTipMsgLabelHPadding, imTipMsgLabelVPadding);
    
}

+ (CGFloat)heightForText:(NSString *)text maxWidth:(CGFloat)maxWidth{
    CGFloat maxLabelWidth = maxWidth - 2*imTipMsgLabelHPadding;
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:imTipMsgLabelFont]} context:NULL].size;
    return size.height + 2*imTipMsgLabelVPadding;
}


@end

//
//  ChatBadgeView.m
//  JTChat
//
//  Created by 姚卓禹 on 16/4/29.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatBadgeView.h"
#import "UIViewAdditions.h"

@interface ChatBadgeView(){
    
}

@end

@implementation ChatBadgeView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void)commonInitialization {
    // Setup defaults
    [self setBackgroundColor:[UIColor clearColor]];
    _badgeBackgroundColor = [UIColor redColor];
    _badgeTextColor = [UIColor whiteColor];
    _badgeTextFont = [UIFont systemFontOfSize:12];
}

- (void)setBadgeValue:(NSString *)badgeValue {
    
    _badgeValue = badgeValue;
    self.size = [self sizeOfBadgeValue:badgeValue];
    [self setNeedsDisplay];
}

- (CGSize)sizeOfBadgeValue:(NSString *)value{
    CGSize badgeSize = CGSizeZero;
    badgeSize = [_badgeValue boundingRectWithSize:CGSizeMake(100, 20)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName: [self badgeTextFont]}
                                          context:nil].size;
    
    CGFloat textOffset = 2.0f;
    
    if (badgeSize.width < badgeSize.height) {
        badgeSize = CGSizeMake(badgeSize.height, badgeSize.height);
    }
    
    CGRect badgeBackgroundFrame = CGRectMake(0,
                                             0,
                                             badgeSize.width + 2 * textOffset,
                                             badgeSize.height + 2 * textOffset);
    return badgeBackgroundFrame.size;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // Draw badges
    
    if ([[self badgeValue] length]) {
        CGSize badgeSize = [self sizeOfBadgeValue:[self badgeValue]];
        CGRect badgeBackgroundFrame = CGRectMake(0,
                                                 0,
                                                 badgeSize.width,
                                                 badgeSize.height);
        
        if ([self badgeBackgroundColor]) {
            CGContextSetFillColorWithColor(context, [[self badgeBackgroundColor] CGColor]);
            
            CGContextFillEllipseInRect(context, badgeBackgroundFrame);
        }
        
        CGContextSetFillColorWithColor(context, [[self badgeTextColor] CGColor]);
        
        NSMutableParagraphStyle *badgeTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        [badgeTextStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [badgeTextStyle setAlignment:NSTextAlignmentCenter];
        
        NSDictionary *badgeTextAttributes = @{
                                              NSFontAttributeName: [self badgeTextFont],
                                              NSForegroundColorAttributeName: [self badgeTextColor],
                                              NSParagraphStyleAttributeName: badgeTextStyle,
                                              };
        
        [[self badgeValue] drawInRect:CGRectMake(CGRectGetMinX(badgeBackgroundFrame),
                                                 CGRectGetMinY(badgeBackgroundFrame)+2,
                                                 badgeSize.width, badgeSize.height)
                       withAttributes:badgeTextAttributes];
    }
    
    CGContextRestoreGState(context);
}


@end

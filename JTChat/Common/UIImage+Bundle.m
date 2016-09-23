//
//  UIImage+Bundle.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/4.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "UIImage+Bundle.h"
#import "ChatMessageTableViewCell.h"
@implementation UIImage (Bundle)

+ (UIImage *)imageForCurrentBundleWithName:(NSString *)name{
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[ChatMessageTableViewCell class]];
    return [UIImage imageNamed:name inBundle:frameworkBundle compatibleWithTraitCollection:nil];
}

@end

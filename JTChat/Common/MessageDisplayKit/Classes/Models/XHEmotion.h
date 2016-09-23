//
//  XHEmotion.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kXHEmotionImageViewSize 30
#define kXHEmotionLineSpacing 12   //Emotion 横向两个image直接的间隔
#define kXHEmotionPerRowsCount 3   //每页显示多少行


@interface XHEmotion : NSObject

/**
 *  gif表情的封面图
 */
@property (nonatomic, strong) UIImage *emotionConverPhoto;

/**
 *  gif表情的路径
 */
@property (nonatomic, copy) NSString *emotionPath;

@end

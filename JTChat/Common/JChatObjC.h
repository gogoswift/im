//
//  JChatObjC.h
//  JTChat
//
//  Created by 姚卓禹 on 16/5/4.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#ifndef JChatObjC_h
#define JChatObjC_h

#import "UIImage+Bundle.h"
#define IM_WIDTH_SCREEN         [[UIScreen mainScreen] bounds].size.width      //屏幕宽度


// 字符串
#define IM_STR_IS_NIL(objStr) (![objStr isKindOfClass:[NSString class]] || objStr == nil || [objStr length] <= 0 )
// 字典
#define IM_DICT_IS_NIL(objDict) (![objDict isKindOfClass:[NSDictionary class]] || objDict == nil || [objDict count] <= 0 )
// 数组
#define IM_ARRAY_IS_NIL(objArray) (![objArray isKindOfClass:[NSArray class]] || objArray == nil || [objArray count] <= 0 )

#define kTipAlert(_S_, ...) [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

#endif /* JChatObjC_h */

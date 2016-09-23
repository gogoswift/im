//
//  HexColor.m
//
//  Created by Marius Landwehr on 02.12.12.
//  The MIT License (MIT)
//  Copyright (c) 2013 Marius Landwehr marius.landwehr@gmail.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "HexColor.h"

@implementation HXColor (HexColorAddition)

+ (HXColor *)colorWithHexString:(NSString *)hexString
{
    return [[self class] colorWithHexString:hexString alpha:1.0];
}

+ (HXColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    // Check for hash and add the missing hash
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor colorWithRGBHex:hexNum alpha:alpha];
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:alpha];
}

+ (HXColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    return [[self class] colorWith8BitRed:red green:green blue:blue alpha:1.0];
}

+ (HXColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha
{
    HXColor *color = nil;
#if (TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE)
    color = [HXColor colorWithRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
#else
    color = [HXColor colorWithCalibratedRed:(float)red/255 green:(float)green/255 blue:(float)blue/255 alpha:alpha];
#endif
    
    return color;
}

+ (NSString *)hexStringTransformFromThreeCharacters:(NSString *)hexString
{
    if(hexString.length == 4)
    {
        hexString = [NSString stringWithFormat:@"#%@%@%@%@%@%@",
                     [hexString substringWithRange:NSMakeRange(1, 1)],[hexString substringWithRange:NSMakeRange(1, 1)],
                     [hexString substringWithRange:NSMakeRange(2, 1)],[hexString substringWithRange:NSMakeRange(2, 1)],
                     [hexString substringWithRange:NSMakeRange(3, 1)],[hexString substringWithRange:NSMakeRange(3, 1)]];
    }
    
    return hexString;
}

+ (unsigned)hexValueToUnsigned:(NSString *)hexValue
{
    unsigned value = 0;
    
    NSScanner *hexValueScanner = [NSScanner scannerWithString:hexValue];
    [hexValueScanner scanHexInt:&value];
    
    return value;
}


@end

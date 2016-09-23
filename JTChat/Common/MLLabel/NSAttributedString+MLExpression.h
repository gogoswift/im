//
//  NSAttributedString+MLExpression.h
//  Pods
//
//  Created by molon on 15/6/18.
//
//

#import <Foundation/Foundation.h>

@class MLExpression;
@interface NSAttributedString (MLExpression)

- (NSAttributedString*)expressionAttributedStringWithExpression:(MLExpression*)expression;
@end

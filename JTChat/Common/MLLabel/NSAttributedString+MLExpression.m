//
//  NSAttributedString+MLExpression.m
//  Pods
//
//  Created by molon on 15/6/18.
//
//

#import "NSAttributedString+MLExpression.h"
#import "MLExpressionManager.h"
@implementation NSAttributedString (MLExpression)


- (NSAttributedString*)expressionAttributedStringWithExpression:(MLExpression*)expression
{
    return [[MLExpressionManager sharedInstance] expressionAttributedStringWithAttributedString:self expression:expression];
}

@end

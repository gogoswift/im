//
//  XHEmotionCollectionViewFlowLayout.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionCollectionViewFlowLayout.h"
#import "XHMacro.h"

@interface XHEmotionCollectionViewFlowLayout(){
    CGSize itemSize;
    CGFloat itemPrePageBeginOffset;
    NSUInteger preRowCount;
    NSDictionary *layoutInfo;
    
    NSUInteger pageNum;
}

@end

@implementation XHEmotionCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        itemSize = CGSizeMake(kXHEmotionImageViewSize, kXHEmotionImageViewSize);
        int count = MDK_SCREEN_WIDTH/(kXHEmotionImageViewSize+kXHEmotionLineSpacing);
        preRowCount = count;
        itemPrePageBeginOffset = (MDK_SCREEN_WIDTH - count * kXHEmotionImageViewSize - (count - 1)*kXHEmotionLineSpacing)/2;
        self.collectionView.alwaysBounceVertical = YES;
    }
    return self;
}


- (void)prepareLayout{
    [super prepareLayout];
    
    
    NSMutableDictionary *mLayoutInfo = [[NSMutableDictionary alloc] init];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    
    NSUInteger count = MDK_SCREEN_WIDTH/(kXHEmotionImageViewSize+kXHEmotionLineSpacing);
    NSUInteger pageCount = count * kXHEmotionPerRowsCount;
    pageNum = (itemCount / pageCount + (itemCount % pageCount ? 1 : 0));
    
    for (NSUInteger index = 0; index < itemCount; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes *itemAttributes =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        NSUInteger hIndex = index%preRowCount;
        
        NSUInteger vIndex = index/preRowCount;
        vIndex = vIndex%kXHEmotionPerRowsCount;
        
        itemAttributes.frame = CGRectMake(itemPrePageBeginOffset + hIndex*(kXHEmotionImageViewSize+kXHEmotionLineSpacing) + MDK_SCREEN_WIDTH * (index/(preRowCount *kXHEmotionPerRowsCount)), 10 + vIndex*(kXHEmotionImageViewSize + 14), kXHEmotionImageViewSize, kXHEmotionImageViewSize);
        mLayoutInfo[indexPath] = itemAttributes;
    }
    
    layoutInfo = [mLayoutInfo copy];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [NSMutableArray arrayWithCapacity:layoutInfo.count];
    
    [layoutInfo enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *indexPath,
                                                    UICollectionViewLayoutAttributes *attributes,
                                                    BOOL *innerStop) {
        if (CGRectIntersectsRect(rect, attributes.frame)) {
            [allAttributes addObject:attributes];
        }
    }];
    
    return allAttributes;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return layoutInfo[indexPath];
}

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.bounds.size.width * pageNum, self.collectionView.bounds.size.height);
}


@end

//
//  ChatProductMessageTableViewCell.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/9.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatProductMessageTableViewCell.h"
#import "JChatObjC.h"
#import "HexColor.h"
#import "UIViewAdditions.h"
#import <JTChat/JTChat-Swift.h>
#import "JSONObjectUtil.h"

@interface ChatProductMessageTableViewCell(){
    UIView *productContainerView;
    UILabel *productTipLabel;
    
    
    UILabel *productLabel;
    
    
    UIView *sperLineView;
    //UILabel *productPriceLabel;
    //UILabel *productPlaceLabel;
}

@end


@implementation ChatProductMessageTableViewCell

@synthesize productImageView = productImageView;
static const CGFloat productContainerSubViewsLeftPadding = 15.0f;

- (void)cellSubViewsInit{
    [super cellSubViewsInit];
    productContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rmtProductViewWidth(), rmtProductViewHeight())];
    {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(productContainerSubViewsLeftPadding, 0, rmtProductViewWidth() - productContainerSubViewsLeftPadding, 30)];
        if (IM_WIDTH_SCREEN < 321) {
            tipLabel.font = [UIFont systemFontOfSize:14];
        }else{
            tipLabel.font = [UIFont systemFontOfSize:15];
        }
        tipLabel.translatesAutoresizingMaskIntoConstraints = NO;
        tipLabel.textColor = [UIColor colorWithHexString:@"0x282828"];
        [productContainerView addSubview:tipLabel];
        tipLabel.numberOfLines = 2;
        productTipLabel = tipLabel;
        
        
        sperLineView = [[UIView alloc] init];
        sperLineView.translatesAutoresizingMaskIntoConstraints = NO;
        [productContainerView addSubview:sperLineView];
        sperLineView.backgroundColor = [UIColor colorWithHexString:@"0xeaeaea"];
        
        ///////
        UIImageView *productImageView_ = [[UIImageView alloc] init];//[UIButton buttonWithType:UIButtonTypeCustom];
        productImageView_.translatesAutoresizingMaskIntoConstraints = NO;
        productImageView_.image = nil;
        productImageView_.contentMode = UIViewContentModeScaleAspectFill;
        productImageView_.clipsToBounds = YES;
        //
        productImageView_.frame = CGRectZero;
        [productContainerView addSubview:productImageView_];
        productImageView = productImageView_;
        
        //
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.textColor = [UIColor colorWithHexString:@"0x5d5d5d"];
        [productContainerView addSubview:nameLabel];
        productLabel = nameLabel;
        
        UIView *superView = productContainerView;
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productTipLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeLeft multiplier:1.0f constant:10]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productTipLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeTop multiplier:1.0f constant:10]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productTipLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationLessThanOrEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0F constant:-10]];
        
//        [productTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(superView.mas_left).with.offset(10);
//            make.top.equalTo(superView.mas_top).with.offset(10);
//            make.right.lessThanOrEqualTo(superView.mas_right).with.offset(-10);
//        }];
        
        [productTipLabel setContentCompressionResistancePriority:999 forAxis:UILayoutConstraintAxisVertical];
        [productTipLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisVertical];
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:sperLineView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:productTipLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:sperLineView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10.0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:sperLineView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:productTipLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:4]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:sperLineView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0.0f constant:0.5]];
        /////
        
        
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:productTipLabel attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:productTipLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-10]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:productImageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f]];
        
//        [productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(productTipLabel.mas_left);
//            make.top.equalTo(productTipLabel.mas_bottom).with.offset(10);
//            make.bottom.equalTo(superView.mas_bottom).with.offset(-10);
//            make.width.equalTo(productImageView.mas_height);
//        }];
        
        productImageView.layer.cornerRadius = 4.0f;
        productImageView.layer.masksToBounds = YES;
        
        
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:productImageView attribute:NSLayoutAttributeRight multiplier:1.0f constant:12]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:productImageView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [superView addConstraint:[NSLayoutConstraint constraintWithItem:productLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:superView attribute:NSLayoutAttributeRight multiplier:1.0f constant:-10.0f]];
        
        
//        [productLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(productImageView.mas_right).with.offset(12);
//            make.centerY.equalTo(productImageView.mas_centerY);
//            make.right.lessThanOrEqualTo(superView.mas_right).with.offset(-10);
//        }];
        
        
    }
    [self.bubbleBgImageView addSubview:productContainerView];
}

- (void)configWithChatMsg:(JChatViewModel *)chatModel{
    
    if (chatModel.mine) {
        productContainerView.origin = CGPointMake(0, 0);
    }else{
        productContainerView.origin = CGPointMake(10, 0);
    }
    
    self.bubbleBgImageView.size = productContainerView.size;
    [super configWithChatMsg:chatModel];
    
    NSDictionary *customDict = chatModel.customMsgDict;
    
    //JMSGCustomMsgType customMsgType = [chatModel.customMsgDict[@"customMsgType"] integerValue];
//    if (customMsgType == JMSGCustomMsgType_BidInterest) {
//        productTipLabel.text = @"我对该报价感兴趣";
//        
//        BOOL needShowSupplyType = customDict[@"suppleType"]?YES:NO;
//        
//        id objBid = [MTLJSONAdapter modelOfClass:[BidEntity class] fromJSONDictionary:customDict error:NULL];
//        if ([objBid isKindOfClass:[BidEntity class]]) {
//            BidEntity *bidEntity = (BidEntity *)objBid;
//            productTipLabel.text = chatModel.chatContent;
//            
//            [productImageView sd_setImageWithURL:[NSURL URLWithString:kImageWithURLWidthHeight(bidEntity.pic, 100, 100)] placeholderImage:IMG_PLACEHOLDER_PRODUCT];
//            
//            NSString *moneyStr = [[bidEntity.price stringValue] RMBString_MoneyFommat];
//            moneyStr = [NSString stringWithFormat:@"¥%@",moneyStr];
//            NSMutableAttributedString *bidMutableAttString = [[NSMutableAttributedString alloc] initWithString:moneyStr attributes:@{NSFontAttributeName:productLabel.font, NSForegroundColorAttributeName:kColorWithHex(0xff871f)}];
//            if (!IM_STR_IS_NIL(bidEntity.unit)) {
//                [bidMutableAttString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" /%@", bidEntity.unit] attributes:@{NSFontAttributeName:productLabel.font, NSForegroundColorAttributeName:[UIColor blackColor]}]];
//            }
//            
//            if (needShowSupplyType) {
//                if ([bidEntity.supplyType integerValue] == 0) {
//                    [bidMutableAttString appendAttributedString:[[NSAttributedString alloc] initWithString:@"(现货)" attributes:@{NSFontAttributeName:productLabel.font, NSForegroundColorAttributeName:kColorWithHex(0x282828)}]];
//                } else {
//                    [bidMutableAttString appendAttributedString:[[NSAttributedString alloc] initWithString:@"(预定)" attributes:@{NSFontAttributeName:productLabel.font, NSForegroundColorAttributeName:kColorWithHex(0x282828)}]];
//                }
//            }
//            
//            productLabel.attributedText = bidMutableAttString;
//            
//            
//        }
//    }else
    if (chatModel.customMsgType == JMSGCustomMsgTypeBrowseProduct){
        productTipLabel.text = customDict[@"productName"]?[NSString stringWithFormat:@"%@", customDict[@"productName"]]:@" ";
        
        NSMutableAttributedString *mAttar = [[NSMutableAttributedString alloc] initWithString:@"售价 " attributes:@{NSFontAttributeName:productLabel.font, NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0x282828"]}];
        [mAttar appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" ￥%@", customDict[@"productPrice"]] attributes:@{NSFontAttributeName:productLabel.font, NSForegroundColorAttributeName:[UIColor colorWithHexString:@"0xff7817"]}]];
        
        productLabel.attributedText = mAttar;
        //productImageView.backgroundColor = [UIColor redColor];
        
        //        productNameLabel.text = customDict[customProductTypeProductNameKey]?[NSString stringWithFormat:@"%@", customDict[customProductTypeProductNameKey]]:@"";
        //
        //        id productPriceObj = customDict[customProductTypeProductPriceKey];
        //        CGFloat productPriceFloat = 0.0;
        //        if ([productPriceObj respondsToSelector:@selector(floatValue)]) {
        //            productPriceFloat = [productPriceObj floatValue];
        //        }
        //
        //        if (fabs(productPriceFloat - (NSInteger)productPriceFloat) < 0.01) {
        //            productPriceLabel.text = [NSString stringWithFormat:@"￥%ld/%@", (NSInteger)productPriceFloat, customDict[customProductTypeProductSupportUnit]];
        //        }else{
        //            productPriceLabel.text = [NSString stringWithFormat:@"￥%.2f/%@", productPriceFloat, customDict[customProductTypeProductSupportUnit]];
        //        }
        //
        //
        //        productPlaceLabel.text = customDict[customProductTypeProductSaleAreaKey]?[NSString stringWithFormat:@"%@", customDict[customProductTypeProductSaleAreaKey]]:@"";
        
        
        //NSString *path =@"";
        //        if (!STR_IS_NIL(customDict[customProductTypeProductImageUrlKey])) {
        //            path = [StringTools getStatusMiddleImageViaRealUrl:customDict[customProductTypeProductImageUrlKey]];
        //        }
        
//        [productImageView sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"cpp_bg.png"]];
        //////
        
    }
    
    
    
    
    [stateActivityIndView stopAnimating];
    [sendFailedBtn setHidden:YES];
    if (chatModel.message.status == kJMSGMessageStatusSending || chatModel.message.status == kJMSGMessageStatusReceiving) {
        [stateActivityIndView startAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatModel.message.status == kJMSGMessageStatusSendSucceed || chatModel.message.status == kJMSGMessageStatusReceiveSucceed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatModel.message.status == kJMSGMessageStatusSendFailed || chatModel.message.status == kJMSGMessageStatusReceiveDownloadFailed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:NO];
    }else {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }
    
    
    if (chatModel.mine) {
        self.bubbleBgImageView.image = [[UIImage imageForCurrentBundleWithName:@"im_bubble_empty_bg_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 25, 10, 20)];
    }else{
        self.bubbleBgImageView.image = [[UIImage imageForCurrentBundleWithName:@"im_bubble_bg_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 8, 25)];
    }
    
}


- (void)bubbleBgImageAction{
//    NSString *customDictString = currentChatMsgModel.customMsgDict[JMSGCustomMsgBodyKey];
//    NSDictionary *customDict = nil;
//    if (!STR_IS_NIL(customDictString)) {
//        customDict = [JSONObjectUtil dictFromString:customDictString];
//    }
//    
//    id objBid = [MTLJSONAdapter modelOfClass:[BidEntity class] fromJSONDictionary:customDict error:NULL];
//    if ([objBid isKindOfClass:[BidEntity class]]) {
//        
//        BidEntity *bidEntity = (BidEntity *)objBid;
//        
//        //        GrabOneDetailViewController *grabOneDetailVC = [[GrabOneDetailViewController alloc] initWithDetailViewType:DetailViewType_Chat PurchaseId:bidEntity.userPurchaseId UserBidId:bidEntity.userBidId];
//        
//        GrabOneDetailViewController *grabOneDetailVC = [[GrabOneDetailViewController alloc] initWithDetailViewType:DetailViewType_Chat BidEntity:bidEntity];
//        [self.viewController.navigationController pushViewController:grabOneDetailVC animated:YES];
//    }
    
    
    
    
    
    //    JMSGCustomMsgType customMsgType = [currentChatMsgModel.customMsgDict[JMSGCustomMsgTypeKey] integerValue];
    //    if (customMsgType == JMSGCustomMsgType_BrowseProduct) {
    //        NSString *productId = customDict[customProductTypeProductIdKey];
    //        NSString *urlStr = [NSString stringWithFormat:@"%@h5/product.do?method=detailProduct&productId=%@&clickUid=%lld&from=1",SERVER_PATH,productId,[SysInfo GetMemberId]];
    //
    //        NSURL *url = [NSURL URLWithString:urlStr];
    //
    //        NSString *productUserId = customDict[customProductTypeProductUserIdKey];
    //
    //        ProductProfile_H5 *productH5 = [[ProductProfile_H5 alloc] initWithURL:url];
    //        productH5.currentProductId = @([productId longLongValue]);
    //        productH5.friendUid = @([productUserId longLongValue]);
    //        productH5.productIUCode = customDict[customProductTypePorductIUCodeKey];
    //        UINavigationController *nav =[tranbAppDelegate TheCenterController].navigationController;
    //        [nav pushViewController:productH5 animated:YES];
    //    }else if (customMsgType == JMSGCustomMsgType_BidInterest){
    //        UINavigationController *nav =[tranbAppDelegate TheCenterController].navigationController;
    //        id bidId = customDict[customBidInterestTypeBidIdKey];
    //        if ([bidId respondsToSelector:@selector(integerValue)]) {
    //            [BidProfile_H5 OpenBidProfile:nav bidId:@([bidId integerValue])];
    //        }
    //    }
    
    
}


static CGFloat rmtProductViewWidth(){
    if (IM_WIDTH_SCREEN < 321) {
        return ceilf(IM_WIDTH_SCREEN*0.7);
    }else{
        return ceilf(IM_WIDTH_SCREEN*0.6);
    }
}

static CGFloat rmtProductViewHeight(){
    if (IM_WIDTH_SCREEN < 321) {
        return ceilf(rmtProductViewWidth()/2.0);
    }else{
        return ceilf(rmtProductViewWidth()/2.2);
    }
}

+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel *)chatModel{
    return rmtProductViewHeight();
}



@end

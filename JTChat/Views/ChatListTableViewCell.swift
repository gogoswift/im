//
//  ChatListTableViewCell.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/27.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import UIKit


let ChatListTableViewCellHeight: CGFloat = 68
let ChatListTableViewCellHeadImageSize: CGFloat = 50
let ChatListTableViewCellLeftPadding: CGFloat = 12

public class ChatListTableViewCell: SWTableViewCell {

    public let headImageBtn: UIButton = {
        let btn = UIButton(type: .Custom)
        return btn
    }()
    
    
    public let nameLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = UIFont.systemFontOfSize(16)
        lb.textColor = UIColor.blackColor()
        return lb
    }()
    
    let contentLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = UIFont.systemFontOfSize(14)
        lb.textColor = UIColor(hexString: "0x888888")
        return lb
    }()
    
    let timeLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = UIFont.systemFontOfSize(13)
        lb.textColor = UIColor(hexString: "0xb3b3b3")
        return lb
    }()
    
    
    let splitView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexString: "0xa8a8a6")
        return v
    }()
    
    let departLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = UIFont.systemFontOfSize(11)
        lb.textColor = UIColor(hexString: "0x888888")
        return lb
    }()
    
    
    
    let badgeView: ChatBadgeView = {
        let badge = ChatBadgeView(frame: CGRectMake(0, 0, 20, 20))
        return badge
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .None
        self.subViewsSetUp()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func bindWithViewModel(threadViewModel: ChatThreadViewModel){
        self.nameLabel.text = threadViewModel.titleShowString
        self.contentLabel.text = threadViewModel.contentString
        self.timeLabel.text = threadViewModel.showDateString
        if threadViewModel.departString.isEmpty{
            self.departLabel.hidden = true
            self.splitView.hidden = true
        }else{
            self.departLabel.text = threadViewModel.departString
            self.departLabel.hidden = false
            self.splitView.hidden = false
        }
        
        
        self.resizeAllLables()
        
        badgeView.hidden = true
        
        if threadViewModel.unreadCount > 0 {
            if threadViewModel.unreadCount > 99 {
                badgeView.badgeValue = "99+"
            }else{
                badgeView.badgeValue = "\(threadViewModel.unreadCount)"
            }
            badgeView.hidden = false
            badgeView.frame.center = CGPointMake(headImageBtn.frame.right, headImageBtn.frame.top)
        }
        
        
        if threadViewModel.type == .SingleChat || threadViewModel.type == .GroupChat{
            let rightUtilityButtons = NSMutableArray()
            rightUtilityButtons.sw_addUtilityButtonWithColor(UIColor.init(colorLiteralRed: 1.0, green: 0.231, blue: 0.188, alpha: 1), title: "删除")
            self.setRightUtilityButtons(rightUtilityButtons as [AnyObject], withButtonWidth: 58.0)
        }
        
    }

}

extension ChatListTableViewCell{
    func subViewsSetUp(){
        headImageBtn.frame = CGRectMake(ChatListTableViewCellLeftPadding, (ChatListTableViewCellHeight - ChatListTableViewCellHeadImageSize)/2, ChatListTableViewCellHeadImageSize, ChatListTableViewCellHeadImageSize)
        self.contentView.addSubview(headImageBtn)
        headImageBtn.setBackgroundImage(UIImage(named: "avatar_default", inBundle: NSBundle(forClass: ChatListTableViewCell.self), compatibleWithTraitCollection: nil), forState: .Normal)
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(splitView)
        self.contentView.addSubview(departLabel)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(badgeView)
    }
    
    
    
    
    func resizeAllLables(){
        self.nameLabel.sizeToFit()
        self.contentLabel.sizeToFit()
        self.timeLabel.sizeToFit()
        self.departLabel.sizeToFit()
        
        let labelLeft: CGFloat = 12 + headImageBtn.frame.right
        let timeLabelRightPadding: CGFloat = 10
        
        let labelVPadding: CGFloat = 4
        
        self.nameLabel.frame.topLeft = CGPointMake(labelLeft, self.headImageBtn.frame.top + labelVPadding)
        if (self.splitView.hidden){
            //没有depart string
            if self.nameLabel.frame.width > (screenWidth() - labelLeft - self.timeLabel.bounds.width - timeLabelRightPadding){
                self.nameLabel.frame.fWidth = screenWidth() - labelLeft - self.timeLabel.bounds.width - timeLabelRightPadding
            }
        }else{
            if self.nameLabel.frame.width > (screenWidth() - labelLeft - self.timeLabel.bounds.width - timeLabelRightPadding){
                self.nameLabel.frame.fWidth = screenWidth() - labelLeft - self.timeLabel.bounds.width - timeLabelRightPadding
                //名字太长，就显示名字了
                self.splitView.hidden = true
                self.departLabel.hidden = true
            }else{
                self.splitView.frame = CGRectMake(self.nameLabel.frame.right+4, self.nameLabel.frame.top + 4, 1, self.nameLabel.frame.height - 8)
                
                self.departLabel.frame.left = self.splitView.frame.right+4
                self.departLabel.frame.centerY = self.nameLabel.frame.centerY
                self.departLabel.frame.fWidth = screenWidth() - self.splitView.frame.right - self.timeLabel.bounds.width - timeLabelRightPadding
                
            }
            
            
        }
        
        self.timeLabel.frame.right = screenWidth() - timeLabelRightPadding
        self.timeLabel.frame.top = self.nameLabel.frame.top
        
        ///
        
        if self.contentLabel.frame.width > (screenWidth() - labelLeft) {
            self.contentLabel.frame.fWidth = screenWidth() - labelLeft
        }
        self.contentLabel.frame.left = self.nameLabel.frame.left
        self.contentLabel.frame.bottom = self.headImageBtn.frame.bottom - labelVPadding
        
        
    }
    
}

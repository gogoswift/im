//
//  ChatListViewController.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/26.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import UIKit
import JMessage
import ReactiveCocoa

public class ChatListViewController: UIViewController {
    
    public lazy var tableView: UITableView = {
        let tb = UITableView(frame: self.view.frame, style: .Plain)
        return tb
    }()
    
    public let chatListViewModel = ChatListViewModel()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        //self.view.addSubview(UIView())
        self.view.addSubview(tableView)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = ChatListTableViewCellHeight
        tableView.registerClass(ChatListTableViewCell.self, forCellReuseIdentifier: "ChatListTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        bindViewModel()
    }
    
    
    private func bindViewModel(){
        self.title = chatListViewModel.title
        
        
        chatListViewModel.errorMessageSignal.observeNext { (err) in
            chatLog("chatlist error \(err)")
            if errorIsUserLoginInvalid(err.code){
                //用户没有登录
                ChatManager.shareChatManager.reLoginIMUser()
            }
        }
        
        chatListViewModel.loginingSignal
            .filter{!$0}
            .map { _ in ()}
            .observe(chatListViewModel.refreshObserver)
        
        ///
        
        
        chatListViewModel.chatListChangesSignal
            .observeOn(UIScheduler())
            .observeNext({[weak self] _ in
                guard let tableView = self?.tableView else { return }
                self?.requestThreadModelsInfo()
                tableView.reloadData()
                print("\(self?.chatListViewModel.threadModels)")
            })
        
        //启动刷新
        chatListViewModel.refreshObserver.sendNext()
        
    }
    
    
}


//子类需要重写的方法
extension ChatListViewController {
    public func generateChatViewControllerWith(conversation: JMSGConversation) -> IMChatViewController{
        return IMChatViewController(conversation)
    }
    
    public func requestThreadModelsInfo(){
        
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return chatListViewModel.threadModels.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let chatListCell: ChatListTableViewCell = tableView.dequeueReusableCellWithIdentifier("ChatListTableViewCell", forIndexPath: indexPath) as! ChatListTableViewCell
        let chatThreadViewModel = chatListViewModel.threadModels[indexPath.row]

        chatListCell.bindWithViewModel(chatThreadViewModel)
        chatListCell.delegate = self
        return chatListCell
    }
    
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let chatThread: ChatThreadViewModel = chatListViewModel.threadModels[indexPath.row]
        
        if let conversation = chatThread.conversation {
            let chatVC = self.generateChatViewControllerWith(conversation)
            chatVC.targetUserInfo = chatThread.ext
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        
    }
    
    public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
        
    }
}

 extension ChatListViewController: SWTableViewCellDelegate{
    public func swipeableTableViewCellShouldHideUtilityButtonsOnSwipe(cell: SWTableViewCell!) -> Bool {
        return true
    }
    
    public func swipeableTableViewCell(cell: SWTableViewCell!, canSwipeToState state: SWCellState) -> Bool {
        if state == .CellStateRight{
            
        }
        
        return true
    }
    
    public func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        guard let indexPath = self.tableView.indexPathForCell(cell) else{
            return
        }
        
        cell.hideUtilityButtonsAnimated(true)
        
        
        let chatThreadViewModel = chatListViewModel.threadModels[indexPath.row]
        guard let conversation = chatThreadViewModel.conversation else{
            return
        }
        
        var needRefreshUnreadCount = false
        if conversation.unreadCount?.integerValue > 0 {
            needRefreshUnreadCount = true
        }
        
        if chatThreadViewModel.type == .SingleChat{
            JMSGConversation.deleteSingleConversationWithUsername(chatThreadViewModel.chatID)
            chatListViewModel.threadModels.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }else if chatThreadViewModel.type == .GroupChat{
            JMSGConversation.deleteGroupConversationWithGroupId(chatThreadViewModel.chatID)
            chatListViewModel.threadModels.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        if needRefreshUnreadCount{
            ChatManager.shareChatManager.refreshMsgsUreadCount()
        }
        
    }
    
}



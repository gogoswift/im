//
//  IMChatDataSource.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/5/3.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import UIKit
import JMessage
import ReactiveCocoa

let CellReuseIdentifier_Text: String = "ChatTextMessageTableViewCell"
let CellReuseIdentifier_Audio: String = "ChatAudioMessageTableViewCell"
let CellReuseIdentifier_Image: String = "ChatImageMessageTableViewCell"
let CellReuseIdentifier_Tip: String = "ChatTipMessageTableViewCell"
let CellReuseIdentifier_Product: String = "ChatProductMessageTableViewCell"

public class IMChatDataSource: NSObject {
    
    let chatConversation: JMSGConversation
    let chatId: String
    
    let messageQueue = dispatch_queue_create("jpush.com", nil)
    
    //缓存所有的message model
    var allMessageModelsDic: [String: JChatViewModel] = [:]
    //按序缓存后有的messageId， 于allMessage 一起使用
    var allMessageIdArr: [String] = []
    
    weak var chatViewController: IMChatViewController?
    
    
    var localMessageLoadCompleted: Bool = false //分页使用，标识当前消息是否显示完
    var currentMsgOffset: Int? = nil   //当前历史消息取到的offset
    let msgPageLimit: Int = 20 //分页每次取多少
    
    
    init(conversation: JMSGConversation, chatId: String) {
        chatConversation = conversation
        self.chatId = chatId
        super.init()
    }
    
    
    
    
    func dataModelsSetUp(){
        
        self.chatViewController?.messageTableView.registerClass(ChatTextMessageTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier_Text)
        self.chatViewController?.messageTableView.registerClass(ChatAudioMessageTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier_Audio)
        self.chatViewController?.messageTableView.registerClass(ChatImageMessageTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier_Image)
        self.chatViewController?.messageTableView.registerClass(ChatTipMessageTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier_Tip)
        self.chatViewController?.messageTableView.registerClass(ChatProductMessageTableViewCell.self, forCellReuseIdentifier: CellReuseIdentifier_Product)
        
        self.chatViewController?.subCellsReigster()
        
        localMessageLoadCompleted = false
        currentMsgOffset = nil
        chatViewController?.messageTableView.reloadData()
        
        
        ChatManager.shareChatManager.chatLogining.signal.filter{!$0}.observeOn(UIScheduler()).observe { _ in
            //重新登录成功之后，刷新消息
            chatLog("re login successed")
            self.refreshMessages()
        }
        
        //先获取消息
        getFirstPageMessages()
    }
    
    func increaseCurrentMsgOffset(){
        currentMsgOffset = currentMsgOffset ?? 0 + 1
    }
    
    func messageModelAtIndexPath(indexPath: NSIndexPath) -> JChatViewModel?{
        if allMessageIdArr.count <= indexPath.row{
            return nil
        }
        
        let messagId = allMessageIdArr[indexPath.row]
        return allMessageModelsDic[messagId]
    }
    
    
    func cleanMessagesCache(){
        allMessageModelsDic = [:]
        allMessageIdArr = []
        chatViewController?.messageTableView.reloadData()
    }
    
    func getFirstPageMessages(){
        self.cleanMessagesCache()
        self.loadMoreMessages()
    }
    
    func refreshMessages(){
        self.cleanMessagesCache()
        localMessageLoadCompleted = false
        currentMsgOffset = nil
        chatViewController?.messageTableView.reloadData()
        self.getFirstPageMessages()
    }
    
    
    func loadMoreMessages(){
        guard let loadingMoreMeesage = chatViewController?.loadingMoreMessage where !loadingMoreMeesage else{
            return
        }
        
        chatViewController?.loadingMoreMessage = true
        chatLog("load message currentMsgOffset ----\(currentMsgOffset))")
        self.asyncLoadLocalMsgWithCurrentOffset(currentMsgOffset, sleepTime: 1) { (pageMsgViewModelDict, pageMsgIdArr) in
            
            var firstPageMsg = false
            if self.currentMsgOffset == nil{
                firstPageMsg = true
            }
            if self.currentMsgOffset != nil{
                self.currentMsgOffset = self.currentMsgOffset! + pageMsgIdArr.count
            }else{
                self.currentMsgOffset = pageMsgIdArr.count
            }
            
            self.insertOldMessagesWithPageMsgViewModelDict(pageMsgViewModelDict, pageMsgIdArr: pageMsgIdArr)
            self.chatViewController?.loadingMoreMessage = false
            
            if firstPageMsg{
                dispatch_async(dispatch_get_main_queue(), { 
                    self.chatViewController?.scrollToBottomAnimated(false)
                })
            }
        }
        
    }
    
    var chatDelayOffset: CGPoint = CGPointZero
    func insertOldMessagesWithPageMsgViewModelDict(pageMsgViewModelDict: [String:JChatViewModel], pageMsgIdArr: [String]){
        
        guard let msgTableView = self.chatViewController?.messageTableView else{
            return
        }
        
        let block = {
            self.allMessageModelsDic += pageMsgViewModelDict
            
            var messageIds = pageMsgIdArr
            messageIds.appendContentsOf(self.allMessageIdArr)
            
            self.chatDelayOffset = msgTableView.contentOffset
            
            UIView.setAnimationsEnabled(false)
            msgTableView.beginUpdates()
            
            self.allMessageIdArr = messageIds
            
            var indexPaths:[NSIndexPath] = []
            for (idx, msgId) in pageMsgIdArr.enumerate(){
                let indexPath = NSIndexPath(forRow: idx, inSection: 0)
                indexPaths.append(indexPath)
                
                let height = self.calculateCellHeightWithMessageId(msgId, indexPath: indexPath)
                self.chatDelayOffset.y += height
            }
            
            msgTableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
            
            //当没有就数据的时候 就设置为nil
            if pageMsgIdArr.count < self.msgPageLimit && pageMsgIdArr.count > 0{
                self.chatDelayOffset.y -= 44.0
                msgTableView.tableHeaderView = nil
            }else if pageMsgIdArr.isEmpty{
                msgTableView.tableHeaderView = nil
            }
            
            msgTableView.setContentOffset(self.chatDelayOffset, animated: false)
            msgTableView.endUpdates()
            
            UIView.setAnimationsEnabled(true)
        }
        
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    
    typealias JMsgCompletionHandler = ([String:JChatViewModel], [String]) -> Void
    func asyncLoadLocalMsgWithCurrentOffset(currentOffser: NSNumber?, sleepTime: Int, completedBlock:JMsgCompletionHandler){
        
        let block = {
            var jMessages = self.chatConversation.messageArrayFromNewestWithOffset(self.currentMsgOffset, limit: self.msgPageLimit)
            
            if sleepTime > 0 {
                sleep(UInt32(sleepTime))
            }
            
            jMessages = jMessages.reverse()
            
            var messageModelDict:[String:JChatViewModel] = [:]
            var messageIdArr:[String] = []
            
            let currentChatUserId = self.chatId
            let isChatGroup = self.chatViewController?.isChatGroup ?? false
            
            jMessages.forEach({ (jMessage) in
                // 移除事件消息数据
                if jMessage.contentType != JMSGContentType.EventNotification {
                    let chatViewModel = JChatViewModel(message: jMessage)
                    chatViewModel.configWithConversation(self.chatConversation, targetId: currentChatUserId, isGroup: isChatGroup)
                    
                    self.checkShowTimeWithMessageModel(chatViewModel, currentMsgModelDict: messageModelDict, currentMsgIdArr: messageIdArr)
                    
                    let msgId = jMessage.msgId
                    messageModelDict[msgId] = chatViewModel
                    messageIdArr.append(msgId)
                }
//                let chatViewModel = JChatViewModel(message: jMessage)
//                chatViewModel.configWithConversation(self.chatConversation, targetId: currentChatUserId, isGroup: isChatGroup)
//                
//                self.checkShowTimeWithMessageModel(chatViewModel, currentMsgModelDict: messageModelDict, currentMsgIdArr: messageIdArr)
//                
//                let msgId = jMessage.msgId
//                messageModelDict[msgId] = chatViewModel
//                messageIdArr.append(msgId)
                
            })
            
            dispatch_async(dispatch_get_main_queue(), { 
                if messageIdArr.count < self.msgPageLimit {
                    self.localMessageLoadCompleted = true
                }
                completedBlock(messageModelDict, messageIdArr)
            })
            
        }
        dispatch_async(messageQueue, block)
        
    }
    
    
    let msgTimeShowInterval: Double = 60*2
    //调用检查是否需要显示时间戳
    func checkShowTimeWithMessageModel(chatViewModel: JChatViewModel, currentMsgModelDict:[String:JChatViewModel], currentMsgIdArr:[String]){
        
        if currentMsgIdArr.isEmpty {
            chatViewModel.showTimeTip = true
            return
        }
        
        let timeNumber = chatViewModel.messageTime
        guard let currentMsgId = currentMsgIdArr.last, lastChatModel = currentMsgModelDict[currentMsgId] else {
            chatViewModel.showTimeTip = true
            return
        }
        
        let lastMsgDate = NSDate.init(timeIntervalSince1970: lastChatModel.messageTime.doubleValue)
        let currentMsgDate = NSDate.init(timeIntervalSince1970: timeNumber.doubleValue)
        
        let timeBetween = currentMsgDate.timeIntervalSinceDate(lastMsgDate)
        
        if fabs(timeBetween) > msgTimeShowInterval{
            chatViewModel.showTimeTip = true
        }
        
    }
    
    func checkShowTimeWithMessageModel(chatViewModel: JChatViewModel){
        self.checkShowTimeWithMessageModel(chatViewModel, currentMsgModelDict: allMessageModelsDic, currentMsgIdArr: allMessageIdArr)
    }
    
    
    //MARK: 计算高度
    func calculateCellHeightWithMessageId(messageId: String, indexPath:NSIndexPath) -> CGFloat{
        return chatViewController?.tableView(chatViewController!.messageTableView, heightForRowAtIndexPath: indexPath) ?? 0
    }
    
    
    
    func getIndexForMessageId(messageId: String) -> Int?{
        return allMessageIdArr.indexOf(messageId)
    }
    
    
    func addChatMessageModelForShow(chatViewModel: JChatViewModel){
        //过滤系统事件
        if chatViewModel.contentType == .EventNotification {
            return
        }
        allMessageIdArr.append(chatViewModel.message.msgId)
        allMessageModelsDic.updateValue(chatViewModel, forKey: chatViewModel.message.msgId)
        self.chatViewController?.messageTableView.reloadData()
        self.chatViewController?.scrollToBottomAnimated(true)
    }
    
    //在发送消息后，对msgModel做的处理
    public func handleChatMessageModelForSend(chatViewModel: JChatViewModel){
        self.increaseCurrentMsgOffset()
        let isChatGroup = self.chatViewController?.isChatGroup ?? false
        chatViewModel.configWithConversation(chatConversation, targetId: chatId, isGroup: isChatGroup)
        self.checkShowTimeWithMessageModel(chatViewModel)
        self.addChatMessageModelForShow(chatViewModel)
    }
    
}


//MARK: JMessageDelegate
extension IMChatDataSource: JMessageDelegate{
    public func onSendMessageResponse(message: JMSGMessage!, error: NSError!){
        if error != nil{
            chatLog("send msg response error \(error.localizedDescription), msg \(message)")
            
            if errorIsUserLoginInvalid(error.code){
                //用户没有登录
                chatLog("用户当前登出，或者没有登录,重新登录")
                ChatManager.shareChatManager.reLoginIMUser()
            }
        }
        
        if message != nil{
            //
            dispatch_async(dispatch_get_main_queue(), {
                if let index = self.getIndexForMessageId(message.msgId) {
                    self.chatViewController?.reloadCellWithIndex(index)
                }
            })
        }
    }
    
    
    public func onReceiveMessage(message: JMSGMessage!, error: NSError!){
        let  block = {
            if message == nil{
                return
            }
            
            if !self.chatConversation.isMessageForThisConversation(message){
                return
            }
            
            if self.allMessageModelsDic[message.msgId] != nil{
                chatLog("msg 以及加载了.....")
                return
            }
            
            let chatViewModel = JChatViewModel(message: message)
            let isChatGroup = self.chatViewController?.isChatGroup ?? false
            chatViewModel.configWithConversation(self.chatConversation, targetId: self.chatId, isGroup: isChatGroup)
            self.checkShowTimeWithMessageModel(chatViewModel, currentMsgModelDict: self.allMessageModelsDic, currentMsgIdArr: self.allMessageIdArr)
            
            self.increaseCurrentMsgOffset()
            self.addChatMessageModelForShow(chatViewModel)
            
        }
        
        dispatch_async(dispatch_get_main_queue(), block)
    }
}

//MARK: UITableViewDataSource
extension IMChatDataSource: UITableViewDataSource{
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessageIdArr.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let chatViewModel = self.messageModelAtIndexPath(indexPath)
        guard let jchatViewModel = chatViewModel else{
            let textCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Tip, forIndexPath: indexPath) as! ChatTipMessageTableViewCell
            textCell.configWithChatMsg(nil)
            return textCell
        }
        
        let msgCell: ChatMessageTableViewCell
        
        switch jchatViewModel.contentType {
        case .Text:
            let textCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Text, forIndexPath: indexPath) as! ChatTextMessageTableViewCell
            msgCell = textCell
        case .Voice:
            let auidoCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Audio, forIndexPath: indexPath) as! ChatAudioMessageTableViewCell
            auidoCell.auidoMessage = jchatViewModel.message
            auidoCell.conversation = chatConversation
            msgCell = auidoCell
        case .Image:
            let imageCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Image, forIndexPath: indexPath) as! ChatImageMessageTableViewCell
            imageCell.message = jchatViewModel.message
            imageCell.conversation = chatConversation
            
            msgCell = imageCell
        case .Custom:
            switch jchatViewModel.customMsgType{
                case .BrowseProduct:
                    let productCell = chatViewController!.generateProductMessageCell(indexPath)
                    msgCell = productCell
                case .None:
                    let textCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Text, forIndexPath: indexPath) as! ChatTextMessageTableViewCell
                    msgCell = textCell
            }
            
        default:
            msgCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Tip, forIndexPath: indexPath) as! ChatTipMessageTableViewCell
            
//            let textCell = tableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Text, forIndexPath: indexPath) as! ChatTextMessageTableViewCell
//            msgCell = textCell
        }
        self.chatViewController?.configWithCell(msgCell, chatViewModel: chatViewModel!)
        msgCell.configWithChatMsg(jchatViewModel)
        
        msgCell.delegate = self.chatViewController
        return msgCell

    }
}



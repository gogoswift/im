//
//  ChatListViewModel.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/26.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import Foundation
import JMessage
import ReactiveCocoa
import Result

public class ChatListViewModel {
    
    public typealias ChatListModels = Array<ChatThreadViewModel>
    
    //Input
    let refreshObserver: Observer<Void, NoError>
    
    // Outputs
    let title: String
    let chatListChangesSignal: Signal<ChatListModels, NoError>
    let isLoading: MutableProperty<Bool>
    let errorMessageSignal: Signal<NSError, NoError>
    
    
    public var threadModels: ChatListModels = []
    
    
    ////
    private let chatListChangesObserver: Observer<ChatListModels, NoError>
    private let errorMessageObserver: Observer<NSError, NoError>
    
    
    //当前是否在登录
    let loginingSignal = ChatManager.shareChatManager.chatLogining.signal
    
    init(){
        self.title = "消息"
        
        let isLoading = MutableProperty(false)
        self.isLoading = isLoading
        
        
        let (refreshSignal, refreshObserver) = SignalProducer<Void, NoError>.buffer(0)
        self.refreshObserver = refreshObserver
        
        
        let (chatListChangesSignal, chatListChangesObserver) = Signal<ChatListModels, NoError>.pipe()
        self.chatListChangesSignal = chatListChangesSignal
        self.chatListChangesObserver = chatListChangesObserver
        
        
        let (errorMessageSignal, errorMessageObserver) = Signal<NSError, NoError>.pipe()
        self.errorMessageSignal = errorMessageSignal
        self.errorMessageObserver = errorMessageObserver
        
        refreshSignal
            .on(next:{ _ in isLoading.value = true })
            .flatMap(.Latest) { _ in
                return ChatListViewModel.fetchConversationList()
                    .flatMapError { error in
                        errorMessageObserver.sendNext(error)
                        return SignalProducer(value: [])
                    }
            }
            .on(next: { _ in isLoading.value = false })
            .map{ conversations in
                
                return conversations.flatMap({ (conversation) -> ChatThreadViewModel? in
                    //过滤掉空的回话
                    if conversation.latestMessage == nil{
                        return nil
                    }
                    
                    let threadType: ChatThreadType
                    if conversation.conversationType == .Single{
                        threadType = .SingleChat
                    }else{
                        threadType = .GroupChat
                    }
                    let threadVM = ChatThreadViewModel(type: threadType)
                    threadVM.conversation = conversation
                    
                    
                    return threadVM
                })
            }
            .startWithNext({ [weak self] (threadModels) in
                if let observer = self?.chatListChangesObserver {
                    self?.threadModels = threadModels.sort({ (first, second) -> Bool in
                        return first.date > second.date
                    })
                    observer.sendNext(threadModels)
                }
            })
        
        //收到消息，更新消息列表
        ChatManager.shareChatManager.msgsUreadCount.signal.observeNext { (_) in
            refreshObserver.sendNext()
        }
    }
    
    
    static func fetchConversationList() -> SignalProducer<[JMSGConversation], NSError>{
        return SignalProducer{ observer, disposable in
                JMSGConversation.allConversations { (result, err) in
                    guard let conversations = result as? [JMSGConversation] else{
                        chatLog("allConversations error \(err)")
                        observer.sendFailed(err)
                        return
                    }
                
                    observer.sendNext(conversations)
                    chatLog("get all conversation count \(conversations.count)")
                    observer.sendCompleted()
                }
            }
    }
    
}




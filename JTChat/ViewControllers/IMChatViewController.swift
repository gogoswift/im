//
//  IMChatViewController.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/14.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import UIKit
import JMessage
import ReactiveCocoa
import Result
import AVFoundation

internal let chatNotSupportMsgTypeTipString = "当前版本较低，无法显示此消息"

public class IMChatViewController: XHMessageTableViewController {

    //当前回话对象
    public let chatConversation: JMSGConversation
    public let currentChatUserId: String
    public let isChatGroup: Bool
    public let targetChatUserId: String
    
    
    //单聊，对方的profile
    public var targetUserInfo: Any?
    
    public let chatDataSource: IMChatDataSource
    
    
    private var longPressIndexPath: NSIndexPath?
    private lazy var menuController: UIMenuController = {
       return UIMenuController.sharedMenuController()
    }()
    private lazy var copyMenuItem: UIMenuItem = {
        return UIMenuItem(title:"复制", action:#selector(copyMenuAction(_:)))
    }()
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = chatConversation.title
        messageTableView.dataSource = chatDataSource
        messageTableView.delegate = self
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 241.0/255, green: 240.0/255, blue: 238.0/255, alpha: 1.0)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        messageTableView.addGestureRecognizer(lpgr)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-friend-info", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil), style: .Plain, target: self, action: #selector(rightBarButtonItemAction(_:)))
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        keyboardMenuItemsSetUp()
        
        chatDataSource.dataModelsSetUp()
        
    }
    
    
    public override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        chatConversation.clearUnreadCount()
        ChatManager.shareChatManager.refreshMsgsUreadCount()
        messageInputView.inputTextView.text = ""
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    public func configWithCell(chatCell: ChatMessageTableViewCell, chatViewModel: JChatViewModel){
        
    }
    
    
    //初始化函数
    public init(_ converastion: JMSGConversation) {
        chatConversation = converastion
        currentChatUserId = ChatManager.shareChatManager.currentLoginUser?.userJChatId ?? ""
        isChatGroup = chatConversation.conversationType == .Group ? true:false
        
        if isChatGroup{
            let group = chatConversation.target as! JMSGGroup
            targetChatUserId = group.gid
        } else{
            let user = chatConversation.target as! JMSGUser
            targetChatUserId = user.username
        }
        
        chatDataSource = IMChatDataSource(conversation: chatConversation, chatId: targetChatUserId)
        
        super.init(nibName: nil, bundle: nil)
        chatDataSource.chatViewController = self
        self.hidesBottomBarWhenPushed = true
        addNotification()
        JChatAudioPlayerHelper.sharedInstance.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        removeNotification()
        JChatAudioPlayerHelper.sharedInstance.delegate = nil
    }
    
    
    func addNotification(){
        JMessage.addDelegate(chatDataSource, withConversation: chatConversation)
    }
    
    
    func removeNotification(){
        JMessage.removeDelegate(chatDataSource, withConversation: chatConversation)
    }
    
    

}

//MARK: UI
extension IMChatViewController{
    public func keyboardMenuItemsSetUp(){
        var shareMenuItems:[XHShareMenuItem] = []
        let plugIcons = ["btn-img", "btn-camera"]
        let plugTitle = ["照片", "拍摄"]
        
        for (idx, iconString) in plugIcons.enumerate(){
            shareMenuItems.append(XHShareMenuItem.init(normalIconImage: UIImage(named: iconString, inBundle: NSBundle(forClass: IMChatViewController.self), compatibleWithTraitCollection: nil), title: plugTitle[idx]))
        }
        self.shareMenuItems = shareMenuItems
        self.shareMenuView.reloadData()
    }
    
    
    func reloadCellWithIndex(index: Int){
        if messageTableView.numberOfRowsInSection(0) > index{
            messageTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
        }
        
    }
    
    func reloadCellWithMessageId(msgId: String){
        let _ = chatDataSource.getIndexForMessageId(msgId).map { (index) -> Void in
            
            let delayInSeconds = 0.2
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue(), { 
                self.reloadCellWithIndex(index)
            })
            
        }
    }
}

//MARK: Action
extension IMChatViewController {
    func handleLongPress(recognizer: UILongPressGestureRecognizer){
        if recognizer.state == .Began && chatDataSource.allMessageIdArr.count > 0{
            let location = recognizer.locationInView(self.messageTableView)
            let indexPath = self.messageTableView.indexPathForRowAtPoint(location)
            let chatModel = indexPath.flatMap({ (indexPath) -> JChatViewModel? in
                self.chatDataSource.messageModelAtIndexPath(indexPath)
            })
            guard let chatModel_c = chatModel where chatModel_c.contentType == .Text else{
                return
            }
            
            
            let cell = self.messageTableView .cellForRowAtIndexPath(indexPath!) as! ChatMessageTableViewCell
            cell.becomeFirstResponder()
            longPressIndexPath = indexPath
            showMenuViewControllerOn(cell.bubbleBgImageView, indexPath: indexPath!)
            
        }
    }
    
    func showMenuViewControllerOn(showView: UIView, indexPath: NSIndexPath){
        menuController.menuItems = [copyMenuItem]
        menuController.setTargetRect(showView.frame, inView: showView.superview!)
        menuController.setMenuVisible(true, animated: true)
        
    }
    
    func rightBarButtonItemAction(sender: UIBarButtonItem){
        ChatManager.shareChatManager.chatLogining.value = false
    }
    
    
    func copyMenuAction(sender: AnyObject){
        guard let pressIndexPath = longPressIndexPath else{
            return
        }
        
        let chatModel = chatDataSource.messageModelAtIndexPath(pressIndexPath)
        UIPasteboard.generalPasteboard().string = chatModel?.chatContent
        
        longPressIndexPath = nil
        
    }
}


//MARK: JChatAudioPlayerHelperDelegate
extension IMChatViewController: JChatAudioPlayerHelperDelegate{
    func didAudioPlayerStopPlay(AudioPlayer: AVAudioPlayer) {
        guard let currentPlayModel = JChatAudioPlayerHelper.sharedInstance.currentPlayModel else{
            return
        }
        
        currentPlayModel.isPlayingAudio = false
        JChatAudioPlayerHelper.sharedInstance.currentPlayModel = nil
        reloadCellWithMessageId(currentPlayModel.message.msgId)
    }
    
    func didAudioPlayerBeginPlay(AudioPlayer:AVAudioPlayer){
        
    }
    
    func didAudioPlayerPausePlay(AudioPlayer:AVAudioPlayer){
        
    }
}

//MARK: override
extension IMChatViewController{
    override public func loadMoreMessagesScrollTotop(){
        chatDataSource.loadMoreMessages()
    }
    
    func currentMessageInputViewType() -> XHMessageInputType{
        return .Normal
    }
    
    override public func shouldPreventScrollToBottomWhileUserScrolling() -> Bool{
        return true
    }
    
    override public func shouldLoadMoreMessagesScrollToTop() -> Bool{
        return !chatDataSource.localMessageLoadCompleted
    }
    
    public func checkHasSensitiveWords(txt: String) -> Bool{
        return false
    }
    
    
    override public func showMutiImageSelected() {
        let imagePickVC = QBImagePickerController()
        imagePickVC.albumsNavigationController.navBarStyle()
        imagePickVC.mediaType = .Image
        imagePickVC.delegate = self
        imagePickVC.allowsMultipleSelection = true
        imagePickVC.maximumNumberOfSelection = 9
        imagePickVC.showToolBarAndPreview = true
        imagePickVC.showsNumberOfSelectedAssets = true
        imagePickVC.showsCancelButton = true
        self.presentViewController(imagePickVC, animated: true, completion: nil)
    }
    
    public func subCellsReigster(){
        
    }
    
    public func generateProductMessageCell(indexPath: NSIndexPath) -> ChatProductMessageTableViewCell{
        return self.messageTableView.dequeueReusableCellWithIdentifier(CellReuseIdentifier_Product, forIndexPath: indexPath) as! ChatProductMessageTableViewCell
    }
    
}

//MARK: QBImagePickerControllerDelegate
extension IMChatViewController: QBImagePickerControllerDelegate{
    public func qb_imagePickerController(imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        
        
        
        if QBImagePickerController.usingPhotosLibrary(){
            let block = {
                guard let assetItems = assets as? [PHAsset] else{
                    return
                }
                
                assetItems.forEach({ (phAsset) in
                    let imageManager = PHImageManager.defaultManager()
                    let requestOption = PHImageRequestOptions()
                    requestOption.deliveryMode = .HighQualityFormat
                    requestOption.version = .Current
                    requestOption.networkAccessAllowed = true
                    requestOption.resizeMode = .None
                    requestOption.progressHandler = { progress, error, stop, info in
                        chatLog("in progressHandler... \(progress)")
                    }
                    
                    imageManager.requestImageForAsset(phAsset, targetSize: CGSizeMake(1000, 1000), contentMode: .AspectFill, options: requestOption, resultHandler: { (result, info) in
                        guard let resultImage = result  else{
                            return
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), { 
                            if imagePickerController.originSelectedAssets != nil && imagePickerController.originSelectedAssets.containsObject(phAsset){
                                //发原图
                                let sendImage = resultImage.resizedImageByWidth(UInt(jPushUpLoadOriginImgWidth))
                                self.didSendImage(sendImage)
                            }else{
                                //发自动剪裁过的图片
                                let sendImage = resultImage.resizedImageByWidth(UInt(jPushUpLoadImgWidth))
                                self.didSendImage(sendImage)
                            }
                        })
                    })
                })//end forEach
                imagePickerController.dismissViewControllerAnimated(true, completion: nil)
            }
            
            dispatch_async(dispatch_get_main_queue(), block)
        }else{
            guard let assetItems = assets as? [ALAsset] else{
                return
            }
            
            assetItems.forEach({ (alAsset) in
                dispatch_async(dispatch_get_main_queue(), { 
                    let highQualityImage = UIImage.fullResolutionImageFromALAsset(alAsset)
                    let sendImage = highQualityImage.resizedImageByWidth(UInt(jPushUpLoadImgWidth))
                    self.didSendImage(sendImage)
                })
                imagePickerController.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
    
    public func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        imagePickerController.dismissViewControllerAnimated(true, completion: nil)
    }
}


//MARK: UITableViewDelegate
extension IMChatViewController{
    override public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let chatViewModel = chatDataSource.messageModelAtIndexPath(indexPath)
        guard let jchatViewModel = chatViewModel else{
            return 44
        }
        
        if let cellCacheHeight = jchatViewModel.cellCacheHeight {
            return cellCacheHeight
        }
        
        switch jchatViewModel.contentType {
        case .Text:
            let height = ChatTextMessageTableViewCell.heightWithChatMsg(jchatViewModel)
            jchatViewModel.cellCacheHeight = height
            return height
        case .Voice:
            let height = ChatAudioMessageTableViewCell.heightWithChatMsg(jchatViewModel)
            jchatViewModel.cellCacheHeight = height
            return height
        case .Image:
            let height = ChatImageMessageTableViewCell.heightWithChatMsg(jchatViewModel)
            jchatViewModel.cellCacheHeight = height
            return height
        case .Custom:
            switch jchatViewModel.customMsgType{
            case .BrowseProduct:
                let height = ChatProductMessageTableViewCell.heightWithChatMsg(jchatViewModel)
                jchatViewModel.cellCacheHeight = height
                return height
            case .None:
                let height = ChatTextMessageTableViewCell.heightWithChatMsg(jchatViewModel)
                jchatViewModel.cellCacheHeight = height
                return height
            }
        default:
            let height = ChatTipMessageTableViewCell.heightWithChatMsg(jchatViewModel)
            jchatViewModel.cellCacheHeight = height
            return height
        }
        
        
    }
}


//MARK: XHMessageTableViewControllerDelegate  (send message)
extension IMChatViewController{
    public override func didSendText(text: String!, fromSender sender: String!, onDate date: NSDate!) {
        let sendText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if sendText.isEmpty{
            showAlertWithTitle("提示", message: "发送消息不能为空", presentViewController: self)
            return
        }
        
        if sendText.characters.count > 300 {
            showAlertWithTitle("提示", message: "文本消息不能超过300个字符", presentViewController: self)
            return
        }
        
        if self.checkHasSensitiveWords(text) {
            return
        }
        
        let textContent = JMSGTextContent(text: sendText)
        let msg_o = chatConversation.createMessageWithContent(textContent)
        guard let msg = msg_o else{
            return
        }
        
        let chatViewModel = JChatViewModel(message: msg)
        chatConversation.sendMessage(msg)
        chatDataSource.handleChatMessageModelForSend(chatViewModel)
        
        self.finishSendMessageWithBubbleMessageType(.Text)
    }
    
    public override func didSendVoice(voicePath: String!, voiceDuration: String!, fromSender sender: String!, onDate date: NSDate!) {
        guard let voiceTime = Double(voiceDuration) where voiceTime > 0.5 && voiceTime <= 60 else{
            chatLog("录音时长小于 0.5s 或者大于  60s")
            return
        }
        
        let voiceContent = JMSGVoiceContent(voiceData: NSData.init(contentsOfFile:voicePath)!, voiceDuration: voiceTime)
        let msg_o = chatConversation.createMessageWithContent(voiceContent)
        guard let msg = msg_o else{
            return
        }
        
        let chatViewModel = JChatViewModel(message: msg)
        chatConversation.sendMessage(msg)
        chatDataSource.handleChatMessageModelForSend(chatViewModel)
        
        self.finishSendMessageWithBubbleMessageType(.Voice)

        deletFileWithPath(voicePath)        
    }
    
    public override func didSendPhoto(photo: UIImage!, fromSender sender: String!, onDate date: NSDate!) {
        if photo == nil{
            return
        }
        
        let imageContent = JMSGImageContent(imageData: UIImagePNGRepresentation(photo)!)
        if imageContent == nil{
            return
        }
        
        let msg_o = chatConversation.createMessageWithContent(imageContent!)
        guard let msg = msg_o else{
            return
        }
        
        let chatViewModel = JChatViewModel(message: msg)
        chatConversation.sendMessage(msg)
        chatDataSource.handleChatMessageModelForSend(chatViewModel)
        
        self.finishSendMessageWithBubbleMessageType(.Photo)
        
    }
    
    public func didSendImage(sendImage: UIImage){
        didSendPhoto(sendImage, fromSender: nil, onDate: nil)
    }
}

//MARK: ChatMessageTableViewCellDelegate
extension IMChatViewController: ChatMessageTableViewCellDelegate{
    
    public func messageTableViewCell(cell: ChatMessageTableViewCell, tapPictureWithView contentImageView: UIImageView, messageId msgId: String) {
        guard let msgModel = chatDataSource.allMessageModelsDic[msgId] else{
            return
        }
        
        let photo = IMMJPhoto()
        photo.message = msgModel
        photo.srcImageView = contentImageView
        
        let browser = IMMJPhotoBrowser()
        browser.currentPhotoIndex = 0
        browser.photos = [photo]
        browser.conversation = chatConversation
        browser.show()
    }
    
    
    //重发消息
    public func messageTableViewCell(cell: ChatMessageTableViewCell, resendMessageWithModel chatMsgModel: JChatViewModel) {
        chatConversation.sendMessage(chatMsgModel.message)
        
        let _ = chatDataSource.getIndexForMessageId(chatMsgModel.message.msgId).map { (index) -> Void in
            reloadCellWithIndex(index)
        }
    }
    
    public func messageTableViewCell(cell: ChatMessageTableViewCell, actionForAudioMsgModel chatModel: JChatViewModel) {
        if !chatModel.isPlayingAudio{
            //没有播放
            if JChatAudioPlayerHelper.sharedInstance.isPlaying(){
                JChatAudioPlayerHelper.sharedInstance.stopAudio()
            }
            
            guard let voiceContent = chatModel.message.content as? JMSGVoiceContent else{
                return
            }
            voiceContent.voiceData({ (data, objectId, error) in
                if error == nil && data != nil{
                    JChatAudioPlayerHelper.sharedInstance.managerAudioWithData(data, toplay: true)
                    JChatAudioPlayerHelper.sharedInstance.currentPlayModel = chatModel
                    chatModel.isPlayingAudio = true
                }else{
                    chatLog("下载语音数据失败 \(error)")
                }
                
                self.reloadCellWithMessageId(chatModel.message.msgId)
            })
            
            
        }else{
            //
            chatModel.isPlayingAudio = false
            JChatAudioPlayerHelper.sharedInstance.stopAudio()
            JChatAudioPlayerHelper.sharedInstance.currentPlayModel = nil
            
            reloadCellWithMessageId(chatModel.message.msgId)
        }
    }
}













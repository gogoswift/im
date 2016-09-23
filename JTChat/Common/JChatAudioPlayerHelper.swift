//
//  JChatAudioPlayerHelper.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/26.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import UIKit
import AVFoundation

protocol JChatAudioPlayerHelperDelegate {
  func didAudioPlayerBeginPlay(AudioPlayer:AVAudioPlayer)
  func didAudioPlayerStopPlay(AudioPlayer:AVAudioPlayer)
  func didAudioPlayerPausePlay(AudioPlayer:AVAudioPlayer)
}

class JChatAudioPlayerHelper: NSObject {

  var player:AVAudioPlayer!
    var delegate:JChatAudioPlayerHelperDelegate?{
        didSet{
            if delegate == nil{
                self.stopAudio()
            }
        }
    }
    
    var currentPlayModel: JChatViewModel?
  
  class var sharedInstance: JChatAudioPlayerHelper {
    struct Static {
      static var onceToken: dispatch_once_t = 0
      static var instance: JChatAudioPlayerHelper? = nil
    }
    dispatch_once(&Static.onceToken) {
      Static.instance = JChatAudioPlayerHelper()
    }
    return Static.instance!
  }
  
  override init() {
    super.init()
    self.changeProximityMonitorEnableState(true)
    UIDevice.currentDevice().proximityMonitoringEnabled = false
  }
    
    deinit{
        self.changeProximityMonitorEnableState(false)
    }

  
  func managerAudioWithData(data:NSData, toplay:Bool) {
    if toplay {
      self.playAudioWithData(data)
    } else {
      self.pausePlayingAudio()
    }
  }
  
  func playAudioWithData(voiceData:NSData) {
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
    } catch let error as NSError {
      print("set category fail \(error)")
    }
    
    if self.player != nil {
      self.player.stop()
      self.player = nil
    }
    
    do {
      let pl:AVAudioPlayer = try AVAudioPlayer(data: voiceData)
      pl.delegate = self
      pl.play()
      self.player = pl
    } catch let error as NSError {
      print("alloc AVAudioPlayer with voice data fail with error \(error)")
    }
    
    UIDevice.currentDevice().proximityMonitoringEnabled = true
    
    self.delegate?.didAudioPlayerBeginPlay(player)
  }

  func pausePlayingAudio() {
    self.player?.pause()
    if (self.player != nil) {
        self.delegate?.didAudioPlayerPausePlay(self.player)
    }
    
  }
  
  func stopAudio() {
    if self.player == nil{
        return
    }
    
    if self.player.playing {
      self.player.stop()
    }
    
    UIDevice.currentDevice().proximityMonitoringEnabled = false
    self.delegate?.didAudioPlayerStopPlay(self.player)
  }
    
    func isPlaying() -> Bool{
        guard let player = self.player else{
            return false
        }
        return player.playing
    }
    
    
    func changeProximityMonitorEnableState(enable: Bool){
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        if UIDevice.currentDevice().proximityMonitoringEnabled {
            if enable{
                //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
                NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sensorStateChange(_:)), name: UIDeviceProximityStateDidChangeNotification, object: nil)
            }else{
                //删除近距离事件监听
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceProximityStateDidChangeNotification, object: nil)
                UIDevice.currentDevice().proximityMonitoringEnabled = false
            }
        }
        
    }
    
    
    func sensorStateChange(notification: NSNotificationCenter){
        //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
        if UIDevice.currentDevice().proximityState == true{
            //黑屏
             _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        }else{
            //没黑屏幕
            _ = try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            if player == nil || !player.playing{
                //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
                UIDevice.currentDevice().proximityMonitoringEnabled = false
            }
            
        }
    }
}


extension JChatAudioPlayerHelper:AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
    self.stopAudio()
    self.delegate?.didAudioPlayerStopPlay(player)
  }
}

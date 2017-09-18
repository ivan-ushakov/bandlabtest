//
//  SoundPlayer.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 14/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import Foundation
import AVFoundation

struct SoundPlayerState {
    var playing: Bool
    var song: Song
}

struct SoundPlayerTime {
    var current: Int
    var duration: Int
}

extension NSNotification.Name {
    
    static let SoundPlayerState = Notification.Name("SoundPlayerState")
    
    static let SoundPlayerTime = Notification.Name("SoundPlayerTime")
}

class SoundPlayer: NSObject {
    
    private var player: AVPlayer?
    
    private var song: Song?
    
    func play(_ song: Song) {
        if let player = self.player {
            player.pause()
        }
        
        guard let url = URL(string: song.audioURL) else { return }
        
        let item = AVPlayerItem(url: url)
        self.player = AVPlayer(playerItem: item)
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 1), queue: nil) { [weak self] time in
            guard let item = self?.player?.currentItem else { return }
            
            if item.status != .readyToPlay {
                return
            }
            
            let object = SoundPlayerTime(current: Int(time.seconds), duration: Int(item.duration.seconds))
            NotificationCenter.default.post(name: .SoundPlayerState, object: self, userInfo: ["object": object])
        }
        
        self.player?.play()
        
        self.song = song
        
        let object = SoundPlayerState(playing: true, song: song)
        NotificationCenter.default.post(name: .SoundPlayerState, object: self, userInfo: ["object": object])
    }
    
    func stop() {
        if let player = self.player {
            player.pause()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if let player = self.player, player.rate == 0.0 {
                notifyStop()
            }
        }
    }
    
    // MARK: Private
    
    private func notifyStop() {
        guard let song = self.song else { return }
        
        let object = SoundPlayerState(playing: false, song: song)
        NotificationCenter.default.post(name: .SoundPlayerState, object: self, userInfo: ["object": object])
    }
}

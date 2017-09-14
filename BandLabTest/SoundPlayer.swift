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

extension NSNotification.Name {
    
    static let SoundPlayerState = Notification.Name("SoundPlayerState")
}

class SoundPlayer: NSObject {
    
    private var player: AVPlayer?
    
    private var song: Song?
    
    func play(_ song: Song) {
        if let player = self.player {
            player.pause()
        }
        
        guard let url = URL(string: song.audioURL) else { return }
        
        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.player?.addObserver(self, forKeyPath: "rate", options: .new, context: nil)
        self.player?.play()
        
        self.song = song
        
        let state = SoundPlayerState(playing: true, song: song)
        NotificationCenter.default.post(name: .SoundPlayerState, object: self, userInfo: ["state": state])
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
        
        let state = SoundPlayerState(playing: false, song: song)
        NotificationCenter.default.post(name: .SoundPlayerState, object: self, userInfo: ["state": state])
    }
}

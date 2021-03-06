//
//  MainViewModel.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 17/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import Foundation

struct Property<T> {
    
    var value: T {
        didSet {
            self.onUpdate?(self.value)
        }
    }
    
    var onUpdate: ((T) -> ())?
    
    func fire() {
        self.onUpdate?(self.value)
    }
}

class SongCellModel {
    
    let authorName: String
    
    let authorAvatarURL: String
    
    let name: String
    
    let coverURL: String
    
    let audioURL: String
    
    let created: String
    
    let service: MainViewServiceProtocol
    
    var playing = Property<Bool>(value: false, onUpdate: nil)
    
    var time = Property<String?>(value: nil, onUpdate: nil)
    
    private let song: Song
    
    private var observers = [Any]()
    
    init(song: Song, service: MainViewServiceProtocol) {
        self.song = song
        self.service = service
        
        self.authorName = song.author.name
        self.authorAvatarURL = song.author.avatarURL
        self.name = song.name
        self.coverURL = song.coverURL
        self.audioURL = song.audioURL
        self.created = Formatter.instance.format(song.created)
    }
    
    deinit {
        removeObservers()
    }
    
    func loadImage(_ url: String, completion: @escaping (String, Data?) -> ()) {
        self.service.loadImage(url, completion: completion)
    }
    
    func play() {
        if self.playing.value {
            self.playing.value = false
            self.time.value = nil
            removeObservers()
            self.service.stopPlayer()
        } else {
            addObservers()
            self.service.play(self.song)
        }
    }
    
    private func addObservers() {
        let stateObserver = NotificationCenter.default.addObserver(forName: .SoundPlayerState, object: nil, queue: nil) { [weak self] object in
            guard let userInfo = object.userInfo, let state = userInfo["object"] as? SoundPlayerState else { return }
            if state.song.id == self?.song.id {
                self?.playing.value = state.playing
                self?.time.value = nil
            }
        }
        self.observers.append(stateObserver)
        
        let timeObserver = NotificationCenter.default.addObserver(forName: .SoundPlayerState, object: nil, queue: nil) { [weak self] object in
            guard let userInfo = object.userInfo, let time = userInfo["object"] as? SoundPlayerTime else { return }
            self?.time.value = "\(formatSeconds(time.current)) / \(formatSeconds(time.duration))"
        }
        self.observers.append(timeObserver)
    }
    
    private func removeObservers() {
        self.observers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

extension SongCellModel {
    
    static func create(song: Song, service: MainViewServiceProtocol) -> SongCellModel {
        return SongCellModel(song: song, service: service)
    }
}

class MainViewModel {
    
    var cells = Property<[SongCellModel]>(value: [SongCellModel](), onUpdate: nil)
    
    var onPlayerState: ((SoundPlayerState) -> ())?
    
    private let service: MainViewServiceProtocol
    
    private var observer: Any?
    
    init(service: MainViewServiceProtocol) {
        self.service = service
        
        self.observer = NotificationCenter.default.addObserver(forName: .SoundPlayerState, object: nil, queue: nil) { [weak self] object in
            guard let userInfo = object.userInfo, let state = userInfo["object"] as? SoundPlayerState else { return }
            self?.onPlayerState?(state)
        }
    }
    
    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func load() {
        self.service.fetch { [weak self] result in
            guard let strong = self else { return }
            
            guard let array = result?.map({ SongCellModel.create(song: $0, service: strong.service) }) else {
                // TODO show error
                return
            }
            
            DispatchQueue.main.async { strong.cells.value = array }
        }
    }
    
    func stopPlayer() {
        self.service.stopPlayer()
    }
}

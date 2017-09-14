//
//  MainViewService.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 14/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import Foundation

protocol MainViewServiceProtocol {

    func fetch(_ completion: @escaping ([Song]?) -> ())
    
    func loadImage(_ url: String, completion: @escaping (String, Data?) -> ())
    
    func play(_ song: Song)
    
    func stopPlayer()
}

class MainViewService: MainViewServiceProtocol {
    
    private let cache = NSCache<NSString, AnyObject>()
    
    private let player = SoundPlayer()
    
    func fetch(_ completion: @escaping ([Song]?) -> ()) {
        guard let url = URL(string: "https://gist.githubusercontent.com/anonymous/fec47e2418986b7bdb630a1772232f7d/raw/5e3e6f4dc0b94906dca8de415c585b01069af3f7/57eb7cc5e4b0bcac9f7581c8.json") else { fatalError() }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let e = error {
                print("API error: \(e)")
                completion(nil)
                return
            }
            
            guard let object = parse(data: data) else {
                print("API error: can't parse data")
                completion(nil)
                return
            }
            
            guard let array = object["data"] as? [Dictionary<String, Any>] else {
                print("API error: invalid JSON")
                completion(nil)
                return
            }
            
            completion(array.flatMap({ Song.map($0) }))
        }
        task.resume()
    }
    
    func loadImage(_ url: String, completion: @escaping (String, Data?) -> ()) {
        if let data = self.cache.object(forKey: NSString(string: url)) as? Data {
            completion(url, data)
            return
        }
        
        guard let file = URL(string: url) else {
            completion(url, nil)
            return
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: file) { [weak self] (data, response, error) in
            if let e = error {
                print("load error: \(e)")
                completion(url, nil)
                return
            }
            
            if let imageData = data {
                DispatchQueue.main.async {
                    self?.cache.setObject(imageData as AnyObject, forKey: NSString(string: url))
                }
            }
            
            completion((url, data))
        }
        task.resume()
    }
    
    func play(_ song: Song) {
        self.player.play(song)
    }
    
    func stopPlayer() {
        self.player.stop()
    }
}

func parse(data: Data?) -> Dictionary<String, Any>? {
    guard let d = data else {
        return nil
    }
    
    if let debug = String(data: d, encoding: .utf8) {
        print("API response: \(debug)")
    }
    
    do {
        let object = try JSONSerialization.jsonObject(with: d)
        switch object {
        case let map as Dictionary<String, Any>:
            return map
        default:
            return nil
        }
    } catch {
        return nil
    }
}

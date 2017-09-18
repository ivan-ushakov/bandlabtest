//
//  Domain.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 17/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import Foundation

struct Author {
    
    var name: String
    
    var avatarURL: String
    
}

extension Author {
    static func create(_ object: Dictionary<String, Any>) -> Author? {
        guard let name = object["name"] as? String else { return nil }
        
        guard let picture = object["picture"] as? Dictionary<String, Any>,
            let avatarURL = picture["xs"] as? String else { return nil }
        
        return Author(name: name, avatarURL: avatarURL)
    }
}

struct Song {
    
    var id: String
    
    var author: Author
    
    var name: String
    
    var coverURL: String
    
    var audioURL: String
    
    var created: Date
}

extension Song {
    
    static func create(_ object: Dictionary<String, Any>) -> Song? {
        guard let id = object["id"] as? String else { return nil }
        
        guard let authorObject = object["author"] as? Dictionary<String, Any>,
            let author = Author.create(authorObject) else { return nil }
        
        guard let name = object["name"] as? String else { return nil }
        
        guard let picture = object["picture"] as? Dictionary<String, Any>,
            let coverURL = picture["m"] as? String else { return nil }
        
        guard let audioURL = object["audioLink"] as? String else { return nil }
        
        guard let createdOn = object["createdOn"] as? String,
            let created = Parser.instance.parse(createdOn) else { return nil }
        
        return Song(id: id,
                    author: author,
                    name: name,
                    coverURL: coverURL,
                    audioURL: audioURL,
                    created: created)
    }
}

fileprivate class Parser {
    
    static let instance = Parser()
    
    private let formatter = DateFormatter()
    
    private init() {
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    }
    
    func parse(_ value: String) -> Date? {
        return self.formatter.date(from: value)
    }
}

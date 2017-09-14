//
//  Author.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 14/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import Foundation

struct Author {
    
    var name: String
    
    var avatarURL: String

}

extension Author {
    static func map(_ object: Dictionary<String, Any>) -> Author? {
        guard let name = object["name"] as? String else { return nil }
        
        guard let picture = object["picture"] as? Dictionary<String, Any>,
            let avatarURL = picture["xs"] as? String else { return nil }
        
        return Author(name: name, avatarURL: avatarURL)
    }
}

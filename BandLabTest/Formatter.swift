//
//  Formatter.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 18/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import Foundation

class Formatter {
    
    static let instance = Formatter()
    
    private let f = DateFormatter()
    
    private init() {
        f.locale = Locale(identifier: "US_en")
        f.dateFormat = "h:mm dd.MM.yyyy"
    }
    
    func format(_ date: Date) -> String {
        return f.string(from:date)
    }
}

func formatSeconds(_ seconds: Int) -> String {
    return String(seconds / 60) + ":" + String(format: "%02d", seconds % 60)
}

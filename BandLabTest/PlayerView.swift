//
//  PlayerView.swift
//  BandLabTest
//
//  Created by Ivan Ushakov on 14/09/2017.
//  Copyright © 2017 Ivan Ushakov. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
    let button = UIButton(type: .custom)
    
    let titleLabel = UILabel()
    
    let authorLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonSize = self.frame.height
        self.button.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        let labelWidth = self.frame.width - buttonSize
        let labelHeight = floor(buttonSize / 2)
        let labelX = self.button.frame.maxX
        self.titleLabel.frame = CGRect(x: labelX, y: 0, width: labelWidth, height: labelHeight)
        self.authorLabel.frame = CGRect(x: labelX, y: labelHeight, width: labelWidth, height: labelHeight)
    }
    
    private func setupUI() {
        self.button.setImage(UIImage(named: "pause_icon_small"), for: .normal)
        addSubview(self.button)
        
        self.titleLabel.font = UIFont.systemFont(ofSize: 12)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.textAlignment = .center
        self.titleLabel.backgroundColor = UIColor.clear
        addSubview(self.titleLabel)
        
        self.authorLabel.font = UIFont.systemFont(ofSize: 12)
        self.authorLabel.textColor = UIColor.lightGray
        self.authorLabel.textAlignment = .center
        self.authorLabel.backgroundColor = UIColor.clear
        addSubview(self.authorLabel)
    }
}

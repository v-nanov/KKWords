//
//  WarningBadge.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/7/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

class WarningBadge: NSTextField {
    var count = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.wantsLayer = true
        self.layer?.cornerRadius = self.frame.size.height / 2
        self.layer?.masksToBounds = true
    }
    
    func set(_ wrongCount: Int) {
        self.count = wrongCount
        if wrongCount > 999 {
            self.stringValue = "999+"
        }
        else {
            self.integerValue = wrongCount
        }
        if wrongCount < 1 {
            self.isHidden = true
        }
        else {
            self.isHidden = false
        }
    }
    
    func incr() {
        self.set(self.count + 1)
    }
    
    func reset() {
        self.set(0)
    }
}

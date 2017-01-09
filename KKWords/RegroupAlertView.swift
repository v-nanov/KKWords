//
//  RegroupAlertView.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/9/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

class RegroupAlertView: NSAlert {
    override init() {
        super.init()
        self.addButton(withTitle: "OK")
        self.addButton(withTitle: "Cancel")
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        
        self.accessoryView = textField
        self.window.initialFirstResponder = textField
    }
}

//
//  WindowController.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/5/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        
        let x = window!.screen!.frame.width / 2 - window!.frame.width / 2
        let y = window!.screen!.frame.height / 2 - window!.frame.height / 2
        window?.setFrame(NSMakeRect(x, y, window!.frame.width, window!.frame.height), display: true)
    }
}

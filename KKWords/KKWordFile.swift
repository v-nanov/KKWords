//
//  KKWordFile.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/8/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

class KKWordFile {
    static func save(to file: String, wordList: [WordInfo]) {
        let writer = CSV(file)
        for word in wordList {
            writer.fileBodyContent.append([word.eng!, word.chn!])
        }
        writer.save()
    }
    
    static func read(from file: String, completionHandler: @escaping ([[String]]) -> ()) {
        let csv = CSV(file)
        csv.read(completionHandler: completionHandler)
    }
}

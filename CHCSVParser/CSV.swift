//
//  CSV.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/8/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Foundation

class CSV: NSObject, CHCSVParserDelegate {
    var filePath: String
    
    var fileHeader: [String] = []
    var fileBodyContent: [[String]] = []
    
    private var readCompletionHandler: ([[String]]) -> () = { _ in }
    private var rowCache: [String] = []
    
    init(_ filePath: String) {
        self.filePath = filePath
    }
    
    func save() {
        let writer = CHCSVWriter(forWritingToCSVFile: self.filePath)!
        
        if self.fileHeader.count != 0 {
            for col in self.fileHeader {
                writer.writeField(col)
            }
            writer.finishLine()
        }
        
        for row in self.fileBodyContent {
            for col in row {
                writer.writeField(col)
            }
            writer.finishLine()
        }
        
        writer.closeStream()
    }
    
    func read(completionHandler: @escaping ([[String]]) -> ()) {
        let stream = InputStream(fileAtPath: self.filePath)
        self.readCompletionHandler = completionHandler
        let reader = CHCSVParser(inputStream: stream, usedEncoding: nil, delimiter: 44)!
        reader.delegate = self
        reader.parse()
    }
    
    func parser(_ parser: CHCSVParser!, didBeginLine recordNumber: UInt) {
        self.rowCache = []
    }
    
    func parser(_ parser: CHCSVParser!, didEndLine recordNumber: UInt) {
        self.fileBodyContent.append(self.rowCache)
    }
    
    func parser(_ parser: CHCSVParser!, didReadField field: String!, at fieldIndex: Int) {
        self.rowCache.append(field)
    }
    
    func parserDidEndDocument(_ parser: CHCSVParser!) {
        self.readCompletionHandler(self.fileBodyContent)
    }
}

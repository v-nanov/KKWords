//
//  KKUtils.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/6/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa
import SQLite

extension NSViewController {
    func showAlert(title: String, text: String) {
        KKUtils.showAlert(title: title, text: text, window: self.view.window)
    }
}

extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class KKUtils {
    static func showAlert(title: String, text: String, window: NSWindow? = nil) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        
        if window != nil {
            alert.beginSheetModal(for: window!, completionHandler: nil)
        }
        else {
            alert.runModal()
        }
    }
    
    static func importOldData() {
        let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        
        let db = try! Connection("/Users/KanzakiMirai/Downloads/iMaid Words/imaid.words")
        
        var i = 1
        for row in try! db.prepare("SELECT * FROM titles") {
            let wordListId = Int(row[0] as! Int64)
            let wordListName = row[1] as! String
            
            if !wordListName.hasPrefix("错词记录") {
                let wordList: WordList!
                if #available(OSX 10.12, *) {
                    wordList = WordList(context: context)
                } else {
                    // Fallback on earlier versions
                    wordList = NSEntityDescription.insertNewObject(forEntityName: "WordList", into: context) as! WordList
                }
                wordList.name = wordListName
                wordList.insertTime = NSDate()
                
                for row in try! db.prepare("SELECT * FROM words WHERE parentid = (?)").run([wordListId]) {
                    let wordId = row[0] as! Int64
                    print("WORD_ID: \(wordId), \(i)/9282")
                    let chn = row[1] as? String
                    let eng = row[2] as? String
                    
                    print("\(eng) - \(chn)")
                    
                    if chn != nil && eng != nil {
                        let wordInfo: WordInfo!
                        if #available(OSX 10.12, *) {
                            wordInfo = WordInfo(context: context)
                        } else {
                            // Fallback on earlier versions
                            wordInfo = NSEntityDescription.insertNewObject(forEntityName: "WordInfo", into: context) as! WordInfo
                        }
                        wordInfo.chn = chn!.trimmingCharacters(in: .whitespacesAndNewlines)
                        wordInfo.eng = eng!.trimmingCharacters(in: .whitespacesAndNewlines)
                        wordInfo.insertTime = NSDate()
                        wordInfo.parentList = wordList
                    }
                    
                    i += 1
                }
                do {
                    try context.save()
                } catch let error {
                    self.showAlert(title: "Warning", text: "Word list save fail, error: \(error.localizedDescription)")
                }
            }
        }
    }
}

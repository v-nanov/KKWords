//
//  AppMenu.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/6/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

class AppMenu: NSMenu {
    @IBAction func deleteAllData(sender: AnyObject!) {
        let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
        let wordListFetchRequest: NSFetchRequest<WordList> = WordList.fetchRequest()
        let wordInfoFetchRequest: NSFetchRequest<WordInfo> = WordInfo.fetchRequest()
        
        do {
            let wordListResults = try context.fetch(wordListFetchRequest)
            for wordResult in wordListResults {
                context.delete(wordResult)
            }
            
            let wordInfoResults = try context.fetch(wordInfoFetchRequest)
            for wordInfoResult in wordInfoResults {
                context.delete(wordInfoResult)
            }
        }
        catch let error {
            KKUtils.showAlert(title: "Warning", text: "Can't delete data, error: \(error.localizedDescription)")
        }
        do {
            try context.save()
        } catch let error {
            KKUtils.showAlert(title: "Warning", text: "Word list save fail, error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func gotoGithub(sender: AnyObject!) {
        let url = URL(string:"http://example.com")!
        NSWorkspace.shared().open(url)
    }
}

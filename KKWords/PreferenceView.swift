//
//  PreferenceView.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/8/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

class PreferenceView: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    var wordListData: [WordList] = []
    
    @IBOutlet var tableView: NSTableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // load word list
        self.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.wordListData.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let colIndex = self.tableView.tableColumns.index(of: tableColumn!)
        if colIndex == 0 {
            return self.wordListData[row].name!
        }
        else {
            return self.wordListData[row].allWords?.count
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?, row: Int) -> Bool {
        return false
    }
    
    func reloadData() {
        let fetchRequest: NSFetchRequest<WordList> = WordList.fetchRequest()
        let sortDate = NSSortDescriptor(key: "insertTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDate]
        do {
            self.wordListData = try self.context.fetch(fetchRequest)
        }
        catch let error {
            self.showAlert(title: "Warning", text: "Word list refresh fail, error: \(error.localizedDescription)")
        }
        self.tableView.reloadData()
    }
    
    @IBAction func importCSV(sender: AnyObject!) {
        let panel = NSOpenPanel()
        panel.message = "Import *.csv word list."
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.canChooseFiles = true
        panel.allowedFileTypes = ["csv"]
        
        panel.beginSheetModal(for: self.view.window!, completionHandler: { (result) in
            if result == NSFileHandlingPanelOKButton {
                let fileURL = panel.url!.path
                KKWordFile.read(from: fileURL, completionHandler: { (data) in
                    let wordList: WordList!
                    if #available(OSX 10.12, *) {
                        wordList = WordList(context: self.context)
                    } else {
                        // Fallback on earlier versions
                        wordList = NSEntityDescription.insertNewObject(forEntityName: "WordList", into: self.context) as! WordList
                    }
                    wordList.name = URL(string: fileURL)!.deletingPathExtension().lastPathComponent
                    wordList.insertTime = NSDate()
                    
                    for row in data {
                        let eng = row[0]
                        let chn = row[1]
                        
                        let wordInfo: WordInfo!
                        if #available(OSX 10.12, *) {
                            wordInfo = WordInfo(context: self.context)
                        } else {
                            // Fallback on earlier versions
                            wordInfo = NSEntityDescription.insertNewObject(forEntityName: "WordInfo", into: self.context) as! WordInfo
                        }
                        wordInfo.chn = chn
                        wordInfo.eng = eng
                        wordInfo.insertTime = NSDate()
                        wordInfo.parentList = wordList
                    }
                    
                    do {
                        try self.context.save()
                    } catch let error {
                        self.showAlert(title: "Warning", text: "Word list save fail, error: \(error.localizedDescription)")
                    }
                    
                    self.reloadData()
                    NotificationCenter.default.post(name: Notification.Name("word_list_changed"), object: nil)
                })
            }
        })

    }
    
    @IBAction func deleteWordListData(sender: AnyObject!) {
        let selctedRows = self.tableView.selectedRowIndexes
        var removedWordListData: [WordList] = []
        
        for row in selctedRows {
            removedWordListData.append(self.wordListData[row])
        }
        
        for each in removedWordListData {
            self.wordListData.remove(at: self.wordListData.index(of: each)!)
            self.context.delete(each)
        }
        
        do {
            try self.context.save()
        } catch let error {
            self.showAlert(title: "Warning", text: "Word list save fail, error: \(error.localizedDescription)")
        }
        NotificationCenter.default.post(name: Notification.Name("word_list_changed"), object: nil)
        self.reloadData()
    }
}

//
//  QuizViewController.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/5/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa
import CoreData

class QuizViewController: NSViewController {
    @IBOutlet var wordListButton: NSPopUpButton!
    @IBOutlet var wordGroupButton: NSPopUpButton!
    @IBOutlet var countDownTimeButton: NSPopUpButton!
    
    @IBOutlet var englishLabel: NSTextField!
    @IBOutlet var chineseLabel: NSTextField!
    
    @IBOutlet var toggleStartButton: NSButton!
    
    @IBOutlet var markWrongButton: NSButton!
    @IBOutlet var markCorrectButton: NSButton!
    @IBOutlet var pronounceButton: NSButton!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    @IBOutlet var wordCountProgress: NSTextField!
    @IBOutlet var loadingIndicator: NSProgressIndicator!
    
    @IBOutlet var correctRateIndicator: NSTextField!
    @IBOutlet var wrongCountIndicator: WarningBadge!
    
    @IBOutlet var textMode: NSButton!
    @IBOutlet var audioMode: NSButton!
    @IBOutlet var shuffleMode: NSButton!
    
    let context = (NSApplication.shared().delegate as! AppDelegate).managedObjectContext
    
    var wordListCurrentIndex = 0
    var wordGroupCurrentIndex = 0
    
    var chapterGroupLimit = 0
    
    var allWordList: [WordList] = []
    var currentWords: [WordInfo] = []
    var wrongWords: [WordInfo] = []
    
    var currentWordIndex = 0
    var quizStarted = false
    var countDownTimer: SwiftTimer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: Notification.Name("word_list_changed"), object: nil)
    }

    func reloadData() {
        // refresh word list
        self.loadWordList()
        self.loadWordListButton()
        // load default word
        self.loadCurrentWords()
        self.loadWordGroup()
        // load settings
        self.loadSettings()
    }
    
    func loadWordList() {
        let fetchRequest: NSFetchRequest<WordList> = WordList.fetchRequest()
        let sortDate = NSSortDescriptor(key: "insertTime", ascending: true)
        fetchRequest.sortDescriptors = [sortDate]
        do {
            self.allWordList = try self.context.fetch(fetchRequest)
        }
        catch let error {
            self.showAlert(title: "Warning", text: "Word list refresh fail, error: \(error.localizedDescription)")
        }
    }
    
    func loadWordListButton() {
        self.wordListButton.removeAllItems()
        for wordList in self.allWordList {
            // random string, ensure duplicaed item will not be overriden
            self.wordListButton.addItem(withTitle: "dYy|<-#:L:IiBVUtg2")
            self.wordListButton.lastItem?.title = wordList.name!
        }
//        if self.allWordList.count > 0 {
//            self.wordListButton.menu?.addItem(NSMenuItem.separator())
//        }
        // self.wordListButton.addItem(withTitle: "dYy|<-#:L:IiBVUtg2")
        // self.wordListButton.lastItem?.title = "Manage Word List..."
    }
    
    func currentChapterRange(_ i: Int) -> (Int, Int) {
        var chapterCount = 0
        if self.chapterGroupLimit != 0 {
            chapterCount = Int(ceil(Double((self.allWordList[self.wordListCurrentIndex].allWords?.count)!) / Double(self.chapterGroupLimit)))
        }
        let lower = (self.chapterGroupLimit * i) + 1
        var upper = self.chapterGroupLimit * (i + 1)
        if i == (chapterCount - 1) {
            upper = (self.allWordList[self.wordListCurrentIndex].allWords?.count)!
        }
        return (lower, upper)
    }
    
    func loadCurrentWords() {
        // stop current quiz first
        if self.quizStarted {
            self.stopQuiz()
        }
        
        let currentIndex = self.wordListCurrentIndex
        
        self.currentWords = []
        let allWordsArray = self.allWordList[currentIndex].allWords!
        
        let lower: Int
        let upper: Int
        if self.wordGroupCurrentIndex == 0 {
            lower = 0
            upper = allWordsArray.count - 1
        }
        else {
            let range = self.currentChapterRange(self.wordGroupCurrentIndex - 2)
            lower = range.0 - 1
            upper = range.1 - 1
        }
        
        // print("RANGE(\(lower), \(upper))")
        
        for i in lower...upper {
            let wordInfo = allWordsArray[i] as! WordInfo
            self.currentWords.append(wordInfo)
        }
        
        // print("self.allWordList[self.wordListCurrentIndex].allWords?.count = \((self.allWordList[self.wordListCurrentIndex].allWords?.count)!)")
        
        self.chapterGroupLimit = Int(self.allWordList[currentIndex].groupLimit)
        // self.chapterGroupLimit = 50
        if self.shuffleMode.state == NSOnState {
            self.currentWords.shuffle()
        }
        
        // set progress
        self.wordCountProgress.stringValue = "1/\(self.currentWords.count)"
    }
    
    func loadWordGroup() {
        var chapterCount = 0
        
        if self.chapterGroupLimit != 0 {
            chapterCount = Int(ceil(Double((self.allWordList[self.wordListCurrentIndex].allWords?.count)!) / Double(self.chapterGroupLimit)))
        }
        
        self.wordGroupButton.removeAllItems()
        self.wordGroupButton.addItem(withTitle: "All")
        
        if chapterCount > 0 {
            self.wordGroupButton.menu?.addItem(NSMenuItem.separator())
            for i in 0..<chapterCount {
                let range = self.currentChapterRange(i)
                self.wordGroupButton.addItem(withTitle: "\(range.0) ~ \(range.1)")
            }
        }
        
        self.wordGroupButton.menu?.addItem(NSMenuItem.separator())
        self.wordGroupButton.addItem(withTitle: "Re-Group...")
    }
    
    func startQuiz() {
        // check can start or not
        let currentIndex = self.wordListCurrentIndex
        if currentIndex < self.allWordList.count {
            self.setProgress(to: 0)
            self.currentWordIndex = 0
            self.quizStarted = true
            self.markWrongButton.isEnabled = true
            self.pronounceButton.isEnabled = true
            self.markCorrectButton.isEnabled = true
            self.toggleStartButton.title = "Stop"
            self.shuffleMode.isEnabled = false
            self.correctRateIndicator.isHidden = false
            // reset wrong words
            self.wrongWords = []
            self.nextWord()
        }
        else {
            self.showAlert(title: "Warning", text: "Word List Not Valid")
        }
    }
    
    func stopQuiz() {
        self.setProgress(to: 0)
        self.quizStarted = false
        self.markWrongButton.isEnabled = false
        self.pronounceButton.isEnabled = false
        self.markCorrectButton.isEnabled = false
        self.toggleStartButton.title = "Start"
        self.correctRateIndicator.isHidden = true
        self.wrongCountIndicator.set(0)
        self.englishLabel.stringValue = "KK Words"
        self.chineseLabel.stringValue = "Ready to Start"
        self.shuffleMode.isEnabled = true
        self.countDownTimer.suspend()
        self.saveWrongWordList()
    }
    
    @IBAction func spaceTriggerCorrect(sender: AnyObject!) {
        self.markCorrectButton.performClick(sender)
    }
    
    @IBAction func enterTriggerWrong(sender: AnyObject!) {
        self.markWrongButton.performClick(sender)
    }

    @IBAction func wordMarkAsWrong(sender: AnyObject!) {
        self.wrongCountIndicator.incr()
        self.wrongWords.append(self.currentWords[self.currentWordIndex - 1])
        self.nextWord()
    }
    
    @IBAction func wordMarkAsCorrect(sender: AnyObject!) {
        if self.countDownTimer.isRunning {
            self.showChinese()
        }
        else {
            self.nextWord()
        }
    }
    
    @IBAction func pronounceWord(sender: AnyObject!) {
        self.loadingIndicator.frame.size.width = 16
        self.loadingIndicator.startAnimation(self)
        KKPronounce.say(word: self.currentWords[self.currentWordIndex - 1].eng!) { (error) in
            self.loadingIndicator.stopAnimation(self)
            self.loadingIndicator.frame.size.width = 0
            if error != nil {
                if KKPronounce.failCount < 2 {
                    KKPronounce.failCount += 1
                    DispatchQueue.main.async {
                        self.showAlert(title: "Warning", text: "Word pronounce fail, please check your network")
                    }
                }
            }
        }
    }
    
    @IBAction func toggleStartButton(sender: AnyObject!) {
        if !self.quizStarted {
            self.startQuiz()
        }
        else {
            self.stopQuiz()
        }
    }
    
    @IBAction func textAudioModeCheck(sender: AnyObject?) {
        if (self.textMode.state == NSOffState) && (self.audioMode.state == NSOffState) {
            if let lastCheckbox = sender as? NSButton {
                lastCheckbox.state = NSOnState
            }
        }
        // if text mode enabled
        if self.textMode.state == NSOnState {
            self.englishLabel.isHidden = false
        }
        // if text mode disabled
        else {
            self.englishLabel.isHidden = true
        }
        UserDefaults.standard.set(self.audioMode.state == NSOnState ? true : false, forKey: "audio_enabled")
        UserDefaults.standard.set(self.textMode.state == NSOnState ? true : false, forKey: "text_enabled")
    }
    
    @IBAction func setShuffleMode(sender: AnyObject!) {
        UserDefaults.standard.set(self.shuffleMode.state == NSOnState ? true : false, forKey: "shuffle_enabled")
        self.loadCurrentWords()
    }
    
    @IBAction func wordListSwitched(sender: NSPopUpButton!) {
        if sender.indexOfSelectedItem < self.allWordList.count {
            if self.wordListCurrentIndex != sender.indexOfSelectedItem {
                // load words
                self.wordListCurrentIndex = sender.indexOfSelectedItem
                self.wordGroupCurrentIndex = 0
                self.wordGroupButton.selectItem(at: 0)
                self.loadCurrentWords()
                self.loadWordGroup()
            }
        }
        else {
            sender.selectItem(at: self.wordListCurrentIndex)
        }
    }
    
    @IBAction func chapterSwitched(sender: NSPopUpButton!) {
        var chapterCount = 0
        
        if self.chapterGroupLimit != 0 {
            chapterCount = Int(ceil(Double((self.allWordList[self.wordListCurrentIndex].allWords?.count)!) / Double(self.chapterGroupLimit)))
        }
        
        if sender.indexOfSelectedItem < (chapterCount + 2) {
            self.wordGroupCurrentIndex = sender.indexOfSelectedItem
            // chapter switched, reload words
            self.loadCurrentWords()
        }
        else {
            sender.selectItem(at: self.wordGroupCurrentIndex)
            
            // split word list
            self.alertWordListSplit(title: "Re-Group Words", question: "How many words do you want in each group?", defaultValue: "", completionHandler: { (groupLimit) in
                if let groupLimitNum = Int(groupLimit) {
                    self.allWordList[self.wordListCurrentIndex].groupLimit = Int64(groupLimitNum)
                    
                    DispatchQueue.global {
                        do {
                            try self.context.save()
                        } catch let error {
                            DispatchQueue.main.async {
                                self.showAlert(title: "Warning", text: "Word list save fail, error: \(error.localizedDescription)")
                            }
                        }
                        self.chapterGroupLimit = groupLimitNum
                        self.loadWordGroup()
                    }
                }
            })
        }
    }
    
    func alertWordListSplit(title: String, question: String, defaultValue: String, completionHandler: @escaping (String) -> ()) {
        let regroupAlert = RegroupAlertView()
        regroupAlert.messageText = title
        regroupAlert.informativeText = question

        regroupAlert.beginSheetModal(for: self.view.window!) { (modalResponse) in
            if (modalResponse == NSAlertFirstButtonReturn) {
                completionHandler((regroupAlert.accessoryView as! NSTextField).stringValue)
            } else {
                completionHandler("")
            }
        }
    }
    
    @IBAction func quizIntervalSwitched(sender: NSPopUpButton!) {
        UserDefaults.standard.set(sender.indexOfSelectedItem, forKey: "interval_index")
    }
    
    func loadSettings() {
        UserDefaults.standard.register(defaults: ["audio_enabled": true])
        UserDefaults.standard.register(defaults: ["text_enabled": true])
        UserDefaults.standard.register(defaults: ["shuffle_enabled": false])

        UserDefaults.standard.register(defaults: ["interval_index": 0])
        
        let audioEnabled = UserDefaults.standard.bool(forKey: "audio_enabled")
        let textEnabled = UserDefaults.standard.bool(forKey: "text_enabled")
        let shuffleEnabled = UserDefaults.standard.bool(forKey: "shuffle_enabled")
        
        let intervalIndex = UserDefaults.standard.integer(forKey: "interval_index")
        
        self.audioMode.state = audioEnabled ? NSOnState : NSOffState
        self.textMode.state = textEnabled ? NSOnState : NSOffState
        self.shuffleMode.state = shuffleEnabled ? NSOnState : NSOffState
        self.countDownTimeButton.selectItem(at: intervalIndex)
    }
    
    func nextWord() {
        if self.currentWordIndex < self.currentWords.count {
            self.englishLabel.stringValue = self.currentWords[self.currentWordIndex].eng!
            self.chineseLabel.stringValue = self.currentWords[self.currentWordIndex].chn!
            self.currentWordIndex += 1
            if self.audioMode.state == NSOnState {
                self.pronounceWord(sender: self)
            }
            self.wordCountProgress.stringValue = "\(self.currentWordIndex)/\(self.currentWords.count)"
            self.setProgress(to: (Double(self.currentWordIndex) / Double(self.currentWords.count)) * 100)
            
            let wrongRate = Double(self.wrongWords.count) / Double(self.currentWords.count)
            var correctRate = 1 - wrongRate
            correctRate = round(correctRate * 10000) / 100
            
            self.correctRateIndicator.stringValue = "\(correctRate)%"
            
            // hide text
            if self.textMode.state == NSOffState {
                self.englishLabel.isHidden = true
            }
            else {
                self.englishLabel.isHidden = false
            }
            
            
            let intervalTimeAll = self.countDownTimeButton.indexOfSelectedItem + 3
            self.chineseLabel.integerValue = intervalTimeAll
            
            self.markWrongButton.isEnabled = false
            self.markCorrectButton.title = "Show  →"
            
            self.countDownTimer = SwiftTimer(interval: .seconds(1), repeats: true, handler: { [weak self] (timer) in
                if let strongSelf = self {
                    if strongSelf.chineseLabel.integerValue <= 1 {
                        timer.suspend()
                        // show
                        strongSelf.showChinese()
                    }
                    else {
                        strongSelf.chineseLabel.integerValue -= 1
                    }
                }
                else {
                    timer.suspend()
                }
            })
            self.countDownTimer.start()
        }
        else {
            // current list end
            self.stopQuiz()
        }
    }
    
    func showChinese() {
        self.chineseLabel.stringValue = self.currentWords[self.currentWordIndex - 1].chn!
        self.markWrongButton.isEnabled = true
        self.markCorrectButton.title = "Correct  →"
        self.countDownTimer.suspend()
        self.englishLabel.isHidden = false
    }
    
    func setProgress(to: Double) {
        self.progressIndicator.doubleValue = to
    }
    
    func saveWrongWordList() {
        if self.wrongWords.count > 0 {
            let alert = NSAlert()
            alert.messageText = "Save Wrong Records"
            alert.informativeText = "Do you want to export the wrong words?"
            alert.addButton(withTitle: "Yes")
            alert.addButton(withTitle: "No")
            alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) in
                if modalResponse == NSAlertFirstButtonReturn {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd-HH.mm.ss"
                    dateFormatter.timeZone = NSTimeZone.system
                    
                    let fileName = dateFormatter.string(from: Date())
                    
                    let panel = NSSavePanel()
                    panel.message = "Save the list of wrong words in last quiz."
                    panel.nameFieldStringValue = "Word.List.\(fileName).csv"
                    panel.beginSheetModal(for: self.view.window!, completionHandler: { (result) in
                        if result == NSFileHandlingPanelOKButton {
                            KKWordFile.save(to: (panel.url?.path)!, wordList: self.wrongWords)
                        }
                    })
                }
            })
        }
    }
}

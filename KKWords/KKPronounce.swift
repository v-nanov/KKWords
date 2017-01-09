//
//  KKPronounce.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/6/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Cocoa

let _API = "https://translate.google.cn/translate_tts?client=it&tl=en&q=%@&hl=zh_TW&total=1&idx=0&textlen=%d&prev=target&ie=UTF-8"

class KKPronounce {
    static var player: NSSound!
    static var failCount = 1
    
    static func say(word: String, completionBlock: @escaping (Error?) -> ()) {
        let escapedWord = word.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        if let API = URL(string: String(format: _API, escapedWord!, word.characters.count)) {
            let mutableRequest = NSMutableURLRequest(url: API)
            mutableRequest.setValue("GoogleTranslate/5.4.54011 (iPhone; iOS 10.1.1; zh_TW; iPhone9,1)", forHTTPHeaderField: "User-Agent")
            mutableRequest.setValue("zh-tw", forHTTPHeaderField: "Accept-Language")
            
            URLSession.shared.dataTask(with: mutableRequest as URLRequest) { (data, response, error) in
                if error == nil {
                    KKPronounce.player = NSSound(data: data!)
                    KKPronounce.player.volume = 1
                    KKPronounce.player.play()
                }
                completionBlock(error)
            }.resume()
        }
    }
}

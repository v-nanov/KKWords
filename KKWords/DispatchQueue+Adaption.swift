//
//  DispatchQueueAdaption.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/9/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func global(block: @escaping () -> ()) {
        DispatchQueueAdaption.dispatch_async_global_queue(block)
    }
}

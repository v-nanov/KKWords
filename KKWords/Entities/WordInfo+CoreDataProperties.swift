//
//  WordInfo+CoreDataProperties.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/7/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Foundation
import CoreData

extension WordInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordInfo> {
        return NSFetchRequest<WordInfo>(entityName: "WordInfo");
    }

    @NSManaged public var chn: String?
    @NSManaged public var eng: String?
    @NSManaged public var insertTime: NSDate?
    @NSManaged public var parentList: WordList?

}

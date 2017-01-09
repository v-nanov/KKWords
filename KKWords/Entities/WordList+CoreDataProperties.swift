//
//  WordList+CoreDataProperties.swift
//  KKWords
//
//  Created by Kanzaki Mirai on 1/7/17.
//  Copyright © 2017 Kanzaki Mirai. All rights reserved.
//

import Foundation
import CoreData

extension WordList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordList> {
        return NSFetchRequest<WordList>(entityName: "WordList");
    }

    @NSManaged public var groupLimit: Int64
    @NSManaged public var insertTime: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var allWords: NSOrderedSet?

}

// MARK: Generated accessors for allWords
extension WordList {

    @objc(insertObject:inAllWordsAtIndex:)
    @NSManaged public func insertIntoAllWords(_ value: WordInfo, at idx: Int)

    @objc(removeObjectFromAllWordsAtIndex:)
    @NSManaged public func removeFromAllWords(at idx: Int)

    @objc(insertAllWords:atIndexes:)
    @NSManaged public func insertIntoAllWords(_ values: [WordInfo], at indexes: NSIndexSet)

    @objc(removeAllWordsAtIndexes:)
    @NSManaged public func removeFromAllWords(at indexes: NSIndexSet)

    @objc(replaceObjectInAllWordsAtIndex:withObject:)
    @NSManaged public func replaceAllWords(at idx: Int, with value: WordInfo)

    @objc(replaceAllWordsAtIndexes:withAllWords:)
    @NSManaged public func replaceAllWords(at indexes: NSIndexSet, with values: [WordInfo])

    @objc(addAllWordsObject:)
    @NSManaged public func addToAllWords(_ value: WordInfo)

    @objc(removeAllWordsObject:)
    @NSManaged public func removeFromAllWords(_ value: WordInfo)

    @objc(addAllWords:)
    @NSManaged public func addToAllWords(_ values: NSOrderedSet)

    @objc(removeAllWords:)
    @NSManaged public func removeFromAllWords(_ values: NSOrderedSet)

}

//
//  Todo+CoreDataProperties.swift
//  
//
//  Created by ellkaden on 23.09.2025.
//
//

import Foundation
import CoreData


extension Todo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
        return NSFetchRequest<Todo>(entityName: "Todo")
    }

    @NSManaged public var name: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var isCompleted: Bool

}

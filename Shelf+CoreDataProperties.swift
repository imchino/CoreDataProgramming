//
//  Shelf+CoreDataProperties.swift
//  BookList
//
//  Created by chino on 2016/05/26.
//  Copyright © 2016年 chino. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Shelf {

    @NSManaged var displayOrder: NSNumber?
    @NSManaged var name: String?
    @NSManaged var books: NSSet?

}

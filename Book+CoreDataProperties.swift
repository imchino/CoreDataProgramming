//
//  Book+CoreDataProperties.swift
//  BookList
//
//  Created by chino on 2016/04/17.
//  Copyright © 2016年 chino. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Book {

    @NSManaged var author: String?
    @NSManaged var registeredDate: NSDate?
    @NSManaged var title: String?
    @NSManaged var wish: NSNumber?

}

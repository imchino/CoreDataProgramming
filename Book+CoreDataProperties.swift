//
//  Book+CoreDataProperties.swift
//  BookList
//
//  Created by chino on 2016/05/11.
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
    @NSManaged var url: NSURL?
    @NSManaged var wish: NSNumber?
    @NSManaged var photo: Photo?
    @NSManaged var shelf: Shelf?
    
}

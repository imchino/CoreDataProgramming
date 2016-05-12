//
//  Photo+CoreDataProperties.swift
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

extension Photo {

    @NSManaged var image: NSData?
    @NSManaged var book: Book?

}

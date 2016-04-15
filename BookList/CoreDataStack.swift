//
//  CoreDataStack.swift
//  BookList
//
//  Created by chino on 2016/04/15.
//  Copyright © 2016年 chino. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    let context: NSManagedObjectContext
    
    let appDocumentDirectryURL: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return urls.last!
    }()
    
    
    
}
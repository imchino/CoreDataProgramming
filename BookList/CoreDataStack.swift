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
    
    //永続ファイルのURL
    let appDocumentDirectryURL: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return urls.last!
    }()
    
    init() {
        //モデルのURL
        let bundle = NSBundle.mainBundle()
        guard let model_URL = bundle.URLForResource("BookListModel", withExtension: "momd") else { fatalError() }
        
        //管理オブジェクトモデルを生成
        guard let model = NSManagedObjectModel(contentsOfURL: model_URL) else { fatalError() }
        
        //コーディネータを生成
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //コンテキストを生成
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

        //コーディネータと接続
        context.persistentStoreCoordinator = coordinator
        
    }
    
}
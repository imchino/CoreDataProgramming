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
    //コンテキスト
    let context: NSManagedObjectContext
    
    //永続ファイルのURL
    let appDocumentDirectryURL: NSURL = {
        //初期値の処理
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains: NSSearchPathDomainMask.UserDomainMask)
        return urls.last!
    }()
    
    //イニシャライザ
    init() {
        //Xcodeモデルエディタで作成した管理オブジェクトモデルのURL
        let bundle = NSBundle.mainBundle()
        guard let model_URL = bundle.URLForResource("BookListModel", withExtension: "momd") else { fatalError("モデルURL取得エラー") }
        //管理オブジェクトモデルのインスタンスを生成
        guard let model = NSManagedObjectModel(contentsOfURL: model_URL) else { fatalError("管理オブジェクトモデル生成エラー") }
        
        //コーディネータを生成
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        //コンテキストを生成
        self.context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        //コンテキストのプロパティにコーディネータとセット
        context.persistentStoreCoordinator = coordinator
    }
    
    //コーディネータとストアを接続する（引数: 完了時の処理）
    func addPersistentStoreWithCompletionHandler(completionHandler: (()->Void)?) {
        /* 非同期処理 */
        //バックグラウンドキューを生成
        let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
        //非同期処理スタート
        dispatch_async(backgroundQueue, {
            //SQLストアのURLを取得
            let directryURL = self.appDocumentDirectryURL
            let storeURL = directryURL.URLByAppendingPathComponent("BookList.sqlite")
            
            //軽量マイグレーションのオプション（ディクショナリ型）
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,  //バンドル内で自動マイグレーション
                           NSInferMappingModelAutomaticallyOption:       true]  //自動マッピング
            
            do {
            //コーティネータにストアを追加
                let coordinator = self.context.persistentStoreCoordinator!
                //返り値(NSPersistentStoreオブジェクト)は保持しない
                try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
                //完了時に通知
                completionHandler?()
                
            } catch let error as NSError {
                fatalError("コーディネータ.ストア接続エラー: \(error)")
            }
        })
    }
    
    //コンテキストを保存
    func saveContext() throws {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print("保存に失敗: \(error)")
                throw error
            }
        }
    }
    
}
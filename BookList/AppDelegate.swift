//
//  AppDelegate.swift
//  BookList
//
//  Created by chino on 2016/04/15.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    //アプリケーション起動時
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        /* KVCテスト */
//        let coreDataStack = CoreDataStack()
//        //コーディネータにストアを接続
//        coreDataStack.addPersistentStoreWithCompletionHandler() {
//            //新規の管理オブジェクトbookを生成
//            let book = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: coreDataStack.context) as! Book
//            
//            //アトリビュートに値を追加・取得（KVC）
//            book.setValue("Hamlet", forKey: "title")
//            book.setValue("Shakespeare", forKey: "author")
//            var title = book.valueForKey("title")   as! String
//            var author = book.valueForKey("author") as! String
//            
//            //アトリビュートに値を追加・取得（動的アクセサ）
//            book.title = "ハムレット"
//            book.author = "シェークスピア"
//            title = book.title!
//            author = book.author!
//            
//            print("タイトル: \(title), 著者名: \(author)")
//            print("登録された日: \(book.registeredDate!)")
//        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


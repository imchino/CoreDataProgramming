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

    //「@NSManaged」キーワード（動的にアクセサが作成される）
    //モデルをアップデートすると更新されるので、エクステンションする
    @NSManaged var author: String?          //著者名
    @NSManaged var registeredDate: NSDate?  //登録日
    @NSManaged var title: String?           //タイトル
    @NSManaged var wish: NSNumber?          //欲しいもの可否（0==False, 0!=True）

}

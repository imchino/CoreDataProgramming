//
//  Book.swift
//  BookList
//
//  Created by chino on 2016/04/17.
//  Copyright © 2016年 chino. All rights reserved.
//  Book型モデル（振る舞いを実装する。プロパティは都度、更新されるのでエクステンションに切り分け。）

import Foundation
import CoreData


class Book: NSManagedObject {

    //コンテキストに最初に登録されたときだけ呼ばれる
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        //内部処理にするので、プリミティブアクセス
        setPrimitiveValue(NSDate(), forKey: "registeredDate")
    }

}

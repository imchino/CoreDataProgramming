//
//  parameters.swift
//  BookList
//
//  Created by chino on 2016/05/26.
//  Copyright © 2016年 chino. All rights reserved.
//

import Foundation


//管理オブジェクトのエンティティ名
struct EntityName {
    static let book  = "Book"
    static let photo = "Photo"
    static let shelf = "Shelf"
}

//識別子
struct Identifier {
    static let segueToEditTableVC  = "EDITBOOK"
    static let segueToShelfTableVC = "PICKSHELF"
    static let cellInBookTable     = "BookCell"
    static let cellInShelfTable    = "ShelfCell"
}

enum EntityNames: String {
    case book  = "Book"
    case photo = "Photo"
    case shelf = "Shelf"
}

enum Identifiers: String {
    case segueToEditTVC  = "EDITBOOK"
    case segueToShelfTVC = "PICKSHELF"
    case cellInBookTable = "BookCell"
    case cellInShelfTabe = "ShelfCell"
}

// MARK: - エラードメイン
let kBookListErrorDomain = "com.playground.BookList.errorDomain"
enum BookErrorCode: Int {
    case InvalidTitle = 1001
    case NoUrl        = 1002
}

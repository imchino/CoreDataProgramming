//
//  Book.swift
//  BookList
//
//  Created by chino on 2016/04/17.
//  Copyright © 2016年 chino. All rights reserved.
//  Book型モデル（振る舞いを実装する。プロパティは都度、更新されるのでエクステンションに切り分け。）

import Foundation
import CoreData

//Bookエンティティのカスタム管理オブジェクト（安全なアクセサを生成する）
class Book: NSManagedObject {
    
    /* recentlyは、メモリ上でのみ有効なアトリビュート（Transient）
       Transientなアトリビュートは、モデルバージョニングが不要
       エクステンション更新すると、プロパティが重複するので注意！ */
    var recently: Bool? {
        let calendar = NSCalendar.currentCalendar() //カレンダーユニット
        let aMonthAgo = calendar.dateByAddingUnit(.Month, value: -1, toDate: NSDate(), options: .WrapComponents)!   //一ヶ月前の日時
        let registeredDate = primitiveValueForKey("registeredDate") as! NSDate  //登録された日（内部アクセスなので、プリミティブなゲッタ）
        
        // 初期値は falseを返す
        var isRecetly = false
        //「登録日 > 一ヶ月前」ならば ture
        let inOneMonth = calendar.compareDate(registeredDate, toDate: aMonthAgo, toUnitGranularity: .Day) == .OrderedDescending
        if inOneMonth {
            isRecetly = true
        }
        return isRecetly
    }

    //コンテキストに最初に登録されたときだけ呼ばれる
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        //初期値の設定は内部処理にするので、プリミティブアクセス
        setPrimitiveValue(NSDate(), forKey: "registeredDate")
    }
    
    
    //MARK: - エラーを検証するカスタム検証メソッド
    //Titleアトリビュートを検証する
    func validateTitle(value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {

        //タイトルがnil => Core Dataが自動チェック
        if value == nil || value.memory == nil {
            print("タイトルがnil　=> システムチェックを利用")
            return
        }
        
        //タイトルがカラ => Core Dataで自動チェック
        let title = value.memory as! String
        if title.isEmpty {
            print("タイトルがカラ　=> システムチェックを利用")
            return
        }
        
        //スペース除去後のタイトルが、カラでなければOK
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        let trimmedTitle = title.stringByTrimmingCharactersInSet(whitespace)
        if !(trimmedTitle.isEmpty) {
            print("タイトルは正しく入力済み")
            return
        }
        
        //ここまで到達したら、エラーを生成して返す
        let userInfoWithTitle = [NSLocalizedDescriptionKey: "タイトル未入力" ,
                                 NSLocalizedRecoverySuggestionErrorKey: "スペースだけのタイトルは無効です"]
        let errorInvalidTitle = NSError(domain: kBookListErrorDomain,
                                        code: BookErrorCode.InvalidTitle.rawValue,
                                        userInfo: userInfoWithTitle)
        throw errorInvalidTitle
    }
    
}

// MARK: - エラードメイン
let kBookListErrorDomain = "com.playground.BookList.errorDomain"
enum BookErrorCode: Int {
    case InvalidTitle = 1001
}
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
        print("Bookオブジェクトのライフサイクル: コンテキストに追加されました")
        //初期値の設定は内部処理にするので、プリミティブアクセス
        setPrimitiveValue(NSDate(), forKey: "registeredDate")
    }
    
    //MARK: - エラーを検証するCoreData標準の検証メソッド
    //オブジェクトを追加したときに呼ばれる
    override func validateForInsert() throws {
        print("検証メソッド: Insert")
        try super.validateForInsert()
        
        try validateUrlAndWish()
    }
    
    //更新したときに呼ばれる
    override func validateForUpdate() throws {
        print("検証メソッド: Update")
        try super.validateForUpdate()   //まずは、標準の検証をする

        //続いて、独自の検証
        try validateUrlAndWish()
    }
    
    //テーブルからセルを削除した瞬間に呼ばれる
    override func validateForDelete() throws {
        print("検証メソッド: Delete")
        try super.validateForInsert()   //まずは、標準の検証をする
        
    }
    
    //MARK: - エラーを検証するカスタム検証メソッド
    //独自の検証処理（お気に入りならば、URL必須）
    func validateUrlAndWish() throws {
        print("カスタム検証: URLチェック")
        if !(wish!.boolValue) {
        //お気に入りでなければ、検証終了
        print("お気に入りではありません")
            return
        }
        
        if let urlString = url?.absoluteString where !(urlString).isEmpty {
        //URL文字列がnilでなければ、検証終了
            print("URLは入力済み")
            return
        }
        
        //ここまで到達したら、カスタム検証でエラーをスロー
        print("カスタム検証でエラー: お気に入りに対して、URLが未入力！")
        let userInfoWithUrl = [NSLocalizedDescriptionKey: "URLが未入力",
                               NSLocalizedRecoverySuggestionErrorKey :"お気に入りにはURLが必須です"]
        let errorInvalidURL = NSError(domain: kBookListErrorDomain, code: BookErrorCode.NoUrl.rawValue, userInfo: userInfoWithUrl)
        
        throw errorInvalidURL
    }
    
    
    //Titleアトリビュートを検証する
    func validateTitle(value: AutoreleasingUnsafeMutablePointer<AnyObject?>) throws {

        //タイトルがnil => Core Dataが自動チェック
        if value == nil || value.memory == nil {
            print("タイトルがnil　=> システムチェックを利用")
            return
        }
        
        
        //スペース除去後のタイトルが、カラでなければOK
        let whitespace = NSCharacterSet.whitespaceCharacterSet()
        let title = value.memory as! String
        let trimmedTitle = title.stringByTrimmingCharactersInSet(whitespace)
        if !(trimmedTitle.isEmpty) {
            print("タイトルは正しく入力済み")
            return
        }
        
        //ここまで到達したら、エラーを生成してスロー
        print("カスタム検証でエラー: タイトル未入力！")
        let userInfoWithTitle = [NSLocalizedDescriptionKey: "タイトル未入力" ,
                                 NSLocalizedRecoverySuggestionErrorKey: "スペースだけのタイトルは無効です"]
        let errorInvalidTitle = NSError(domain: kBookListErrorDomain,
                                        code: BookErrorCode.InvalidTitle.rawValue,
                                        userInfo: userInfoWithTitle)
        throw errorInvalidTitle
    }
    
}


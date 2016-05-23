//
//  BookTableViewController.swift
//  BookList
//
//  Created by chino on 2016/04/18.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

// MARK: - BookTableViewControllerクラス
class BookTableViewController: UITableViewController {
    
    // MARK: -　メンバ
    let coreDataStack = CoreDataStack() //CoreDataパッケージ
    var books = [Book]()                 //データソース（フェッチ結果が格納される）
    
    //Bookを読み出すフェッチリクエスト（lazy: アクセス時に値が決定される）
    lazy var fetchRequestForBooks: NSFetchRequest = {
        //モデル内のエンティティを指定して、リクエスト生成
        let fetchRequest = NSFetchRequest(entityName: "Book")
        //結果の並び順を指定
        let sortDescriptorForBooks = NSSortDescriptor(key: "registeredDate", ascending: false)  //登録日の降順でソート
        fetchRequest.sortDescriptors = [sortDescriptorForBooks]   //リクエストにソート条件をセット
        
        return fetchRequest
    }()

    
    // MARK: - ライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()

        //ナビゲーションバー初期化
        self.navigationItem.leftBarButtonItem = editButtonItem()    //左に編集ボタン
        
        //テーブルビュー初期化
        tableView.rowHeight = UITableViewAutomaticDimension //Self-Sizeingセルに対して、高さを自動設定
        tableView.estimatedRowHeight = 56.0                 //セルの基準高さを56ptに指定
        
        //コーディネータにストアを接続
        userInterancitonEnabled(false)  //UI待機
        coreDataStack.addPersistentStoreWithCompletionHandler({
            //非同期処理が完了時の処理
            dispatch_async(dispatch_get_main_queue(), {
                self.userInterancitonEnabled(true)  //UI許可
                self.fetchBooks()                   //ストア接続完了したらフェッチ
            })
        })
        
        //オブザーバに登録（コンテキストが保存されたときを監視）
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: Selector.contextDidSave , name: NSManagedObjectContextDidSaveNotification, object: coreDataStack.context)
    }
    
    
    //デイニシャライザ（オブザーバを削除）
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //非同期処理が完了するまで、UIを待機させる
    private func userInterancitonEnabled(enabled: Bool) {
        let segmentCntrol = self.navigationItem.titleView as! UISegmentedControl
        segmentCntrol.enabled = enabled
        
        self.navigationItem.rightBarButtonItem?.enabled = enabled
        self.navigationItem.leftBarButtonItem?.enabled  = enabled
    }
    
    //画面遷移の直前
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.editBook {
            var sendBook: Book  //渡すbookオブジェクト
            if let tappedCell = sender as? UITableViewCell {
            //セルタップからの遷移なら
                let indexPath = tableView.indexPathForCell(tappedCell)!
                sendBook = self.books[indexPath.row]
            } else {
            //新規ブック作成（＋ボタンをタップ）なら、コンテキスト上のbookを渡す
                let newBookOnContext = coreDataStack.context.insertedObjects.first as! Book
                sendBook = newBookOnContext
            }
            
            //遷移先のプロパティを取得して、プロパティを渡す
            let naviVC = segue.destinationViewController as! UINavigationController
            let editVC = naviVC.topViewController as! BookEditTableViewController
            editVC.book = sendBook
            editVC.coreDataStack = self.coreDataStack
        }
    }
    

    // MARK: - 各種メソッド
    //永続ストアからBookエンティティをフェッチ実行（結果は、books配列に格納される）
    private func fetchBooks() {
        do {
            try books = coreDataStack.context.executeFetchRequest(fetchRequestForBooks) as! [Book]
        } catch let error as NSError {
            fatalError("フェッチ失敗: \(error)")
        }
        
        tableView.reloadData()  //テーブルビュー更新
    }
    
    //UIを更新するため、コンテキスト保存を監視するオブザーバのセレクタ（引数: 受けた通知）
    func contextDidSave(notification: NSNotification) {
        print("オブザーバ通知: コンテキストが更新されたので、保存します！")
        //通知内容がnilなら終了
        guard let userinfo = notification.userInfo else {
            return
        }
        
        //UIを更新する処理
        
        //取得した通知内容から更新されたbookオブジェクトを取得して、当該セルを更新
        let updatedObjects = userinfo[NSUpdatedObjectsKey] as! NSSet    //通知内容から、コンテキスト上で更新された全ての型の管理オブジェクトを抽出（集合に変換）
        for object in updatedObjects {
            print("アップデートされたオブジェクトを取得！")
            let entityName = (object as! NSManagedObject).entity.name   //取得したオブジェクトのエンティティ名
            let book: Book  //Book型オブジェクトを用意

            //集合から取り出したオブジェクトをBook型にする
            if entityName == EntityName.book {
                book = object as! Book
            } else { continue }
            
            //該当するBooks配列の要素を特定し、テーブルのセルを更新
            if let index = books.indexOf(book) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
        
        //取得した通知内容から挿入されたbookオブジェクトを取得して、テーブルと当該セルを更新
        let insertedObjects = userinfo[NSInsertedObjectsKey] as! NSSet    //通知内容から、コンテキスト上で挿入された全ての型の管理オブジェクトを抽出（集合に変換）
        for object in insertedObjects {
            print("新規追加されたオブジェクトを取得！")
            let entityName = (object as! NSManagedObject).entity.name   //取得したオブジェクトのエンティティ名
            let book: Book  //Book型オブジェクトを用意
            
            //集合から取り出したオブジェクトをBook型にする
            if entityName == EntityName.book {
                book = object as! Book
            } else { continue }
            
            //テーブルのデータソースを更新（新規作成時は先頭に追加）
            books.insert(book, atIndex: 0)
            
            //該当するBooks配列の要素を特定し、テーブルのセルを挿入
            if let index = books.indexOf(book) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }

    }
    
    
    // MARK: - テーブルビューのデリゲートメソッド
    //セクション数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //セクション内の行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    //セル生成
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as! BookTableViewCell

        let book = books[indexPath.row] //データソースからセルを生成
        cell.configureWithBook(book)    //セルにbookオブジェクト内容を表示させる

        return cell
    }

    // テーブルビューを編集可能とする
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // 編集完了時の処理
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let book = books[indexPath.row]
            coreDataStack.context.deleteObject(book)    //コンテキストから削除
            books.removeAtIndex(indexPath.row)          //データソースから削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)  //テーブルビューから削除
            try! coreDataStack.saveContext()    //コンテキスト保存（ブックを追加 or 削除のタイミングで保存）
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            print("新規追加")
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - ナビゲーション
    //新規ブック追加（ナビケーションバー.右ボタン）
    @IBAction func addBook(sender: UIBarButtonItem) {
        
        //空の管理オブジェクトをコンテキストに生成して、編集画面へ遷移
        NSEntityDescription.insertNewObjectForEntityForName(EntityName.book, inManagedObjectContext: coreDataStack.context)
        performSegueWithIdentifier(SegueIdentifier.editBook, sender: nil)   //senderは「nil」なので、通常の遷移とは別あつかい
        
//        /* 新規セルとしてオブジェクトを追加するテスト */
//        //コンテキストに追加された、新規Bookオブジェクトを生成し、データソースの先頭に追加
//        let newBook = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: coreDataStack.context) as! Book
//        newBook.title  = "仮タイトル"    //titleプロパティは必須項目
//        newBook.author = "不明な著者名"
//        newBook.url = NSURL(string: "http://www.sample.com")
//        books.insert(newBook, atIndex: 0)
//        
//        //テーブルを更新する
//        //コンテキスト保存（ブックを追加 or 削除のタイミングで保存）
//        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
//        try! coreDataStack.saveContext()
    }
    
    //全書籍 <-> 欲しいものリスト
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        var condition:NSPredicate? = nil    //初期条件は無し

        //セグメントが欲しいものリスト選択中のとき
        if (sender.selectedSegmentIndex == 1) {
            condition = NSPredicate(format: "wish == true") //絞り込み条件を指定
        }
        fetchRequestForBooks.predicate = condition  //絞り込み条件をセット
        fetchBooks()    //フェッチ実行
    }
    

    //演習モードのとき、新規ブックは追加させない
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = !(editing)
    }


}

// MARK: - セレクタエクステンション
private extension Selector {
    static let contextDidSave = #selector(BookTableViewController.contextDidSave(_:))
}

// MARK: - セル
class BookTableViewCell: UITableViewCell {
    
    //セルの表示項目
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var wishLabel:   UILabel!
    @IBOutlet weak var dateLabel:   UILabel!
    
    //日付形式を初期化
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .MediumStyle
        return dateFormatter
    }()
    
    //管理オブジェクトの値をセルにセット
    func configureWithBook(book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        wishLabel.hidden = !(book.wish!.boolValue)
        dateLabel.text = dateFormatter.stringFromDate(book.registeredDate!)
    }
}

//管理オブジェクトのエンティティ名
struct EntityName {
    static let book = "Book"
    static let photo = "Photo"
}

//セグエの識別子
struct SegueIdentifier {
    static let editBook = "EDITBOOK"
}

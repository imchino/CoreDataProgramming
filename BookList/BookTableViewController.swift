//
//  BookTableViewController.swift
//  BookList
//
//  Created by chino on 2016/04/18.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

class BookTableViewController: UITableViewController {
    
    let coreDataStack = CoreDataStack() //CoreDataパッケージ
    var books = [Book]()                 //データソース
    
    //Bookを読み出すフェッチリクエスト
    lazy var fetchRequestForBooks: NSFetchRequest = {
        let fetchRequest = NSFetchRequest(entityName: "Book")
        return fetchRequest
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
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
    
    //永続ストアからBookエンティティをフェッチ
    private func fetchBooks() {
        do {
            try books = coreDataStack.context.executeFetchRequest(fetchRequestForBooks) as! [Book]
        } catch let error as NSError {
            fatalError("フェッチ失敗: \(error)")
        }
        
        tableView.reloadData()  //テーブルビュー更新
    }
    
    //新規ブック追加（なビケーションバー.右ボタン）
    @IBAction func addBook(sender: UIBarButtonItem) {
        //コンテキストに追加された、新規Bookオブジェクトを生成する
        let newBook = NSEntityDescription.insertNewObjectForEntityForName("Book", inManagedObjectContext: coreDataStack.context) as! Book
        newBook.title  = "仮タイトル"    //titleプロパティは必須
        newBook.author = "不明な著者名"
        
        //データソースの先頭に追加
        books.insert(newBook, atIndex: 0)
        
        //テーブルを更新する
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        
        //コンテキスト保存
        try! coreDataStack.saveContext()
    }
    
    //全書籍 <-> 欲しいものリスト
    @IBAction func segmentChanged(sender: UISegmentedControl) {
    }

    // MARK: - テーブルビューのデータソース
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

        let book = books[indexPath.row]
        cell.configureWithBook(book)

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
            try! coreDataStack.saveContext()    //コンテキスト保存
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
    //演習モードのとき、新規ブックは追加させない
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        self.navigationItem.rightBarButtonItem?.enabled = !(editing)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

//セル
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
    
    //セルの表示内容
    func configureWithBook(book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        wishLabel.hidden = !(book.wish!.boolValue)
        dateLabel.text = dateFormatter.stringFromDate(book.registeredDate!)
    }
    
    
}

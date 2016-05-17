//
//  BookEditTableViewController.swift
//  BookList
//
//  Created by chino on 2016/05/13.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

class BookEditTableViewController: UITableViewController {

    // MARK: - プロパティ
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var wishSwitch: UISwitch!
    @IBOutlet weak var registeredDateLabel: UILabel!
    
    @IBOutlet weak var recentlyLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var shelfNameLabel: UILabel!
    
    /* BookTableVCから受け取るプロパティ */
    var book: Book!
    var coreDataStack: CoreDataStack!
    
    /* BookEditVCに表示する日時を遅延取得 */
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        return dateFormatter
    }()
    
    // MARK: - ビューライフサイクル
    //ビュー初期化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.text = book.title
        authorTextField.text = book.author
        urlTextField.text = book.url?.absoluteString    //URLの絶対パス（Bookエンティティのオプショナルなアトリビュート）
        wishSwitch.on = book.wish!.boolValue            //必須アトリビュートなので、オプショナルチェインは「!」
        registeredDateLabel.text = dateFormatter.stringFromDate(book.registeredDate!)
        
        recentlyLabel.hidden = book.recently!.boolValue
        
        if let imageData = book.photo?.image {
        //bookエンティティ.photoリレーション先のPhontoエンティティ.imageアトリビュートがある場合
            photoImageView.image = UIImage(data: imageData) //ソースはバイナリ（NSData）
        }
        
        shelfNameLabel.text = book.shelf?.name  //shelfリレーション先のnameプロパティ
        
        /* ビューコントローラ.ナビゲーションのタイトル
           タイトルなし -> 新規, タイトルあり -> 編集 */
        if book.title == nil {
            self.title = "New Book"
        } else {
            self.title = "Edit Book"
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - メソッド

    // MARK: - Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
     
     

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}

//
//  BookEditTableViewController.swift
//  BookList
//
//  Created by chino on 2016/05/13.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

class BookEditTableViewController: UITableViewController, UITextFieldDelegate,
                                                          UIImagePickerControllerDelegate,
                                                          UINavigationControllerDelegate {
    // MARK: - プロパティ
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var wishSwitch: UISwitch!
    @IBOutlet weak var registeredDateLabel: UILabel!
    
    @IBOutlet weak var recentlyLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var shelfNameLabel: UILabel!
    
    weak var editingTextFeild: UITextField? //編集中のテキストフィールドを保持する
    
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
    
    /* ShelfTableVCに渡すコンテキスト */
    lazy var shelfContext: NSManagedObjectContext = {
        //新規のコンテキストを生成して、既存のコーティネータに接続
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = self.coreDataStack.context.persistentStoreCoordinator
        return context
    }()
    
    // MARK: - ビューライフサイクル
    //ビュー初期化
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 各セルの初期値 */
        titleTextField.text = book.title
        authorTextField.text = book.author
        urlTextField.text = book.url?.absoluteString    //URLの絶対パス（Bookエンティティのオプショナルなアトリビュート）
        wishSwitch.on = book.wish!.boolValue            //必須アトリビュートなので、オプショナルチェインは「!」
        registeredDateLabel.text = dateFormatter.stringFromDate(book.registeredDate!)
        recentlyLabel.hidden = book.recently!.boolValue //bookオブジェクト側で、内部アクセスして判断
        
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

    //画面遷移
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "PICKSHELF" {
            let vc = segue.destinationViewController as! ShelfTableViewController
            vc.context = self.shelfContext
        }
    }
    
    // MARK: - メソッド
    @IBAction func wishChange(sender: UISwitch) {
        book.wish = sender.on
    }
    
    // MARK: - デリゲートメソッド
    //PHOTOセルをタップしたときに画面遷移する
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let imagePC = UIImagePickerController()
            imagePC.delegate = self
            presentViewController(imagePC, animated: true, completion: nil)
        }
    }
    
    //テキスト編集を開始（テキストフィールドを取得）
    func textFieldDidBeginEditing(textField: UITextField) {
        editingTextFeild = textField
        print("キーボードを展開！")
    }
    
    //キーボードが格納されたとき（テキスト編集が完了した時）
    func textFieldDidEndEditing(textField: UITextField) {
        print("キーボードを収納しました！")
        editingTextFeild = nil  //取得したテキストフィールドを破棄
        
        //編集中のビューを、管理オブジェクトと一致させる
        switch textField {
        case titleTextField:
            book.title = textField.text
        case authorTextField:
            book.author = textField.text
        case urlTextField:
            if let urlText = textField.text {
                book.url = NSURL(string: urlText)
            } else {
                book.url = nil
            }
        default:
            break
        }
    }
    
    //リターンキーでキーボードを格納する
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //遷移先のイメージピッカーで画像を選択した時
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        /* セル内のビューの更新 */
        photoImageView.image = image
        
        /* 管理オブジェクトの更新 */
        if let photo = book.photo {
        //bookオブジェクトのphotoリレーションが存在している
        //（-> リレーション先のプロパティに選択したイメージを格納する）
            photo.image = UIImageJPEGRepresentation(image, 1.0) //リレーション先のイメージ属性を更新
        } else {
        //bookオブジェクトのphotoリレーションがない
        //（-> 新しいphotoオブジェクトをコンテキスト上に生成して、bookのリレーション先にする）
            let newEntity = NSEntityDescription.insertNewObjectForEntityForName("Photo", inManagedObjectContext: coreDataStack.context)
            //新しいPhotoエンティティをコンテキストに挿入
            let newPhotoObj = newEntity as! Photo   //新しいPhoto管理オブジェクト（プロパティはカラ）
            newPhotoObj.image = UIImageJPEGRepresentation(image, 1.0)   //Photoオブジェクトのimageプロパティに選択イメージを保持
            book.photo = newPhotoObj    //Photoオブジェクトをbookオブジェクトのリレーション先にする
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //ピッカーキャンセル時
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation
    //bookの編集をキャンセル（コンテキストを保存しない）
    @IBAction func cancel(sender: UIBarButtonItem) {
        print("編集をキャンセルしたので、コンテキストをロールバックします...")
        editingTextFeild?.resignFirstResponder()    //キーボード収納（テキスト編集完了の処理 => コンテキストの状態を同期）
        coreDataStack.context.rollback()            //コンテキストの状態を（前回の保存、フェッチ時点に）戻す
        
        dismissViewControllerAnimated(true, completion: nil)    //画面を一覧表示へ
    }
    
    //bookの編集を完了（コンテキストを保存する）
    @IBAction func done(sender: UIBarButtonItem) {
        
        editingTextFeild?.resignFirstResponder()    //キーボード収納（テキスト編集完了の処理 => コンテキストの状態を同期）
        
        do {
            /* コンテキスト保存して、一覧画面へ */
            try coreDataStack.saveContext()
            dismissViewControllerAnimated(true, completion: nil)

        } catch let error as NSError {
            /* エラーを解析して、アラート表示 */
            var validationError: NSError
            
            if error.code == NSValidationMultipleErrorsError {
            //複合エラーだった場合
                let errors = error.userInfo[NSDetailedErrorsKey] as! [NSError]  //エラー情報の配列を取得
                validationError = errors.first! //先頭のエラーをデフォルトに設定
                for errorObj in errors {
                    if errorObj.domain == kBookListErrorDomain {
                    //独自エラードメインなら
                        //エラーを取得して、ループから脱出
                        validationError = errorObj
                        break
                    }
                }
            } else {
            //単一エラーだった場合
                validationError = error
            }
            
            //アラート表示
            let alert = UIAlertController(title: validationError.localizedDescription,
                                          message: validationError.localizedRecoverySuggestion,
                                          preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        
        
        
        
    }
     
}

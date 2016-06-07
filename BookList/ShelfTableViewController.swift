//
//  ShelfTableViewController.swift
//  BookList
//
//  Created by chino on 2016/05/26.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

class ShelfTableViewController: UITableViewController {
    
    var sub_Context: NSManagedObjectContext!    //メインとは別の2つ目のコンテキスト
    var shelfs = [Shelf]()                  //全ての本棚を格納するデータソース
    
    var isSingleEdit = false    //スワイプ削除かどうか（スワイプ編集時には挿入ボタン不可にするため）
    
    //フェッチリクエスト（Shelfエンティティを読み出し）
    var fetchRequest: NSFetchRequest = {
        let request = NSFetchRequest(entityName: "Shelf")
        let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        request.sortDescriptors = [sortDescriptor]  //displayOrder属性を昇順
        
        return request
    }()
    
    // MARK: - ビューライフサイクル
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //本棚オブジェクトをディスクから読み出す
        fetchShefs()
        
        //画面のナビ右に編集ボタン
        navigationItem.rightBarButtonItem = editButtonItem()
        
        //テーブルビューは編集中もセルを選択できる
        tableView.allowsSelectionDuringEditing = true
    }
    
    //ビューコントローラの編集状態を切り替え
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        print("実行: func setEditing(editing: animated: )")
        
        var indexPath: NSIndexPath
        
        if !(isSingleEdit) {
            //スワイプ編集でない => 最終行のインデックスパスを生成
            let lastRow = shelfs.count
            indexPath = NSIndexPath(forRow: lastRow, inSection: 0)
        } else {
            //スワイプ編集ならば終了
            return
        }
        
        if editing {
            //編集中なら最終行に挿入
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            //編集中でなければ、最終行を削除
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        //スワイプモードでなければ
        //編集モード => 戻るボタンを表示、 通常モード => 戻るボタンを隠す
        navigationItem.hidesBackButton = editing    //Yes: 隠す, No: 表示
    }
    

    
    // MARK: - Core Data Private Method
    //フェッチリクエストを実行して、テーブル表示を更新
    private func fetchShefs() {
        do {
            shelfs = try sub_Context.executeFetchRequest(fetchRequest) as! [Shelf]
        } catch let error as NSError {
            fatalError("\(error)")
        }
        
        let indexSet = NSIndexSet(index: 0)
        tableView.reloadSections(indexSet, withRowAnimation: .Fade)
    }

    //本棚名から本棚を追加する（入力アラートビューの完了時ハンドラ）
    private func addShelfWithName(name: String?) {
        //新規の本棚オブジェクトをコンテキストに追加
        let entityNameShelf = EntityNames.shelf.rawValue
        let newShelf = NSEntityDescription.insertNewObjectForEntityForName(entityNameShelf, inManagedObjectContext: sub_Context) as! Shelf
        
        //コンテキストに追加された本棚オブジェクトのプロパティに、値を格納
        newShelf.name = name
        newShelf.displayOrder = shelfs.count
        
        /* コンテキスト状態をディスクに保存 */
        do {
            try sub_Context.save()  //コンテキスト上のオブジェクトをディスクに保存
            
            //データソースに本棚を追加
            shelfs.append(newShelf)
            //テーブルのラスト行に本棚を追加
            let lastRowNum = shelfs.count - 1
            let lastIndexPath = NSIndexPath(forRow: lastRowNum, inSection: 0)
            tableView.insertRowsAtIndexPaths([lastIndexPath], withRowAnimation: .Fade)
        
        } catch let error as NSError {
        //保存エラーをキャッチ
            sub_Context.rollback()
            print("本棚追加に失敗:\n\(error)")
        }
    }
    
    //本棚名を変更する（アラートビューの完了ハンドラ）
    func updateShelfAtIndex(index: Int, withName newName: String?) {
        //データソースの本棚を操作
        let editingShelf = shelfs[index]
        editingShelf.name = newName
        
        do {
            //コンテキストのオブジェクトをディスクに保存
            try sub_Context.save()

            //テーブルビューの表示を更新
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } catch let error as NSError {
            sub_Context.rollback()
            print("本棚名のアップデートに失敗: \(error)")
        }
    }
    
    //本棚を削除する
    private func deleteShelfAtIndex(index: Int) {
        //コンテキストから削除
        let targetShelf = shelfs[index]
        sub_Context.deleteObject(targetShelf)
        
        /* データソース操作: 削除する本棚以降のdisplayOrder属性は、-1する */
        /*
         ex)shelfs[0:"155", 1:"156", 2:"157", 3:"158", 4:"159", 5:"160"] のに対して（shelfs.count = 6）
         => shelfs[2:"157"]が削除される場合（削除index = 2）
         => shelfs[0:"155", 1:"156", x:"xxx", "3:"158", 4:"159", 5:"160"] になるので
         => shelfs[0:"155", 1:"156", x:"xxx", "3:"157", 4:"158", 5:"159"] としたい
         => [3:"158", 4:"159", 5:"160"]の値を -1 する（ [3] 〜 [5] の値に -=1 ）
         => ループ開始のindex: (削除index + 1) = 3, ループ終了index: (... 5) = (..< shelfs.count)
         */
        let nextIndexFromDeletedShelf = index + 1
        for currentOrderNum in nextIndexFromDeletedShelf ..< shelfs.count {
            let newOrderNum = currentOrderNum - 1
            shelfs[currentOrderNum].displayOrder = newOrderNum
        }
        
        /* コンテキスト保存 */
        do {
            try sub_Context.save()
            
            //データソースから本棚を削除
            shelfs.removeAtIndex(index)
            //テーブルからも削除
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } catch let error as NSError {
            sub_Context.rollback()
            print("削除の保存エラー\n\(error)")
        }
    }
    
    //本棚名を入力させるアラートビューを表示する（引数: 本棚名, 完了時の処理）
    func presentAlertViewForInputName(name: String?, actionHandler: (String?) -> Void) {
        
        let alertController = UIAlertController(title: "Add or Edit with shelf", message: "input shelf name", preferredStyle: .Alert)
        //アラートビューにテキストフィールドを用意
        alertController.addTextFieldWithConfigurationHandler({ (textField: UITextField) in
            textField.text = name   //編集時には、既存の本棚名（新規ならnil）
        })
        
        //タップしたら、テキストフィールド内容をハンドラに渡すアクション
        let okAction = UIAlertAction(title: "OK",
                                     style: .Default,
                                     handler: { (action: UIAlertAction) in
                                        let textFields = alertController.textFields!
                                        actionHandler(textFields.first?.text)
        })
        //キャンセルボタン
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - テーブルビューのデリゲートメソッド
    //セクション数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //セクション内のセル数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("実行: numberOfRowInSection（セクション内セル数）")
        
        if (editing && !isSingleEdit) {
        //ナビゲーションボタンからの編集ならば => 本棚の数を＋1
            return shelfs.count + 1
        } else {
        //通常時
            return shelfs.count
        }
    }
    
    //セルを生成
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdShelf = Identifiers.cellInShelfTabe.rawValue
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdShelf, forIndexPath: indexPath)

        var shelfName = String?()   //本棚名の初期値は空欄
        if indexPath.row < shelfs.count {
        //本棚配列から名前を取得
            shelfName = shelfs[indexPath.row].name
        }
        
        //セルに本棚名を表示
        cell.textLabel?.text = shelfName
        return cell
    }
    
    //スワイプによる編集開始
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        print("tableView: willBeginEditingRowAtIndexPath!!")
        isSingleEdit = true     //スワイプ編集ステータス: ON
    }
    
    //スワイプによる編集完了
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        print("tableView: didEndEditingRowAtIndexPath!!")
        isSingleEdit = false    //スワイプ編集ステータス: OFF
    }

    //セルの編集を許可する（全てのセルに対して）
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //それぞれのセルが移動できるかを返す
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        //データソース以上のセルは移動させない
        let isMove = indexPath.row < shelfs.count
        return isMove
    }

    //それぞれのセルの編集スタイル
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {

        //セルのインデックスが
        if indexPath.row < shelfs.count {
        //データソース未満
            return .Delete  //削除モード
        } else {
        //データソース以上
            return .Insert  //新規挿入モード
        }
    }
    
    //テーブルビュー編集完了のとき
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        print("編集完了: tableView_comitEditingStyle")
        //
        if editingStyle == .Delete {
        //削除モードの場合
            deleteShelfAtIndex(indexPath.row)
        } else if editingStyle == .Insert {
        //新規挿入モードの場合
            //入力アラートビューを表示して、本棚名を入力させる
            presentAlertViewForInputName(nil, actionHandler: {
                //完了時: 入力した名前の本棚を追加する
                [unowned self] (name: String?) in self.addShelfWithName(name)
            })
        }
    }
    
    //セル選択したとき
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //テーブルが編集モードでなければ何もしない
        if !(tableView.editing) { return }
        
        /* 以下、テーブルが編集モード時の処理 */
        if indexPath.row < shelfs.count {
            print("データソースのセルを選択")
        //データソース上のサイズ内のセルの場合
            //データソースからタップしたセルの本棚名を取得
            let tappedShelf = shelfs[indexPath.row]
            let currentName = tappedShelf.name
            //編集するためのアラートビューに現在の本棚名を表示
            presentAlertViewForInputName(currentName, actionHandler: {
                //編集完了したら、本棚名を上書き
                [unowned self] (inputedName: String?) in
                self.updateShelfAtIndex(indexPath.row, withName: inputedName)
            })
        } else {
            print("データソース外のセルを選択！")
        //データソースサイズ以上のセルならば
            //新規本棚セルを追加（テキストフィールドが空欄のアラートビューを表示）
            presentAlertViewForInputName(nil, actionHandler: {
                //編集完了時には新規セルを追加
                [unowned self](name: String?) in
                self.updateShelfAtIndex(indexPath.row, withName: name)
            })
            
        }
        
        
    }
    
    //テーブルビューのセルを並べ替える
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        //データソースを操作
        let movingShelf = shelfs[fromIndexPath.row]             //移動する要素A
        shelfs.removeAtIndex(fromIndexPath.row)                 //移動元の要素Aを削除
        shelfs.insert(movingShelf, atIndex: toIndexPath.row)    //移動先の要素Bに挿入
        
        /* displayOrder属性を操作 */
        //移動元, 移動先の位置を取得
        var startIndex = fromIndexPath.row
        var endIndex = toIndexPath.row
        print("スタート: \(startIndex), エンド: \(endIndex)")

        //移動がマイナス方向ならば（例. start:7 => end:4 など
        if startIndex > endIndex {
            //入れ替える
            swap(&startIndex, &endIndex)
//            startIndex = toIndexPath.row
//            endIndex = fromIndexPath.row
            print("セルが逆方向に移動されました！")
            print("スタート: \(startIndex), エンド: \(endIndex)")
        }
        
        for i in startIndex...endIndex {
            let obj = shelfs[i]
            obj.displayOrder = i
        }
        
        //コンテキストを保存
        try! sub_Context.save()
    }

    //編集モード時に最終行には移動させない
    override func tableView(tableView: UITableView,
                            targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath,
                            toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        print("移動先をチェック")
        //移動先はデフォルト
        var destinationIndexPath = proposedDestinationIndexPath

        if proposedDestinationIndexPath.row == shelfs.count {
        //移動先がテーブルの追加セルだった場合
            print("このセル移動は禁止！")
            //移動先は無効にする（移動元に戻す）
            destinationIndexPath = sourceIndexPath
        }
        
        return destinationIndexPath
    }
    
    /*
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

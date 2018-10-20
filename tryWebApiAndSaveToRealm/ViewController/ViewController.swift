//
//  ViewController.swift
//  tryObservableWebApiAndRealm
//
//  Created by Marko Dimitrijevic on 19/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealmDataSources

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    let realmViewModel = RealmViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }

    private func bindUI() {
        
        let dataSource = RxTableViewRealmDataSource<RealmRoom>(cellIdentifier:
        "cell", cellType: UITableViewCell.self) { cell, _, rRoom in
            cell.textLabel?.text = rRoom.name
        }
        
        realmViewModel.oRooms
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: disposeBag)
        
//        rooms
//            .bind(to: tableView.rx.items) {
//                (tableView: UITableView, index: Int, element: String) in
//                    let cell = UITableViewCell(style: .default, reuseIdentifier:
//                        "cell")
//                    cell.textLabel?.text = element
//                    return cell
//            }
//            .disposed(by: disposeBag)
    }

}

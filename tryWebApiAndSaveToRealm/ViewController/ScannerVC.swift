//
//  ScannerVC.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 22/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ScannerVC: UIViewController {
    
    @IBOutlet weak var sessionConstLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var sessionTimeAndRoomLbl: UILabel!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() { super.viewDidLoad()
        sessionConstLbl.text = SessionTextData.sessionConst
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        guard let name = segue.identifier, name == "segueShowSettings",
//            let navVC = segue.destination as? UINavigationController,
//            let settingsVC = navVC.children.first as? SettingsVC else { return }

//        settingsVC.settingsViewModel.shouldCloseSettingsVC
//            .take(1)
//            .subscribe(onNext: { (success) in
//                if success {
//                    self.dismiss(animated: true)
//                } else {
//                    print("please provide all data....")
//                }
//            })
//            .disposed(by: disposeBag)
    }
    
    private func updateUI() {
        
        
    }
    
}

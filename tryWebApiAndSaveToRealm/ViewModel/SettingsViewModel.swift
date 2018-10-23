//
//  SettingsViewModel.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 20/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

class SettingsViewModel {
    
    let disposeBag = DisposeBag()
    
    private var unsyncedConnections: Int = 0
    var saveSettings: ControlEvent<()>
    var cancelSettings: ControlEvent<()>
    
    // 1 - dependencies-init
    init(unsyncedConnections: Int, saveSettings: ControlEvent<()>, cancelSettings: ControlEvent<()>) {
        self.unsyncedConnections = unsyncedConnections
        self.saveSettings = saveSettings
        self.cancelSettings = cancelSettings
        bindControls()
    }
    
    //  // treba da slusas preko vc-a o room i session
    var roomSelected = PublishSubject<RealmRoom>.init()
    var sessionSelected = PublishSubject<RealmBlock?>.init()
    
    // 3 - output
    
    var shouldCloseSettingsVC = PublishSubject<Bool>()
    
    // MARK:- Privates
    
    private func bindControls() { // ovo radi za session + saveSettings
        
        let oSaveSettingsClick = saveSettings
                                    .throttle(0.5, scheduler: MainScheduler.init())
                                    .asObservable()

        oSaveSettingsClick.withLatestFrom(sessionSelected)
            .subscribe(onNext: { [weak self] block in
                guard let strongSelf = self else { return }
                
                if block == nil {
                    print("is clicked but block is nil, please select session")
                    strongSelf.shouldCloseSettingsVC.onNext(false)
                } else {
                    print("is clicked should navigate...")
                    strongSelf.shouldCloseSettingsVC.onNext(true)
                }

            })
            .disposed(by: disposeBag)
        
        cancelSettings
            .throttle(0.5, scheduler: MainScheduler.init())
            .asObservable()
            .subscribe(onNext: { [weak self] tap in
                guard let strongSelf = self else { return }
                strongSelf.shouldCloseSettingsVC.onNext(true)
            })
            .disposed(by: disposeBag)
    }
    
}

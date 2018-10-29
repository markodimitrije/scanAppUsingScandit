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
import Reachability

//class SettingsViewModel {
struct SettingsViewModel {
    
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
    
    // INPUT // treba da slusas preko vc-a o room i session
    var roomSelected = Variable<RealmRoom?>.init(nil)
    var sessionSelected = Variable<RealmBlock?>.init(nil)
    
    private var oRoomSelected: Observable<RealmRoom?> {
        return roomSelected.asObservable()
    }
    
    private var oSessionSelected: Observable<RealmBlock?> {
        return sessionSelected.asObservable()
    }
    
    // 3 - output
    
    var shouldCloseSettingsVC = PublishSubject<Bool>()
    
    // MARK:- Privates
    
    private func bindControls() { // ovo radi za session + saveSettings
        
        let oSaveSettingsClick = saveSettings
                                    .throttle(0.5, scheduler: MainScheduler.init())
                                    .asObservable()

        oSaveSettingsClick.withLatestFrom(oSessionSelected)
            .subscribe(onNext: { block in
                
                if block == nil {
                    print("is clicked but block is nil, please select session")
                    self.shouldCloseSettingsVC.onNext(false)
                } else {
                    print("is clicked should navigate...")
                    self.shouldCloseSettingsVC.onNext(true)
                }

            })
            .disposed(by: disposeBag)
        
        cancelSettings
            .throttle(0.5, scheduler: MainScheduler.init())
            .asObservable()
            .subscribe(onNext: { tap in
                self.shouldCloseSettingsVC.onCompleted() // neces da se nista save...
            })
            .disposed(by: disposeBag)
    }
    
}

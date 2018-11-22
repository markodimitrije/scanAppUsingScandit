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

/*
//class SettingsViewModel {
struct SettingsViewModel {
    
    let disposeBag = DisposeBag()
    
    //var saveSettings: ControlEvent<()>
    //var cancelSettings: ControlEvent<()>
    var saveSettings: Driver<()>
    var cancelSettings: Driver<()>
    
    // 1 - dependencies-init
    init(saveSettings: Driver<()>, cancelSettings: Driver<()>) {
        self.saveSettings = saveSettings
        self.cancelSettings = cancelSettings
        bindControls()
    }
    
    // INPUT // treba da slusas preko vc-a o room i session
    var roomSelected = BehaviorRelay<RealmRoom?>.init(value: nil)
    var sessionSelected = BehaviorRelay<RealmBlock?>.init(value: nil)
    
    private var oRoomSelected: Observable<RealmRoom?> {
        return roomSelected.asObservable()
    }
    
    private var oSessionSelected: Observable<RealmBlock?> {
        return sessionSelected.asObservable()
    }
    
    // 3 - output
    
    var shouldCloseSettingsVC = PublishSubject<Bool>()
    
    var oSessionText = BehaviorRelay<String>.init(value: "")
    
    // MARK:- Privates
    
    private func bindControls() { // ovo radi za session + saveSettings
        
        let oSaveSettingsClick = saveSettings
                                    .throttle(0.5)
                                    .asObservable()

        oSaveSettingsClick.withLatestFrom(oSessionSelected)
            .subscribe(onNext: { block in
                
                self.shouldCloseSettingsVC.onNext(block != nil)

            })
            .disposed(by: disposeBag)
        
        cancelSettings
            .throttle(0.5)
            .asObservable()
            .subscribe(onNext: { tap in
                self.shouldCloseSettingsVC.onCompleted() // neces da se nista save...
            })
            .disposed(by: disposeBag)
    }
    
}
*/

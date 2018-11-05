//
//  UnsyncScansViewModel.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 05/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import UIKit
import RealmSwift
import Realm
import RxSwift
import RxRealm
import RxCocoa

class UnsyncScansViewModel {
    
    let bag = DisposeBag()
    
    var syncScansTap: ControlEvent<()>
    
    init(syncScans: ControlEvent<()>) {
        
        self.syncScansTap = syncScans // sacuvaj na sebi bez modifikacija
        
        bindOutput()
        
        bindInputWithOutput()
    }
    
    // INPUT:
    
    
    
    // OUTPUT
    private (set) var syncControlAvailable = BehaviorSubject<Bool>.init(value: false)
    
    private (set) var syncScansCount = BehaviorSubject<Int>.init(value: 0)
    
    var syncFinished = Variable<Bool>.init(false)
    
    private func bindInputWithOutput() {
        // povezi se sa ostalim inputs i emituj na svoj output
        
        syncScansTap
            .subscribe(onNext: { [weak self] tap in
                
                print("okini event da izprazni codes iz Realm-a")
                
                guard let sSelf = self else {return}
                
                
                if codesDumper == nil { // DUPLICATED !!
                    codesDumper = CodesDumper() // u svom init, zna da javlja reports web-u...
                    codesDumper.oCodesDumped
                        .asObservable()
                        .subscribe(onNext: { (success) in
                            if success {
                                codesDumper = nil
                            }
                        })
                        .disposed(by: sSelf.bag)
                }
                 //izmesti na global ili gde mu je mesto
                
            })
            .disposed(by: bag)
    }

    private func bindOutput() {
        
        // 1
        let realm = try! Realm()
        let result = realm.objects(RealmCodeReport.self)
        Observable.collection(from: result)
            .subscribe(onNext: { [weak self] items in
                guard let sSelf = self else {return}
                print("Query returned \(items.count) items")
                sSelf.syncScansCount.onNext(items.count) // output syncScansCount
            })
            .disposed(by: bag)
        
        // 2
        syncScansCount.asObservable()
            .subscribe(onNext: { [weak self] count in
                guard let sSelf = self else {return}
                sSelf.syncControlAvailable.onNext(count != 0) // output syncControlAvailable
            })
            .disposed(by: bag)
        
    }
    
}


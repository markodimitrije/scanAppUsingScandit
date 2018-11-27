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
    
    private var syncScansTap: Driver<()>
    
    init(syncScans: Driver<()>) {
        
        self.syncScansTap = syncScans // sacuvaj na sebi bez modifikacija
        
        bindOutput()
        
        bindInputWithOutput()
    }
    
    // INPUT:
    
    // OUTPUT
    private (set) var syncControlAvailable = BehaviorSubject<Bool>.init(value: false)
    
    private (set) var syncScansCount = BehaviorSubject<Int>.init(value: 0)
    
    var syncFinished = BehaviorRelay<Bool>.init(value: false)
    
    // interna upotreba....
    
    private let bag = DisposeBag()
    
    private func bindInputWithOutput() {
        // povezi se sa ostalim inputs i emituj na svoj output
        
        syncScansTap
            .drive(onNext: { [weak self] tap in
                
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

        Observable.collection(from: realm.objects(RealmCodeReport.self))
            .map({
                return $0.toArray()
            })
            .asDriver(onErrorJustReturn: [])
                .map {$0.count}
                .debug()
                .drive(syncScansCount)
                .disposed(by: bag)
        
        syncScansCount
            .map {$0 != 0}
            .asDriver(onErrorJustReturn: false) // netacno... a sta je uopste tacno u ovom slucaju ??
            .drive(syncControlAvailable)
            .disposed(by: bag)
    }
    
}


//
//  ScannerViewModel.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 23/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

struct ScannerViewModel {
    
    var roomSelected = PublishSubject<RealmRoom>.init()
    var sessionSelected = PublishSubject<RealmBlock?>.init()
    
    let bag = DisposeBag()
    
    init() {
        bindOutput()
    }
    
    // OUTPUT
    var sessionName = PublishSubject<String>.init()
    var sessionInfo = PublishSubject<String>.init()
    
    private func bindOutput() {
    
        Observable.combineLatest(roomSelected, sessionSelected) { (room, block) -> (String, String) in
            
            guard let block = block else {
                return (SessionTextData.noActiveSession,"")
            }
            
            return (block.name, block.duration + ", " + room.name)
            
            }.subscribe(onNext: {  (blockName, blockInfo) in
                self.sessionName.onNext(blockName)
                self.sessionInfo.onNext(blockInfo)
            })
            .disposed(by: bag)
    }
    
}

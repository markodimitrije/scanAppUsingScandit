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
    
    var roomSelected = PublishSubject<RealmRoom?>.init()
    var sessionSelected = PublishSubject<RealmBlock?>.init()
    
    let bag = DisposeBag()
    
    init() {
        bindOutput()
    }
    
    // OUTPUT
    var sessionName = PublishSubject<String>.init()
    var sessionInfo = PublishSubject<String>.init()
    private (set) var oSessionId = Variable<Int>.init(-1) // err state
    var sessionId: Int {
        return oSessionId.value
    }
    
    private func bindOutput() {
    
        Observable.combineLatest(roomSelected, sessionSelected) { (room, block) -> (String, String, Int) in
            
                guard let room = room else {
                    return (RoomTextData.noRoomSelected,"", -1)
                }
            
                guard let block = block else {
                    return (SessionTextData.noActiveSession,"", -1)
                }
            
                return (block.name, block.duration + ", " + room.name, block.id)
            
            }
            .subscribe(onNext: {  (blockName, blockInfo, blockId) in
                self.sessionName.onNext(blockName)
                self.sessionInfo.onNext(blockInfo)
                self.oSessionId.value = blockId
            })
            .disposed(by: bag)
    }
    
}

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
    
    var dataAccess: DataAccess!
    
    init(dataAccess: DataAccess) {
        self.dataAccess = dataAccess
        bindOutput()
    }
    
    // OUTPUT
    var sessionName = PublishSubject<String>.init()
    var sessionInfo = PublishSubject<String>.init()

    private (set) var oSessionId = BehaviorRelay<Int>.init(value: -1) // err state
    
    var sessionId: Int {
        return oSessionId.value
    }
    
    private let bag = DisposeBag()
    
    private func bindOutput() {
    
        dataAccess.output
            .delay(0.05, scheduler: MainScheduler.instance) // HACK - ovaj signal emituje pre nego je izgradjen UI
            .map({ (room, block) -> (String, String, Int) in
                guard let room = room else {
                    return (RoomTextData.noRoomSelected, "", -1)
                }
                
                guard let block = block else {
                    return (SessionTextData.noActiveSession, "", -1)
                }
                return (block.name, block.duration + ", " + room.name, block.id)
            })
            .subscribe(onNext: { (blockName, blockInfo, blockId) in
                self.sessionName.onNext(blockName)
                self.sessionInfo.onNext(blockInfo)
                self.oSessionId.accept(blockId)
            })
            .disposed(by: bag)
        
    }
    
}

//
//  AutoSelSessionViewModel.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 24/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift

struct AutoSelSessionViewModel {
    
    let bag = DisposeBag()
    let blockViewModel: BlockViewModel!
    
    init(roomId: Int) {
        blockViewModel = BlockViewModel.init(roomId: roomId)
        bindInputWithOutput()
    }
    
    // INPUT:
    var selectedRoom = BehaviorSubject<RealmRoom?>.init(value: nil) // implement me
    var switchState = BehaviorSubject<Bool>.init(value: true)
    
    // OUTPUT
    var selectedSession = BehaviorSubject<RealmBlock?>.init(value: nil)
    
    private func bindInputWithOutput() {
        // povezi se sa ostalim inputs i emituj na svoj output
        switchState
            .subscribe(onNext: { tap in
                if tap { // nadji mu po odg algoritmu za vreme do starta session-a
                    guard let value = try? self.blockViewModel.oAutomaticSession.value() else {
                        return self.selectedSession.onNext(nil)
                    }
                    
                    self.selectedSession.onNext(value)
                    
                } else {
                
                    self.selectedSession.onNext(nil)
                }
            })
        .disposed(by: bag)
    }

}

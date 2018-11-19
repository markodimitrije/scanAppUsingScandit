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

class AutoSelSessionViewModel {
    
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
                    guard let value = self.blockViewModel.oAutomaticSession.value else {
                        return self.selectedSession.onNext(nil)
                    }
                    
                    self.selectedSession.onNext(value)
                    
                } else {
                
                    self.selectedSession.onNext(nil)
                }
            })
        .disposed(by: bag)
    }
    
    deinit {
        print("AutoSelSessionViewModel.deinit")
    }
    
}



class AutoSelSessionWithWaitIntervalViewModel {
    
    let bag = DisposeBag()
    let blockViewModel: BlockViewModel!
    
    init(roomId: Int, interval: TimeInterval = MyTimeInterval.waitToMostRecentSession) {
        inSelTimeInterval.onNext(interval)
        blockViewModel = BlockViewModel.init(roomId: roomId)
        bindInputWithOutput()
    }
    
    // INPUT:
    var selectedRoom = BehaviorSubject<RealmRoom?>.init(value: nil) // implement me
    var switchState = BehaviorSubject<Bool>.init(value: true)
    var inSelTimeInterval = BehaviorSubject<TimeInterval>.init(value: MyTimeInterval.waitToMostRecentSession)
    
    private var inSelTimeIntervalDriver: SharedSequence<DriverSharingStrategy, TimeInterval> {
        return inSelTimeInterval.asDriver(onErrorJustReturn: MyTimeInterval.waitToMostRecentSession)
    }
    
    private var inSwitchStateDriver: SharedSequence<DriverSharingStrategy, Bool> {
        return switchState.asDriver(onErrorJustReturn: false)
    }
    
    // OUTPUT
    var selectedSession = BehaviorSubject<RealmBlock?>.init(value: nil)
    
    private func bindInputWithOutput() {
        
        // switch binding:
        
        inSwitchStateDriver // switch driver
            .drive(onNext: { tap in // pretplati se da slusas (observe)
                self.blockViewModel.oAutomaticSessionDriver // uzmi slave-ov output
                    .drive(self.selectedSession) // i njime 'pogoni' svoj output
                    .disposed(by: self.bag)
            })
            .disposed(by: bag)

        // autoSelTimeInterval binding:
        
        inSelTimeIntervalDriver // hookUp input ! // sopstveni input
            .drive(blockViewModel.oAutoSelSessInterval) // prosledi na input svog slave-a
            .disposed(by: bag)
        
        blockViewModel.oAutomaticSessionDriver // output svog slave-a
            .drive(selectedSession) // prosledi na svoj output
            .disposed(by: bag)
        
    }
    
    deinit { print("AutoSelSessionViewModel.deinit") }
    
}

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
        bindAutoSelSession()
    }
    
    // INPUT:
    var selectedRoom = BehaviorSubject<RealmRoom?>.init(value: nil) // implement me
    var selectedSession = BehaviorSubject<RealmBlock?>.init(value: nil)
    var switchState = BehaviorSubject<Bool>.init(value: false)
    
    // OUTPUT
    var sessionName = PublishSubject<String>.init()
    
    private func bindInputWithOutput() {
        // povezi se sa ostalim inputs i emituj na svoj output
        switchState
            .subscribe(onNext: { tap in
                if tap { // nadji mu po odg algoritmu za vreme do starta session-a
                    guard let value = try? self.blockViewModel.oAutomaticSession.value() else {return}
                        let name = value?.name ?? "Error finding auto session"
                    
                    self.sessionName.onNext(name)
                    
                } else {
                
                    do {
                        if let selected = try self.selectedSession.value() {
                            self.sessionName.onNext(selected.name)
                        } else {
                            self.sessionName.onNext(SessionTextData.selectSession)
                        }
                    } catch { // ovde treba da throw nesto, ali sta ?
                        self.sessionName.onNext(SessionTextData.selectSession)
                    }
                }
            })
        .disposed(by: bag)
    }
    
    private func bindAutoSelSession() {
        
        blockViewModel.oAutomaticSession
            .subscribe(onNext: { block in
                let name = block?.name ?? SessionTextData.noAutoSelSessionsAvailable
                self.sessionName.onNext(name)
            })
            .disposed(by: bag)
    }
    
}

//
//  File.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 22/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import RxSwift
import RxCocoa

final class SettingsViewModel: ViewModelType {
    
    var dataAccess: DataAccess
    
    init(dataAccess: DataAccess) {
        self.dataAccess = dataAccess
    }
    
    func transform(input: Input) -> Output {
        
        let roomTxt = input.roomSelected.map { room -> String in
            return room?.name ?? RoomTextData.selectRoom
        }
        
        let autoSessionDriver = Driver.combineLatest(input.roomSelected.startWith(nil),
                                                     input.autoSelSessionSwitch.startWith(true),
                                                     input.picker.startWith(MyTimeInterval.waitToMostRecentSession)) { (room, switchIsOn, interval) -> RealmBlock? in
            guard let roomId = room?.id else {return nil}
            if switchIsOn {
                let autoModelView = AutoSelSessionWithWaitIntervalViewModel.init(roomId: roomId)
                autoModelView.inSelTimeInterval.onNext(interval)
                return try! autoModelView.selectedSession.value() ?? nil // pazi ovde !! try !
            }
            return nil
        }
        
        let manualAndAutoSession = Driver.merge([input.sessionSelected, autoSessionDriver])//.debug()
        let a = input.roomSelected.map { _ -> Void in return () }
        let b = input.sessionSelected.map { _ -> Void in return () }
        let c = autoSessionDriver.map { _ -> Void in return () }
        
        let composeAllEvents = Driver.merge([a,b,c])

        let saveSettingsAllowed = composeAllEvents.withLatestFrom(manualAndAutoSession)
            .map { block -> Bool in
                return block != nil
            }
        
        let sessionTxt = Driver.combineLatest(manualAndAutoSession.startWith(nil),
                                        input.autoSelSessionSwitch.startWith(true)) { (block, state) -> String in
                                            if let name = block?.name {
                                                return name
                                            } else {
                                                if state {
                                                    return SessionTextData.noAutoSessAvailable
                                                } else {
                                                    return SessionTextData.selectSessionManually
                                                }
                                            }
        }
        
        let saveCancelTrig = Driver.merge([input.cancelTrigger.map {return false},
                                           input.saveSettingsTrigger.map {return true}])
        
        let finalSession = Driver.combineLatest(manualAndAutoSession, saveCancelTrig) {
            (session, tap) -> RealmBlock? in
                if tap {
                    return session
                } else {
                    return nil
                }
        }
        
        let sessionInfo = Driver.combineLatest(input.roomSelected, finalSession) { (room, session) -> (Int, Int)? in
            guard let roomId = room?.id, let sessionId = session?.id else {
                self.dataAccess.userSelection = (nil, nil)
                return nil}

            self.dataAccess.userSelection = (roomId, sessionId)

            return (roomId, sessionId)
        }
        
        return Output(roomTxt: roomTxt,
                      sessionTxt: sessionTxt,
                      saveSettingsAllowed: saveSettingsAllowed,
//                      wiFiStaticTxt: editing,
//                      wiFiDynamicTxt: post,
                      selectedBlock: finalSession,
                      sessionInfo: sessionInfo
        )
    }
}

extension SettingsViewModel {
    struct Input {
        let cancelTrigger: Driver<Void>
        let saveSettingsTrigger: Driver<Void>
        let roomSelected: Driver<RealmRoom?>
        let sessionSelected: Driver<RealmBlock?>
        let autoSelSessionSwitch: Driver<Bool>
        let picker: Driver<TimeInterval>
//        let internetConnection: Driver<Bool>
//        let unsyncScans: Driver<Int>
    }
    
    struct Output {
        let roomTxt: Driver<String>
        let sessionTxt: Driver<String>
        let saveSettingsAllowed: Driver<Bool>
//        let wiFiStaticTxt: Driver<String>
//        let wiFiDynamicTxt: Driver<String>
        let selectedBlock: Driver<RealmBlock?>
        let sessionInfo: Driver<(Int, Int)?>
    }
}


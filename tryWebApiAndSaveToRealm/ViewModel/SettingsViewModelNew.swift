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
//    private let post: Post // public struct Post: Codable u Domain/Entities
//    private let useCase: PostsUseCase // public protocol PostsUseCase u Domain/UseCases
//    private let navigator: EditPostNavigator // protocol EditPostNavigator u Scenes/EditPosts/EditPostNavigator
    
//    init(post: Post, useCase: PostsUseCase) {
//        self.post = post
//        self.useCase = useCase // ovo treba da znas sta ces da radis, use case, obrisi u bazi i slicno
//        self.navigator = navigator // data ti je navigacija, jer znas koji vc da prikazes u kom slucaju...
//    }
    
    func transform(input: Input) -> Output {
        
        let roomTxt = input.roomSelected.map { room -> String in
            return room?.name ?? RoomTextData.selectRoom
        }
//        let sessionTxt = input.sessionSelected.map { block -> String in
//            return block?.name ?? SessionTextData.noAutoSessAvailable
//        }
        let saveSettingsAllowed = Driver.combineLatest(input.roomSelected, input.sessionSelected) { (room, session) -> Bool in
            return (session != nil)
        }
        
        let cancelTap = input.cancelTrigger.map {return false}
        let saveTap = input.saveSettingsTrigger.withLatestFrom(saveSettingsAllowed)
        
        let settingsCorrect = Driver
                                .merge([cancelTap, saveTap])
                                .debug()
        
        let sessionTxt = Driver.combineLatest(input.sessionSelected, input.autoSelSessionSwitch) { (session, switchState) -> String in
            if let name = session?.name {
                return name
            } else {
                if switchState {
                    return SessionTextData.noAutoSelSessionsAvailable
                } else {
                    return SessionTextData.selectSessManuallyOrTryAuto
                }
            }
        }
        
        return Output(roomTxt: roomTxt,
                      sessionTxt: sessionTxt,
                      saveSettingsAllowed: saveSettingsAllowed,
//                      wiFiStaticTxt: editing,
//                      wiFiDynamicTxt: post,
                      settingsCorrect: settingsCorrect
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
//        let picker: Driver<TimeInterval>
//        let internetConnection: Driver<Bool>
//        let unsyncScans: Driver<Int>
    }
    
    struct Output {
        let roomTxt: Driver<String>
        let sessionTxt: Driver<String>
        let saveSettingsAllowed: Driver<Bool>
//        let wiFiStaticTxt: Driver<String>
//        let wiFiDynamicTxt: Driver<String>
        let settingsCorrect: Driver<Bool>
    }
}


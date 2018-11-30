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
    
    var dataAccess: DataAccess
    
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

class DataAccess: NSObject {
    
    private var _roomSelected = BehaviorRelay<RealmRoom?>.init(value: nil)
    private var _blockSelected = BehaviorRelay<RealmBlock?>.init(value: nil)
    
    static var shared = DataAccess()
    
    var output: Observable<(RealmRoom?, RealmBlock?)> {
        return Observable.combineLatest(_roomSelected.asObservable(), _blockSelected.asObservable(), resultSelector: { (room, block) -> (RealmRoom?, RealmBlock?) in
            print("emitujem iz DataAccess..room i session za.... \(room?.id), \(block?.id)")
            return (room, block)
        })
    }
    
    override init() {
        super.init()
        UserDefaults.standard.addObserver(self, forKeyPath: "roomId", options: [.initial, .new], context: nil)
        UserDefaults.standard.addObserver(self, forKeyPath: "sessionId", options: [.initial, .new], context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else {return}
        guard let realm = try? Realm.init() else {return}
        
        if keyPath == "roomId" {
            guard let roomId = UserDefaults.standard.value(forKey: keyPath) as? Int else {return}
            
            _roomSelected.accept(RealmRoom.getRoom(withId: roomId, withRealm: realm))
            
        } else if keyPath == "sessionId" {
            guard let sessionId = UserDefaults.standard.value(forKey: keyPath) as? Int else {return}
            
            _blockSelected.accept(RealmBlock.getBlock(withId: sessionId, withRealm: realm))
            
        }
        
    }

    var userSelection: (Int?,Int?) {
        get {
            return (UserDefaults.standard.value(forKey: "roomId") as? Int,
                    UserDefaults.standard.value(forKey: "sessionId") as? Int
            )
        }
        set {
            UserDefaults.standard.set(newValue.0, forKey: "roomId")
            UserDefaults.standard.set(newValue.1, forKey: "sessionId")
        }
    }

    
}

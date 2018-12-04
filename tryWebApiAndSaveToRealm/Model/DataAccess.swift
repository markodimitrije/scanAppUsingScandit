//
//  DataAccess.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 04/12/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Realm
import RealmSwift

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

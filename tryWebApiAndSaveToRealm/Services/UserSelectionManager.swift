//
//  UserSelectionManager.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 29/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserSelectionManager: NSObject {
    
    private let _location = BehaviorRelay<Int?>.init(value: nil)
    private let _block = BehaviorRelay<Int?>.init(value: nil)
    
    private static var observerContext = 0
    
    var location: Driver<Int?> {
        return _location.asDriver(onErrorJustReturn: nil)
    }
    var block: Driver<Int?> {
        return _block.asDriver(onErrorJustReturn: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let roomId = keyPath, roomId == "roomId" {
            _location.accept(UserDefaults.standard.value(forKey: "roomId") as? Int)
        } else if let sessionId = keyPath, sessionId == "sessionId" {
            _block.accept(UserDefaults.standard.value(forKey: "sessionId") as? Int)
        }
    }
    
}

//
//  BatteryState.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 28/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BatteryLevelManager {
    
    // OUTPUT
    var batteryLevel: BehaviorRelay<Float>!
    var level: Float!
    
    init() {
        //batteryLevel = Observable.from(optional: UIDevice.current.batteryLevel)
        batteryLevel = BehaviorRelay.init(value: UIDevice.current.batteryLevel)
        level = UIDevice.current.batteryLevel
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        print("batteryLevelDidChange = \(UIDevice.current.batteryLevel)")
        batteryLevel.accept(UIDevice.current.batteryLevel)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
    }
}

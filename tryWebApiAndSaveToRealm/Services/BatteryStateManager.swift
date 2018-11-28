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

class BatteryManager {
    
    // OUTPUT
    var batteryLevel: BehaviorRelay<Int>!
    var batteryState: BehaviorRelay<UIDevice.BatteryState>!
    
    var info: BatteryInfo {
        return BatteryInfo.init(level: _level,
                                status: _batteryState)
    }
    
    // MARK: - Private vars
    
    private var _level: Int!
    
    private var _batteryState: String {
        switch UIDevice.current.batteryState {
        case .charging: return "charging"
        case .full: return "full"
        case .unplugged: return "unplugged"
        default: return "unknown"
        }
    }
    
    init() {
        
        batteryLevel = BehaviorRelay.init(value: Int(100 * UIDevice.current.batteryLevel))
        _level = Int(UIDevice.current.batteryLevel * 100)
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange), name: UIDevice.batteryLevelDidChangeNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange), name: UIDevice.batteryStateDidChangeNotification, object: nil)

    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        print("batteryLevelDidChange = \(UIDevice.current.batteryLevel)")
        batteryLevel.accept(Int( 100 * UIDevice.current.batteryLevel ))
    }
    
    @objc func batteryStateDidChange(_ notification: Notification) {
        print("batteryStateDidChange = \(UIDevice.current.batteryState)")
        batteryState.accept(UIDevice.current.batteryState)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
    }
}

struct BatteryInfo {
    var level: Int
    var status: String
}

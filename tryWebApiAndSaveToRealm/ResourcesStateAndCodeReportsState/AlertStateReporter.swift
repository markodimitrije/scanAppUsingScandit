//
//  AlertStateReporter.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 28/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AlertStateMonitor {
    
    // OUTPUT
    var deviceReport = DeviceReport.init()
    
    // MARK: - Private vars
    
    private var _batteryState: String {
        return batteryStateConverter[UIDevice.current.batteryState] ?? ""
    }
    
    init() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryLevelDidChange(_:)), name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(batteryStateDidChange(_:)), name: UIDevice.batteryStateDidChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterForeground(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    @objc func batteryLevelDidChange(_ notification: Notification) {
        print("AlertStateMonitor/batteryLevelDidChange = \(UIDevice.current.batteryLevel)")
        deviceReport.batteryLevel.accept(Int( 100 * UIDevice.current.batteryLevel ))
    }
    
    @objc func batteryStateDidChange(_ notification: Notification) {
        print("AlertStateMonitor/batteryStateDidChange = \(UIDevice.current.batteryState)")
        deviceReport.batteryState.accept(_batteryState)
    }
    
    @objc func appDidEnterForeground(_ notification: Notification) {
        print("AlertStateMonitor/appDidEnterForeground is called")
        deviceReport.appInForeground.accept(true)
    }
    
    @objc func appWillResignActive(_ notification: Notification) {
        print("AlertStateMonitor/appWillResignActive is called")
        deviceReport.appInForeground.accept(false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryLevelDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.batteryStateDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    struct DeviceReport {
        
        var batteryLevel: BehaviorRelay<Int>!
        var batteryState: BehaviorRelay<String>!
        var appInForeground: BehaviorRelay<Bool>!
        
        init() { // init-ujem sa actual vals + losiji scenario za appInForeground..
            //print("emitujem batLevel = \(Int(100*UIDevice.current.batteryLevel))")
            batteryLevel = BehaviorRelay<Int>.init(value: Int(100*UIDevice.current.batteryLevel))
            batteryState = BehaviorRelay<String>.init(value: batteryStateConverter[UIDevice.current.batteryState] ?? "")
            appInForeground = BehaviorRelay<Bool>.init(value: false)
        }
    }
    
}

// NECU DA IMA INPUT-OUTPUT JER SU INPUT OBICNO USER_ACTIONS< A OVDE JE SVE SISTEM PARAMS (BATT, CHARGE ...)

class AlertStateReporter {
    
    var roomId: BehaviorRelay<Int?> = BehaviorRelay.init(value: nil)
    var sessionId: BehaviorRelay<Int?> = BehaviorRelay.init(value: nil)
    
    init(monitor: AlertStateMonitor, webAPI: ApiController) {
        
        Observable.combineLatest(roomId,
                                 sessionId,
                                 monitor.deviceReport.appInForeground,
                                 //monitor.deviceReport.batteryLevel.filter {$0 < MyConstants.batteryLevelTrig},
                                 monitor.deviceReport.batteryLevel, // test
                                 monitor.deviceReport.batteryState) {
                                    
            (room, session, appInFg, batLevel, batStatus) -> SessionReport in
            
            //print("sklopio inpute u sessionReport")
            
                return SessionReport.init(location_id: room ?? -1, block_id: session ?? -1, battery_level: batLevel, battery_status: batStatus, app_active: appInFg)
                                    
            }.subscribe(onNext: { report in
                
                print("AlertStateReporter.javi web-u ovaj report = \(report.description)")
                
                _ = webAPI
                    .reportSelectedSession(report: report) // ne reagujem da odg, a nije lose da ima UserDefaults i da onda javlja stalno...
            })
            .disposed(by: bag)
        
    }
    
    private let bag = DisposeBag()
}

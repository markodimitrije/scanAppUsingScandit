//
//  DeviceStateReporter.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 28/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import Foundation
import RxSwift

// ideja je da ova klasa ima nekoliko API-ja i da onda javlja web-u (i manage na device) report vezano za:
// battery level opao ispod 20%
// session i room selected
// device se vratio iz background-a
// i slicno ...

// za sada implementiram samo input da je roomId i sessionId selected, i tome pridruzujem aktuelni battery level

class DeviceStateReporter {
    
    private let bag = DisposeBag()
    
    // API
    
    func sessionIsSet(info: (location_id: Int, block_id: Int),
                      battery_info: BatteryInfo,
                      app_active: Bool) {
        
        let session = SessionReport.init(location_id: info.location_id,
                                         block_id: info.block_id,
                                         battery_level: battery_info.level,
                                         battery_status: battery_info.status,
                                         app_active: app_active)
        
        reportToWeb(session: session)
        
    }
    
    private func reportToWeb(session: SessionReport) {
        
        ApiController.shared.reportSelectedSession(report: session)
            .subscribe(onNext: { (report, success) in
//                print("DeviceStateReporter.sessionIsSet: \(report), success \(success)")
            })
            .disposed(by: bag)
        
    }
    
}

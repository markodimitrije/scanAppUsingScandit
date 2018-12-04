//
//  CodesDumper.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 04/11/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import Realm

class CodesDumper {
    
    let bag = DisposeBag.init()
    
    var timer: Observable<Int>?
    
    var isRunning = BehaviorRelay.init(value: false) // timer
    
    var timerFired = BehaviorRelay.init(value: ()) // timer events
    
    var timeToSendReport: Observable<Bool> {
        return timerFired
                    .asObservable()
                    //.map {return true} // temp ON
                    .withLatestFrom(connectedToInternet()) // temp OFF
    }
    
    var codeReportsDeleted: BehaviorRelay<Bool> = {
        return BehaviorRelay.init(value: RealmDataPersister.shared.getCodeReports().isEmpty)
    }()
    
    init() { print("CodesDumper.INIT, fire every 8 sec or on wi-fi changed")
        
        hookUpTimer()
        
        hookUpNotifyWeb()
        
        hookUpAllCodesReportedToWeb()
        
    }
    
    // Output
    
    var oCodesDumped = BehaviorRelay<Bool>.init(value: false)
    
    // MARK:- Private
    
    private func hookUpTimer() {
        
        isRunning.asObservable()
            .debug("isRunning")
            .flatMapLatest {  isRunning in
                isRunning ? Observable<Int>.interval(8, scheduler: MainScheduler.instance) : .empty()
            }
            .flatMapWithIndex { (int, index) in
                return Observable.just(index)
            }
            .debug("timer")
            .subscribe({[weak self] _ in
                guard let sSelf = self else {return}
                sSelf.timerFired.accept(())
            })
            .disposed(by: bag)
        
        isRunning.accept(true) // one time pokreni timer
        
    }
    
    private func hookUpNotifyWeb() {
        
        timeToSendReport
            .subscribe(onNext: { [weak self] timeToReport in
                
//                print("timeToReport = \(timeToReport)")
                
                guard let sSelf = self else {return}
                
                let codeReports = RealmDataPersister.shared.getCodeReports()
                
                sSelf.reportSavedCodesToWeb(codeReports: codeReports)
                    .subscribe(onNext: { success in
                        if success {
                            
                            RealmDataPersister.shared.deleteCodeReports(codeReports)
                                .subscribe(onNext: { deleted in
                                    
                                    sSelf.codeReportsDeleted.accept(deleted)
                                })
                                .disposed(by: sSelf.bag)
                        } else {
                            print("nije success, nastavi da saljes")
                        }
                    })
                    .disposed(by: sSelf.bag)
            })
            .disposed(by: bag)
        
    }
    
    private func hookUpAllCodesReportedToWeb() {
        
        codeReportsDeleted.asObservable()
            .subscribe(onNext: { [weak self] success in
                guard let sSelf = self else {return}
                if success { print("all good, ugasi timer!")
                    
                    sSelf.isRunning.accept(false)  // ugasi timer, uspesno si javio i obrisao Realm
                    sSelf.oCodesDumped.accept(true)
                }
            })
            .disposed(by: bag)
    }
    
    private func reportSavedCodesToWeb(codeReports: [CodeReport]) -> Observable<Bool> { print("reportSavedCodesToWeb")
        
        guard !codeReports.isEmpty else { print("CodesDumper.reportSavedCodes/ internal error...")
            return Observable.just(false)
        }
        
        // posalji codes web-u... - // posalji web-u ... koji vraca Observable<>Bool

        return ApiController.shared
            .reportMultipleCodes(reports: codeReports) // Observable<Bool>
            .map({ (success) -> Bool in
//                print("reportSavedCodesToWeb.reported \(success)")
                if success {
                    return true
                } else {
                    return false
                }
            })
    }
    
}


enum ReportToWebError: Error {
    case noCodesToReport
    case notConfirmedByServer // nije 201
}

//
//  Logic.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 30/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import Realm

class ResourcesState {
    
    var resourcesDownloaded: Bool? {
        get {
            return UserDefaults.standard.value(forKey: UserDefaults.keyResourcesDownloaded) as? Bool
        }
        set {
            UserDefaults.standard.set(true, forKey: UserDefaults.keyResourcesDownloaded)
        }
    }
    
    var shouldDownloadResources: Bool {
        if resourcesDownloaded == nil || resourcesDownloaded == false {
            print("shouldDownloadResources. TRUE!")
            return true
        } else {
            print("shouldDownloadResources. FALSE!")
            return false
        }
    }
    
    private var timer: Timer?
    
    private let bag = DisposeBag()
    
    private var downloads = PublishSubject<Bool>.init()
    
    init() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appWillEnterBackground),
            name: UIApplication.willResignActiveNotification,
            object: nil)
        
        downloads
            .take(2) // room API and blocks API
            .reduce(true) { (sum, last) -> Bool in
                sum && last
            }
            .subscribe(onNext: { [weak self] success in
                guard let sSelf = self else {return}
                sSelf.resourcesDownloaded = success
                sSelf.timer?.invalidate()
            })
            .disposed(by: bag)
    }
    
    @objc private func appDidBecomeActive() {
        
        //        print("ResourcesState/ appDidBecomeActive is called")
        
        if shouldDownloadResources {
            
            fetchRoomsAndBlocksResources()
            
            if timer == nil {
                
                timer = Timer.scheduledTimer(
                    timeInterval: TimeInterval.timerForFetchingRoomAndBlockResources,
                    target: self,
                    selector: #selector(ResourcesState.fetchRoomsAndBlocksResources),
                    userInfo: nil,
                    repeats: true)
            }
        }
    }
    
    @objc private func appWillEnterBackground() {
        
        //        print("ResourcesState/ appWillEnterForeground is called")
        
        timer?.invalidate()
        //timer = nil
    }
    
    @objc private func fetchRoomsAndBlocksResources() {
        
        //        print("fetchRoomsAndBlocksResources is called")
        
        RealmDataPersister.shared.deleteDataIfAny()
            .subscribe(onNext: { [weak self] (realmIsEmpty) in
                
                guard let strongSelf = self else {return}
                
                if realmIsEmpty {
                    
                    strongSelf.fetchRoomsAndSaveToRealm()
                    strongSelf.fetchSessionsAndSaveToRealm()
                }
            })
            .disposed(by: bag)
        
    }
    
    
    private func fetchRoomsAndSaveToRealm() {
        
        //        print("fetchRoomsAndSaveToRealm is called")
        
        let oRooms = ApiController.shared.getRooms(updated_from: nil,
                                                   with_pagination: 0,
                                                   with_trashed: 0)
        oRooms
            .subscribe(onNext: { [ weak self] (rooms) in
                
                guard let strongSelf = self else {return}
                
                RealmDataPersister.shared.saveToRealm(rooms: rooms)
                    .subscribe(onNext: { (success) in
                        
                        strongSelf.downloads.onNext(success)
                        
                    })
                    .disposed(by: strongSelf.bag)
                
            })
            .disposed(by: bag)
        
    }
    
    private func fetchSessionsAndSaveToRealm() {
        
        //        print("fetchSessionsAndSaveToRealm is called")
        
        let oBlocks = ApiController.shared.getBlocks(updated_from: nil,
                                                     with_pagination: 0,
                                                     with_trashed: 0)
        oBlocks
            .subscribe(onNext: { [weak self] (blocks) in
                
                guard let strongSelf = self else {return}
                
                RealmDataPersister.shared.saveToRealm(blocks: blocks)
                    .subscribe(onNext: { (success) in
                        
                        strongSelf.downloads.onNext(success) // okini na svom observable, njega monitor
                        
                    })
                    .disposed(by: strongSelf.bag)
                
            })
            .disposed(by: bag)
    }
    
    deinit {
        print("ResourcesState.deinit is called")
    }
    
}




class CodeReportsState {
    
    private var codeReports: Results<CodeReport>? {
        
        guard let realm = try? Realm.init() else {return nil} // ovde bi trebalo RealmError!
        
        return realm.objects(CodeReport.self)
    }
    
    private var shouldReportToWeb: Bool {
        
        guard let reports = codeReports else {return false} // ovde bi trebalo RealmError!
        
        return reports.isEmpty
    }
    
    private var timer: Timer?
    
    private let bag = DisposeBag()
    
    // INPUT
    
    //let codeReport = BehaviorRelay<CodeReport?>.init(value: nil)
    let codeReport = Variable<CodeReport?>.init(nil)
    
    // OUTPUT
    
    let webNotified = Variable<(CodeReport, Bool)?>.init(nil)
    
    //let webNotified = BehaviorRelay<(CodeReport, Bool)?>.init(value: nil)

    init() {
        
        bindInputWithOutput()
        
    }
    
    private func bindInputWithOutput() {
        
        print("CodeReportsState.bindInputWithOutput")
        
        codeReport
            .asObservable()
            .subscribe(onNext: { [weak self] report in
                
                print("pozivam reportImidiatelly ??")
                
                guard let sSelf = self else {return}
                let obs = sSelf.reportImidiatelly(codeReport: sSelf.codeReport.value)
                obs
                    .subscribe(onNext: { (code, success) in
                        print("web notified onNext za \(code), sa success \(success)")
                        sSelf.webNotified.value = (code, success)
                    })
                    .disposed(by: sSelf.bag)
            })
            .disposed(by: bag)
    }
    
    private func reportImidiatelly(codeReport: CodeReport?) -> Observable<(CodeReport, Bool)> {
        
        guard let report = codeReport else {return Observable.empty()}
        
        return ApiController.shared.reportSingleCode(report: report)
        
    }
    
    private func reportToWeb(codeReports: Results<CodeReport>?) {
        
        // sviranje... treba mi servis da javi sve.... za sada posalji samo jedan...
        
        guard let report = codeReports?.first else {
            print("nemam ni jedan code da report!...")
            return
        }

        print("CodeReportsState/ javi web-u za ovaj report:")
        print("code = \(report.code)")
        print("code = \(report.date)")
        print("code = \(report.sessionId)")
    }
    
    private func reportToWebFailed(codeReport: CodeReport) {
        
        // sviranje... treba mi servis da javi sve.... za sada posalji samo jedan...
        
        guard let report = codeReports?.first else {
            print("nemam ni jedan code da report!...")
            return
        }
        
        print("CodeReportsState/ javi web-u za ovaj report:")
        print("code = \(report.code)")
        print("code = \(report.date)")
        print("code = \(report.sessionId)")
    }
    
}

class CodeReport: Object { // Realm Entity
    
    var code: String = ""
    var sessionId: Int = -1
    var date: Date = Date(timeIntervalSinceNow: 0)
    
    init(code: String, sessionId: Int, date: Date) {
        self.code = code
        self.sessionId = sessionId
        self.date = date
        super.init()
    }
    
    func getPayload() -> [String: String] {
        
        return [
            "block_id": "\(sessionId)",
            "code": code,
            "time_of_scan": date.toString(format: Date.defaultFormatString) ?? ""
        ]
    }
    
    // kompajler me tera da implementiram, mogu li ikako bez toga ? ...
    
    required init() {
        super.init()
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
}

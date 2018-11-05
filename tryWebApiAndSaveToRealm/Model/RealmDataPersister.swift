//
//  RealmDataPersister.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 30/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift
import Realm

struct RealmDataPersister {
    
    static var shared = RealmDataPersister()
    
    // MARK:- CodeReports
    
    func getCodeReportsCount() -> Observable<Int> {
        
        guard let realm = try? Realm.init() else {return Observable.empty()} // iako je Error!
        
        let count = realm.objects(RealmCodeReport.self).count
        
        return Observable.just(count)
        
    }
    
    func getCodeReports() -> [CodeReport] {
        
        guard let realm = try? Realm.init() else {return [ ]} // iako je Error!
        
        let realmResults = realm.objects(RealmCodeReport.self).toArray()
        
        return realmResults.map {CodeReport.init(realmCodeReport: $0)}
        
    }
    
    func deleteAllCodeReports() -> Observable<Bool> {
        
        guard let realm = try? Realm.init() else {
            return Observable.just(false)
        } // iako je Error!
        
        let realmResults = realm.objects(RealmCodeReport.self)
        
        do {
            try realm.write {
                realm.delete(realmResults)
            }
//            print("RealmDataPersister.deleteAllCodeReports.all code reports are deleted")
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }
        
    }
    
    func deleteCodeReports(_ codeReports: [CodeReport]) -> Observable<Bool> {
        
        guard let realm = try? Realm.init() else {
            return Observable.just(false)
        } // iako je Error!
        
        let realmResults = realm.objects(RealmCodeReport.self).filter { report -> Bool in
            return codeReports.map {$0.code}.contains(report.code)
        }
        
        do {
            try realm.write {
                realm.delete(realmResults)
            }
            print("RealmDataPersister.deleteCodeReports: delete Reported CodeReports")
            return Observable.just(true)
        } catch {
            return Observable.just(false)
        }
        
    }
    
    // MARK:- Save data
    
    func saveToRealm(rooms: [Room]) -> Observable<Bool> {
        
        // prvo ih map u svoje objects a onda persist i javi da jesi...
        let objects = rooms.map { (room) -> RealmRoom in
            let r = RealmRoom()
            r.updateWith(room: room)
            return r
        }
        
        let realm = try! Realm()
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch { return Observable<Bool>.just(false) }
        
        return Observable<Bool>.just(true)
    }
    
    func saveToRealm(blocks: [Block]) -> Observable<Bool> {
        
        guard let realm = try? Realm() else {
            return Observable<Bool>.just(false) // treba da imas err za Realm...
        }
        
        // prvo ih map u svoje objects a onda persist i javi da jesi...
        let objects = blocks.map { (block) -> RealmBlock in
            let b = RealmBlock()
            b.updateWith(block: block, withRealm: realm)
            return b
        }
        
        do {
            try realm.write {
                realm.add(objects)
            }
        } catch {
            return Observable<Bool>.just(false)
        }
        
        return Observable<Bool>.just(true) // all good here
        
    }
    
    func saveToRealm(codeReport: CodeReport) -> Observable<Bool> {
        
        guard let realm = try? Realm() else {
            return Observable<Bool>.just(false) // treba da imas err za Realm...
        }
        
        let newCodeReport = RealmCodeReport.create(with: codeReport)

        if realm.objects(RealmCodeReport.self).filter("code = %@", codeReport.code).isEmpty {
            
            do { // ako nemas ovaj objekat kod sebe u bazi
                
                try realm.write {
                    realm.add(newCodeReport)
//                    print("\(codeReport.code), \(codeReport.sessionId) saved to realm")
                }
            } catch {
                return Observable<Bool>.just(false)
            }
        
        }
        //else {
//            print("saveToRealm.objekat vec postoji u bazi")
        //}
        
        return Observable<Bool>.just(true) // all good here
        
    }
    
    // MARK: All data (delete)
    
    func deleteDataIfAny() -> Observable<Bool> {
        guard let realm = try? Realm() else {
            return Observable<Bool>.just(false) // treba da imas err za Realm...
        }
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            return Observable<Bool>.just(false) // treba da imas err za Realm...
        }
        return Observable<Bool>.just(true) // all good
    }
    
}

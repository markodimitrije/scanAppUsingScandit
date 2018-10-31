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

        do {
            try realm.write {
                realm.add(newCodeReport)
            }
        } catch {
            return Observable<Bool>.just(false)
        }
        
        print("\(codeReport.code), \(codeReport.sessionId) saved to realm")
        
        return Observable<Bool>.just(true) // all good here
        
    }
    
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

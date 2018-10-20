//
//  RealmViewModel.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 20/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RxSwift
import RxRealm

class RealmViewModel {
    
    let disposeBag = DisposeBag()
    
    // dependencies-init
    init() {
//        oRooms.subscribe(onNext: { (rooms) in
//            print("rooms = \(rooms)")
//        }).disposed(by: disposeBag)
//        roomSelected = PublishSubject<Int?>.init()
        
        bindOutput()
    }
    
    // input
    var roomSelected: PublishSubject<Int?>!
    
    // output
    
    private(set) var oRooms: Observable<(AnyRealmCollection<RealmRoom>, RealmChangeset?)>!
    private(set) var oBlocks: Observable<(AnyRealmCollection<RealmBlock>, RealmChangeset?)>!
    
    private func bindOutput() { // hook-up se za Realm, sada su Rooms synced sa bazom
        
        guard let realm = try? Realm() else { return }
        
//        oRooms = Observable.changeset(from: realm.objects(RealmRoom.self))
        oRooms = Observable.changeset(from: realm.objects(RealmRoom.self).filter("type = 'Room'"))
        
         // oBlocks mi treba by selected room....
        oBlocks = Observable.changeset(from: realm.objects(RealmBlock.self))

    }
    
    private func bindInput() {
        
    }
    
}

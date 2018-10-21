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

class RoomViewModel {
    
    private let disposeBag = DisposeBag()
    
    private(set) var rooms: Results<RealmRoom>!
    
    // dependencies-init
    init() {
//        bindOutputRoomSelection()
        bindOutput()
    }
    
    // input
    var selectedTableIndex: BehaviorSubject<Int?> = BehaviorSubject.init(value: nil)
    
    // output
    
    private(set) var oRooms: Observable<(AnyRealmCollection<RealmRoom>, RealmChangeset?)>!
    
    private(set) var selectedRoom = BehaviorSubject<RealmRoom?>.init(value: nil)
    
    // MARK:- calculators
    
    func getRoom(forSelectedTableIndex index: Int) -> RealmRoom {
        // mogao si check za index i rooms.count -> RealmRoom?
        return rooms[index]
    }
    
    // MARK:- Private methods
    
    private func bindOutput() { // hook-up se za Realm, sada su Rooms synced sa bazom
        
        guard let realm = try? Realm() else { return }
        
        rooms = realm.objects(RealmRoom.self).filter("type = 'Room'")
        
        oRooms = Observable.changeset(from: rooms)

    }
    
//    private func bindOutputRoomSelection() {
//
//        selectedTableIndex
//            .subscribe(onNext: { [weak self] index in
//
//                guard let strongSelf = self else {return}
//                guard let index = index else {return}
//
//                print("pushujem na subject room sa id: \(strongSelf.rooms[index].id)")
//                strongSelf.selectedRoom.onNext(strongSelf.rooms[index])
//            })
//            .disposed(by: disposeBag)
//
//    }
//
}

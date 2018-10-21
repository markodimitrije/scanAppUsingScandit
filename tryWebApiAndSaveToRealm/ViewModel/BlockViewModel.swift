//
//  BlockViewModel.swift
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

class BlockViewModel {
    
    let disposeBag = DisposeBag()
    
    private (set) var blocks: Results<RealmBlock>!
    
    let roomId: Int
    
    // 1 - dependencies-init
    init(roomId: Int) {
        self.roomId = roomId
        bindOutput()
    }
    
    //... 2 - input
    
    // 3 - output
    
    private(set) var oBlocks: Observable<(AnyRealmCollection<RealmBlock>, RealmChangeset?)>!
    
    private func bindOutput() { // hook-up se za Realm, sada su Rooms synced sa bazom
        
        guard let realm = try? Realm() else { return }
        
        print("implement me, filter by roomId = \(roomId)")
        
        // ovde mi treba jos da su od odgovarajuceg Room-a
        blocks = realm.objects(RealmBlock.self).filter("type = 'Oral'").filter("location_id = %@", roomId)
        
        oBlocks = Observable.changeset(from: blocks)
        
    }
    
}


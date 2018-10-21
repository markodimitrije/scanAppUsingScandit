//
//  SettingsViewModel.swift
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

class SettingsViewModel {
    
    let disposeBag = DisposeBag()
    
    // 1 - dependencies-init
    init(roomId: Int?) {
        bindOutput()
    }
    
    // 2 - input
    var roomSelected: Int?
    
    // 3 - output
    
    private(set) var oBlocks: Observable<(AnyRealmCollection<RealmBlock>, RealmChangeset?)>!
    
    // MARK:- Privates
    
    private func bindOutput() { // hook-up se za Realm, sada su Rooms synced sa bazom
        
        guard roomSelected != nil else {
            print("show alert, please select Room first")
            return
        }
        
        guard let realm = try? Realm() else { return }
        
        // ovde mi treba jos da su od odgovarajuceg Room-a
        let blocks = realm.objects(RealmBlock.self).filter("type = 'Oral'")
        
        oBlocks = Observable.changeset(from: blocks)
        
    }
    
}


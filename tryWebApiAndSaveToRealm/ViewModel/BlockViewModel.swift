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
    
    // output
    
    var sectionsHeadersAndItems = [SectionOfCustomData]()
    var oSectionsHeadersAndItems: Observable<[SectionOfCustomData]> {
        return Observable.just(sectionsHeadersAndItems)
    }
    
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
        
        let blocksByDay = sortBlocksByDay(blocksArray: blocks.toArray()) // private helper
        
        sectionsHeadersAndItems = blocksByDay.map({ (blocks) -> SectionOfCustomData in
            let sectionName = blocks.first?.starts_at.components(separatedBy: " ").first ?? ""
            let items = blocks.map {$0.starts_at + " " + $0.name}
            return SectionOfCustomData.init(header: sectionName, items: items)
        })
        
    }
    
    private func sortBlocksByDay(blocksArray:[RealmBlock]) -> [[RealmBlock]] {
        
        if blocksArray.isEmpty { return [] }
        
        let inputArray = blocksArray.sorted { Date.parse($0.starts_at) < Date.parse($1.starts_at) }
        
        var resultArray = [[inputArray[0]]]
        
        let calendar = Calendar(identifier: .gregorian)
        for (prevBlock, nextBlock) in zip(inputArray, inputArray.dropFirst()) {
            let prevDate = Date.parse(prevBlock.starts_at)
            let nextDate = Date.parse(nextBlock.starts_at)
            if !calendar.isDate(prevDate, equalTo: nextDate, toGranularity: .day) {
                resultArray.append([]) // Start new row
            }
            resultArray[resultArray.count - 1].append(nextBlock)
        }
        return resultArray
    }
    
}

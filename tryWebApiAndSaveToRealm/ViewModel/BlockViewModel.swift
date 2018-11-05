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
    
    // ovi treba da su ti SUBJECTS! sta je poenta imati ih ovako ??
    
    private (set) var blocks: Results<RealmBlock>! // ostavio sam zbog vc-a.. (nije dobro ovo)
//    private (set) var blocksSortedByDate = [RealmBlock]()

    private (set) var sectionBlocks = [[RealmBlock]]() // niz nizova jer je tableView sa sections
    
    private var blocksSortedByDate = [RealmBlock]()
    
    // output 1 - za prikazivanje blocks na tableView...
    
    var sectionsHeadersAndItems = [SectionOfCustomData]()
    var oSectionsHeadersAndItems: Observable<[SectionOfCustomData]> {
        return Observable.just(sectionsHeadersAndItems)
    }
    
    // output 2 - expose your calculated stuff
    var oAutomaticSession = BehaviorSubject<RealmBlock?>.init(value: nil)
    
    let roomId: Int
    
    private var mostRecentSessionBlock: RealmBlock? {
//        let todayBlocks = blocksSortedByDate.filter {
//            Calendar.current.isDateInToday(Date.parse($0.starts_at))
//        }
        let todayBlocks = blocksSortedByDate.filter { // mock za test !
            return Calendar.current.compare(NOW,
                                            to: Date.parse($0.starts_at),
                                            toGranularity: Calendar.Component.day) == ComparisonResult.orderedSame
        }
        
        return todayBlocks.filter { block -> Bool in
            let startsAt = Date.parse(block.starts_at)
            //return startsAt > Date.now
            return startsAt > NOW
        }.first
    }
    
    // 1 - dependencies-init
    init(roomId: Int) {
        self.roomId = roomId
        bindOutput()
        bindAutomaticSession()
    }
    
    //... 2 - input
    
    // 3 - output
    
    private(set) var oBlocks: Observable<(AnyRealmCollection<RealmBlock>, RealmChangeset?)>!
    
    private func bindOutput() { // hook-up se za Realm, sada su Rooms synced sa bazom
        
        guard let realm = try? Realm() else { return }
        
        // ovde mi treba jos da su od odgovarajuceg Room-a
        blocks = realm
                    .objects(RealmBlock.self)
                    .filter("type = 'Oral'")
                    .filter("location_id = %@", roomId)
        
        sectionBlocks = sortBlocksByDay(blocksArray: blocks.toArray())
        
        blocksSortedByDate = blocks.toArray().sorted(by: {
            return Date.parse($0.starts_at) < Date.parse($1.starts_at)
        })
        
        oBlocks = Observable.changeset(from: blocks)
        
        let blocksByDay = sortBlocksByDay(blocksArray: blocks.toArray()) // private helper
        
        sectionsHeadersAndItems = blocksByDay.map({ (blocks) -> SectionOfCustomData in
            let sectionName = blocks.first?.starts_at.components(separatedBy: " ").first ?? ""
            let items = blocks.map {$0.starts_at + " " + $0.name}
            return SectionOfCustomData.init(header: sectionName, items: items)
        })
        
    }
    
    // ako ima bilo koji session u zadatom Room, na koji se ceka krace od 2 sata, emituj SessionId; ako nema, emituj nil.
    private func bindAutomaticSession() {
        
        let result = autoSessionIsAvailable(inLessThan: TimeInterval.waitToMostRecentSession) ?
        mostRecentSessionBlock : nil
        
        oAutomaticSession.onNext(result)
        
    }
    
    private func autoSessionIsAvailable(inLessThan interval: TimeInterval) -> Bool { // implement me
//        let now = Date.init(timeIntervalSinceNow: 0) // 1
        
        let now = NOW // mock date !
        
        guard let firstAvailableSession = mostRecentSessionBlock else {
            return false
        }
        let sessionDate = Date.parse(firstAvailableSession.starts_at) // 2
        let date = now.addingTimeInterval(TimeInterval.waitToMostRecentSession) // 3
        
        let difference = date.timeIntervalSince(sessionDate)
        if difference < 0 { // ima da ceka vise od zadatog intervala
            return false
        }
        
        return difference < TimeInterval.waitToMostRecentSession
        
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

var NOW: Date {
    return Date.init(timeIntervalSinceNow: 0)
}

/*

let NOW = Date.parse("2018-05-24 12:35:00") // ovo je 10:35 - 2.blok
//let NOW = Date.parse("2018-05-24 12:55:00") // ovo je 10:55 - nema
//let NOW = Date.parse("2018-05-24 08:40:00") // ovo je 06:40 - 1.blok
//let NOW = Date.parse("2018-05-24 08:00:00") // ovo je 06:00 - nema

 */

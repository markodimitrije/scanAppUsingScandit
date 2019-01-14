//
//  Block.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 22/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Blocks: Codable {
    var data: [Block]
}

class Block: Codable {
    var id: Int
    var name: String
    var subtitle: String?
    var type: String
    var external_type: String?
    var starts_at: String
    var ends_at: String
    var code: String
    var chairperson: String?
    var block_category_id: Int?
    var imported_id: String
    var has_presentation_on_timeline: Bool
    var has_available_presentation: Bool
    var has_dialog: Bool
    var survey: Bool
    var sponsor_id: Int?
    var topic_id: Int?
    var tags: String
    var featured: Bool
    var updated_at: String
    var location_id: Int
}

class RealmBlock: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var subtitle: String?
    @objc dynamic var type: String = ""
    @objc dynamic var external_type: String?
    @objc dynamic var starts_at: String = ""
    @objc dynamic var ends_at: String = ""
    @objc dynamic var code: String = ""
    @objc dynamic var chairperson: String?
    @objc dynamic var imported_id: String = ""
    @objc dynamic var has_presentation_on_timeline: Bool = false
    @objc dynamic var has_available_presentation: Bool = false
    @objc dynamic var has_dialog: Bool = false
    @objc dynamic var survey: Bool = false
    @objc dynamic var tags: String = ""
    @objc dynamic var featured: Bool = false
    @objc dynamic var updated_at: String = ""
    @objc dynamic var location_id: Int = -1 // ref na location (room)
    var block_category_id = RealmOptional<Int>()
    var sponsor_id = RealmOptional<Int>()
    var topic_id = RealmOptional<Int>()
    
    @objc dynamic var owner: RealmRoom?
    
    // rac. var koji ako je "today" vraca starts_at(HH:mm) - ends_at(HH:mm)
    // ako nije onda yyyy-MM-dd (starts_at)HH:mm-(ends_at)HH:mm
    var duration: String {
        
        let timeStartsAt = Date.parseIntoTime(starts_at, outputWithSeconds: false)
        let timeEndsAt = Date.parseIntoTime(ends_at, outputWithSeconds: false)
        
        let calendar = Calendar.init(identifier: .gregorian)
        
        let timeDuration = timeStartsAt + "-" + timeEndsAt
        
        if calendar.isDateInToday(Date.parse(starts_at)) {
            return timeDuration
        } else {
            return Date.parseIntoDateOnly(starts_at) + " " + timeDuration
        }
        
    }
    
    func updateWith(block: Block, withRealm realm: Realm) {
        self.id = block.id
        self.name = block.name
        self.subtitle = block.subtitle
        self.type = block.type
        self.external_type = block.external_type
        self.starts_at = block.starts_at
        self.ends_at = block.ends_at
        self.code = block.code
        self.chairperson = block.chairperson
        self.imported_id = block.imported_id
        self.has_presentation_on_timeline = block.has_presentation_on_timeline
        self.has_available_presentation = block.has_available_presentation
        self.has_dialog = block.has_dialog
        self.survey = block.survey
        self.tags = block.tags
        self.featured = block.featured
        self.updated_at = block.updated_at
        self.location_id = block.location_id
        
        self.block_category_id = RealmOptional.init(block.block_category_id)
        self.sponsor_id = RealmOptional.init(block.sponsor_id)
        self.topic_id = RealmOptional.init(block.topic_id)
        
        owner = RealmRoom.getRoom(withId: self.location_id, withRealm: realm)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["subtitle", "external_type", "code", "chairperson", "block_category_id", "imported_id", "has_presentation_on_timeline", "has_available_presentation", "", "has_dialog", "survey", "sponsor_id", "topic_id", "tags", "featured"]
    }
    
    static func getBlock(withId id: Int, withRealm realm: Realm) -> RealmBlock? {
        
        return realm.objects(RealmBlock.self).filter("id = %@", id).first
    }

}

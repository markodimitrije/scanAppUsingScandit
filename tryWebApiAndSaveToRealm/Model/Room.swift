//
//  Room.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 22/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Rooms: Codable {
    var data: [Room]
}

class Room: Codable {
    var id: Int
    var name: String
    var type: String
    var color: String?
    var floor: Int
    var imported_id: String
    var x_coord: String
    var y_coord: String
    var conference_id: Int
    var party_id: Int?
    var order: Int
    var updated_at: String
}

class RealmRoom: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var color: String?
    @objc dynamic var floor: Int = -1
    @objc dynamic var imported_id: String = ""
    @objc dynamic var x_coord: String = ""
    @objc dynamic var y_coord: String = ""
    @objc dynamic var conference_id: Int = 0
    @objc dynamic var order: Int = -1
    @objc dynamic var updated_at: String = ""
    var party_id = RealmOptional<Int>()
    
    //var blocks = List<RealmBlock>()
    
    func updateWith(room: Room) {
        self.id = room.id
        self.name = room.name
        self.party_id = RealmOptional.init(room.party_id)
        self.type = room.type
        self.color = room.color
        self.floor = room.floor
        self.imported_id = room.imported_id
        self.x_coord = room.x_coord
        self.y_coord = room.y_coord
        self.conference_id = room.conference_id
        self.order = room.order
        self.updated_at = room.updated_at
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] { // sta nije bitno za Scaner app?
        return ["x_coord", "y_coord", "party_id", "color", "floor", "imported_id"]
    }
    
    static func getRoom(withId id: Int, withRealm realm: Realm) -> RealmRoom? {
        
        return realm.objects(RealmRoom.self).filter("id = %@", id).first
    }
    
}

//
//  ModelData.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 22/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation

enum SessionTextData {
    static let sessionConst = NSLocalizedString("Strings.Scaner.session.SessionConst", comment: "")
    static let noActiveSession = NSLocalizedString("Strings.Scaner.session.noActiveSession", comment: "")
    static let noActiveSessionForRoom = NSLocalizedString("Strings.Scaner.session.noActiveSessionForRoom", comment: "")
    static let selectSession = NSLocalizedString("Strings.Scaner.session.selectSession", comment: "")
    static let noAutoSelSessionsAvailable = NSLocalizedString("Strings.Scaner.session.noAutoSelSessionsAvailable", comment: "")

    
}

enum RoomTextData {
    static let selectRoom = NSLocalizedString("Strings.Scaner.room.SelectRoom", comment: "")
    static let noRoomSelected = NSLocalizedString("Strings.Scaner.room.noRoomSelected", comment: "")
}

struct MyTimeInterval {
    static let waitToMostRecentSession: TimeInterval = 15*60 // 15 minutes
    //static var waitToMostRecentSession: TimeInterval = 60*60 // 60 minutes
    static let timerForFetchingRoomAndBlockResources: Double = 15 // 10 seconds
    static let timeoutForFetchingRoomAndBlockResources = 10 // 10 seconds
}

extension UserDefaults {
    static let keyResourcesDownloaded = "resourcesDownloaded"
}

extension String {
    static let now = Date.init(timeIntervalSinceNow: 0).toString(format: Date.defaultFormatString) ?? ""
}

//
//  Protocols.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 21/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

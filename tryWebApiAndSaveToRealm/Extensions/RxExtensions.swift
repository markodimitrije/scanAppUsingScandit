//
//  RxExtensions.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 25/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import Foundation

import RxSwift
import RxSwift.Swift
import SwiftOnoneSupport
import RxCocoa
import UIKit

extension Reactive where Base: UISwitch {
    public var isOn: Binder<Bool> {
        return Binder(self.base) { switchControl, isOn in
            switchControl.isOn = isOn
        }
    }
}

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

extension Reactive where Base: UITableView {
    
    var roomValidationSideEffects: Binder<RealmRoom?> {
        return Binder(self.base) { target, roomSelected in // _ je view (self)
            _ = target.visibleCells.filter {
                target.indexPath(for: $0)?.section == 1
                }.map {
                    $0.isUserInteractionEnabled = (roomSelected != nil)
                    $0.alpha = (roomSelected != nil) ? 1.0: 0.5
            }
        }
    }
    
}

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

extension Reactive where Base: UISwitch {
    
    var switchTapSequence: Observable<Void> {
        return controlEvent(.allTouchEvents).asObservable()
    }
    var switchActiveSequence: Observable<Bool> {
        return switchTapSequence.map({ (_) -> Bool in
            return self.base.isOn
            })
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
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

extension Reactive where Base: UIViewController {
    var shouldBeDismiss: Binder<Bool> {
        return Binder(self.base) { target, shouldDismiss in
            if shouldDismiss {
                target.dismiss(animated: true)
            } else {
                // mozes neki alert i slicno....
            }
        }
    }
}

extension Reactive where Base: UIButton {
    var btnIsActive: Binder<Bool> {
        return Binder(self.base) { target, value in
            target.alpha = value ? 1.0 : 0.5
            target.isUserInteractionEnabled = value
        }
    }
}



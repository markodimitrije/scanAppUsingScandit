//
//  AlertWithRx.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 01/11/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import RxSwift
import RxSwift.Swift
import SwiftOnoneSupport
import RxCocoa
import UIKit

extension UIViewController {
    func alert(title: String, text: String?, btnText: String?) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alertVC.addAction(
                UIAlertAction(title: btnText, style: .default, handler: {_ in
                    observer.onCompleted()
                })
            )
            self?.present(alertVC, animated: true, completion: nil)
            return Disposables.create {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

struct AlertInfo {
    static let ok = NSLocalizedString("OK", comment: "")
    struct Scaner {
        static let title = NSLocalizedString("Scanning not supported", comment: "")
        static let msg = NSLocalizedString("Your device does not support scanning a code from an item. Please use a device with a camera.", comment: "")
    }
}


//
//  WiFiConnectionView.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 24/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WiFiConnectionView: UIView {
    
    @IBOutlet weak var wiFiStatusConstLbl: UILabel!
    
    @IBOutlet weak var wiFiConnectedConstLbl: UILabel!
    
    @IBOutlet weak var wiFiStatusLbl: UILabel!
    
    //var oWiFiConnected: Observable<Bool>! = Observable<Void>.
    
    private (set) var wiFiStatusConstText: String? {
        get {
            return wiFiStatusConstLbl.text
        }
        set {
            wiFiStatusConstLbl.text = newValue
        }
    }
    
    private (set) var wiFiConnectedConstText: String? {
        get {
            return wiFiConnectedConstLbl.text
        }
        set {
            wiFiConnectedConstLbl.text = newValue
        }
    }
    
    fileprivate (set) var statusText: String? {
        get {
            return wiFiStatusLbl.text
        }
        set {
            wiFiStatusLbl.text = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    convenience init(frame: CGRect,
                     wiFiStatusConstText: String?,
                     wiFiConnectedConstText: String?,
                     statusText: String?) {
        
        self.init(frame: frame)
        self.wiFiStatusConstText = wiFiStatusConstText
        self.wiFiConnectedConstText = wiFiConnectedConstText
        self.statusText = statusText
    }
    private func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WiFiConnectionView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view)
        
    }
    
    fileprivate func update(connected: Bool) {
        
        self.statusText = connected ? "✔︎" : "✘"
        updateColor(connected: connected)
        
    }
    
    fileprivate func updateColor(connected: Bool) {
        
        let color = connected ? UIColor.wiFiConnected : UIColor.wiFiDisconnected
        
        wiFiConnectedConstLbl.textColor = color
        
        wiFiStatusLbl.textColor = color
    }
    
}

extension Reactive where Base: WiFiConnectionView {
    
    var connected: Binder<Bool> {
        return Binder(self.base) { _, connected in // _ je view (self)
            //print("update wi-fi connection with: \(connected)")
            self.base.update(connected: connected)
        }
    }
    
}

//extension Reactive where Base: RealmBlock {
//    var sessionLblTxt: Binder<String> {
//        return Binder.init(self.base, binding: { (block, value) in
//
//        })
//    }
//}


extension Reactive where Base: UILabel {
    var sessionLblTxt: Binder<String> {
        return Binder.init(self.base, binding: { (lbl, value) in
            lbl.text = value + "whatever" // ....
        })
    }
}

//
//  WiFiConnectionView.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 24/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit

class WiFiConnectionView: UIView {
    
    @IBOutlet weak var wiFiStatusConstLbl: UILabel!
    
    @IBOutlet weak var wiFiConnectedConstLbl: UILabel!
    
    @IBOutlet weak var wiFiStatusLbl: UILabel!
    
    var wiFiStatusConstText: String? {
        get {
            return wiFiStatusConstLbl.text
        }
        set {
            wiFiStatusConstLbl.text = newValue
        }
    }
    
    var wiFiConnectedConstText: String? {
        get {
            return wiFiConnectedConstLbl.text
        }
        set {
            wiFiConnectedConstLbl.text = newValue
        }
    }
    
    var statusText: String? {
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
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "WiFiConnectionView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view)
        
    }
    
    func update(connected: Bool) {
        
        self.statusText = connected ? "✔︎" : "✘"
        updateColor(connected: connected)
        
    }
    
    private func updateColor(connected: Bool) {
        
        let color = connected ? UIColor.wiFiConnected : UIColor.wiFiDisconnected
        
        wiFiConnectedConstLbl.textColor = color
        
        wiFiStatusLbl.textColor = color
    }
    
}

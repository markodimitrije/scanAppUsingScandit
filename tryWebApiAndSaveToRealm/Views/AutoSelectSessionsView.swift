//
//  WiFiConnectionView.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 24/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit

class AutoSelectSessionsView: UIView {
    
    @IBOutlet weak var autoSelectSessionsConstLbl: UILabel!
    
    @IBOutlet weak var controlSwitch: UISwitch!
    
    var autoSelectSessionsConstText: String? {
        get {
            return autoSelectSessionsConstLbl.text
        }
        set {
            autoSelectSessionsConstLbl.text = newValue
        }
    }
    
    var switchState: Bool {
        get {
            return controlSwitch.isOn
        }
        set {
            controlSwitch.isOn = newValue
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
                     autoSelectSessionsConstText: String?,
                     switchState: Bool) {
        
        self.init(frame: frame)
        self.autoSelectSessionsConstText = autoSelectSessionsConstText
        self.switchState = switchState
    }
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AutoSelectSessionsView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view)
        
    }
    
}

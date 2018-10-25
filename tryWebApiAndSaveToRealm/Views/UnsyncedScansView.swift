//
//  WiFiConnectionView.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 24/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit

class UnsyncedScansView: UIView {
    
    @IBOutlet weak var unsyncScansConstLbl: UILabel!
    
    @IBOutlet weak var countLbl: UILabel!
    
    @IBOutlet weak var syncBtn: UIButton!
    
    var unsyncScansConstText: String? {
        get {
            return unsyncScansConstLbl.text
        }
        set {
            unsyncScansConstLbl.text = newValue
        }
    }
    
    var unsyncedCount: Int {
        get {
            return Int(countLbl.text ?? "0")!
        }
        set {
            countLbl.text = "\(newValue)"
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
                     unsyncScansConstText: String?,
                     unsyncedCount: Int) {
        
        self.init(frame: frame)
        self.unsyncScansConstText = unsyncScansConstText
        self.unsyncedCount = unsyncedCount
    }
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "UnsyncedScansView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view)
        
    }
    
    func update(unsyncedCount count: Int) {
        self.unsyncedCount = count
        updateColor(unsyncedCount: count)
        
    }
    
    private func updateColor(unsyncedCount count: Int) {
        syncBtn.isEnabled = (count != 0)
        syncBtn.alpha = (count != 0) ? 1 : 0.5
        
        let lblsColor = (count != 0) ? UIColor.red : UIColor.black
        unsyncScansConstLbl.textColor = lblsColor
        countLbl.textColor = lblsColor
    }
    
}

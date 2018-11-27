//
//  AutoSessionIntervalSettingsView.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 06/11/2018.
//  Copyright © 2018 Navus. All rights reserved.
//

import UIKit

class SetIntervalForAutoSessionView: UIView {
   
    @IBOutlet weak var textLbl: UILabel!
    
    @IBOutlet weak var picker: UIDatePicker!
    
    var constText: String? {
        get {
            return textLbl.text
        }
        set {
            textLbl.text = newValue
        }
    }
    
    var date: Date? {
        get {
            return picker.date
        }
        set {
            picker.setDate(newValue ?? NOW, animated: false)
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
                     constText: String?,
                     date: Date?) {
        
        self.init(frame: frame)
        self.constText = constText
        self.date = date
        
    }
    
    private func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SetIntervalForAutoSessionView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(view)
        
        picker.datePickerMode = UIDatePicker.Mode.countDownTimer
        picker.countDownDuration = MyTimeInterval.waitToMostRecentSession // sec 900 sec - 15 min
        
        
    }
    
    // MARK:- API
    
    func update(text: String, date: Date) {
        self.constText = text
        self.date = date
    }
    
}


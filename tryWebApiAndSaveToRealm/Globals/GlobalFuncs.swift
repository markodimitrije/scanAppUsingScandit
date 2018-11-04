//
//  GlobalFuncs.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 04/11/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit

func getArrowImgView(frame: CGRect) -> UIImageView {
    let v = UIImageView.init(frame: frame)
    v.image = UIImage.init(named: "arrow")
    v.tag = 20
    return v
}

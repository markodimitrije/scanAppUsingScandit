//
//  AppDelegate.swift
//  tryObservableWebApiAndRealm
//
//  Created by Marko Dimitrijevic on 19/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ScanditBarcodeScanner

let kScanditBarcodeScannerAppKey = "AVUcbY6BGmLRGfE9ZRq3FAMRkzcwGCeWBG5s+SFJGRE4Vh22m1isjYE2LkXQR08sYCiFkbsvpcYhFHQuHQW2bl4hk80Nem3XqlZ1flpVMwoWKMG+AQqBIm80v0J6cZ66KgZS2h1NxXkP8y+F4ASYAOTXOvkKj8b5YbvtWIgdaAnDKjkEe4O8fHk3jtAFBoqIJj2TOmsA5OVrgmTgSKeTgokUpBJ59YB8SxnaBa/YCVa9+Jm78+UUmBZhWOzP6eGqCXs5fXjiwKwOEtS68flsDudHSUZclSvL0j48UotSEn1czuCJ8HWhLjxuTtZYVW+wfyFyJ411JB48YjrecaSZmEd5NzjIQqde8aCzQun9dBtI8670TjpLnY1r8lP3D/xMhgzAgWIDgWPWrl3NdDrn9iWkzFX/+E2nuuiM+kBWXjYdD0by518/wL+OSafK8ZpZFqk+U2arb3jb72d+Al1Q5tc5MRInIi8zNK46zW6EItHcnNh1rlP7LhaHQ6A9VDyuBWWq6a2Dagw8RGgFiiG/iBNjIkw9zYIIPyr0GR5xDr7FSyr9ed0oNMqzq8SQG36xzn0txLnfMh2tLgZNqSzpuHQ9YDgv9d/Ro07l+u27CJt3pvElCPDfgOn4fIfQdDibldO5de7KiWT0Vf9K67t12IDT8AnZbHBw3si2k50mB/MrB1fAeV7FJTSeYWTR1VX/vRIQeiQ1lGS7kr3+eQPJ1/tSN75q2R6bq/M8OCoG24qwFTrnFcDG8K4X1K0zrd0L9PVi6KpCNdV/v4V6WbUDoOxHcFfFLs2uASScqDU="

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var alertStateMonitor: AlertStateMonitor!
    private var deviceAlertMonitor: AlertStateReporter!
    private var userSelection = UserSelectionManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        UIDevice.current.isBatteryMonitoringEnabled = true
        UIApplication.shared.isIdleTimerDisabled = true // stop the iOS screen sleeping
        
        if resourcesState == nil {
            resourcesState = ResourcesState.init()
        }
        
        alertStateMonitor = AlertStateMonitor.init()
        deviceAlertMonitor = AlertStateReporter.init(monitor: alertStateMonitor, webAPI: ApiController.shared)
        
        UserDefaults.standard.addObserver(userSelection, forKeyPath: "roomId", options: [.new, .initial], context: nil)
        UserDefaults.standard.addObserver(userSelection, forKeyPath: "sessionId", options: [.new, .initial], context: nil)
        
        userSelection.location.drive(deviceAlertMonitor.roomId).disposed(by: bag)
        userSelection.block.drive(deviceAlertMonitor.sessionId).disposed(by: bag)
        
        SBSLicense.setAppKey(kScanditBarcodeScannerAppKey)
        
        return true
    }
    
//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .pad {
//            return [.landscapeLeft, .landscapeRight]
//        } else if UIDevice.current.userInterfaceIdiom == .phone {
//            return .portrait
//        }
//        return .portrait
//    }
    
    deinit {
        UserDefaults.standard.removeObserver(self, forKeyPath: "roomId")
        UserDefaults.standard.removeObserver(self, forKeyPath: "sessionId")
    }
    
    private let bag = DisposeBag()

}

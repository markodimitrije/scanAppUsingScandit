//
// Copyright 2016 Scandit AG
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
// in compliance with the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the
// License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import ScanditBarcodeScanner

class ScanditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    private func setupScanner() {
        // Scandit Barcode Scanner Integration
        // The following method calls illustrate how the Scandit Barcode Scanner can be integrated
        // into your app.
        
        // Create the scan settings and enabling some symbologies
        let settings = SBSScanSettings.default()
        let symbologies: Set<SBSSymbology> = [.ean8, .ean13, .qr, .aztec, .fiveDigitAddOn, .twoDigitAddOn, .itf]
        for symbology in symbologies {
            settings.setSymbology(symbology, enabled: true)
        }
        
        // Create the barcode picker with the settings just created
        let barcodePicker = SBSBarcodePicker(settings:settings)
        
        // Add the barcode picker as a child view controller
        addChild(barcodePicker)
        view.addSubview(barcodePicker.view)
        barcodePicker.didMove(toParent: self)
        
        // Set the allowed interface orientations. The value UIInterfaceOrientationMaskAll is the
        // default and is only shown here for completeness.
        barcodePicker.allowedInterfaceOrientations = .all
        // Set the delegate to receive scan event callbacks
        barcodePicker.scanDelegate = self
        barcodePicker.startScanning()
    }
}

extension ScanditViewController: SBSScanDelegate {
    // This delegate method of the SBSScanDelegate protocol needs to be implemented by
    // every app that uses the Scandit Barcode Scanner and this is where the custom application logic
    // goes. In the example below, we are just showing an alert view with the result.
    func barcodePicker(_ picker: SBSBarcodePicker, didScan session: SBSScanSession) {
        // Call pauseScanning on the session (and on the session queue) to immediately pause scanning
        // and close the camera. This is the preferred way to pause scanning barcodes from the
        // SBSScanDelegate as it is made sure that no new codes are scanned.
        // When calling pauseScanning on the picker, another code may be scanned before pauseScanning
        // has completely paused the scanning process.
        session.pauseScanning()
        
        let code = session.newlyRecognizedCodes[0]
        // The barcodePicker(_:didScan:) delegate method is invoked from a picker-internal queue. To
        // display the results in the UI, you need to dispatch to the main queue. Note that it's not
        // allowed to use SBSScanSession in the dispatched block as it's only allowed to access the
        // SBSScanSession inside the barcodePicker(_:didScan:) callback. It is however safe to
        // use results returned by session.newlyRecognizedCodes etc.
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Scanned code \(code.symbologyName)",
                message: code.data,
                preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { _ in
                picker.resumeScanning()
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

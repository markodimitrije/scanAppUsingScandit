//
//  ScannerVC.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 22/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import RealmSwift
import ScanditBarcodeScanner

class ScannerVC: UIViewController {
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var sessionConstLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var sessionTimeAndRoomLbl: UILabel!
    
    lazy private var scanerViewModel = ScannerViewModel.init(dataAccess: DataAccess.shared)
    
    let avSessionViewModel = AVSessionViewModel()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private (set) var scanedCode = BehaviorSubject<String>.init(value: "")
    var code: String {
        return try! scanedCode.value()
    }
    
    private let codeReporter = CodeReportsState.init() // vrsta viewModel-a ?
    
    var settingsVC: SettingsVC!
    
    // interna upotreba:
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() { super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        setupScanner()
        
        sessionConstLbl.text = SessionTextData.sessionConst
        bindUI()
        
    }
    
    private func bindUI() { // glue code for selected Room
        
        scanerViewModel.sessionName // SESSION NAME
            .bind(to: sessionNameLbl.rx.text)
            .disposed(by: disposeBag)
        
        scanerViewModel.sessionInfo // SESSION INFO
            .bind(to: sessionTimeAndRoomLbl.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let name = segue.identifier, name == "segueShowSettings",
            let navVC = segue.destination as? UINavigationController,
            let settingsVC = navVC.children.first as? SettingsVC else { return }
        
        self.settingsVC = settingsVC
        
        hookUpScanedCode(on: settingsVC)
        
    }
    
    private func hookUpScanedCode(on settingsVC: SettingsVC) {
        
        settingsVC.codeScaned = self.scanedCode
        
    }
    
    // MARK:- Scanner related....
    
    private func bindAVSession() {
        
        avSessionViewModel.oSession
            .subscribe(onNext: { [unowned self] (session) in
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
                self.previewLayer.frame = self.scannerView.layer.bounds
                self.previewLayer.videoGravity = .resizeAspectFill
                self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight

                self.scannerView.layer.addSublayer(self.previewLayer)
                
                }, onError: { [unowned self] err in
                    self.failed()
            })
            .disposed(by: disposeBag)
    }
    
//    private func bindBarCode() {
//
//        avSessionViewModel.oCode
//            .subscribe(onNext: { [weak self] (barCodeValue) in
//                guard let sSelf = self else {return}
//
//                sSelf.found(code: barCodeValue)
//            })
//            .disposed(by: disposeBag)
//
//    }
    
    private func failed() { print("failed.....")

        self.alert(title: AlertInfo.Scan.ScanningNotSupported.title,
                   text: AlertInfo.Scan.ScanningNotSupported.msg,
                   btnText: AlertInfo.ok)
            .subscribe {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func failedDueToNoSettings() {
        
        self.alert(title: AlertInfo.Scan.NoSettings.title,
                   text: AlertInfo.Scan.NoSettings.msg,
                   btnText: AlertInfo.ok)
            .subscribe {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func found(code: String, picker: SBSBarcodePicker) { // ovo mozes da report VM-u kao append novi code
        
        if scanerViewModel.sessionId != -1 {
            scanditSuccessfull(code: code, picker: picker)
        } else {
            failedDueToNoSettings()
        }
        
    }
    
    private func scanditSuccessfull(code: String, picker: SBSBarcodePicker) {
        
        if self.scannerView.subviews.contains(where: {$0.tag == 20}) { return } // already arr on screen...
        
        scanedCode.onNext(code)
        
        self.scannerView.addSubview(getArrowImgView(frame: scannerView.bounds))
        
        delay(2.0) { // ovoliko traje anim kada prikazujes arrow
            DispatchQueue.main.async {
                self.scannerView.subviews.first(where: {$0.tag == 20})?.removeFromSuperview()
                picker.resumeScanning()
            }
        }
        
        codeReporter.codeReport.accept(getActualCodeReport())
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape //[.landscapeLeft, .landscapeRight]
    }
    
    // MARK:- Private
    
    private func getActualCodeReport() -> CodeReport {
       
        print("getActualCodeReport = \(code)")
        
        return CodeReport.init(code: code,
                               sessionId: scanerViewModel.sessionId,
                               date: Date.now)
    }
    
    
    
    // SCANDIT
    
    private func setupScanner() {
        
        // Create the scan settings and enabling some symbologies
        let settings = SBSScanSettings.default()
//        let symbologies: Set<SBSSymbology> = [.ean8, .ean13, .qr, .aztec, .code128, .pdf417, .itf]
        let symbologies: Set<SBSSymbology> = [.aztec, .codabar, .code11, .code128, .code25, .code32, .code39, .code93, .datamatrix, .dotCode, .ean8, .ean13, .fiveDigitAddOn, .gs1Databar, .gs1DatabarExpanded, .gs1DatabarLimited, .itf, .kix, .lapa4sc, .maxiCode, .microPDF417, .microQR, .msiPlessey, .pdf417,.qr, .rm4scc, .twoDigitAddOn, .upc12, .upce]
        for symbology in symbologies {
            settings.setSymbology(symbology, enabled: true)
        }
        
        // Create the barcode picker with the settings just created
        let barcodePicker = SBSBarcodePicker(settings:settings)
        barcodePicker.view.frame = self.scannerView.bounds
        
        // Add the barcode picker as a child view controller
        addChild(barcodePicker)
        self.scannerView.addSubview(barcodePicker.view)
        barcodePicker.didMove(toParent: self)
        
        // Set the allowed interface orientations. The value UIInterfaceOrientationMaskAll is the
        // default and is only shown here for completeness.
        barcodePicker.allowedInterfaceOrientations = .all
        // Set the delegate to receive scan event callbacks
        barcodePicker.scanDelegate = self
        barcodePicker.startScanning()
    }
    
}

extension ScannerVC: SBSScanDelegate {
    // This delegate method of the SBSScanDelegate protocol needs to be implemented by
    // every app that uses the Scandit Barcode Scanner and this is where the custom application logic
    // goes. In the example below, we are just showing an alert view with the result.
    func barcodePicker(_ picker: SBSBarcodePicker, didScan session: SBSScanSession) {

        session.pauseScanning()
        
        let code = session.newlyRecognizedCodes[0]
        
        DispatchQueue.main.async { [weak self] in
            self?.found(code: code.symbologyName, picker: picker)
        }
    }
}

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

class ScannerVC: UIViewController {
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var sessionConstLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var sessionTimeAndRoomLbl: UILabel!
    
    let disposeBag = DisposeBag()
    var scanerViewModel = ScannerViewModel.init()
    
    let avSessionViewModel = AVSessionViewModel()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private (set) var scanedCode = BehaviorSubject<String>.init(value: "")
    var code: String {
        return try! scanedCode.value()
    }
    
    let codeReporter = CodeReportsState.init() // vrsta viewModel-a ?
    
    var settingsVC: SettingsVC!
    
    override func viewDidLoad() { super.viewDidLoad()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        sessionConstLbl.text = SessionTextData.sessionConst
        bindUI()
        
        // scaner functionality
        bindAVSession()
        bindBarCode()
        
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
        
        hookUpInputs(on: settingsVC)
        
        hookUpScanedCode(on: settingsVC)
        
    }
    
    private func hookUpInputs(on settingsVC: SettingsVC) {
        settingsVC.roomSelected
            .subscribe(onNext: { [weak self] (room) in
                guard let strongSelf = self else {return}
                strongSelf.scanerViewModel.roomSelected.onNext(room) // hookUp inputs
            })
            .disposed(by: disposeBag)
        
        settingsVC.sessionSelected
            .subscribe(onNext: { [weak self] (block) in
                guard let strongSelf = self else {return}
                strongSelf.scanerViewModel.sessionSelected.onNext(block) // hookUp inputs
            })
            .disposed(by: disposeBag)
        
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
    
    private func bindBarCode() {
        
        avSessionViewModel.oCode
            .subscribe(onNext: { [weak self] (barCodeValue) in
                guard let sSelf = self else {return}
                
                sSelf.found(code: barCodeValue)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func failed() { print("failed.....")

        self.alert(title: AlertInfo.Scan.ScanningNotSupported.title,
                   text: AlertInfo.Scan.ScanningNotSupported.msg,
                   btnText: AlertInfo.ok)
            .subscribe {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func failedDueToNoSettings() { print("failed failedDueToNoSettings.....")
        
        self.alert(title: AlertInfo.Scan.NoSettings.title,
                   text: AlertInfo.Scan.NoSettings.msg,
                   btnText: AlertInfo.ok)
            .subscribe {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func found(code: String) { // ovo mozes da report VM-u kao append novi code
        
        if scanerViewModel.sessionId != -1 {
            codeSuccessfull(code: code)
        } else {
            failedDueToNoSettings()
        }
        
    }
    
    private func codeSuccessfull(code: String) {
        
        avSessionViewModel.captureSession.stopRunning()
        
        if self.scannerView.subviews.contains(where: {$0.tag == 20}) {
//            print("vec prikazuje arrow, izadji...")
            return
        } // already arr
        
        scanedCode.onNext(code)
        
        self.scannerView.addSubview(getArrowImgView(frame: scannerView.bounds))
        
        delay(2.0) { // ovoliko traje anim kada prikazujes arrow
            DispatchQueue.main.async {
                self.scannerView.subviews.first(where: {$0.tag == 20})?.removeFromSuperview()
                self.avSessionViewModel.captureSession.startRunning()
            }
        }
        
        codeReporter.codeReport.value = getActualCodeReport()
        
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
    
}

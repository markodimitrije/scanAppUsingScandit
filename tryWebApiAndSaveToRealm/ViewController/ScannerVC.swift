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

class ScannerVC: UIViewController {
    
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var sessionConstLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var sessionTimeAndRoomLbl: UILabel!
    @IBOutlet weak var reportCodeBtn: UIButton!
    
    let disposeBag = DisposeBag()
    var scanerViewModel = ScannerViewModel.init()
    
    let avSessionViewModel = AVSessionViewModel()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var reportCodeStatus = BehaviorSubject<Bool>.init(value: false)
    private var codeReportIsHidden: Observable<Bool> {
        return
            reportCodeStatus
                .asObservable()
                .map(!)
    }
    
    var scanedCode = BehaviorSubject<String>.init(value: "")
    
    var settingsVC: SettingsVC!
    
    override func viewDidLoad() { super.viewDidLoad()
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
        
        codeReportIsHidden
            .map(viewIsHiddenToAlpha)
            .subscribe(onNext: { [weak self] (value) in
                guard let sSelf = self else {return}
                print("anim called...")
                
                UIView.animate(withDuration: 2.0, animations: {
                    DispatchQueue.main.async {
                        sSelf.reportCodeBtn.alpha = value
                    }
                })
            })
            .disposed(by: disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let name = segue.identifier, name == "segueShowSettings",
            let navVC = segue.destination as? UINavigationController,
            let settingsVC = navVC.children.first as? SettingsVC else { return }
        
        self.settingsVC = settingsVC
        
        hookUpInputs(on: settingsVC)
        hookupOutputs(on: settingsVC)
        
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
    
    private func hookupOutputs(on settingsVC: SettingsVC) {
        settingsVC.codeReport.asObserver()
            .subscribe(onNext: { [weak self] success in
                guard let success = success,
                    let strongSelf = self else {return}
                strongSelf.reportCodeStatus.onNext(success)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func hookUpScanedCode(on settingsVC: SettingsVC) {
        
        /* zasto sve ovo ne radi ???
         
        scanedCode.asObservable()
            .subscribe(settingsVC.codeScaned)
            .disposed(by: disposeBag)
        scanedCode.asObservable()
            .subscribe(onNext: { (code) in
                settingsVC.codeScaned.onNext(code)
            })
            .disposed(by: disposeBag)
        */
        
        settingsVC.codeScaned = self.scanedCode
        
    }
    
    // MARK:- Scanner related....
    
    
    private func bindAVSession() {
        
        avSessionViewModel.oSession
            .subscribe(onNext: { [unowned self] (session) in
                
                print("bindAVSession. onnext handler....")
                
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
                print("dobio sam code \(barCodeValue), moze report!!")
                sSelf.found(code: barCodeValue)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func failed() {
        print("failed.....")
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func found(code: String) { // ovo mozes da report VM-u kao append novi code
        
        scanedCode.onNext(code)

        self.performSegue(withIdentifier: "segueShowSettings", sender: self)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape //[.landscapeLeft, .landscapeRight]
    }
    
    // napravi API za ovo na odg viewModel-u...
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        
        if (avSessionViewModel.captureSession.isRunning == false) {
            avSessionViewModel.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated)
        
        if (avSessionViewModel.captureSession.isRunning == true) {
            avSessionViewModel.captureSession.stopRunning()
        }
    }
    
}

func viewIsHiddenToAlpha(hidden: Bool) -> CGFloat {
    return (hidden == true) ? 0 : 1
}

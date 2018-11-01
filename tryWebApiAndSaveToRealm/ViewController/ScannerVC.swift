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
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var sessionConstLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var sessionTimeAndRoomLbl: UILabel!
    
    let disposeBag = DisposeBag()
    var scanerViewModel = ScannerViewModel.init()
    
    let avSessionViewModel = AVSessionViewModel()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
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
        
        print("bindAVSession")
        
        avSessionViewModel.oSession
            .subscribe(onNext: { [unowned self] (session) in

//                print("on next emitovan za session")
                
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
                print("dobio sam code \(barCodeValue), pozovi found!!")
                sSelf.found(code: barCodeValue)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func failed() { print("failed.....")

        self.alert(title: AlertInfo.Scaner.title,
                   text: AlertInfo.Scaner.msg,
                   btnText: AlertInfo.ok)
            .subscribe {
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func found(code: String) { // ovo mozes da report VM-u kao append novi code
        
        avSessionViewModel.captureSession.stopRunning()
        
        scanedCode.onNext(code)
        
        self.scannerView.addSubview(getArrowImgView())
        
        delay(2.0) { // ovoliko traje anim kada prikazujes arrow
            DispatchQueue.main.async {
                self.scannerView.subviews.first(where: {$0.tag == 20})?.removeFromSuperview()
                self.avSessionViewModel.captureSession.startRunning()
            }
        }
        
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
    
    func getArrowImgView() -> UIImageView {
        let v = UIImageView.init(frame: scannerView.bounds)
        v.image = UIImage.init(named: "arrow")
        v.tag = 20
        return v
    }
    
}



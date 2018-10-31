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

class ScannerVC: UIViewController {
    
    @IBOutlet weak var sessionConstLbl: UILabel!
    @IBOutlet weak var sessionNameLbl: UILabel!
    @IBOutlet weak var sessionTimeAndRoomLbl: UILabel!
    
    @IBOutlet weak var reportCodeBtn: UIButton!
    
    let disposeBag = DisposeBag()
    var scanerViewModel = ScannerViewModel.init()
    
    private var reportCodeStatus = BehaviorSubject<Bool>.init(value: false)
    private var codeReportIsHidden: Observable<Bool> {
        return
            reportCodeStatus
                .asObservable()
                .map(!)
    }
    
    override func viewDidLoad() { super.viewDidLoad()
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
        
        hookUpInputs(on: settingsVC)
        hookupOutputs(on: settingsVC)

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
    
}

func viewIsHiddenToAlpha(hidden: Bool) -> CGFloat {
    return (hidden == true) ? 0 : 1
}

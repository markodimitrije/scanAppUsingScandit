//
//  SettingsVC.swift
//  tryWebApiAndSaveToRealm
//
//  Created by Marko Dimitrijevic on 20/10/2018.
//  Copyright © 2018 Marko Dimitrijevic. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa
import Realm
import RealmSwift
import RxRealmDataSources

class SettingsVC: UITableViewController {

    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var sessionLbl: UILabel!
    
    @IBOutlet weak var saveSettingsAndExitBtn: UIButton!
    @IBOutlet weak var cancelSettingsBtn: UIBarButtonItem!
    
    @IBOutlet weak var setIntervalForAutoSessionView: SetIntervalForAutoSessionView!
    
    @IBOutlet weak var autoSelectSessionsView: AutoSelectSessionsView!
    @IBOutlet weak var unsyncedScansView: UnsyncedScansView!
    @IBOutlet weak var wiFiConnectionView: WiFiConnectionView!
    
    let disposeBag = DisposeBag()
    
    // output
    var roomId: Int! = nil {
        didSet {
            bindXibEvents()
            bindInterval()
        }
    }
    let roomSelected = BehaviorSubject<RealmRoom?>.init(value: nil)
    let sessionSelected = BehaviorSubject<RealmBlock?>.init(value: nil)
    var selectedInterval = BehaviorRelay<TimeInterval>.init(value: MyTimeInterval.waitToMostRecentSession) // posesava na odg XIB
    
    // input - trebalo je u INIT !!
    var codeScaned = BehaviorSubject<String>.init(value: "")
    private var codeScan: String {
        return try! codeScaned.value()
    }
    
    var sessionId: Int {
        guard let block = try? sessionSelected.value(),
            let id = block?.id else {
            return -1 // bez veze je ovo.. BehaviorSubject... treba zamena za Variable !
        }
        return id
    }
    
    // MARK:- ViewModels
    fileprivate let roomViewModel = RoomViewModel()
    
    lazy var settingsViewModel = SettingsViewModel(
                                        saveSettings: saveSettingsAndExitBtn.rx.tap.asDriver(),
                                        cancelSettings: cancelSettingsBtn.rx.tap.asDriver())
    
    lazy fileprivate var autoSelSessionViewModel = AutoSelSessionWithWaitIntervalViewModel.init(roomId: roomId)
    
    lazy fileprivate var unsyncScansViewModel = UnsyncScansViewModel.init(syncScans: unsyncedScansView.syncBtn.rx.tap.asDriver())
    
    override func viewDidLoad() { super.viewDidLoad()
        bindUI()
        bindControlEvents()
        bindReachability()
        bindUnsyncedScans()
//        bindState() // ovde je rano za tableView.visibleCells !!
    }
    
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated)
        bindState()
    }
    
    private func bindUI() { // glue code for selected Room
        
        roomSelected
            .asDriver(onErrorJustReturn: nil)
            .map { $0?.name ?? RoomTextData.selectRoom }
            .drive(roomLbl.rx.text)
            .disposed(by: disposeBag)
        
        sessionSelected // SESSION - sessionLbl
            .map {
                guard let session = $0 else {
                    if self.autoSelectSessionsView.switchState { // ON
                        return SessionTextData.noAutoSessAvailable
                    } else {
                        return SessionTextData.selectSessManuallyOrTryAuto
                    }
                }
                return session.starts_at + " " + session.name
            }
            .bind(to: sessionLbl.rx.text)
            .disposed(by: disposeBag)
        
    }

    private func bindControlEvents() {
        // ova 2 su INPUT za settingsViewModel - start
        
        roomSelected.asDriver(onErrorJustReturn: nil)
            .drive(settingsViewModel.roomSelected)
            .disposed(by: disposeBag)
        
        sessionSelected.asDriver(onErrorJustReturn: nil)
            .drive(settingsViewModel.sessionSelected)
            .disposed(by: disposeBag)
        
        // switch povezivanje - end
        // shouldCloseSettingsVC dismiss behaviour - start
        
        let shouldCloseSettingsVCDriver = settingsViewModel.shouldCloseSettingsVC
            .asDriver(onErrorJustReturn: false)
        
        shouldCloseSettingsVCDriver
            .drive(self.rx.shouldBeDismiss)
            .disposed(by: disposeBag)
        
        shouldCloseSettingsVCDriver
            .drive(onCompleted: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.dismiss(animated: true)
                strongSelf.roomSelected.onNext(nil)
                strongSelf.sessionSelected.onNext(nil)
            })
            .disposed(by: disposeBag)
        
        // saveSettingsAndExitBtn availability for user interaction - start
        Observable.combineLatest(roomSelected, sessionSelected, resultSelector: { (room, session) -> Bool in // OK
            return room != nil && session != nil
        }).asDriver(onErrorJustReturn: false)
            .drive(saveSettingsAndExitBtn.rx.btnIsActive)
            .disposed(by: disposeBag)
    }
    
    private func bindReachability() {
        
        connectedToInternet()
            .asDriver(onErrorJustReturn: false)
            .drive(wiFiConnectionView.rx.connected) // ovo je var tipa binder na xib-u
            .disposed(by: disposeBag)
        
    }
    
    private func bindUnsyncedScans() {
        
        unsyncScansViewModel.syncScansCount
            .map {"\($0)"}
            .bind(to: unsyncedScansView.countLbl.rx.text)
            .disposed(by: disposeBag)
        
        unsyncScansViewModel.syncControlAvailable
            .map(!)
            .bind(to: unsyncedScansView.syncBtn.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func bindInterval() {
        
        let diffComponents = Calendar.current.dateComponents(
            hourMinuteSet,
            from: defaultAutoSessionDate,
            to: NOW)
        
        setIntervalForAutoSessionView.picker.date = Calendar.current.date(from: diffComponents)!
        
        setIntervalForAutoSessionView.picker.addTarget(
            self,
            action: #selector(SettingsVC.datePickerValueChanged(_:)),
            for:.valueChanged)
        
        selectedInterval // ovo je bilo ok dok nisam ubacio picker kontrolu
            .asObservable()
            .bind(to: autoSelSessionViewModel.inSelTimeInterval)
            .disposed(by: disposeBag)
        
    }
    
    private func bindState() {
        
        roomSelected
            .asDriver(onErrorJustReturn: nil) // ovu liniju napisi u modelu...
            .drive(tableView.rx.roomValidationSideEffects) // ovo je rx world, npr Binder na extension Reactive where Base: TableView
            .disposed(by: disposeBag)
    }
    
    private func getActualCodeReport() -> CodeReport { // refactor - delete
        print("KONACNO IMAM DA JE codeScan = \(codeScan)")
        return CodeReport.init(code: codeScan,
                               sessionId: sessionId,
                               date: Date.now)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let name = segue.identifier, name == "segueShowRooms",
            let roomsVC = segue.destination as? RoomsVC else { return }
        
        roomsVC.selRoomDriver
            .do(onNext: { room in // side-effect
                self.roomId = room.id
            })
            .drive(roomSelected)
            .disposed(by: disposeBag)
    
    }
    
    private func bindXibEvents() { // ovde hook-up controls koje imas na xib
        
        // mozes da viewmodel-u prosledis switch kao hook  // + treba mu i room
        autoSelSessionViewModel = AutoSelSessionWithWaitIntervalViewModel.init(roomId: roomId)
        autoSelSessionViewModel.selectedRoom = roomSelected
        
        self.selectedInterval.asObservable()
            .subscribe(onNext: { (val) in
                self.autoSelSessionViewModel.blockViewModel.oAutoSelSessInterval.accept(val)
                self.autoSelSessionViewModel.switchState.onNext(self.autoSelectSessionsView.controlSwitch!.isOn)
            }).disposed(by: disposeBag)
        
        autoSelectSessionsView.controlSwitch.rx.switchActiveSequence // ovo je slabo, jer driver nije Model !!
            .skipUntil(roomViewModel.selectedRoom)
            .bind(to: autoSelSessionViewModel.switchState)
            .disposed(by: disposeBag)
        
        autoSelSessionViewModel.selectedSession // viewmodel-ov output
            .asDriver(onErrorJustReturn: nil)
            .drive(sessionSelected) // steta sto nije Rx world nego sopstveni var, bind-ujes 2 puta....
            .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.item) {
        //case (0, 0): print("auto segue ka rooms...")
        case (1, 0):
            
            guard let roomId = roomId,
                !autoSelectSessionsView.controlSwitch.isOn,
                let blocksVC = storyboard?.instantiateViewController(withIdentifier: "BlocksVC") as? BlocksVC else {
                    return
            }
            
            blocksVC.selectedRoomId = roomId
            navigationController?.pushViewController(blocksVC, animated: true)
            
            blocksVC.selectedRealmBlock
                .subscribe(onNext: { [weak self] block in
                    guard let strongSelf = self else {return}
                    strongSelf.sessionSelected.onNext(block)
                })
                .disposed(by: disposeBag)
            
        default: break
        }
    }
    
    deinit { print("deinit.setingsVC") }
    
}

extension SettingsVC { // ovo treba da napises preko Rx ....
    @objc func datePickerValueChanged(_ picker: UIDatePicker) {
//        print("datePickerValueChanged.value = \(picker.countDownDuration)")
        self.selectedInterval.accept(picker.countDownDuration)
    }
}

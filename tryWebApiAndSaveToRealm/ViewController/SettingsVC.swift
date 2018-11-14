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
    
    @IBOutlet weak var autoSelectSessionsView: AutoSelectSessionsView!
    @IBOutlet weak var unsyncedScansView: UnsyncedScansView!
    @IBOutlet weak var wiFiConnectionView: WiFiConnectionView!
    
    let disposeBag = DisposeBag()
    
    // output
    var roomId: Int! = nil {
        didSet {
            bindXibEvents()
        }
    }
    let roomSelected = BehaviorSubject<RealmRoom?>.init(value: nil)
    let sessionSelected = BehaviorSubject<RealmBlock?>.init(value: nil)
    
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
        saveSettings: saveSettingsAndExitBtn.rx.controlEvent(.touchUpInside),
        cancelSettings: cancelSettingsBtn.rx.tap)
    
    lazy fileprivate var autoSelSessionViewModel = AutoSelSessionViewModel.init(roomId: roomId)
    
    lazy fileprivate var unsyncScansViewModel = UnsyncScansViewModel.init(syncScans: unsyncedScansView.syncBtn.rx.controlEvent(.touchUpInside))
    
    
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
        
        let roomSelectedShared = roomSelected // ROOM - roomLbl
            .map { $0?.name ?? RoomTextData.selectRoom }
            .share()
        
        roomSelectedShared // ROOM - roomLbl
            .bind(to: roomLbl.rx.text)
            .disposed(by: disposeBag)
        
        sessionSelected // SESSION - sessionLbl
            .map {
                guard let session = $0 else { return "Select session" }
                return session.starts_at + " " + session.name
            }
            .bind(to: sessionLbl.rx.text)
            .disposed(by: disposeBag)
        
    }

    private func bindControlEvents() {
        // ova 2 su INPUT za settingsViewModel - start
        
        roomSelected
            .subscribe(onNext: { [weak self] (selectedRoom) in
                guard let strongSelf = self else {return}
                strongSelf.settingsViewModel.roomSelected.value = selectedRoom
            })
            .disposed(by: disposeBag)
        
        sessionSelected
            .subscribe(onNext: { [weak self] (sessionSelected) in
                guard let strongSelf = self else {return}
                strongSelf.settingsViewModel.sessionSelected.value = sessionSelected
            })
            .disposed(by: disposeBag)
        // ova 2 su INPUT za settingsViewModel - end
        
        settingsViewModel.shouldCloseSettingsVC
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self else {return}
                if $0 {
                    
                    strongSelf.dismiss(animated: true)
                    
                } else {
                    print("prikazi alert da izabere room....")
                }
            }, onCompleted: { [weak self] in // slucaj da je cancel
                guard let strongSelf = self else {return}
                strongSelf.dismiss(animated: true)
                strongSelf.roomSelected.onNext(nil)
                strongSelf.sessionSelected.onNext(nil)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(roomSelected, sessionSelected, resultSelector: { (room, session) -> Bool in // OK
            return room != nil && session != nil
        })
            .subscribe(onNext: { [weak self] validSettings in//[weak self] (block) in
                guard let strSelf = self else {return}
                strSelf.saveSettingsAndExitBtn.alpha = validSettings ? 1.0 : 0.5
                strSelf.saveSettingsAndExitBtn.isUserInteractionEnabled = validSettings
            })
            .disposed(by: disposeBag)
        
        
        
    }
    
    private func bindReachability() {
        
        connectedToInternet()
            //.debug("")
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] status in
                guard let strongSelf = self else {return}
                strongSelf.wiFiConnectionView.update(connected: status)
            })
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
    
    private func bindState() {
        
        roomSelected
            .subscribe(onNext: { [weak self] room in
                guard let strongSelf = self else {return}
                //reloadAutoSelViewModel(forRoomId: room?.id)
                _ = strongSelf.tableView.visibleCells.filter {
                    strongSelf.tableView.indexPath(for: $0)?.section == 1
                    }.map {
                        $0.isUserInteractionEnabled = (room != nil)
                        $0.alpha = (room != nil) ? 1.0: 0.5
                    }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func getActualCodeReport() -> CodeReport { // refactor - delete
        print("KONACNO IMAM DA JE codeScan = \(codeScan)")
        return CodeReport.init(code: codeScan,
                               sessionId: sessionId,
                               date: Date.now)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        hookUpIfRoomSegue(for: segue, sender: sender)
    
    }
    
    private func hookUpIfRoomSegue(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let name = segue.identifier, name == "segueShowRooms",
            let roomsVC = segue.destination as? RoomsVC else { return }
        
        roomsVC.selectedRealmRoom
            .subscribe(onNext: { [weak self] (room) in
                guard let strongSelf = self else {return}
                
                strongSelf.roomId = room.id // sranje, kako izvuci val iz PublishSubj? necu Variable..
                strongSelf.roomSelected.onNext(room)
                strongSelf.sessionSelected.onNext(nil)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func bindXibEvents() { // ovde hook-up controls koje imas na xib
        
        // mozes da viewmodel-u prosledis switch kao hook  // + treba mu i room
        autoSelSessionViewModel = AutoSelSessionViewModel.init(roomId: roomId)
        autoSelSessionViewModel.selectedRoom = roomSelected
        
        let switchState: Observable<Bool> = autoSelectSessionsView.controlSwitch.rx.controlEvent(.allTouchEvents)
            .map { [weak self] _ in
                guard let strongSelf = self else {return false}
                return strongSelf.autoSelectSessionsView.controlSwitch!.isOn
            }
        switchState
            .throttle(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .skipUntil(roomSelected)
            .subscribe(onNext: { [weak self] switchState in
                guard let strongSelf = self else {return}
                strongSelf.autoSelSessionViewModel.switchState.onNext(switchState) // forward..
            })
            .disposed(by: disposeBag)
        
        autoSelSessionViewModel.selectedSession // viewmodel-ov output
            .subscribe(onNext: {  [weak self] (session) in
                guard let strongSelf = self else {return}
                strongSelf.sessionSelected.onNext(session)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func navigateToSessionVCAndSubscribeForSelectedSession(roomId: Int) {
        
        if autoSelectSessionsView.controlSwitch.isOn { return }
        
        guard let blocksVC = storyboard?.instantiateViewController(withIdentifier: "BlocksVC") as? BlocksVC else {return}
        
        blocksVC.selectedRoomId = roomId
        navigationController?.pushViewController(blocksVC, animated: true)
    
        blocksVC.selectedRealmBlock
            .subscribe(onNext: { [weak self] block in
                guard let strongSelf = self else {return}
                strongSelf.sessionSelected.onNext(block)
            })
            .disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.item) {
        //case (0, 0): print("auto segue ka rooms...")
        case (1, 0):
            guard let roomId = roomId else {return}
            navigateToSessionVCAndSubscribeForSelectedSession(roomId: roomId)
        default: break
        }
    }
    
    deinit { print("deinit.setingsVC") }
    
}

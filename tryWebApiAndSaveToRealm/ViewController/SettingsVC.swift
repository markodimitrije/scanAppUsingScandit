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
    
    let codeReport = BehaviorSubject<Bool?>.init(value: false)
    
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
    
    let codeReporter = CodeReportsState.init() // vrsta viewModel-a ?
    
    fileprivate let roomViewModel = RoomViewModel()
    lazy var settingsViewModel = SettingsViewModel(unsyncedConnections: 0, saveSettings: saveSettingsAndExitBtn.rx.controlEvent(.touchUpInside), cancelSettings: cancelSettingsBtn.rx.tap)
    lazy fileprivate var autoSelSessionViewModel = AutoSelSessionViewModel.init(roomId: roomId)
    
    override func viewDidLoad() { super.viewDidLoad()
        bindUI()
        bindControlEvents()
        bindReachability()
//        bindState() // ovde je rano za tableView.visibleCells !!
        bindCodeReporter()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    private func bindCodeReporter() {
        
        codeReporter.webNotified
            .asObservable()
            .subscribe(onNext: { [weak self] arg in
                guard let sSelf = self else { return }
                guard let (report, success) = arg else { return }
                // da li je isto stanje sveta kada si se vratio ? zbog checkmark ? (report)
                sSelf.codeReport.onNext(success)
                if !success {
                    _ = RealmDataPersister().saveToRealm(codeReport: report)
                }
            })
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
                    print("uradi dismiss koji treba....")
                    strongSelf.dismiss(animated: true)
                    
                    strongSelf.codeReporter.codeReport.value = strongSelf.getActualCodeReport()
                    
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
    
    private func bindState() {
        
//        func reloadAutoSelViewModel(forRoomId roomId: Int?) {
//            guard let roomId = roomId else {return}
//            autoSelSessionViewModel = AutoSelSessionViewModel.init(roomId: roomId)
//        }
        
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
    
    private func getActualCodeReport() -> CodeReport {
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
                print("room.name is \(room.name)")
                strongSelf.roomId = room.id // sranje, kako izvuci val iz PublishSubj? necu Variable..
                strongSelf.roomSelected.onNext(room)
                strongSelf.sessionSelected.onNext(nil)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func bindXibEvents() { // ovde hook-up controls koje imas na xib
        
        print("bindXibEvents is called")
        
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
        
        /* implement me....
        unsyncedScansView.syncBtn.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { [weak self] tap in
                guard let strongSelf = self else {return}
                print("sync btn is tapped, snimi sta self scaning app salje bekendu")
            })
            .disposed(by: disposeBag)
 */
        
        roomSelected
            .distinctUntilChanged()
            .map {_ in return false} // hocemo da je default iskljuceno
            .bind(to: autoSelectSessionsView.controlSwitch.rx.isOn)
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
        case (0, 0): print("auto segue ka rooms...")
        case (1, 0):
            guard let roomId = roomId else {return}
            navigateToSessionVCAndSubscribeForSelectedSession(roomId: roomId)
        default: break
        }
    }
    
    deinit { print("deinit.setingsVC") }
    
}


//func codeReportMatchWorldAsBefore(report: CodeReport, sessionId: Int) -> Bool {
//    return report.sessionId == sessionId && report.code ==
//}

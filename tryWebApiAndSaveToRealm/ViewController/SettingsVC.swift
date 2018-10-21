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

class SettingsVC: UIViewController {

    @IBAction func selectSessionTapped(_ sender: UIButton) {
        guard let roomId = roomId else {return}
        navigateToSessionVCAndSubscribeForSelectedSession(roomId: roomId)
    }
    
    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var sessionLbl: UILabel!
    
    let disposeBag = DisposeBag()
    
    // output
    var roomId: Int!
    let roomSelected = PublishSubject<RealmRoom>.init()
    let sessionSelected = PublishSubject<RealmBlock?>.init()
    
    fileprivate let roomViewModel = RoomViewModel()
    
    override func viewDidLoad() { super.viewDidLoad()
        bindUI()
    }
    
    private func bindUI() { // glue code for selected Room
        
        roomSelected
        .map { (realmRoom) -> String in
            print("vracam za ime = \(realmRoom.name)")
            return realmRoom.name
        }
        .bind(to: roomLbl.rx.text)
        .disposed(by: disposeBag)

        sessionSelected
            .map { (realmBlock) -> String in
                print("vracam za ime session-a = \(realmBlock?.name ?? "Select session")")
                return realmBlock?.name ?? "Select session"
            }
            .bind(to: sessionLbl.rx.text)
            .disposed(by: disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        hookUpIfRoomSegue(for: segue, sender: sender)
    
    }
    
    private func hookUpIfRoomSegue(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let name = segue.identifier, name == "segueShowRooms",
            let navVC = segue.destination as? UINavigationController,
            let roomsVC = navVC.children.first as? RoomsVC else { return }
        
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
    
    private func navigateToSessionVCAndSubscribeForSelectedSession(roomId: Int) {
        
        guard let navVC = storyboard?.instantiateViewController(withIdentifier: "NavVcForBocks") as? UINavigationController,
         let blocksVC = navVC.children.first as? BlocksVC else {return}
        
        blocksVC.selectedRoomId = roomId
        self.present(navVC, animated: true)
    
        blocksVC.selectedRealmBlock
            .subscribe(onNext: { [weak self] block in
                guard let strongSelf = self else {return}
                strongSelf.sessionSelected.onNext(block)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func updateUI() {
     
        roomSelected
            .map { (realmRoom) -> String in
                print("vracam za ime = \(realmRoom.name)")
                return realmRoom.name
            }
            .bind(to: roomLbl.rx.text)
            .disposed(by: disposeBag)
        
        sessionSelected
            .map { (realmBlock) -> String in
                print("vracam za ime session-a = \(realmBlock?.name ?? "Select session")")
                return realmBlock?.name ?? "Select session"
            }
            .bind(to: sessionLbl.rx.text)
            .disposed(by: disposeBag)
        
    }
    
}

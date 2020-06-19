//
//  TGAccountsPreferencesViewController.swift
//  Telegram
//
//  Created by John Doe on 19.06.2020.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation
import Postbox
import TelegramCore
import TGUIKit
import SwiftSignalKit
import SyncCore

class AccountsTableCellView: NSTableCellView {
    @IBOutlet weak public var profilePictureImageView: NSImageView!
    @IBOutlet weak public var accountNameTextField: NSTextField!
    @IBOutlet weak public var phoneNumberTextField: NSTextField!
}

class TGAccountsPreferencesViewController: TGPreferencesViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    fileprivate static let AccountCell = NSUserInterfaceItemIdentifier(rawValue: "AccountCellID")
    
    private let disposable = MetaDisposable()
    private var context: AccountContext!
    
    private var accounts: [AccountWithInfo]?
    private var accountsComplementary: [PeerId : (peerView: PeerView, photo: CGImage?)]?
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.setupUI()
    }
    
    private func setupUI() {
        context = (self.view.window!.windowController as! TGPreferencesWindowController).context!
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let signal = context.sharedContext.activeAccountsWithInfo |> mapToSignal { primary, accounts -> Signal<([AccountWithInfo], [PeerId : (PeerView, CGImage?)]), NoError> in
            let complementary = accounts.map { info -> Signal<(PeerId, PeerView, CGImage?), NoError> in
                return combineLatest(info.account.viewTracker.peerView(info.account.peerId), peerAvatarImage(account: info.account, photo: .peer(info.peer, info.peer.smallProfileImage, info.peer.displayLetters, nil), displayDimensions: NSMakeSize(48, 48), scale: System.backingScale)) |> map { peerView, photo in
                    (info.account.peerId, peerView, photo.0)
                }
            }
            
            return combineLatest(complementary) |> map { complementary in
                let complementary = complementary.map {
                    return ($0.0, (peerView: $0.1, photo: $0.2))
                }
                let dict: [PeerId: (PeerView, CGImage?)] = complementary.reduce([:], { result, current in
                    var result = result
                    result[current.0] = current.1
                    return result
                })
                return (accounts, dict)
            }
            
        } |> deliverOnMainQueue
        
        
        disposable.set(signal.start(next: { [weak self] in
            guard let self = self else { return }
            self.accounts = $0
            self.accountsComplementary = $1
            self.reloadTable()
        }))
    }
    
    private func reloadTable() {
        tableView.reloadData()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return accounts?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let item = accounts?[row] else {
            return nil
        }
        
        if let cell = tableView.makeView(withIdentifier: TGAccountsPreferencesViewController.AccountCell, owner: nil) as? AccountsTableCellView {
            if let peerView = accountsComplementary?[item.peer.id]?.peerView, let user = peerViewMainPeer(peerView) as? TelegramUser {
                cell.accountNameTextField.stringValue = user.displayTitle
                if let phone = user.phone {
                    cell.phoneNumberTextField.stringValue = formatPhoneNumber(phone)
                }
            }
            if let photo = accountsComplementary?[item.peer.id]?.photo {
                cell.profilePictureImageView.image = NSImage(cgImage: photo, size: NSMakeSize(48, 48))
            }
            return cell
        }
        return nil
    }
    
    deinit {
        disposable.dispose()
    }
}

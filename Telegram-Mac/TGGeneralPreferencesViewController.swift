//
//  TGGeneralPreferencesViewController.swift
//  Telegram
//
//  Created by William on 2019-04-14.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Cocoa
import SwiftSignalKit
import SyncCore

class TGGeneralPreferencesViewController: TGPreferencesViewController {
    
    private let disposable = MetaDisposable()
    private var context: AccountContext!
    
    @IBOutlet weak var messageSendingReturnRadio: NSButton!
    @IBOutlet weak var messageSendingCmdReturnRadio: NSButton!
    
    @IBOutlet weak var showSidebarCheckbox: NSButton!
    @IBOutlet weak var showCallsTabCheckbox: NSButton!
    
    @IBOutlet weak var autoReplaceEmoticonsCheckbox: NSButton!
    @IBOutlet weak var suggestEmojiWhileTypingCheckbox: NSButton!
    
    @IBOutlet weak var playInAppSoundsCheckbox: NSButton!
    
    @IBOutlet weak var forceTouchRepliesRadio: NSButton!
    @IBOutlet weak var forceTouchEditsRadio: NSButton!
    @IBOutlet weak var forceTouchForwardsRadio: NSButton!
    
    @IBOutlet weak var scrollInstantViewWithSpacebarCheckbox: NSButton!
    
    
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
        
        let baseSettingsSignal: Signal<BaseApplicationSettings, NoError> = .single(context.sharedContext.baseSettings) |> then(baseAppSettings(accountManager: context.sharedContext.accountManager))
        
        let signal = combineLatest(queue: prepareQueue, baseSettingsSignal, appearanceSignal, appLaunchSettings(postbox: context.account.postbox), context.account.postbox.preferencesView(keys: [PreferencesKeys.secretChatSettings])) |> deliverOnMainQueue
        
        disposable.set(signal.start(next: { [weak self] settings, appearance, launchSettings, preferencesView in
            if let strongSelf = self {
                let baseSettings: BaseApplicationSettings = settings
                //
                //            let secretChatSettings = preferencesView.values[PreferencesKeys.secretChatSettings] as? SecretChatSettings ?? SecretChatSettings.defaultSettings
                            
                strongSelf.messageSendingReturnRadio.state = FastSettings.sendingType == .enter ? .on : .off
                strongSelf.messageSendingCmdReturnRadio.state = FastSettings.sendingType == .cmdEnter ? .on : .off
                
                strongSelf.showSidebarCheckbox.state = FastSettings.sidebarEnabled ? .on : .off
                strongSelf.showCallsTabCheckbox.state = baseSettings.showCallsTab ? .on : .off
                
                strongSelf.autoReplaceEmoticonsCheckbox.state = FastSettings.isPossibleReplaceEmojies ? .on : .off
                strongSelf.suggestEmojiWhileTypingCheckbox.state = baseSettings.predictEmoji ? .on : .off
                
                strongSelf.playInAppSoundsCheckbox.state = FastSettings.inAppSounds ? .on : .off
                
                strongSelf.forceTouchRepliesRadio.state = FastSettings.forceTouchAction == .reply ? .on : .off
                strongSelf.forceTouchEditsRadio.state = FastSettings.forceTouchAction == .edit ? .on : .off
                strongSelf.forceTouchForwardsRadio.state = FastSettings.forceTouchAction == .forward ? .on : .off
                
                strongSelf.scrollInstantViewWithSpacebarCheckbox.state = FastSettings.instantViewScrollBySpace ? .on : .off
            }
        }))
    }
    
    @IBAction func messageSendKeyChanged(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            FastSettings.changeSendingType(.enter)
            return
        case 1:
            FastSettings.changeSendingType(.cmdEnter)
            return
        default:
            return
        }
    }
    
    @IBAction func showSidebarChanged(_ sender: NSButton) {
        FastSettings.toggleSidebar(sender.state == .on)
    }
    
    @IBAction func showCallsTabChanged(_ sender: NSButton) {
        _ = updateBaseAppSettingsInteractively(accountManager: context.sharedContext.accountManager, { settings -> BaseApplicationSettings in
            return settings.withUpdatedShowCallsTab(sender.state == .on)
        }).start()
    }
    
    @IBAction func autoReplaceEmoticonsChanged(_ sender: NSButton) {
        FastSettings.toggleAutomaticReplaceEmojies(sender.state == .on)
    }
    
    @IBAction func suggestEmojiWhileTypingChanged(_ sender: NSButton) {
        _ = updateBaseAppSettingsInteractively(accountManager: context.sharedContext.accountManager, { settings -> BaseApplicationSettings in
            return settings.withUpdatedPredictEmoji(sender.state == .on)
        }).start()
    }
    
    @IBAction func playInAppSoundsChanged(_ sender: NSButton) {
        FastSettings.toggleInAppSouds(sender.state == .on)
    }
    
    @IBAction func forceTouchMessageActionChanged(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            FastSettings.toggleForceTouchAction(.reply)
            return
        case 1:
            FastSettings.toggleForceTouchAction(.edit)
            return
        case 2:
            FastSettings.toggleForceTouchAction(.forward)
            return
        default:
            return
        }
    }
    
    @IBAction func scrollInstantViewWithSpacebarChanged(_ sender: NSButton) {
        FastSettings.toggleInstantViewScrollBySpace(sender.state == .on)
    }
    
    deinit {
        disposable.dispose()
    }
    
}

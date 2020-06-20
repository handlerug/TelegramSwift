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
    
    @IBOutlet weak var preserveFormattingWhenCopyingCheckbox: NSButton!
    
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
            guard let self = self else { return }
            
            let baseSettings: BaseApplicationSettings = settings
            
//            let secretChatSettings = preferencesView.values[PreferencesKeys.secretChatSettings] as? SecretChatSettings ?? SecretChatSettings.defaultSettings
                        
            self.messageSendingReturnRadio.state = FastSettings.sendingType == .enter ? .on : .off
            self.messageSendingCmdReturnRadio.state = FastSettings.sendingType == .cmdEnter ? .on : .off
            
            self.showSidebarCheckbox.state = FastSettings.sidebarEnabled ? .on : .off
            self.showCallsTabCheckbox.state = baseSettings.showCallsTab ? .on : .off
            
            self.autoReplaceEmoticonsCheckbox.state = FastSettings.isPossibleReplaceEmojies ? .on : .off
            self.suggestEmojiWhileTypingCheckbox.state = baseSettings.predictEmoji ? .on : .off
            
            self.playInAppSoundsCheckbox.state = FastSettings.inAppSounds ? .on : .off
            
            self.preserveFormattingWhenCopyingCheckbox.state = FastSettings.enableRTF ? .on : .off
            
            self.forceTouchRepliesRadio.state = FastSettings.forceTouchAction == .reply ? .on : .off
            self.forceTouchEditsRadio.state = FastSettings.forceTouchAction == .edit ? .on : .off
            self.forceTouchForwardsRadio.state = FastSettings.forceTouchAction == .forward ? .on : .off
            
            self.scrollInstantViewWithSpacebarCheckbox.state = FastSettings.instantViewScrollBySpace ? .on : .off
        }))
    }
    
    @IBAction func messageSendKeyChanged(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            FastSettings.changeSendingType(.enter)
        case 1:
            FastSettings.changeSendingType(.cmdEnter)
        default:
            return
        }
    }
    
    @IBAction func showSidebarToggled(_ sender: NSButton) {
        FastSettings.toggleSidebar(sender.state == .on)
    }
    
    @IBAction func showCallsTabToggled(_ sender: NSButton) {
        let state = sender.state == .on
        _ = updateBaseAppSettingsInteractively(accountManager: context.sharedContext.accountManager, {
            $0.withUpdatedShowCallsTab(state)
        }).start()
    }
    
    @IBAction func autoReplaceEmoticonsToggled(_ sender: NSButton) {
        FastSettings.toggleAutomaticReplaceEmojies(sender.state == .on)
    }
    
    @IBAction func suggestEmojiWhileTypingToggled(_ sender: NSButton) {
        let state = sender.state == .on
        _ = updateBaseAppSettingsInteractively(accountManager: context.sharedContext.accountManager, {
            $0.withUpdatedPredictEmoji(state)
        }).start()
    }
    
    @IBAction func playInAppSoundsToggled(_ sender: NSButton) {
        FastSettings.toggleInAppSouds(sender.state == .on)
    }
    
    @IBAction func preserveFormattingWhenCopyingToggled(_ sender: NSButton) {
        FastSettings.enableRTF = sender.state == .on
    }
    
    @IBAction func forceTouchMessageActionChanged(_ sender: NSButton) {
        switch sender.tag {
        case 0:
            FastSettings.toggleForceTouchAction(.reply)
        case 1:
            FastSettings.toggleForceTouchAction(.edit)
        case 2:
            FastSettings.toggleForceTouchAction(.forward)
        default:
            return
        }
    }
    
    @IBAction func scrollInstantViewWithSpacebarToggled(_ sender: NSButton) {
        FastSettings.toggleInstantViewScrollBySpace(sender.state == .on)
    }
    
    deinit {
        disposable.dispose()
    }
    
}

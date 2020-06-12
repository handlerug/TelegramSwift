//
//  ChatInputAttachView.swift
//  Telegram-Mac
//
//  Created by keepcoder on 26/09/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa
import TGUIKit
import SwiftSignalKit
import TelegramCore
import SyncCore
import Postbox


class ChatInputAttachView: ImageButton, Notifable {
    
    
    
    private var chatInteraction:ChatInteraction
    private var controller:SPopoverViewController?
    private let editMediaAccessory: ImageView = ImageView()
    
    @objc private func attachMenuUpdateEditingMessageMedia(_ sender: AnyObject) {
        self.chatInteraction.updateEditingMessageMedia(mediaExts, true)
    }
    
    @objc private func attachMenuUpdateEditingMessageFile(_ sender: AnyObject) {
        self.chatInteraction.updateEditingMessageMedia(nil, false)
    }
    
    @objc private func attachMenuUpdateEditingMessageEditPhoto(_ sender: AnyObject) {
        if let editState = chatInteraction.presentation.interfaceState.editState, let media = editState.originalMedia, media is TelegramMediaImage {
            self.chatInteraction.editEditingMessagePhoto(media as! TelegramMediaImage)
        }
    }
    
    @objc private func attachMenuPhotoOrVideo(_ sender: AnyObject) {
        if let peer = chatInteraction.presentation.peer {
            if let permissionText = permissionText(from: peer, for: .banSendMedia) {
                alert(for: mainWindow, info: permissionText)
                return
            }
            self.chatInteraction.attachPhotoOrVideo()
        }
    }
    
    @objc private func attachMenuPicture(_ sender: AnyObject) {
        if let peer = chatInteraction.presentation.peer {
            if let permissionText = permissionText(from: peer, for: .banSendMedia) {
                alert(for: mainWindow, info: permissionText)
                return
            }
            self.chatInteraction.attachPicture()
        }
    }
    
    @objc private func attachMenuPoll(_ sender: AnyObject) {
        if let peer = chatInteraction.presentation.peer {
            if let permissionText = permissionText(from: peer, for: .banSendPolls) {
                alert(for: mainWindow, info: permissionText)
                return
            }
            showModal(with: NewPollController(chatInteraction: self.chatInteraction), for: mainWindow)
        }
    }
    
    @objc private func attachMenuFile(_ sender: AnyObject) {
        if let peer = chatInteraction.presentation.peer {
            if let permissionText = permissionText(from: peer, for: .banSendMedia) {
                alert(for: mainWindow, info: permissionText)
                return
            }
            self.chatInteraction.attachFile(false)
        }
    }
    
    @objc private func attachMenuLocation(_ sender: AnyObject) {
        self.chatInteraction.attachLocation()
    }
    
    let attachMenuUpdateEditingMessageMediaItem = NSMenuItem(title: L10n.inputAttachPopoverPhotoOrVideo, action: #selector(attachMenuUpdateEditingMessageMedia(_:)), keyEquivalent: "")
    let attachMenuUpdateEditingMessageFileItem = NSMenuItem(title: L10n.inputAttachPopoverFile, action: #selector(attachMenuUpdateEditingMessageFile(_:)), keyEquivalent: "")
    let attachMenuUpdateEditingMessageEditPhotoItem = NSMenuItem(title: L10n.editMessageEditCurrentPhoto, action: #selector(attachMenuUpdateEditingMessageEditPhoto(_:)), keyEquivalent: "")
    
    let attachMenuPhotoOrVideoItem = NSMenuItem(title: L10n.inputAttachPopoverPhotoOrVideo, action: #selector(attachMenuPhotoOrVideo(_:)), keyEquivalent: "")
    let attachMenuPictureItem = NSMenuItem(title: L10n.inputAttachPopoverPicture, action: #selector(attachMenuPicture(_:)), keyEquivalent: "")
    let attachMenuPollItem = NSMenuItem(title: L10n.inputAttachPopoverPoll, action: #selector(attachMenuPoll(_:)), keyEquivalent: "")
    let attachMenuFileItem = NSMenuItem(title: L10n.inputAttachPopoverFile, action: #selector(attachMenuFile(_:)), keyEquivalent: "")
    let attachMenuLocationItem = NSMenuItem(title: L10n.inputAttachPopoverLocation, action: #selector(attachMenuLocation(_:)), keyEquivalent: "")
    
    init(frame frameRect: NSRect, chatInteraction:ChatInteraction) {
        self.chatInteraction = chatInteraction
        super.init(frame: frameRect)
        
        highlightHovered = true
        
        updateLayout()

        chatInteraction.add(observer: self)
        addSubview(editMediaAccessory)
        editMediaAccessory.layer?.opacity = 0
        updateLocalizationAndTheme(theme: theme)
    }
    
    func isEqual(to other: Notifable) -> Bool {
        if let view = other as? ChatInputAttachView {
            return view === self
        } else {
            return false
        }
    }
    
    func notify(with value: Any, oldValue: Any, animated: Bool) {
        let value = value as? ChatPresentationInterfaceState
        let oldValue = oldValue as? ChatPresentationInterfaceState
        
        if value?.interfaceState.editState != oldValue?.interfaceState.editState {
            if let editState = value?.interfaceState.editState {
                let isMedia = editState.message.media.first is TelegramMediaFile || editState.message.media.first is TelegramMediaImage
                editMediaAccessory.change(opacity: isMedia ? 1 : 0)
                self.highlightHovered = isMedia
                self.autohighlight = isMedia
            } else {
                editMediaAccessory.change(opacity: 0)
                self.highlightHovered = true
                self.autohighlight = true
            }
        }
       
//        if let slowMode = value?.slowMode {
//            if slowMode.hasError  {
//                self.highlightHovered = false
//                self.autohighlight = false
//            }
//        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if let peer = chatInteraction.presentation.peer {
            
            let menu = NSMenu()

            if let editState = chatInteraction.presentation.interfaceState.editState, let media = editState.originalMedia, media is TelegramMediaFile || media is TelegramMediaImage {
                
                menu.addItem(self.attachMenuUpdateEditingMessageMediaItem)
                
                if editState.message.groupingKey == nil {
                    menu.addItem(self.attachMenuUpdateEditingMessageFileItem)
                }
                
                if media is TelegramMediaImage {
                    menu.addItem(self.attachMenuUpdateEditingMessageEditPhotoItem)
                }
                
                
            } else if chatInteraction.presentation.interfaceState.editState == nil {
                
                if let slowMode = self.chatInteraction.presentation.slowMode, slowMode.hasLocked {
                    showSlowModeTimeoutTooltip(slowMode, for: self)
                    return
                }
                
                menu.addItem(self.attachMenuPhotoOrVideoItem)
                
                menu.addItem(self.attachMenuPictureItem)
                
                var canAttachPoll = false
                if let peer = chatInteraction.presentation.peer, peer.isGroup || peer.isSupergroup {
                    canAttachPoll = true
                }
                if let peer = chatInteraction.presentation.mainPeer, peer.isBot {
                    canAttachPoll = true
                }
                
                if let peer = chatInteraction.presentation.peer as? TelegramChannel {
                    canAttachPoll = peer.hasPermission(.sendMessages)
                }
                if canAttachPoll && permissionText(from: peer, for: .banSendPolls) != nil {
                    canAttachPoll = false
                }
               
                if canAttachPoll {
                    menu.addItem(self.attachMenuPollItem)
                }
                
                menu.addItem(self.attachMenuFileItem)
                
                menu.addItem(self.attachMenuLocationItem)
            }
            
            
            if !menu.items.isEmpty {
                NSMenu.popUpContextMenu(menu, with: event, for: self)
            }
        }
    }
    
    override func layout() {
        super.layout()
        editMediaAccessory.setFrameOrigin(46 - editMediaAccessory.frame.width, 23)
    }
    
    deinit {
        chatInteraction.remove(observer: self)
    }

    override func updateLocalizationAndTheme(theme: PresentationTheme) {
        super.updateLocalizationAndTheme(theme: theme)
        let theme = (theme as! TelegramPresentationTheme)
        editMediaAccessory.image = theme.icons.editMessageMedia
        editMediaAccessory.sizeToFit()
        set(image: theme.icons.chatAttach, for: .Normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(frame frameRect: NSRect) {
        fatalError("init(frame:) has not been implemented")
    }
    

}

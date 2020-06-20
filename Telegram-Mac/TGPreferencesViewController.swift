//
//  TGPreferencesViewController.swift
//  Telegram
//
//  Created by s0ph0s on 2019-04-14.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Cocoa

class TGPreferencesViewController: NSViewController {
    
    private var size: NSSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the preferred size for each view
        self.size = self.view.frame.size
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        guard let parent = self.parent as? TGPreferencesTabViewController,
            let window = parent.view.window,
            let size = self.size else {
            return
        }
        
        // Update the window's title to match the active tab view's title
        window.title = self.title!
        
        // Animate pane size change
        let contentRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
        let contentFrame = window.frameRect(forContentRect: contentRect)
        let toolbarHeight = window.frame.size.height - contentFrame.size.height
        let newOrigin = NSPoint(x: window.frame.origin.x, y: window.frame.origin.y + toolbarHeight)
        let newFrame = NSRect(origin: newOrigin, size: contentFrame.size)
        window.setFrame(newFrame, display: false, animate: parent.didFirstTabAppear)
        
        parent.didFirstTabAppear = true
    }
}

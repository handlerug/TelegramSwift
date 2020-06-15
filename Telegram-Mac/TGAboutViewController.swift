//
//  TGAboutViewController.swift
//  Telegram
//
//  Created by s0ph0s on 2019-04-06.
//  Copyright © 2019 Telegram. All rights reserved.
//

import Cocoa

class TGAboutViewController: NSViewController {

    @IBOutlet weak var versionLabel: NSTextField!
    @IBOutlet weak var copyVersionButton: NSButton!
    @IBOutlet weak var copyrightNoticeLabel: NSTextField!
    
    let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "1"
    let buildString = Bundle.main.infoDictionary?["CFBundleVersion"] ?? "0"
    #if STABLE
    let releaseChannel = "Stable channel"
    #elseif APP_STORE
    let releaseChannel = "Mac App Store"
    #elseif BETA
    let releaseChannel = "Beta channel"
    #else
    let releaseChannel = "Alpha channel"
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.stringValue = "Version \(versionString) (\(buildString))\n\(releaseChannel)"
        
        // no matching string for copy to clipboard except the image menu item label
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        copyrightNoticeLabel.stringValue = "Copyright © 2016–\(formatter.string(from: Date(timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate)))\nTELEGRAM MESSENGER LLP.\nAll rights reserved."
    }
    
    @IBAction func copyButtonClicked(_ sender: Any) {
        copyToClipboard("\(versionString) (\(buildString)) \(releaseChannel)")
    }
}

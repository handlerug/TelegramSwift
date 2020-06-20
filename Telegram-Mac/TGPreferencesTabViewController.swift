//
//  TGPreferencesTabViewController.swift
//  Telegram
//
//  Created by John Doe on 20.06.2020.
//  Copyright © 2020 Telegram. All rights reserved.
//

import Foundation

class TGPreferencesTabViewController: NSTabViewController {
    
    /// A flag that changes to `true` when any tab appears.
    /// Used for disabling animation for the first appeared tab.
    public var didTabAppear = false
}

//
//  PreferencesWindowController.swift
//  EFI Patcher
//
//  Created by Sad Pony on 2020-02-10.
//  Copyright © 2020 None. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // hide the window instead of closing
        self.window?.orderOut(sender)
        return false
    }

}

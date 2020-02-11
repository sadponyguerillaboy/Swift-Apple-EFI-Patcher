//
//  AppDelegate.swift
//  EFI Patcher
//
//  Created by Sad Pony on 2020-01-28.
//  Copyright © 2020 None. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var preferencesController: NSWindowController?


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func showPreferences (_ sender: Any) {
        
        if !(preferencesController != nil) {
            
            let storyboard = NSStoryboard(name: "Preferences", bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if (preferencesController != nil) {
            preferencesController?.showWindow(sender)
        }
    }
}

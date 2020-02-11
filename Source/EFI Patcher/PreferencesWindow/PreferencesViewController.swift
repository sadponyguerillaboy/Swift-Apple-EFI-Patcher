//
//  PreferencesViewController.swift
//  EFI Patcher
//
//  Created by Sad Pony on 2020-02-10.
//  Copyright © 2020 None. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    

    @IBOutlet weak var flashromLocation: NSTextField!
    @IBOutlet weak var programmerConfig: NSComboBox!
    //@IBOutlet weak var programmerConfig: NSComboBox!
    // Generate List of Programmers
    fileprivate let programmerList = createMenuList(file: "progList", term: "device")
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the size for each view
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
        
        //Populate Programmer Type Dropdown List
        programmerConfig.removeAllItems()
        programmerConfig.addItems(withObjectValues: programmerList)
        
        let flashromLoc = defaults.string(forKey: "FlashromLocation")
        if flashromLoc != nil {
            flashromLocation.stringValue = flashromLoc!
        }
        
        let progConfig = defaults.string(forKey: "ProgrammerConfig")
        if progConfig != nil {
            programmerConfig.stringValue = progConfig!
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        //Update window title with the active tabview title
        self.parent?.view.window?.title = self.title!
    }
    
    @IBAction func saveConfig (sender: AnyObject) {
        defaults.set(flashromLocation.stringValue, forKey: "FlashromLocation")
        defaults.set(programmerConfig.stringValue, forKey: "ProgrammerConfig")
        self.view.window?.performClose(self)
    }
    
}

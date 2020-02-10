//
//  ViewController.swift
//  EFI Patcher
//
//  Created by NoOne on 2020-01-28.
//  Copyright © 2020 None. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    // IBOutlet Variable Initialization
    @IBOutlet weak var filename_field: NSTextField!
    @IBOutlet weak var serial_field: NSTextField!
    @IBOutlet weak var mefilename_field: NSTextField!
    @IBOutlet weak var ChangeSerialRadioButton: NSButton!
    @IBOutlet weak var CleanMeRadioButton: NSButton!
    @IBOutlet weak var RemovePassRadioButton: NSButton!
    @IBOutlet weak var ClearNVRamRadioButton: NSButton!
    @IBOutlet weak var VerifyDumpRadioButton: NSButton!
    @IBOutlet weak var outputWindow: NSTextView!
    @IBOutlet weak var flashromLocation: NSTextField!
    @IBOutlet weak var dumpLocation: NSTextField!
    @IBOutlet weak var programmerType: NSComboBox!
    @IBOutlet weak var chipType: NSComboBox!
    public var efiPath = String()
    public var mePath = String()
    //fileprivate let programmerList = ["buspirate_spi", "ch341a_spi", "dediprog", "developerbox", "digilent_spi", "dummy", "ft2232_spi", "linux_mtd", "linux_spi", "pickit2_spi", "pony_spi", "rayer_spi", "serprog", "usbblaster_spi"]
    //fileprivate let chipList = ["MX25L6405", "MX25L6405D", "MX25L6406E/MX25L6408E", "MX25L6436E/MX25L6445E/MX25L6465E/MX25L6473E/MX25L6473F", "M25PX64", "N25Q064..1E", "N25Q064..3E","S25FL164K", "SST25VF064C", "SST26VF064B(A)", "W25Q64.V", "W25Q64.W", "W25X64"]
    // Generate List of Programmers from JSON File
    fileprivate let programmerList = createMenuList(file: "progList", term: "device")
    // Generate List of Chips from JSON File
    fileprivate let chipList = createMenuList(file: "chipList", term: "device")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Acquire username for default dump location
        let userName = NSUserName()
        //let fullUserName = NSFullUserName()
        dumpLocation.stringValue = "/Users/" + userName + "/Desktop/firmware_dump.bin"
        
        // Populate Programmer Type Dropdown List
        programmerType.removeAllItems()
        programmerType.addItems(withObjectValues: programmerList)
        
        // Populate Chip Type Dropdown List
        chipType.removeAllItems()
        chipType.addItems(withObjectValues: chipList)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // Open EFI File
    @IBAction func browseFile(sender: AnyObject) {
        
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose an EFI file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["bin", "rom"]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                efiPath = result!.path
                filename_field.stringValue = efiPath
            }
        } else {
            // User clicked on "Cancel"
            return
        }
        
    }
    
    // Open ME Region File
    @IBAction func browseMeFile(sender: AnyObject) {
           
           let dialog = NSOpenPanel();
           
           dialog.title                   = "Choose an ME Region file"
           dialog.showsResizeIndicator    = true
           dialog.showsHiddenFiles        = false
           dialog.canChooseDirectories    = true
           dialog.canCreateDirectories    = true
           dialog.allowsMultipleSelection = false
           dialog.allowedFileTypes        = ["bin", "rgn"]

           if (dialog.runModal() == NSApplication.ModalResponse.OK) {
               let result = dialog.url // Pathname of the file
               
               if (result != nil) {
                   mePath = result!.path
                   mefilename_field.stringValue = mePath
               }
           } else {
               // User clicked on "Cancel"
               return
           }
       }
    
    // Global Variable Initialization
    public var patched1 = NSMutableData()
    public var patched2 = NSMutableData()
    public var patched3 = NSMutableData()
    public var patched4 = NSMutableData()
    public var patchedLowerCase = NSMutableData()
    public var finalPatched = NSMutableData()
    public var serialBytes = Data()
    public var serialUpperCaseBytes = Data()
    public var hwcBytes = Data()
    public var sonBytes = Data()
    public var eofBytes = Data()
    public var fsysBlock = Data()
    public var oldCRC32Bytes = Data()
    public var crc32Offset = UInt64()
    public var errorActivated = false
    public var choiceMade = false
    public var efiPathURL = URL(fileURLWithPath: "")
    public var writePathURL = URL(fileURLWithPath: "")
    public var efiFileExists = true

    // Dump Chip:
    @IBAction func dumpChip(sender: AnyObject) {
        // if flashrom app location left empty (or with placeholder)
        // set to default brew install location, assuming v1.1
        if flashromLocation.stringValue == "" {
            flashromLocation.stringValue = "/usr/local/Cellar/flashrom/1.1/bin/flashrom"
        }
        // Initialize flashrom argument variables
        let progOption = "-p"
        let programmer = programmerType.stringValue
        let chipOption = "-c"
        let chip = chipType.stringValue
        let readOption = "-r"
        let writeLocation = dumpLocation.stringValue
        let argumentSet = [progOption, programmer, chipOption, chip, readOption, writeLocation]
        let (output, error, status) = runCommand(cmd: flashromLocation.stringValue, args: argumentSet)
        
        // Convert terminal output arrays to text strings
        let newOutput = output.joined(separator:" ")
        let newError = error.joined(separator:" ")

        // Print flashrom exit status code
        outputWindow.textStorage?.append(NSAttributedString(string: "Flashrom Exited with Status: " + String(status) + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
        outputWindow.scrollToEndOfDocument(nil)
        
        // Print flashrom terminal output
        if output.count > 0 {
            outputWindow.textStorage?.append(NSAttributedString(string: newOutput + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                outputWindow.scrollToEndOfDocument(nil)
        }
        
        // Print flashrom terminal error output
        if error.count > 0 {
            outputWindow.textStorage?.append(NSAttributedString(string: newError + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
            outputWindow.scrollToEndOfDocument(nil)
        }
        
        // Print flashrom dumping completed
        outputWindow.textStorage?.append(NSAttributedString(string: "Finished Dumping EFI Chip to: " + dumpLocation.stringValue + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.green ]))
        outputWindow.scrollToEndOfDocument(nil)
            
        // Verification of Dump:
        if VerifyDumpRadioButton.state == .on {
            // Initialize additional flashrom argument variables for verification
            let verifyOption = "-v"
            let argSet = [progOption, programmer, chipOption, chip, verifyOption, writeLocation]
            let (outp, err, stat) = runCommand(cmd: flashromLocation.stringValue, args: argSet)
            
            // Convert terminal output arrays to text strings
            let newOut = outp.joined(separator:" ")
            let newErr = err.joined(separator:" ")

            // Print flashrom exit status code
            outputWindow.textStorage?.append(NSAttributedString(string: "Flashrom Exited with Status: " + String(stat) + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
            outputWindow.scrollToEndOfDocument(nil)
            
            // Print flashrom terminal output
            if output.count > 0 {
                outputWindow.textStorage?.append(NSAttributedString(string: newOut + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                outputWindow.scrollToEndOfDocument(nil)
            }
            
            // Print flashrom terminal error output
            if error.count > 0 {
                outputWindow.textStorage?.append(NSAttributedString(string: newErr + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                outputWindow.scrollToEndOfDocument(nil)
            }
            
            // Print flashrom verification completed
            outputWindow.textStorage?.append(NSAttributedString(string: "Finished Verifying EFI Dump" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.green ]))
            outputWindow.scrollToEndOfDocument(nil)
        }
        
        // Auto-populate EFI file field with newly dumped file
        filename_field.stringValue = dumpLocation.stringValue
    }
    
    // Write Chip:
    @IBAction func writeChip(sender: AnyObject) {
        // if flashrom app location left empty (or with placeholder)
        // set to default brew install location, assuming v1.1
        if flashromLocation.stringValue == "" {
            flashromLocation.stringValue = "/usr/local/Cellar/flashrom/1.1/bin/flashrom"
        }
        
        // Initialize flashrom argument variables
        let progOption = "-p"
        let programmer = programmerType.stringValue
        let chipOption = "-c"
        let chip = chipType.stringValue
        let writeOption = "-w"
        let readLocation = filename_field.stringValue + "_patched.bin"
        let argumentSet = [progOption, programmer, chipOption, chip, writeOption, readLocation]
        let (output, error, status) = runCommand(cmd: flashromLocation.stringValue, args: argumentSet)
        
        // Convert terminal output arrays to text strings
        let newOutput = output.joined(separator:" ")
        let newError = error.joined(separator:" ")

        // Print flashrom exit status code
        outputWindow.textStorage?.append(NSAttributedString(string: "Flashrom Exited with Status: " + String(status) + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
        outputWindow.scrollToEndOfDocument(nil)
        
        // Print flashrom terminal output
        if output.count > 0 {
            outputWindow.textStorage?.append(NSAttributedString(string: newOutput + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
            outputWindow.scrollToEndOfDocument(nil)
        }
        
        // Print flashrom terminal error output
        if error.count > 0 {
            outputWindow.textStorage?.append(NSAttributedString(string: newError + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
            outputWindow.scrollToEndOfDocument(nil)
        }
        
        // Print flashrom writing completed
        outputWindow.textStorage?.append(NSAttributedString(string: "Finished Writing Patched EFI File to Chip" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.green ]))
        outputWindow.scrollToEndOfDocument(nil)
    }
    
    // Patching Process:
    @IBAction func patchStart(sender: AnyObject) {
        // Proceed if EFI File field NOT empty
        if filename_field.stringValue != "" {
            //Reset errorActivated if tripped from previous attempt
            errorActivated = false
            //Reset selection made variable from previous attempt
            choiceMade = false
         
            // Begining of Patching Process
            // Acquire Path to EFI File (from auto-populate or user selection)
            if efiPath != "" {
                efiPathURL = URL(fileURLWithPath: efiPath)
            } else {
                efiPathURL = URL(fileURLWithPath: filename_field.stringValue)
            }
            
            // Get contents of EFI File
            var data = NSMutableData()
            // Check to see if file exists
            let fileExists = FileManager.default.fileExists(atPath: efiPathURL.path)
            // If file exists read contents of file into data variable
            if fileExists == true {
                data = try! NSMutableData(contentsOf: efiPathURL)
                //let data: NSMutableData? = NSMutableData(contentsOf: efiPathURL)
                //let filesize = data!.count
                //var dataArray: [UInt8] = Array(data!)
                
                // Initialize Search Variables for Fsys Block
                let fsys = Data(bytes: "Fsys", count: 4)
                let eof = Data(bytes: "EOF", count: 3)
                let ssn = Data(bytes: "ssn", count: 3)
                let ssnUpperCase = Data(bytes: "SSN", count: 3)
                let hwc = Data(bytes: "hwc", count: 3)
                let son = Data(bytes: "son", count: 3)
                
                // Acquire Offsets for searched variables
                let fsysStartOffset = findInitialOffset(file: data, searchItem: fsys)
                let eofOffset = findOtherOffsetsRestricted(file: data, searchItem: eof, start: fsysStartOffset, end: data.count)
                let serialOffset = findOtherOffsets (file: data, searchItem: ssn, start: fsysStartOffset, end: eofOffset)
                let serialUpperCaseOffset = findOtherOffsets (file: data, searchItem: ssnUpperCase, start: fsysStartOffset, end: eofOffset)
                let hwcOffset = findOtherOffsets (file: data, searchItem: hwc, start: fsysStartOffset, end: eofOffset)
                let sonOffset = findOtherOffsets (file: data, searchItem: son, start: fsysStartOffset, end: eofOffset)
                
                // If fsys block found begin reading data
                if fsysStartOffset != NSNotFound {
                    let handle = try! FileHandle(forReadingFrom: efiPathURL)
                    
                    // Get lowercase ssn Serial
                    if serialOffset != NSNotFound {
                        handle.seek(toFileOffset: UInt64(serialOffset + 5))
                        serialBytes = handle.readData(ofLength: 12)
                    }
                    
                    // Get uppercase SSN Serial
                    if serialUpperCaseOffset != NSNotFound {
                        handle.seek(toFileOffset: UInt64(serialUpperCaseOffset + 5))
                        serialUpperCaseBytes = handle.readData(ofLength: 12)
                    }
                    
                    // Get hwc - Hardware Code
                    if hwcOffset != NSNotFound {
                        handle.seek(toFileOffset: UInt64(hwcOffset + 5))
                        hwcBytes = handle.readData(ofLength: 4)
                    }
                    
                    // Get son = Model
                    if sonOffset != NSNotFound {
                        handle.seek(toFileOffset: UInt64(sonOffset + 5))
                        sonBytes = handle.readData(ofLength: 9)
                    }
                    
                    // Get eof - End Of File for Fsys Block
                    if eofOffset != NSNotFound {
                        handle.seek(toFileOffset: UInt64(eofOffset)) // EOF
                        eofBytes = handle.readData(ofLength: 3)
                    }
                    
                    // Locate End of Fsys Block / CRC32 Location
                    // After EOF, is all 0x00's, so scan byte by byte until
                    // reads a byte that is not 0x00
                    // Initialize required search variables and counters
                    var startByte: UInt8 = 0x00
                    var insideByte = Data(bytes: &startByte, count: 1)
                    let compareByte = Data(bytes: &startByte, count: 1)
                    var seekCounter = 3
                    //var crc32Offset = UInt64()
                    //handle.seek(toFileOffset: UInt64(eofOffset + 3))
                            
                    //While insideByte(current byte read) is 0x00, read bytes
                    while (insideByte == compareByte) {
                        // Update crc32 offset to current byte being read
                        crc32Offset = handle.offsetInFile
                        handle.seek(toFileOffset: UInt64(eofOffset + seekCounter))
                        let holder = handle.readData(ofLength: 1)
                        insideByte = holder
                        seekCounter += 1
                    }
                    // Once and if crc32 offset discovered
                    if crc32Offset != NSNotFound {
                        handle.seek(toFileOffset: crc32Offset)
                        // read original crc32 hash
                        oldCRC32Bytes = handle.readData(ofLength: 4)
                        handle.seek(toFileOffset: UInt64(fsysStartOffset)) // EOF
                        // read fsys block from start to end (used for verification calc)
                        fsysBlock = handle.readData(ofLength: Int(crc32Offset) - Int(fsysStartOffset))
                    }
                    handle.closeFile()
                    
                    // Recalculate CRC32 to verify
                    let fsysBlockConverted = [UInt8](fsysBlock)
                    let oldCRC32BytesArray = [UInt8](oldCRC32Bytes)
                    let oldCRC32BytesArrayReversed = oldCRC32BytesArray.reversed().reduce(0) { soFar, byte in
                        return soFar << 8 | UInt32(byte)
                    }
                    let oldCRC32Recalculation = checksum(bytes: fsysBlockConverted)
                    
                    // Print Original EFI Information:
                    outputWindow.textStorage?.append(NSAttributedString(string: "Acquiring EFI Information" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                    outputWindow.scrollToEndOfDocument(nil)
                    
                    // Print Original EFI serial:
                    if serialOffset != NSNotFound {
                        outputWindow.textStorage?.append(NSAttributedString(string: "Original Serial: " + String(data: serialBytes, encoding: String.Encoding.ascii)! + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                    
                    // Print Original EFI hwc
                    if hwcOffset != NSNotFound {
                        outputWindow.textStorage?.append(NSAttributedString(string: "Original HWC: " + String(data: hwcBytes, encoding: String.Encoding.ascii)! + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                    
                    // Print Original EFI son
                    if sonOffset != NSNotFound {
                        outputWindow.textStorage?.append(NSAttributedString(string: "Original Model: " + String(data: sonBytes, encoding: String.Encoding.ascii)! + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
        
                    // Print Original EFI CRC32 read from file
                    outputWindow.textStorage?.append(NSAttributedString(string: "Original CRC32: " + String(format:"%llX", oldCRC32BytesArrayReversed) + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                    outputWindow.scrollToEndOfDocument(nil)
                    
                    // Print Re-Calculation of CRC32 for Verification
                    outputWindow.textStorage?.append(NSAttributedString(string: "Original CRC32 Re-Calculated: " + String(format:"%llX", oldCRC32Recalculation) + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                    outputWindow.scrollToEndOfDocument(nil)
                    
                    // Print CRC32 Verification Status
                    if oldCRC32BytesArrayReversed == oldCRC32Recalculation {
                        outputWindow.textStorage?.append(NSAttributedString(string: "Original CRC32 Correct" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.green ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    } else {
                        outputWindow.textStorage?.append(NSAttributedString(string: "Original CRC32 Incorrect" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                
                // If Fsys Block NOT found - Activate Error Handler
                } else {
                    // Activate Error handler
                    errorActivated = true
                    // Print Error Message
                    outputWindow.textStorage?.append(NSAttributedString(string: "Error: Fsys Block Not Found!" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                    outputWindow.scrollToEndOfDocument(nil)
                }
                
                // Begin Patching Process
                // Print that patching has begun
                if errorActivated == false {
                    outputWindow.textStorage?.append(NSAttributedString(string: "Patching..." + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                    outputWindow.scrollToEndOfDocument(nil)
                }
                
                // If ME Region Patch Radio Button on and no error activate
                // Begin patching ME Region
                if CleanMeRadioButton.state == .on && errorActivated == false {
                    // Activate Choice Selection counter
                    choiceMade = true
                    
                    // If ME Region File field NOT empty
                    if mefilename_field.stringValue != "" {
                        // Initialize ME Region file variables
                        let mePatchPathURL = URL(fileURLWithPath: mePath)
                        let mePatch: NSMutableData? = NSMutableData(contentsOf: mePatchPathURL)
                        //var mePatch = NSMutableData(contentsOf: mePath)
                        let meBytes = mePatch!.bytes
                        let meDataPtr = meBytes.advanced(by: 0)
                        let meSize = mePatch!.count
                        
                        // ME Region Header Bytes to Search For
                        var meRegionBytesV1 : [UInt8] = [ 0x20, 0x20, 0x80, 0x0F, 0x40, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x46, 0x50, 0x54  ]
                        let meRegionV1 = Data(bytes: &meRegionBytesV1, count: meRegionBytesV1.count)

                        var meRegionBytesV2 : [UInt8] = [ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24, 0x46, 0x50, 0x54 ]
                        let meRegionV2 = Data(bytes: &meRegionBytesV2, count: meRegionBytesV2.count)
                        
                        // Search for ME Region Offset
                        let meRegionOffset = findInitialMeRegionOffset (file: data, searchItem1: meRegionV1, searchItem2: meRegionV2)
                        
                        // Clean ME Region (replace with *.rgn or *.bin file)
                        patched1 = patchBytesRaw (file: data, toReplace: meDataPtr, start: meRegionOffset, end: (meSize + meRegionOffset))
                        
                        // Print ME Patch Status
                        outputWindow.textStorage?.append(NSAttributedString(string: "ME Region Successfully Patched " + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                        outputWindow.scrollToEndOfDocument(nil)
                        
                    // If Me Region File Path Empty:
                    } else {
                        // Activate Error handler
                        errorActivated = true
                        // Print Error Message
                        outputWindow.textStorage?.append(NSAttributedString(string: "Error: No ME Region File Selected" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                }
                
                // If Change Serial # Radio Button on and no error activate
                // Begin patching Serial & Correcting CRC32 for new Serial
                if ChangeSerialRadioButton.state == .on && errorActivated == false {
                    // Activate Choice Selection Counter
                    choiceMade = true
                    // If New Serial Field NOT empty and Entered serial is 12 Characters
                    if serial_field.stringValue != "" && serial_field.stringValue.count == 12 {
                        // Initialize patch serial variables
                        let patch_ssn = NSData(bytes: serial_field.stringValue.uppercased(), length: 12)
                        let patch_ssnPtr = patch_ssn.bytes
                        
                        // If previous ME Region Selections is ON
                        if CleanMeRadioButton.state == .on {
                            // If Both SSN and ssn fields exist
                            if serialUpperCaseOffset != NSNotFound {
                                patchedLowerCase = patchBytesRaw (file: patched1, toReplace: patch_ssnPtr, start: (serialOffset + 5), end: (serialOffset + 17))
                                let patchedPre = patchBytesRaw (file: patchedLowerCase, toReplace: patch_ssnPtr, start: (serialUpperCaseOffset + 5), end: (serialUpperCaseOffset + 17))
                                let crc32Ptr = createCRC32Bytes(data: patchedPre, startOffset: fsysStartOffset, endOffset: crc32Offset - 1)
                                patched2 = patchBytesRaw (file: patchedPre, toReplace: crc32Ptr, start: Int(crc32Offset), end: Int(crc32Offset + 3))
                            
                            // if only ssn field exits
                            }else{
                                let patchedPre = patchBytesRaw (file: patched1, toReplace: patch_ssnPtr, start: (serialOffset + 5), end: (serialOffset + 17))
                                let crc32Ptr = createCRC32Bytes(data: patchedPre, startOffset: fsysStartOffset, endOffset: crc32Offset - 1)
                                patched2 = patchBytesRaw (file: patchedPre, toReplace: crc32Ptr, start: Int(crc32Offset), end: Int(crc32Offset + 3))
                            }
                            
                            // Print New Serial Number
                            outputWindow.textStorage?.append(NSAttributedString(string: "New Serial Number: " + serial_field.stringValue.uppercased() + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                            outputWindow.scrollToEndOfDocument(nil)
                            
                            // Print Serial Patching Status
                            outputWindow.textStorage?.append(NSAttributedString(string: "Serial Number Successfully Patched" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                            outputWindow.scrollToEndOfDocument(nil)
                        
                        // If previous ME Region Selections is OFF
                        } else {
                            // If Both SSN and ssn fields exist
                            if serialUpperCaseOffset != NSNotFound {
                                patchedLowerCase = patchBytesRaw (file: data, toReplace: patch_ssnPtr, start: (serialOffset + 5), end: (serialOffset + 17))

                                let patchedPre = patchBytesRaw (file: patchedLowerCase, toReplace: patch_ssnPtr, start: (serialUpperCaseOffset + 5), end: (serialUpperCaseOffset + 17))
                                let crc32Ptr = createCRC32Bytes(data: patchedPre, startOffset: fsysStartOffset, endOffset: crc32Offset - 1)
                                patched2 = patchBytesRaw (file: patchedPre, toReplace: crc32Ptr, start: Int(crc32Offset), end: Int(crc32Offset + 3))
                                
                            // If only ssn field exits
                            }else{
                                let patchedPre = patchBytesRaw (file: data, toReplace: patch_ssnPtr, start: (serialOffset + 5), end: (serialOffset + 17))
                                let crc32Ptr = createCRC32Bytes(data: patchedPre, startOffset: fsysStartOffset, endOffset: crc32Offset - 1)
                                patched2 = patchBytesRaw (file: patchedPre, toReplace: crc32Ptr, start: Int(crc32Offset), end: Int(crc32Offset + 3))
                            }
                            
                            // Print New Serial Number
                            outputWindow.textStorage?.append(NSAttributedString(string: "New Serial Number: " + serial_field.stringValue.uppercased() + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                            outputWindow.scrollToEndOfDocument(nil)
                            
                            // Print Serial Patching Status
                            outputWindow.textStorage?.append(NSAttributedString(string: "Serial Number Successfully Patched" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                            outputWindow.scrollToEndOfDocument(nil)
                        }
                    
                    // If Serial Field Empty or Entered Serial is Incorrect Length
                    } else {
                        // Activate Error handler
                        errorActivated = true
                        // Print Error Message
                        outputWindow.textStorage?.append(NSAttributedString(string: "Error: No Serial Number Entered or Serial Number Incorrect Length" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                }
                
                // If Remove Firmware Lock Radio Button ON and no error activate
                // Begin Removing Firmware Lock - fill section with 0xFF
                if RemovePassRadioButton.state == .on && errorActivated == false {
                    // Activate Choice Selection Counter
                    choiceMade = true
                    
                    // Initialize search Variable
                    let svs = Data(bytes: "$SVS", count: 4)
                           
                    //Initialize fill variable
                    let svsFill = NSMutableData()
                    
                    // Locate Firmware Lock Offset
                    let svsOffset = findInitialOffset (file: data, searchItem: svs)
                    
                    // If Firmware Lock Offset Located
                    if svsOffset != NSNotFound {
                        
                        // Skip past header (16 bytes)
                        let lockStartOffset = svsOffset + 16 // skip past header
                        
                        // Locate Firmware Lock End Offset
                        let lockEndOffset = findOtherOffsetsRestricted(file: data, searchItem: svs, start: lockStartOffset, end: data.count)
                        
                        // Generate Fill Bytes = (0xFF) * Length of Area
                        svsFill.calculateFill(255, start: lockStartOffset, end: lockEndOffset)
                        let svsFillBytes = svsFill.bytes
                        
                        // Account for Previous Selections and Patch Firmware Lock Area
                        if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .on {
                            patched3 = patchBytesRaw (file: patched2, toReplace: svsFillBytes, start: lockStartOffset, end: (lockEndOffset - 1))
                        }else if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .off {
                            patched3 = patchBytesRaw (file: patched1, toReplace: svsFillBytes, start: lockStartOffset, end: (lockEndOffset - 1))
                        }else if CleanMeRadioButton.state == .off && ChangeSerialRadioButton.state == .on {
                            patched3 = patchBytesRaw (file: patched2, toReplace: svsFillBytes, start: lockStartOffset, end: (lockEndOffset - 1))
                        } else {
                            patched3 = patchBytesRaw (file: data, toReplace: svsFillBytes, start: lockStartOffset, end: (lockEndOffset - 1))
                        }
                        // check that you actually need the end)ffset - 1 ????
                        
                        // Print Lock Removal Status
                        outputWindow.textStorage?.append(NSAttributedString(string: "Firmware Lock Successfully Removed" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    
                    // If Firmware Lock Offset NOT found
                    } else {
                        // Activate Error handler
                        errorActivated = true
                        // Print Error Message
                        outputWindow.textStorage?.append(NSAttributedString(string: "Error: $SVS - Firmware Lock Region Not Found" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                }
                
                // If Clear NVRAM Radio Button ON and no error activate
                // Begin Clearing NVRAM - fill section with 0xFF
                if ClearNVRamRadioButton.state == .on && errorActivated == false {
                    // Activate Choice Selection Counter
                    choiceMade = true
                    
                    // Initialize NVRAM Search variable
                    let vss = Data(bytes: "$VSS", count: 4)
                    
                    // Initialize Fill Variable
                    let vssFill = NSMutableData()
                    
                    // Locate NVRAM Offset
                    let vssOffset = findInitialOffset (file: data, searchItem: vss)
                    
                    // If NVRAM Offset Located
                    if vssOffset != NSNotFound {
                        
                        // Skip past header (16 bytes)
                        let nvramStartOffset = vssOffset + 16
                        
                        // Locate NVRAM End Offset
                        let nvramEndOffset = findOtherOffsetsRestricted(file: data, searchItem: vss, start: nvramStartOffset, end: data.count)
                        
                        // Generate Fill Bytes = (0xFF) * Length of Area
                        vssFill.calculateFill(255, start: nvramStartOffset, end: nvramEndOffset)
                        let vssFillBytes = vssFill.bytes
                               
                        // Account for Previous Selections and Clean NVRAM Area
                        if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .on && RemovePassRadioButton.state == .on {
                            patched4 = patchBytesRaw (file: patched3, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        } else if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .off && RemovePassRadioButton.state == .on {
                            patched4 = patchBytesRaw (file: patched3, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        } else if CleanMeRadioButton.state == .off && ChangeSerialRadioButton.state == .on && RemovePassRadioButton.state == .on {
                            patched4 = patchBytesRaw (file: patched3, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        } else if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .on && RemovePassRadioButton.state == .off {
                            patched4 = patchBytesRaw (file: patched2, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        } else if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .off && RemovePassRadioButton.state == .off {
                            patched4 = patchBytesRaw (file: patched1, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        } else if CleanMeRadioButton.state == .off && ChangeSerialRadioButton.state == .on && RemovePassRadioButton.state == .off {
                            patched4 = patchBytesRaw (file: patched2, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        } else {
                            patched4 = patchBytesRaw (file: data, toReplace: vssFillBytes, start: nvramStartOffset, end: (nvramEndOffset - 1))
                        }
                        
                        // Print NVRAM Cleaning Status
                        outputWindow.textStorage?.append(NSAttributedString(string: "NVRAM Successfully Cleared" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.headerTextColor ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    
                    // If NVRAM Offset NOT Located
                    } else {
                        // Activate Error Handler
                        errorActivated = true
                        // Print Error Message
                        outputWindow.textStorage?.append(NSAttributedString(string: "Error: $VSS - NVRAM Region Not Found" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                        outputWindow.scrollToEndOfDocument(nil)
                    }
                }
                
                // If Error Handler NOT Activate and Choice Selection Activate
                // Begin formulating final data to write to file
                if errorActivated == false && choiceMade == true{
                    if CleanMeRadioButton.state == .on && ChangeSerialRadioButton.state == .off && RemovePassRadioButton.state == .off && ClearNVRamRadioButton.state == .off {
                        finalPatched = patched1
                    } else if ChangeSerialRadioButton.state == .on && RemovePassRadioButton.state == .off && ClearNVRamRadioButton.state == .off {
                        finalPatched = patched2
                    } else if RemovePassRadioButton.state == .on && ClearNVRamRadioButton.state == .off {
                        finalPatched = patched3
                    } else {
                        finalPatched = patched4
                    }
                    
                    // Generate Name of New file to write
                    // Acquite Path of dumped file or opened file
                    // attach "_patched.bin" ot original name and use for write name
                    if efiPath != "" {
                        writePathURL = URL(fileURLWithPath: efiPath + "_patched.bin")
                    } else {
                        writePathURL = URL(fileURLWithPath: filename_field.stringValue + "_patched.bin")
                    }
                    
                    // Write Newly Patch File to Disk
                    let fileManager = FileManager.default
                    fileManager.createFile(atPath: writePathURL.path, contents: nil, attributes: nil)
                    let fileHandle = try! FileHandle(forWritingTo: writePathURL)
                    fileHandle.write(finalPatched as Data)
                    fileHandle.closeFile()
                    
                    // Print Writing Status
                    outputWindow.textStorage?.append(NSAttributedString(string: "Finished" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.green ]))
                    outputWindow.scrollToEndOfDocument(nil)
                    
                // If Error Handler Activated and Choice Selction Counter NOT Activate
                } else {
                    // Print Error Message
                    outputWindow.textStorage?.append(NSAttributedString(string: "Encountered an Error while patching. Process Terminated!" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                    outputWindow.scrollToEndOfDocument(nil)
                }
            //If fileExists is false
            } else {
                // Print Error Message
                outputWindow.textStorage?.append(NSAttributedString(string: "Error: The file you are attempting to patch does not exist!" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
                outputWindow.scrollToEndOfDocument(nil)
            }

        // If EFI File Field Empty
        } else {
            // Print Error Message
            outputWindow.textStorage?.append(NSAttributedString(string: "Error: No EFI File Selected" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.red ]))
            outputWindow.scrollToEndOfDocument(nil)
        }
    }
    
    // Reset All User Input Variables
    @IBAction func reset(sender: AnyObject) {
        let userName = NSUserName()
        programmerType.stringValue = "Programmer Type"
        chipType.stringValue = "Chip Type"
        flashromLocation.stringValue = ""
        dumpLocation.stringValue = "/Users/" + userName + "/Desktop/firmware_dump.bin"
        filename_field.stringValue = ""
        mefilename_field.stringValue = ""
        serial_field.stringValue = ""
        VerifyDumpRadioButton.state = .off
        ChangeSerialRadioButton.state = .off
        CleanMeRadioButton.state = .off
        RemovePassRadioButton.state = .off
        ClearNVRamRadioButton.state = .off
        outputWindow.textStorage?.append(NSAttributedString(string: "All Options Cleared / Reset" + "\n", attributes: [ NSAttributedString.Key.foregroundColor : NSColor.green ]))
        outputWindow.scrollToEndOfDocument(nil)
        
    }
}

// TODO:
// try / catch statements for better error handling
// output crc32 for new patched fsys
// masking of CRC32 values to keep unsigned = 0xFFFFFFFF if needed? but uses UInt32 so?
// drop down menu widths needs to be fixed
// verify filesize and only work with 8MB files
// still need to patch hwc, son ???

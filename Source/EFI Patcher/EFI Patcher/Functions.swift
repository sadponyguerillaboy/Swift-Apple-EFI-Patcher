//
//  Functions.swift
//  EFI Patcher
//
//  Created by Sad Pony on 2020-01-29.
//  Copyright © 2020 None. All rights reserved.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined().uppercased()
    }
}

// CRC32
var table: [UInt32] = {
    (0...255).map { i -> UInt32 in
        (0..<8).reduce(UInt32(i), { c, _ in
            (c % 2 == 0) ? (c >> 1) : (0xEDB88320 ^ (c >> 1))
        })
    }
}()
func checksum(bytes: [UInt8]) -> UInt32 {
    return ~(bytes.reduce(~UInt32(0), { crc, byte in
        (crc >> 8) ^ table[(Int(crc) ^ Int(byte)) & 0xFF]
    }))
}

func createCRC32Bytes(data: NSData, startOffset: Int, endOffset: UInt64) -> UnsafeRawPointer {
    let fsysBlockAltered = [UInt8](data[startOffset...Int(endOffset)])
    let newCRC32 = checksum(bytes: fsysBlockAltered)
    var littleEndian = newCRC32.littleEndian
    let count = MemoryLayout<UInt32>.size
    let bytePtr = withUnsafePointer(to: &littleEndian) {
        $0.withMemoryRebound(to: UInt8.self, capacity: count) {
            UnsafeBufferPointer(start: $0, count: count)
        }
    }
    let byteArray = Array(bytePtr)
    let convData = NSData(bytes: byteArray, length: 4)
    let convDataPtr = convData.bytes
    return convDataPtr
    
}

// Search Array for another Array / Sequence - works but slow, so decided not to use
// Decided to Patch Bytes directly instead. Is more resource efficient.
func searchArray (mainArray: [UInt8], searchSequence: [UInt8]) -> Int {// change to Bool if use found
    var index = 0
    var found = false
    
    while index < (mainArray.count - searchSequence.count) && found == false {
        let subarray = mainArray[index ..< (index + searchSequence.count)]
        if subarray.elementsEqual(searchSequence) {
            found = true
        } else {
            index += 1
        }
    }
    print(index)
    return index // or return found if you want Bool
}
//Example of how to use searchArray function
//var fsysArray: [UInt8] = Array(fsys)
//let result = searchArray(mainArray: dataArray, searchSequence: fsysArray)

// Locate Initial ME Offset searching for ME Headers within entire file
func findInitialMeRegionOffset (file: NSData, searchItem1: Data, searchItem2: Data, searchItem3: Data) -> Int {
    let searchRange = NSMakeRange(0, file.count)
    let foundRange = file.range(of: searchItem1, in: searchRange)
    let location = NSNotFound
    if foundRange.location != NSNotFound {
        let location = foundRange.location
        return location
    }
    else if foundRange.location == NSNotFound {
        let foundRange = file.range(of: searchItem2, in: searchRange)
        if foundRange.location != NSNotFound {
            let location = foundRange.location
            return location
        }
    }
    else if foundRange.location == NSNotFound {
        let foundRange = file.range(of: searchItem3, in: searchRange)
        if foundRange.location != NSNotFound {
            let location = foundRange.location
            return location
        }
    }
    return location
}

// Locate Initial Offset searching for data within entire file
func findInitialOffset (file: NSData, searchItem: Data) -> Int {
    let searchRange = NSMakeRange(0, file.count)
    let foundRange = file.range(of: searchItem, in: searchRange)
    let location = foundRange.location
    return location
}

// Located Additional Offsets within a specified range
func findOtherOffsets (file: NSData, searchItem: Data, start: Int, end: Int) -> Int {
    let searchRange = NSRange(start ... end)
    let foundRange = file.range(of: searchItem, in: searchRange)
    let location = foundRange.location
    return location
}

// Located Additional Offsets within a specified range, not including last index
func findOtherOffsetsRestricted (file: NSData, searchItem: Data, start: Int, end: Int) -> Int {
    let searchRange = NSRange(start ..< end)
    let foundRange = file.range(of: searchItem, in: searchRange)
    let location = foundRange.location
    return location
}

// Patch Bytes
func patchBytesRaw (file: NSMutableData, toReplace: UnsafeRawPointer, start: Int, end: Int) -> NSMutableData {
    let searchRange = NSRange(start ... end)
    file.replaceBytes(in: searchRange, withBytes: toReplace)
    return file
}

// Execute External Applications - used for flashrom
func runCommand(cmd : String, args : [String]) -> (output: [String], error: [String], exitCode: Int32) {
    var output : [String] = []
    var error : [String] = []

    let task = Process()
    task.launchPath = cmd
    task.arguments = args

    let outpipe = Pipe()
    task.standardOutput = outpipe
    let errpipe = Pipe()
    task.standardError = errpipe
    
    do {
        try task.run()
        //task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }

        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }

        task.waitUntilExit()
        let status = task.terminationStatus

        return (output, error, status)
        
    } catch {
        //task.terminate()
        task.waitUntilExit()
        let output = [String()]
        let error = ["Error: Unable to Locate or Execute Flashrom"]
        let status = 1
        return (output, error, Int32(status))
    }
}

// Generate the Fill Data used to overwrite NVRAM and Firmware Lock
extension NSMutableData {
    func calculateFill(_ i: UInt8, start: Int, end:Int) {
        let size = end - start
        var count = 0
        var i = i
        while count <= size {
            self.append(&i, length: 1)
            count += 1
        }
    }
}

// Parse JSON Files to Generate Menu List for Programmer and Chip Types
func createMenuList(file: String, term: String) -> [String] {
    
    // Initialize Array
    var menuArray: [String] = []
    // Fetch URL
    let url = Bundle.main.url(forResource: file, withExtension: "json")!

    // Load Data
    let data = try! Data(contentsOf: url)

    // Deserialize JSON
    do {
        let json = (try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]])!
        for item in json {
            for (key, value) in item {
                if key == term {
                    menuArray.append(value)
                }
            }
        }
    } catch {
        print("Error: Couldn't parse JSON. \(error.localizedDescription)")
    }
    return menuArray
}

// Parse JSON Files to Get Preferences for Flashrom & Programmer Config
func getJsonValue(file: String, term: String) -> String? {
    
    // Initialize variable
    var result = String()
    // Fetch URL
    let url = Bundle.main.url(forResource: file, withExtension: "json")!

    // Load Data
    let data = try! Data(contentsOf: url)

    // Deserialize JSON
    do {
        let json = (try JSONSerialization.jsonObject(with: data, options: []) as? [[String: AnyObject]])!
        for item in json {
            for (key, value) in item {
                if key == term {
                    if value is NSNull {
                        return nil
                    } else {
                        result = (value as? String)!
                    }
                }
            }
        }
    } catch {
        print("Error: Couldn't parse JSON. \(error.localizedDescription)")
    }
    return result
}

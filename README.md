# Swift-Apple-EFI-Patcher
Apple EFI Patcher written in Swift with Flashrom integration. This application was developed out of a need for a simple user-friendly and native macOS based approach to working with Apple EFI roms. The result is an all-in-one application that can utilize affordable SPI / eeprom chip reading hardware to read/dump from, patch and write to EFI Rom chips. EFI Patcher integrates flashrom support in order to communicate with hardware, thus incorporating a lot of the methodologies and current hardware already utilized by technicians.

The core of this application was inspired by my Python-Apple-EFI-Patcher, but has utilized better methods for obtaining offset positionality. This newer version impliments search functions opposed to relying on hard coded offsets to located specific regions within the EFI file.


__Prerequisites:__

Xcode Command Line Tools:
```
xcode-select --install
```

Brew:
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
```

Flashrom:
```
brew install flashrom
```


__Hardware:__

This software was developed with the intention of utilizing widely available and cost effective USB based hardware in the $3-$15 range. These include USB devices such as CH341a or FT2232H boards. These devices are natively supported by flashrom, so after installing flashrom with brew, no additional drivers or software is required to support these devices.
<br><a href="https://ibb.co/SBhq43B"><img src="https://i.ibb.co/njHhNLj/hardware.jpg" alt="hardware" border="0" /></a>


__Pre-Built Binary Downloads:__

![Click Here for Downloads](https://github.com/sadponyguerillaboy/Swift-Apple-EFI-Patcher/tree/master/binaries)


__Usage:__

After prerequisites have been setup and installed, you can either download a binary from the binary folder or build from source. Once you have downloaded or built EFI Patcher.App, just double click to run it. If on Catalina you may need to provide the utility with the necessary security clearances.


__Application Layout:__


Dumping Utilities:
<br><a href="https://ibb.co/GTLDQ6M"><img src="https://i.ibb.co/nCvyMG1/dump.jpg" alt="dump" border="0" /></a><br>

The top portion of the application window is utilized for EFI Chip reading / dumping processes. The first text field entitled "Flashrom Location" is for the location of your flashrom app. If you installed the most recent version with brew (which at the time this was written was v1.1) then you can just leave this field untouched. If left untouched, it will default to the brew install location. If you installed your flashrom to a different location, then you can enter the alternative path.

The next text field below entitled "Dump Location" is where the application will save the dumped EFI file. By default it will save to your desktop as "firmware_dump.bin".

The radio button entitled "Verify Dump" activates the verification process during EFI dumping and is recommended to verify the integtity of your dumped files. Note that activating the verification process will extend the time of the dumping procedure.

The dropdown menu entitled "Programmer Type" allows you to select your programmer.

The dropdown menu entitled "Chip Type" allows you to select your EFI chip.

The "Dump" button initiates the dumping process.


Patching Utilities:
<br><a href="https://ibb.co/Tbh1zC6"><img src="https://i.ibb.co/HxgCmJ6/patch.jpg" alt="patch" border="0" /></a>

The patching portion of the application window is where you can edit your EFI dump. If you dumped your EFI using the dump utility above, then the "Original EFI File" text field will auto-populate with the location of the dumped file. If you already have a dumped EFI file you wish to modify, then you can either type the path into the "Original EFI File" field, or yo can click the "Open" button and choose the file, which will in turn auto-populate the "Original EFI File" filed.

The four radio buttons activate each of the patching processes and should be pretty self explanatory.

To patch the serial number, click the "Change Serial Number" radio button and enter a new 12 character serial number of your choosing.

To clean the ME Region, click the "Clean ME Region" radio button, and either manually enter the path to the ME Region file or click the open button and select the file, which will in turn auto-populate the ME Region File path field.

To Remove firmware locks, click the "Remove Firmware Lock" radio button. This will fill the $SVS region with 0xFF.

To Clear NVRAM, click the "Clear NVRAM' radio button. This will fill the first $VSS region with 0xFF.

Once patching selections have been made. Click the "Patch' button below.


Console Output Window:
<br><a href="https://ibb.co/HCp7kPN"><img src="https://i.ibb.co/3vY1LFf/console.jpg" alt="console" border="0" /></a>

The console output portion of the application is where you will receive feedback on the various process taking place. 


Bottom Buttons:
<br><a href="https://ibb.co/tMCDQcV"><img src="https://i.ibb.co/Y7jhP8H/bottombuttons.jpg" alt="bottombuttons" border="0" /></a>

The three buttons at the bottom of the application window should be fairly self explanatory. "Reset" resets all user input selections and returns everything back to its original default settings. "Patch" initiates the patching process once you have made your selections above. The patching process will create a file in the same location as the dump file and add "patched.bin" to the end of the file. The "Write" button will write the patched EFI back onto the chip. The write function searches for a file name that equals (dumped file name + patched.bin). If you've used the patching utility, then you will already have a file that it will be able to automatically locate.

Editing JSON Menu Lists:
<br><a href="https://imgbb.com/"><img src="https://i.ibb.co/xgKTGNn/json.jpg" alt="json" border="0" /></a>

This application was designed with the intention of utilizing cost effective USB based chip readers such as CH341a or FT2232H based boards. During this application's inception, it was realized that attempting to account for the multitude of hardware and chip types currently in use and the future needs of user would be impossible. To allow for future customizations, the list of programmer and chip types are stored in JSON files inside the application. To edit these files, simply right click on the application, select "show package contents" and navigate to the JSON files in the Resources folder. Just edit the files and append your additions following the JSON format. Your additions will then become available in the programmer and chip type selection menus upon next restart.


__Flashrom Integration:__

Again, please remember that this program was designed with simplicity in mind. This was also in regards to hardware choices and flashrom usage. The application incorporates the following flashrom configurations:

```
/path_to_flashrom/flashrom -p <programmer type> -c <chip type> -r /Users/username/Desktop/firmware_dump.bin
/path_to_flashrom/flashrom -p <programmer type> -c <chip type> -v /Users/username/Desktop/firmware_dump.bin 
/path_to_flashrom/flashrom -p <programmer type> -c <chip type> -w /Users/username/Desktop/firmware_dump.bin_patched.bin
```

Any other configuration or usage of flashrom is beyond the scope of this application and currently not supported. If you require a more sophisticated flashrom integration, then feel free to modify the source code and impliment your desired functionality!


__Xcode Build Settings:__

This project was developed on the following configuration:
```
Xcode 11.3
macOS 10.15
swift 5
```
It has been optimized to be able to deploy to the following targets: 10.15, 10.14 and 10.13. You can change the deployment target under the general tab of the project settings.

<br><a href="https://ibb.co/MNH1F6S"><img src="https://i.ibb.co/F71YRV3/build.jpg" alt="build" border="0" /></a>


__How to Fix "App is Damaged & Can't Be Opened" Message:__
<br><a href="https://imgbb.com/"><img src="https://i.ibb.co/48B6tc7/damaged.jpg" alt="damaged" border="0" /></a>

After downloading the app and attempting to run one of the binaries, you might get a message stating that the app is damaged and can't be opened, with macOS offering to move it to the trash. This is just a signing issue. If you build the app from source on your own machine you won't experience this issue.

To Fix the Binary, run the following command in terminal (assuming your app is installed in the Applications folder):
```
sudo xattr -rd com.apple.quarantine /Applications/EFI\ Patcher.app
```

or just type:
```
sudo xattr -rd com.apple.quarantine 
```
into the terminal and then drag and drop the app into the terminal window. Hit enter and viola!

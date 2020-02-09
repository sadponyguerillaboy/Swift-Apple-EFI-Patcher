# Swift-Apple-EFI-Patcher
Apple EFI Patcher written in Swift with Flashrom integration. This application was developed out of a need for a simple user-friendly and native macOS based approach to working with Apple EFI roms. The result is a an all-in-one application that can utilize affordable SPI / eeprom chip reader hardware to read/dump from, patch and write to EFI Rom chips. EFI Patcher integrates flashrom support to communicate with hardware, thus having the ability incorporating a lot of the methodologies and current hardware already utilized by technicians.


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


__Pre-Built Binary Downloads:__

![Click Here for Downloads](https://github.com/sadponyguerillaboy/Swift-Apple-EFI-Patcher/tree/master/binaries)


__Usage:__

After prerequisites have been setup and installed, you can either download a binary from the binary folder or build from source. Once you have downloaded or built EFI Patcher.App, just double click to run it. If on Catalina you may need to provide the utility with the necessary security clearances.


__Application Layout:__


__Dumping Utilities:__

<br><a href="https://ibb.co/4Rym3VT"><img src="https://i.ibb.co/GQwxN52/dump.jpg" alt="dump" border="0" /></a><br>

The top portion of the application window is utilized for EFI Chip reading / dumping processes. The first text field entitled "Flashrom Location" is for the location of your flashrom app. If you installed the most recent version with brew (which at the time this was written was v1.1) then you can just leave this field untouched. If left untouched, it will default to the brew install location. If you installed your flashrom to a different location, then you can enter the alternative path.

The next text field below entitled "Dump Location" is where the application will save the dumped EFI file. By default it will save to your desktop as "firmware_dump.bin".

The radio button entitled "Verify Dump" activates the verification process during EFI Dumping and is recommended to verify integtity of your dumps. Activating the verification process will extend the time of the dumping procedure.

The dropdown menu entitled "Programmer Type" allows you to select your programmer.

The dropdown menu entitled "Chip Type" allows you to select your EFI chip.

The "Dump" but initiates the dumping process.


Patching Utilities:
<br><a href="https://ibb.co/Tbh1zC6"><img src="https://i.ibb.co/HxgCmJ6/patch.jpg" alt="patch" border="0" /></a>

Console Output Window:
<br><a href="https://ibb.co/HCp7kPN"><img src="https://i.ibb.co/3vY1LFf/console.jpg" alt="console" border="0" /></a>

Bottom Buttons:
<br><a href="https://ibb.co/tMCDQcV"><img src="https://i.ibb.co/Y7jhP8H/bottombuttons.jpg" alt="bottombuttons" border="0" /></a>

Editing JSON Menu Lists:
<br><a href="https://imgbb.com/"><img src="https://i.ibb.co/xgKTGNn/json.jpg" alt="json" border="0" /></a>


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

Dumping Utilities:
<br><a href="https://ibb.co/4Rym3VT"><img src="https://i.ibb.co/GQwxN52/dump.jpg" alt="dump" border="0" /></a>

Patching Utilities:
<br><a href="https://ibb.co/Tbh1zC6"><img src="https://i.ibb.co/HxgCmJ6/patch.jpg" alt="patch" border="0" /></a>

Console Output Window:
<br><a href="https://ibb.co/HCp7kPN"><img src="https://i.ibb.co/3vY1LFf/console.jpg" alt="console" border="0" /></a>

Bottom Buttons:
<br><a href="https://ibb.co/tMCDQcV"><img src="https://i.ibb.co/Y7jhP8H/bottombuttons.jpg" alt="bottombuttons" border="0" /></a>

Editing JSON Menu Lists:
<br><a href="https://imgbb.com/"><img src="https://i.ibb.co/xgKTGNn/json.jpg" alt="json" border="0" /></a>


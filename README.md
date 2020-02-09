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

![Image of Dumping Utilities](https://raw.githubusercontent.com/sadponyguerillaboy/Swift-Apple-EFI-Patcher/master/images/dump.jpg)

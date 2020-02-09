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

__Usage:__

![GitHub Logo](https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.persofoto.com%2Fupload%2Fpassport-photo&psig=AOvVaw2CWiPbBjiYqZnnKW7hKk6z&ust=1581359727854000&source=images&cd=vfe&ved=0CAIQjRxqFwoTCJijs5mOxecCFQAAAAAdAAAAABAI)

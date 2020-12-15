# Swift-Apple-EFI-Patcher
Apple EFI Patcher written in Swift with Flashrom integration. This application was developed out of a need for a simple user-friendly and native macOS based approach to working with Apple EFI roms. The result is an all-in-one application capable of utilizing affordable SPI / eeprom chip reading hardware for reading/dumping from, patching and writing to EFI Rom chips. This application integrates flashrom support in order to communicate with hardware, thus incorporating a lot of the methodologies and current hardware already utilized by technicians.

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

This software was developed with the intention of utilizing widely available and cost effective USB based hardware in the $3-$15 range. This includes USB devices such as CH341a or FT2232H boards. These devices are natively supported by flashrom, so after installing flashrom with brew, no additional drivers or software is required to support these devices. With that said, other hardware compatible with flashrom may require specific drivers. For a complete list of the hardware supported by Flashrom, please refer to <a href="https://flashrom.org/Supported_hardware">flashrom's official supported hardware page</a>

<br><a href="https://ibb.co/SBhq43B"><img src="https://i.ibb.co/njHhNLj/hardware.jpg" alt="hardware" border="0" /></a>


__Usage:__

After prerequisites have been setup and installed, you can either download a binary from the binary folder or build from source. Once you have downloaded or built EFI Patcher.App, just double click to run it. If on Catalina you may need to provide the utility with the necessary security clearances. If you receive a message stating "App is Damaged & Can't Be Opened", please scroll to the bottom of the readme for the fix.


__Application Layout:__

Initial Setup:

The first thing to do is setup the flashrom configuration. Click "EFI Patcher" from the overhead menu and then select "preferences" from the drop down.
<br><a href="https://imgbb.com/"><img src="https://i.ibb.co/WpxMDWN/menu.jpg" alt="menu" border="0" /></a>

The preferences pane has two items that need to be set in order for the flashrom components of the application to function correctly. If you only intend to use the patching function on files acquired from alternate sources, then the configuration is not necessary.

<br><a href="https://ibb.co/DkxJSPx"><img src="https://i.ibb.co/82WCSnW/preferences.jpg" alt="preferences" border="0" /></a>

The first item is the location of your flashrom installation. If you installed flashrom using brew, then it is likely located in:
```
/usr/local/bin/flashrom
/usr/local/Cellar/flashrom/1.1/bin/flashrom
```
You will need to enter the full path to the flashrom app. The second item is the programmer configuration. The "Programmer Config" field is a ComboBox, so it provides both a dropdown selection menu and the ability to enter text manually. The drop down selection provides a basic list of programmers. Some programmers like the `ch341a_spi` only require what is provided in the dropdown, but others like the `buspirate_spi` may require specified port mappings and speed parameters. These may be entered into the text field manually.


Chip Reading Utilities:

<br><a href="https://ibb.co/8cqLWrP"><img src="https://i.ibb.co/PQKv7c1/read.jpg" alt="read" border="0" /></a><br>

The top portion of the application window is utilized for EFI Chip reading / dumping processes. The first checkbox enables the chip type argument used by flashrom. This was set as an optional choice, as flashrom has the ability to autodetect certain types of chips, where others require manual entry. The Chip Type selection is also a ComboBox, which provides a dropdown list of chips that can be selected, but also allows for manual entry should the chip you are looking for not be listed. The "Save Location" text field is the location that any extracted data will be saved. By default this is `/Users/<your_username>/Desktop/firmware_dump.bin` This may be altered to any location of your choosing.

The "Verify" checkbox activates the verification process during EFI dumping and is recommended to verify the integtity of your extracted files. Note that activating the verification process will extend the time of the extraction procedure.

The "Read" button initiates the extraction process.

Please note that while reading or writing, the application may appear to be frozen, but it's just waiting for the flashrom task to complete and send it's console output back to the application.


Patching Utilities:

<br><a href="https://ibb.co/Tbh1zC6"><img src="https://i.ibb.co/HxgCmJ6/patch.jpg" alt="patch" border="0" /></a>

The patching portion of the application window is where you can edit your EFI dump. If you obtained your EFI using the extraction utility above, then the "Original EFI File" text field will auto-populate with the location of the extracted file. If you already have a dumped EFI file you wish to modify, then you can either type the path into the "Original EFI File" field, or you can click the "Open" button and choose the file, which will in turn auto-populate the "Original EFI File" field.

The four checkboxes activate each of the patching processes and should be pretty self explanatory.

To patch the serial number, click the "Change Serial Number" checkbox and enter a new 12 character serial number of your choosing.

To clean the ME Region, click the "Clean ME Region" checkbox, and either manually enter the path to the ME Region file or click the open button and select the file, which will in turn auto-populate the ME Region File path field.

To Remove firmware locks, click the "Remove Firmware Lock" checkbox. This will fill the $SVS region with 0xFF.

To Clear NVRAM, click the "Clear NVRAM' checkbox. This will fill the first $VSS region with 0xFF.

Once patching selections have been made. Click the "Patch' button below.


Console Output Window:
<br><a href="https://ibb.co/HCp7kPN"><img src="https://i.ibb.co/3vY1LFf/console.jpg" alt="console" border="0" /></a>

The console output portion of the application is where you will receive feedback on the various processes taking place. 


Bottom Buttons:
<br><a href="https://ibb.co/tMCDQcV"><img src="https://i.ibb.co/Y7jhP8H/bottombuttons.jpg" alt="bottombuttons" border="0" /></a>

The three buttons at the bottom of the application window should be fairly straight forward. "Reset" resets all user input selections and returns everything back to its original default settings. "Patch" initiates the patching process once you have made your selections above. The patching process will create a patched file with the same name as the original dumped file and created a backup of the original file with the appended ".bak" extension in the filename. The "Write" button will write the patched EFI back onto the chip. The write function searches for a file with the name equal to that of the dumped and patched file, meaning that this utility can act as a gui for flashrom as well if all you wish to do is write rom files to chip.

Editing JSON Menu Lists:

<a href="https://imgbb.com/"><img src="https://i.ibb.co/xgKTGNn/json.jpg" alt="json" border="0" /></a>

This application was designed with the intention of utilizing cost effective USB based chip readers such as CH341a or FT2232H based boards. During this application's inception, it was realized that attempting to account for the multitude of hardware and chip types currently in use as well as the future needs of users would be impossible. To allow for future customizations, the list of programmer and chip types are stored in JSON files inside the application. To edit these files, simply right click on the application, select "show package contents" and navigate to the JSON files in the Resources folder. Just edit the files and append your additions following the JSON format. Your additions will then become available in the programmer and chip type selection menus upon next restart. Note that if your programmer requires more complex usage, you can also change the value in the JSON file to reflect those needs.


__Program Flow:__

The program works in the following fashion. It reads the file from a chip and saves to disk, or alternatively it can just open a local file from disk. Then if the user presses the patch button, it reads that data into a variable, creates a backup of the original EFI as filename + ".bak", then patches the data and overwrites the original file. When the write button is clicked, it looks for the original filename. This methodology allows the application to also double as just a GUI for flashrom.

__Crashes:__

The application has basic error handling, but there are instances where corrupted files or fresh .fd files lacking the necessary regions being patched can cause errors. If you run into issues, make sure the efi rom you are working with is good.


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

<a href="https://imgbb.com/"><img src="https://i.ibb.co/48B6tc7/damaged.jpg" alt="damaged" border="0" /></a>

After downloading the app and attempting to run one of the binaries, you might get a message stating that the app is damaged and can't be opened, with macOS offering to move it to the trash. This is just a signing issue. If you build the app from source on your own machine you won't experience this issue.

To Fix the Binary, run the following command in terminal (assuming your app is installed in the Applications folder):
```
sudo xattr -rd com.apple.quarantine /Applications/EFI\ Patcher.app
```

or just type:
```
sudo xattr -rd com.apple.quarantine 
```
in terminal and then drag and drop the app into the terminal window. Hit enter and viola!

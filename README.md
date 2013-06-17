# Wizfrk Converter Script

Convert your downloads easily and autonomisly.

Wizfrk Converter Script is a Windows batch script that autonosly handles media file conversion to the most widely accepted formats, allowing for easy access on multiple platforms.

## Install
You can install the script either by:

* Downloading the [archive](https://github.com/wizfrk/converter/archive/master) from GitHub.
* Extracting the contents to your chosen folder

or

* Checkout the source: `git clone git://github.com/wizfrk/converter.git` from GitHub.
* Alternatively if you have  "Git for Windows" use the "Clone in Windows" button on Github.

The script then can be run directly or by integrating it with 3rd party programs.

Additionally you can create some shortcuts to help you with using the program.

* One your desktop to drag and drop files to.
* One with `update` added to the end of the Target, to make updating easy.
* One with `Run` set to `Minimized` for automated tasks.

## Usage

You can drag and drop files and folders to `converter.bat` or to its shortcut. When using the command line simply:

`C:\>[path to script]\converter.bat [path to file or folder] [file or folder] ...`

The script identifies the files and determines an action to take, any conversion files are saved to the same directory as the source file.

**WARNING** By default the script is set to go through all subfolders and files if a folder is inputed. If you don't want to convert everything just select the file you want and drag them to the script.

## Automating

The script can be automated via other programs, so far I have tried [uTorrent](http://www.utorrent.com/) and Windows Task Manager.

### Utorrent
Go to Options>Preferences>Advanced>Run Program>Run this program when a torrent finishes:

`"[path to script or 'Minized' shortcut]" -t "%D" "%F"`

Alternatively this is supposed to
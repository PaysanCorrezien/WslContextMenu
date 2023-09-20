# NNN Context Menu for WSL


🚧 This project is a still work in progress. It's only working in wsl debian for now

A context menu for the NNN file manager running in WSL that offers a range of file operations, including copying paths to clipboard, opening files, and more.

## 🔍  Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Features](#features)
- [Optional Features](#optional-features)
- [Usage](#usage)
- [Customization](#customization)
- [TODO](#todo)
- [Contributing](#contributing)
- [License](#license)

## ✅ Prerequisites

- **WSL (Windows Subsystem for Linux)**: Ensure that WSL is installed and set up on your machine.
- **NNN File Manager**: This script is designed to work with the NNN file manager.
- **PowerShell**: Some functionalities use PowerShell scripts, so make sure PowerShell is installed.
- **fzf**: This script uses `fzf` for its menu system, ensure `fzf` is installed.
- **BurntToast PowershellModule** (Optional) for system notification

## 🚩 Installation

1. Clone the repository:

    ```bash
    git clone paysancorrezien/wslcontextmenu
    ```

2. Copy the script and the `wsl` folder to the NNN plugins directory:

    ```bash
    cp wslcontextmenu/wsl_contextmenu ~/.config/nnn/plugins/
    cp -r wslcontextmenu/wsl ~/.config/nnn/plugins/
    ```

## 🌟 Features

- **Copy Paths**: Easily copy file paths to your clipboard in both Windows and Linux format.
- **File Execution**: Open files using their default application in Windows.
- **Open in Explorer**: Directly navigate to the file's location in Windows Explorer.
- **Drag And Drop**: Copy file (copy file on explorer equivalent), usefull for Web form, Chat apps.
- **File Properties**: Open the properties window for the file.
- **Editor Support**: Open files in a specified text editor (configurable).
- **Notifications**: Receive notifications for certain operations.

## Optional Features

- **Notifications**: This feature requires the PowerShell BurntToast module [Github](https://github.com/Windos/BurntToast) . Make sure to install it for notification support.
Launch powershell as admins and run  : 
```powershell
Install-Module -Name BurntToast -Scope AllUsers
```

## 💪 Usage

1. Export the plugin variable in your `.zshrc`:

    ```bash
    export NNN_PLUG='m:wsl_contextmenu'
    ```

    For more details, refer to the [NNN Wiki on Plugins](https://github.com/jarun/nnn/tree/master/plugins).

2. Run the script from within NNN or directly from the terminal, passing the filename as an argument:

    ```bash
    ~/.config/nnn/plugins/wsl_contextmenu filename
    ```

Use the `fzf` menu to select the desired action.

## 🪐 Customization

To customize the script to your liking, you can modify several variables and functions:

- **Text Editor**: Change the `NEOVIM` variable to the path of your preferred text editor.
- **Drive Mapping**: Edit the `drive_map` associative array if you have additional drives to map between Windows and Linux.
- **New Features**: Add new menu items and corresponding actions in the `case` statement.

## 💦 TODO

- remove all log message ( the powershell one !!)
- Implement real-time file synchronization.
- Add more file operations like emailing, sharing, etc.
- Fix known bugs (e.g., CTRL+C issue on the properties window).
- Change the dragdrop to allow multi file select (another script ?)
- Clean the code 

## 🚁 Tips

### Install
To install `nnn` on wsl debian just use : 
```bash
sudo apt update
sudo apt-get install pkg-config libreadline-dev
cd ~ # or any dir like ~/repo/ 
git clone https://github.com/jarun/nnn.git
cd nnn
# Apply the patch to restorepreview (usefull with vim and tmux)
patch -p1 < patches/restorepreview/mainline.diff
# Compile nnn with custom flags gitstatus and nerdfonts enable 
make O_NERD=1 O_GITSTATUS=1
# Replace the system-wide installation of nnn with the custom build
sudo cp ./nnn /usr/local/bin/nnn
# Install nnn plugins :
sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"
```
### 💀 Symlink

Symlink on linux are not detected by Windows correctly, we cant symlink the repo to ~/.config/nnn/plugins/' 

## 💖 Contributing

If you have suggestions or improvements, feel free to open an issue or submit a pull request.

## 🏛️License  
This project is licensed under the MIT License. See the `LICENSE` file for details.


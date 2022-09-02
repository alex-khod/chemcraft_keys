# Chemcraft Keys
[![en](https://img.shields.io/badge/lang-en-green.svg)](README.md)
[![ru](https://img.shields.io/badge/lang-ru-red.svg)](README.ru.md)

Autohotkey script that adds hotkey to save current simulation in multiple palettes/display modes ("Basic", "Publication", etc.).

Comes with GUI that allows to select palettes and define hotkey. Remembers chosen settings in INI file.

Images will be saved in `7000x[aspect]` resolution and .jpg format.

Saved filename format is inferred as `[main window title]_[step№ from abstract tab, if present]_[palette name].jpg`.

Any pre-existing image will be rewritten.
  
Tested with chemcraft **version 1.8**, possible but not guaranteed to work with other versions.
  
# Usage
Download "current" version 1.1.x of [autohotkey](https://www.autohotkey.com) and launch the `chemcraft.ahk`, the GUI should come up.

**OR**

Use standalone .exe provided from ["Releases"](https://github.com/alex-khod/chemcraft_keys/releases) section.

# Implementation details
When hotkey is pressed, "Chemcraft" main window must be focused. Main window is found as "chemcraft.exe" window, so if .exe was renamed, hotkey won't work.
The script will attempt click through "File" and "Display" menu elements, choose the palette and save the image.

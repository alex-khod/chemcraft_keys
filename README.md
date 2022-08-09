# Chemcraft Keys
Autohotkey script that adds hotkey to save current simulation in multiple palettes/display modes ("Basic", "Publication", etc.).

Comes with GUI that allows to select palettes and define hotkey. Remembers chosen settings in INI file.

Images will be saved in 7000x<aspect> resolution and .jpg format.

Saved filename format is inferred as [main window title]\_[step№ from abstract tab, if present]\_[palette name].jpg.

Any pre-existing image will be rewritten.

# Implementation details
When hotkey is pressed, "Chemcraft" main window must be focused. Main window is found as "chemcraft.exe" window, so if .exe was renamed, hotkey won't work.
The script will attempt click through "File" and "Display" menu elements, choose the palette and save the image.








global MainFormWinTitle := "ahk_class TMainForm ahk_exe chemcraft.exe"
global SavePictureWinTitle := "ahk_class TSavepicturedialog ahk_exe chemcraft.exe"
global SaveWinTitle := "ahk_class #32770 ahk_exe chemcraft.exe"
global SaveRewriteWinTitle := "Chemcraft ahk_class #32770 ahk_exe chemcraft.exe"

;wait_Timeout := -60000 ;ms
wait_Timeout := "Off" ;forever
wait_IsLooping := 0

menu_y0 := 10
menu_elem_height := 22

display_modes := ["Basic 1","Basic 2"
,"CPK coloring 1 (dark background)","CPK coloring 2 (dark background)"
,"Simple","Big atoms","Sticks","Thin sticks"
,"Publication 1","Publication 2","Publication 3"
,"2d style 1 (with all H atoms)"
,"2d style 2 (with all H except attached to carbons)"
,"2d style 3 (without H atoms)"
,"2d style 4 (same with separate fragments like NO2)"
,"2d style 5 (same with CH2 labels visible)"
,"2d style 6 (same with C, CH labels visible)"
,"2d style 7 (same as 3 but with all labels on carbons)"
,"Quick","GaussView style","Hyperchem style","Spartan style"]

display_modes_short := ["basic1","basic2"
,"CPK1","CPK2"
,"simple","big_atoms","sticks","thin_sticks"
,"publication1","publication2","publication3"
,"2d_1"
,"2d_2"
,"2d_3"
,"2d_4"
,"2d_5"
,"2d_6"
,"2d_7"
,"quick","gaussView","hyperchem","spartan"]

dmode := 1
display_modes_enabled := []
display_modes_count := display_modes_short.length()
loop, %display_modes_count%
    display_modes_enabled.push(0)

initGui:
    Gui, StylesGui:New,, Chemcraft Keys 1.0.0
    if activeSaveAllHotkey
    Hotkey %activeSaveAllHotkey%, SaveEachDisplayMode, Off
    IniRead, activeSaveAllHotkey, chemcraft_keys.ini, General, SaveAllHotkey, !^s
    Hotkey %activeSaveAllHotkey%, SaveEachDisplayMode, On
    Gui, Add, Text,, Сохранять в палитрах:
    for k, v in display_modes
    {
        IniRead, CheckedValue, chemcraft_keys.ini, General, DisplayCheck%k%, 0
        Gui, Add, Checkbox, gUpdateDisplayList vDisplayCheck%k% Checked%CheckedValue%, %v%
    }
    Gui, Add, Button, gUnsetAll, Выключить все
    Gui, Add, Button, gSetAll, Включить все
    Gui, Add, Text,, Горячая клавиша для сохранения:
    Gui, Add, Hotkey, vSaveAllHotkey gUpdateSaveAllHotkey, %activeSaveAllHotkey%
    Gui, Show
return

StylesGuiGuiClose:
ExitApp
return
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#include chemcraft_hdr.ahk

#IfWinActive ahk_exe chemcraft.exe

;SetTitleMatchMode, 2
;SetTitleMatchMode, Slow

#include chemcraft_keys.ahk

TimedTooltip(text, timeout){
    Tooltip, %text%
    SetTimer, tooltip_clear, -%timeout%
    return
    tooltip_clear:
    Tooltip
    return
}

UpdateSaveAllHotkey(){
    global activeSaveAllHotkey
    GuiControlGet, SaveAllHotkey,, % A_GuiControl
    if not SaveAllHotkey
        return
    ;Tooltip, %SaveAllHotkey%
    Hotkey %activeSaveAllHotkey%,, Off
    Try {
        Hotkey %SaveAllHotkey%, SaveEachDisplayMode, On
        IniWrite, %SaveAllHotkey%, chemcraft_keys.ini, General, SaveAllHotkey
        activeSaveAllHotkey := SaveAllHotkey
    }
}

SaveEachDisplayMode(){
    global display_modes

    if not IsWinActive(MainFormWinTitle)
        return

    active_modes := 0
    for k, v in display_modes
    {
        GuiControlGet, CheckedValue, StylesGui:, DisplayCheck%k%
        if not CheckedValue
            continue
        active_modes += 1
        SetDisplayMode(k)
        Tooltip, Saving...
        Sleep, 32
        InvokeSave()

        WaitUntilActive(MainFormWinTitle)
        is_active := IsWinActive(MainFormWinTitle)
        if not is_active {
                TimedTooltip("Wait-for-save timed out", 5000)
                return
        }
    }
    if not active_modes
        InvokeSave()
    TimedTooltip("Done!", 5000)
}

UpdateDisplayList(){
    ; Remember contents of StylesGui window
    GuiControlGet, CheckedValue, StylesGui:, % A_GuiControl
    IniWrite, %CheckedValue%, chemcraft_keys.ini, General, % A_GuiControl

    ;DisplayModesEnabled[Ind := StrReplace(A_GuiControl, "DisplayCheck")] := %CheckedValue%
    ;CheckboxVariableName := "DisplayCheck"
    ;display_no := StrReplace(A_GuiControl, CheckboxVariableName)
    ;GuiControl, +Checked, DisplayCheck1, 1
    ;tooltip, %A_GuiControl% %display_no% %CheckedValue%
}

TrySetControl()
{
    ; Unused. Can't find a way to set CheckBox state.
    ; That is, except 1) rebuilding window with new control 2) simulating clicks
    GuiControl, +Checked, DisplayCheck1
    GuiControl, +Checked, DisplayCheck1, 1
    GuiControl, +Checked0, DisplayCheck1
    GuiControl, +Checked0, DisplayCheck1, 1
}

UnsetAll(){
    global display_modes
    for k, v in display_modes
    {
        ;GuiControlGet, CheckedValue, StylesGui:, DisplayCheck%k%
        IniWrite, 0, chemcraft_keys.ini, General, DisplayCheck%k%
    }
    gosub initGui
}

SetAll(){
    global display_modes
    for k, v in display_modes
    {
        ;GuiControlGet, CheckedValue, StylesGui:, DisplayCheck%k%
        IniWrite, 1, chemcraft_keys.ini, General, DisplayCheck%k%
    }
    gosub initGui
}

CountActiveDisplayModes(){
    global display_modes_short
    active := 0
    for k, v in display_modes_short
    {
        GuiControlGet, CheckedValue, StylesGui:, DisplayCheck%k%
        if CheckedValue
        active += 1
    }
    return active
}

DumpDisplayModes(){
    global display_modes_short
    out := ""
    for k, v in display_modes_short
    {
        GuiControlGet, CheckedValue, StylesGui:, DisplayCheck%k%
        out .= "#" . k . " " . v "=" . CheckedValue . "`n"
    }
    TimedTooltip(out, 5000)
}

InvokeSave()
{
    is_save_picture_init := IsSavePictureInit()
    if (is_save_picture_init > 0) {
        ShowSavePicture()
    } else {
        SaveFileMenuClick()
    }
    SavePictureSetImageWidth()
    SavePictureHitSave()
    HideSavePicture()
    SaveSetFilename()
    SaveHitSave()
    HandleRewrite()
    return
}

SetDisplayMode(idx)
{
    global dmode
    dmode := idx
    GetDisplayButtonCenter(x, y)
    Click %x%, %y%
    Sleep, 32
    global menu_y0
    global menu_elem_height
    ; calculate center of display mode button button
    idx -= 1
    y += menu_y0 + menu_elem_height * idx + menu_elem_height // 2
    Click %x%, %y%
    return
}

SaveFileMenuClick()
{
    global menu_y0
    global menu_elem_height

    WinGet, main_hwnd, ID, A

    ;click File button, open menu
    GetFileButtonCenter(x0, y0)
    Click %x0%, %y0%
    Sleep, 128

    ;small nudge to move to the menu
    dy := menu_y0 + menu_elem_height // 2

    ;move to Save button
    menu_elem_idx := 5
    x1 := x0
    y1 := y0 + menu_elem_height * menu_elem_idx
    Click %x1%, %y1%, 0
     Sleep, 1024

    ;read menu size
    MouseGetPos,dumx,dumy, menu_hwnd
    WinGetPos, dumx, dumy, w, h, ahk_id %menu_hwnd%

    ;move to Save Image button
    menu_elem_idx := 8
    dx := 20
    x2 := x1 + w + dx
    y2 := y1 + menu_elem_height * menu_elem_idx
    Click %x2%, %y2%

    WaitUntilActive(SavePictureWinTitle)
    return
}

WaitUntilActive(wintitle)
{
    global wait_Timeout
    global wait_IsLooping
    SetTimer , Timeout, %wait_Timeout%
    wait_IsLooping := 1
    ticks := 0
    Loop
    {
        is_active := IsWinActive(wintitle)
        ticks += 1
        if is_active
            break
        if not wait_IsLooping
            break
    }
    Timeout:
    wait_IsLooping := 0
    SetTimer , Timeout, Off
    ;Tooltip, wait ticks %ticks%, 120, 50
    return
}

IsWinActive(wintitle)
{
    WinGet, active_id, ID, A
    WinGet, main_id, ID, %wintitle%
    res := 0
    if (active_id == main_id)
        res := 1
    return res
}

HandleRewrite(){
    rewrite_hwnd := 0
    WinGet, rewrite_hwnd, Id, %SaveRewriteWinTitle%
    if rewrite_hwnd > 0
    {
        SaveButtonClass = Button1
        ControlFocus, %SaveButtonClass%, %SaveRewriteWinTitle%
        SaveRewriteWinTitle := "Chemcraft ahk_class #32770 ahk_exe chemcraft.exe"
        Send, {Space}
        Sleep, 32
    }
}

SavePictureSetImageWidth(){
    global SavePictureTitle
    WidthEdit = TEdit4
    ControlSetText, %WidthEdit%, 7000, %SavePictureWinTitle%
    Sleep, 32
    return
}

SavePictureHitSave(){
    SaveButtonClass = TButton2
    ControlFocus, %SaveButtonClass%, %SavePictureWinTitle%
    Send, {Space}
    Sleep, 256
    return
}

SaveSetFilename(){
    global dmode
    filename := GetFinalFilename()
    tooltip, Saving as %filename%...
    FilenameEdit = Edit1
    ControlSetText, %FilenameEdit%, %filename%, %SaveWinTitle%
    return
}

SaveHitSave(){
    SaveButtonClass = Button2
    ControlFocus, %SaveButtonClass%, %SaveWinTitle%
    Send, {Space}
    Sleep, 256
    return
}

IsSavePictureInit()
{
    ; Check if save window was invoked by user/script click so TEdit4 is now visible on form
    DetectHiddenWindows, On
    WinGet, ctrlList, ControlList, %SavePictureWinTitle%
    DetectHiddenWindows, Off
    res := 0
    if ctrlList contains TEdit4
        res := 1
    return res
}

ShowSavePicture()
{
    DetectHiddenWindows, On
    WinShow, %SavePictureWinTitle%
    DetectHiddenWindows, Off
;    Control, Show,,, %SavePictureWinTitle%
;    Doesn't help to make button working. It's not disabled it's just doesn't work on show.
;    Maybe it's callback isn't bound?
;    CancelButton = TButton1
;    Control, Enable,, %CancelButton%, %SavePictureWinTitle%
;    Control, Disable,, %CancelButton%, %SavePictureWinTitle%
    return
}

HideSavePicture()
{
    WinHide, %SavePictureWinTitle%
    WinActivate, %MainFormWinTitle%
    return
}

GetFinalFilename(){
    global display_modes_short
    global dmode
    filename := GetFilenameFromTitle() . "_"
    step := GetStepFromAbstract()
    if step
        filename .= "step" . step . "_"
    filename .= display_modes_short[dmode] . ".jpg"
    tooltip, %filename%
    return filename
}

GetFileNameFromTitle()
{
    WinGetTitle, title, %MainFormWinTitle%
    filename := StrSplit(title, " - ")
    filename := filename[1]
    return filename
}

GetStepFromAbstract()
{
    MemoClass = TMemo2
    ControlGetText, memoText, %MemoClass%, %MainFormWinTitle%
    ; Documentation example. Step should be "XYZ", but is "abcXYZ123" instead. Funny that
    ; RegexMatch("abcXYZ123", "O)abc(.*)123", step)

    ; parse step
    ; find Match object O)
    ; that is one or more digits (\d+)
    ; preceded by word Step and zero or more whitespace characters \s*
    RegExMatch(memoText, "O)Step\s*(\d+)", step)
    step := step.Value(1)
    Tooltip, %step%
    return step
}

ControlGetText, OutputVar , Control, WinTitle

GetFileButtonCenter(byRef x, byRef y)
{
    global MainFormTitle
    ; Get dimensions for TToolbar1 that hosts the button
    ControlGetPos, tbx, tby, w, h, TToolbar1, %MainFormWinTitle%
    ; Calculate button center
    display_btn_client_x := 25
    x := tbx + display_btn_client_x
    y := tby + h // 2
    ;ToolTip, X%x%`tY%y%, 120, 50
    return
}

GetDisplayButtonCenter(byRef x, byRef y)
{
    ; Get dimensions for TToolbar1 that hosts the button
    ControlGetPos, tbx, tby, w, h, TToolbar1, %MainFormWinTitle%
    ; Calculate button center
    display_btn_client_x := 185
    x := tbx + display_btn_client_x
    y := tby + h // 2
    ;ToolTip, X%x%`tY%y%, 120, 50
    return
}

DumpWindowAtMousePos()
{
    MouseGetPos , mx, my, hwnd, control
    WinGetTitle, title, ahk_id %hwnd%
    WinGetClass, cls, ahk_id %hwnd%
    WinGet, style, Style , ahk_id %hwnd%
    phwnd := DllCall("GetParent", Ptr, %hwnd%)
    ListWindowsByWinTitle(wndList, "ahk_class " . cls)
    WinGet, ctrllisthwnds, ControlListHwnd , ahk_id %hwnd%

    ControlCount := 0
    Loop, Parse, ctrllisthwnds, "`n"
        ControlCount += 1

    tooltiptext .= wndList
    tooltiptext := "id " . hwnd . " parent " . phwnd . "`n"
    tooltiptext .= "title " . title . "`n"
    tooltiptext .= "style " . style . "`n"
    tooltiptext .= "cls " . cls . " - " . control . " @ " . mx . " " . my . "`n"
    tooltiptext .= wndList . "`n"
    tooltiptext .= "control count=" . ControlCount
    ;tooltiptext .= "Controls `n" . ctrllisthwnds
    ;id %wnd% parent %cwnd% `n title %title% `n style %style% `n cls %cls% - %control% @ %mx% %my% `n%wndList%

    Tooltip, %tooltiptext%
    return
}

ListWindowsByWinTitle(byRef out, wintitle){
    ; obtain hwnd of all visible windows in form of wndlist1, wndlist2 .. wndlistx, wndlist = x
    ; id = ahk_exe chemcraft.exe
    WinGet, wndlist, List, %wintitle%
    ; list hwnds
    out := "List of " . wintitle . "`n"
    out := out . "Count " . wndlist . "`n"
    Loop, %wndlist%
    {
        out := out . A_Index . " - " . wndlist%A_Index% . " `n"
    }
    return
}

_RecursiveShowControls(hwnd){
    ; Try to show all controls of parent hwnd recursively
    WinGet, ctrllisthwnds, ControlListHwnd , ahk_id %hwnd%
    Loop, Parse, ctrllisthwnds, % "`n"
    {
        Control, Show,,,ahk_id %A_LoopField%
        _RecursiveShowControls(%A_LoopField%)
    }
}

_ShowWindowAttempts()
{
    ;unused
;    res := DllCall("ShowWindow", Ptr, hwnd, Int, 1)
    ;res := DllCall("PostMessage", Int, %hwnd%, Int, 5, Int, %hwnd%, Int, 5)
    ;(WM_SHOWWINDOW = 0x18)
    PostMessage, 0x18, 1, 0,,ahk_id %hwnd%
    ;WM_SYSCOMMAND = 0x0112, SC_RESTORE = 0xF120
    PostMessage, 0x0112, 0xF120,0,,ahk_id %hwnd%
    WinShow, ahk_id %hwnd%
    WinHide, ahk_id %hwnd%
}

_GetChildControl()
{
    ; unused
    ; Try to get child button from a toolbar, doesn't work
    MouseGetPos, mx, my, pwnd, control
    ; pwnd is now toolbar's handle
    cwnd := DllCall("ChildWindowFromPoint", Int, %pwnd%, Int, %mx%, Int,%my%)
    ; call returns 0. cwnd is invalid, so doesn't work
    Tooltip, %cwnd% - %controL% @ %mx% %my%, 120, 50
    return
}

_GetParent()
{
    ; unused
    ; try to get window's parent
    MouseGetPos , mx, my, pwnd, control
    ;cwnd := DllCall("ChildWindowFromPoint", Int, %pwnd%, Int, %mx%, Int,%my%)
    cwnd := DllCall("GetParent", UInt, %pwnd%)
    Tooltip, %cwnd% @ %mx% %my%, 120, 50
    return
}
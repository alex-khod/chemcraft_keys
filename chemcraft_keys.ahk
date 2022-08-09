; #MaxThreadsPerHotkey 2
debug := 0

#if, debug
e::
{
    ;SaveEachDisplayMode()
    InvokeSave()
    return
}

w::
{
;    ShowSavePicture()
    DumpDisplayModes()
;    TrySetControl()
    return
}

d::
{
;    HideSavePicture()
    return
}

f::
{
    DumpWindowAtMousePos()
    return
}

g::
{
    ;GetFinalFilename()
    return
}

#IfWinActive
#if, debug

#g:: ; press win+g to reload
  Tooltip, Reloading..., 300, 10
  Sleep, 300
  Reload
  return

#IfWinActive
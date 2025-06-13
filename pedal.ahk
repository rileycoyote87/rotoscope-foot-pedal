#Requires AutoHotkey v2.0
#SingleInstance Force
#Include Lib\AutoHotInterception.ahk

vid := 0x0426
pid := 0x3011

AHI := AutoHotInterception()
keyboardId := AHI.GetKeyboardId(vid, pid)
if (keyboardId = 0) {
    MsgBox("Could not find keyboard with VID " vid " PID " pid)
    ExitApp()
}

cm := AHI.CreateContextManager(keyboardId)

ClearToolTip() {
    ToolTip()
}

lastTapTime := 0
doubleTapThreshold := 400  ; ms
tapCount := 0

#HotIf cm.IsActive

1::
{
    global lastTapTime, doubleTapThreshold, tapCount

    currentTime := A_TickCount
    if (currentTime - lastTapTime <= doubleTapThreshold) {
        tapCount++
    } else {
        tapCount := 1
    }

    lastTapTime := currentTime

    if (tapCount = 2) {
        ToolTip("Double tap detected! Sending PageUp x10")
        SetTimer(ClearToolTip, -1000)
        Loop 10 {
            Send("{PgUp}")
            Sleep 50
        }
        tapCount := 0  ; reset after double tap
    } else {
        ; Delay the single tap action to confirm it’s not a double tap
        SetTimer(HandleSingleTap, -doubleTapThreshold)
    }
    return
}

HandleSingleTap() {
    global tapCount
    if (tapCount = 1) {
        ToolTip("Single tap! Sending PageDown x10")
        Loop 10 {
            Send("{PgDn}")
            Sleep 50
        }
    }
    tapCount := 0
    SetTimer(ClearToolTip, -1000)
}

1 up::
{
    ToolTip("Pedal released")
    SetTimer(ClearToolTip, -500)
    return
}

#HotIf

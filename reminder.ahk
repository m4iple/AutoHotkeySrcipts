#Requires AutoHotkey v2.0

; Reminder Script with Interval Notifications
; Hotkey -> GUI with end time and interval selection
; Starts timer that shows confirmation boxes at each interval
; Opening hotkey cancels running timer

; Global variables
timerActive := false
reminderTimer := 0
endTime := ""
intervalMinutes := 0

!+r::ToggleReminder()  ; ALT+Shift+R


ToggleReminder() {
    if (timerActive) {
        CancelTimer()
        MsgBox("Reminder timer has been cancelled.", "Reminder", "0x40")
    } else {
        ShowReminderGui()
    }
}

ShowReminderGui() {
    ui := Gui("+AlwaysOnTop", "Reminder Timer")

    ui.Add("Text", "x10 y10", "End Time:")
    dtPicker := ui.AddDateTime("x10 y30 w200", "yyyy-MM-dd HH:mm:ss")

    defaultEndTime := DateAdd(A_Now, 1, "Hours")
    dtPicker.Value := defaultEndTime

    ui.Add("Text", "x10 y65", "Reminder Interval:")
    intervalDrop := ui.Add("DropDownList", "x10 y85 w100", ["15 minutes", "30 minutes", "1 hour", "1.5 hours", "2 hours"])
    intervalDrop.Choose(2)  ; Default to 30 minutes

    startBtn := ui.Add("Button", "x10 y120 w80 h30", "Start")
    cancelBtn := ui.Add("Button", "x100 y120 w80 h30", "Cancel")

    startBtn.OnEvent("Click", (*) => StartReminder(dtPicker.Value, intervalDrop.Value))
    cancelBtn.OnEvent("Click", (*) => ui.Destroy())
    
    ui.Show()

    StartReminder(selectedEndTime, selectedInterval) {
        global timerActive, endTime, intervalMinutes, reminderTimer

        intervalMap := [15, 30, 60, 90, 120]  ; minutes for each dropdown option
        intervalMinutes := intervalMap[selectedInterval]

        endTime := selectedEndTime

        currentTime := A_Now
        totalMinutes := DateDiff(endTime, currentTime, "Minutes")
        
        if (totalMinutes <= 0) {
            MsgBox("End time must be in the future!", "Error", "0x10")
            return
        }

        ui.Destroy()
        timerActive := true

        reminderTimer := SetTimer(ShowReminderPopup, intervalMinutes * 60000)  ; Convert to milliseconds

        SetTimer(ShowEndTimePopup, totalMinutes * 60000)
        
        MsgBox("Reminder started! Next reminder in " . intervalMinutes . " minutes.`nEnd time: " . FormatTime(endTime, "yyyy-MM-dd HH:mm:ss"), "Reminder Active", "0x40")
    }
}

CancelTimer() {
    global timerActive, reminderTimer
    
    if (reminderTimer) {
        SetTimer(reminderTimer, 0)
        reminderTimer := 0
    }
    
    timerActive := false
}

ShowReminderPopup() {
    global timerActive, endTime, intervalMinutes
    
    if (!timerActive) {
        return
    }
    
    currentTime := A_Now
    timeRemaining := DateDiff(endTime, currentTime, "Minutes")

    if (timeRemaining <= 0) {
        ShowEndTimePopup()
        return
    }

    result := MsgBox("Reminder: " . timeRemaining . " minutes remaining until " . FormatTime(endTime, "HH:mm:ss") . "`n`nNext reminder in " . intervalMinutes . " minutes.", "Interval Reminder", "0x40")
}

ShowEndTimePopup() {
    global timerActive
    
    CancelTimer()
    
    MsgBox("Time's up! Your reminder period has ended.`n`nCurrent time: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss"), "Reminder Complete", "0x40")
}
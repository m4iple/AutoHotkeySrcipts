#Requires AutoHotkey v2.0

; V1 of a Discord Date Time Selecter and Formatter
; Inspiration from the Apple Shortcut Discord_Time_Code
; TODO Modifi the Date Selection to make it more intuitive and better


; Create the GUI function
ShowDatePicker() {
    MyGui := Gui("+AlwaysOnTop", "Discord Date Formater")
    
    ; DateTime picker
    dtPicker := MyGui.AddDateTime("w320", "yyyy-MM-dd HH:mm")
    
    ; Radio buttons for format selection
    MyGui.Add("GroupBox", "x10 y50 w320 h190", "Format Options") 
    rb1 := MyGui.Add("Radio", "x20 y80 checked", "Long date and Time (" FormatTime(dtPicker.Value, "dddd, MMMM d, yyyy 'at' h:mm tt") ")") ; Saturday, February 8, 2025 at 5:31 PM
    rb2 := MyGui.Add("Radio", "x20 y100", "Short date and time (" FormatTime(dtPicker.Value, "MMMM d, yyyy 'at' h:mm tt") ")") ; February 8, 2025 at 5:32 PM
    rb3 := MyGui.Add("Radio", "x20 y120", "Long date (" FormatTime(dtPicker.Value, "MMMM d, yyyy") ")") ; February 8, 2025
    rb4 := MyGui.Add("Radio", "x20 y140", "Short date (" FormatTime(dtPicker.Value, "M/d/yy") ")") ; 2/8/25
    rb5 := MyGui.Add("Radio", "x20 y160", "Long time (" FormatTime(dtPicker.Value, "h:mm:ss tt") ")") ; 5:33:03 PM
    rb6 := MyGui.Add("Radio", "x20 y180", "Short time (" FormatTime(dtPicker.Value, "h:mm tt") ")") ; 5:33 PM
    rb7 := MyGui.Add("Radio", "x20 y200", "Relative time (15 Seconds ago)")

    ; Copy button
    btnProcess := MyGui.Add("Button", "x60 y215 w120", "Copy Date")
    btnProcess.OnEvent("Click", ProcessDate)
    
    MyGui.Show()
    
    ; Procces the selected Date and copy it to the Clipboard
    ProcessDate(*) {
        date := dtPicker.Value
        unixTime := GetUnixTime(date)

        if rb1.Value {
            formatted := "<t:" unixTime ":F>"
        } else if rb2.Value {
            formatted := "<t:" unixTime ":f>"
        } else if rb3.Value {
            formatted := "<t:" unixTime ":D>"
        } else if rb4.Value {
            formatted := "<t:" unixTime ":d>"
        } else if rb5.Value {
            formatted := "<t:" unixTime ":T>"
        } else if rb6.Value {
            formatted := "<t:" unixTime ":t>"
        } else if rb7.Value {
            formatted := "<t:" unixTime ":R>"
        }
        
        A_Clipboard := formatted
        Send(formatted)
        MyGui.Destroy()
    }

    UpdateLabels(date) {
        unixTime := GetUnixTime(date)
        formatDate := FormatTime(date)
        
        rb1.Text := "Long date and Time (" FormatTime(date, "dddd, MMMM d, yyyy 'at' h:mm tt") ")"
        rb2.Text := "Short date and time (" FormatTime(date, "MMMM d, yyyy 'at' h:mm tt") ")"
        rb3.Text := "Long date (" FormatTime(date, "MMMM d, yyyy") ")"
        rb4.Text := "Short date (" FormatTime(date, "M/d/yy") ")"
        rb5.Text := "Long time (" FormatTime(date, "h:mm:ss tt") ")"
        rb6.Text := "Short time (" FormatTime(date, "h:mm tt") ")"
        rb7.Text := "Relative time"
    }

    UpdateLabels(dtPicker.Value)
    dtPicker.OnEvent("Change", (*) => UpdateLabels(dtPicker.Value))
}

; Formant a Human Time to an Unix Timestamp
GetUnixTime(date) {
    epoch := "19700101000000"
    diff := DateDiff(date, epoch, "Seconds")
    return diff
}

!+d::ShowDatePicker()  ; ALT+Shift+D

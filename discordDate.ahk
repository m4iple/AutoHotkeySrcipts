#Requires AutoHotkey v2.0

; V1 of a Discord Date Time Selecter and Formatter
; Inspiration from the Apple Shortcut Discord_Time_Code
; TODO Modifi the Date Selection to make it more intuitive and better


; Create the GUI function
ShowDatePicker() {
    MyGui := Gui("+AlwaysOnTop", "Discord Date Formater")
    
    ; DateTime picker
    dtPicker := MyGui.Add("DateTime", "w220", "yyyy-MM-dd HH:mm")
    
    ; Radio buttons for format selection
    MyGui.Add("GroupBox", "x10 y50 w220 h190", "Format Options")
    rb1 := MyGui.Add("Radio", "x20 y80 checked", "Long date and Time")
    rb2 := MyGui.Add("Radio", "x20 y100", "Short date and time")
    rb3 := MyGui.Add("Radio", "x20 y120", "Long date")
    rb4 := MyGui.Add("Radio", "x20 y140", "Short date")
    rb5 := MyGui.Add("Radio", "x20 y160", "Long time")
    rb6 := MyGui.Add("Radio", "x20 y180", "Short time")
    rb7 := MyGui.Add("Radio", "x20 y200", "Relative time")

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
}

; Formant a Human Time to an Unix Timestamp
GetUnixTime(date) {
    epoch := "19700101000000"
    diff := DateDiff(date, epoch, "Seconds")
    return diff
}

!+d::ShowDatePicker()  ; ALT+Shift+D

#Requires AutoHotkey v2.0

; V1.1 of a Discord Date Time Selector and Formatter
; Inspiration from the Apple Shortcut Discord_Time_Code
; Function "DateToUTC" was written by AI

!+d::ShowDatePicker()  ; ALT+Shift+D

; Create the GUI function
ShowDatePicker() {
    MyGui := Gui("+AlwaysOnTop", "Discord Date Formatter")
    
    ; DateTime picker
    dtPicker := MyGui.AddDateTime("w340", "'Date:' yyyy-MM-dd 'Time:' hh:mm:ss tt")
    
    ; Radio buttons for format selection
    MyGui.Add("GroupBox", "x10 y40 w340 h160", "Format Options (Preview may differ from Discord)") 
    rb1 := MyGui.Add("Radio", "x20 y60 w320 checked", "Long date and Time ( " FormatTime(dtPicker.Value, "dddd, MMMM d, yyyy 'at' h:mm tt") " )") ; Saturday, February 8, 2025 at 5:31 PM
    rb2 := MyGui.Add("Radio", "x20 y80 w320", "Short date and time ( " FormatTime(dtPicker.Value, "MMMM d, yyyy 'at' h:mm tt") " )") ; February 8, 2025 at 5:32 PM
    rb3 := MyGui.Add("Radio", "x20 y100 w320", "Long date ( " FormatTime(dtPicker.Value, "MMMM d, yyyy") " )") ; February 8, 2025
    rb4 := MyGui.Add("Radio", "x20 y120 w320", "Short date ( " FormatTime(dtPicker.Value, "M/d/yy") " )") ; 2/8/25
    rb5 := MyGui.Add("Radio", "x20 y140 w320", "Long time ( " FormatTime(dtPicker.Value, "h:mm:ss tt") " )") ; 5:33:03 PM
    rb6 := MyGui.Add("Radio", "x20 y160 w320", "Short time ( " FormatTime(dtPicker.Value, "h:mm tt") " )") ; 5:33 PM
    rb7 := MyGui.Add("Radio", "x20 y180 w320", "Relative time ( " FormatRelativeTime(dtPicker.Value) " ) ") ; in 10 hours

    ; Copy button
    btnProcess := MyGui.Add("Button", "x10 y210 w340", "Copy")
    btnProcess.OnEvent("Click", ProcessDate)
    
    MyGui.Show()
    
    ; Process the selected Date and copy it to the Clipboard
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

        rb1.Text := "Long date and Time ( " FormatTime(date, "dddd, MMMM d, yyyy 'at' h:mm tt") " )"
        rb2.Text := "Short date and time ( " FormatTime(date, "MMMM d, yyyy 'at' h:mm tt") " )"
        rb3.Text := "Long date ( " FormatTime(date, "MMMM d, yyyy") " )"
        rb4.Text := "Short date ( " FormatTime(date, "M/d/yy") " )"
        rb5.Text := "Long time ( " FormatTime(date, "h:mm:ss tt") " )"
        rb6.Text := "Short time ( " FormatTime(date, "h:mm tt") " )"
        rb7.Text := "Relative time ( " FormatRelativeTime(date) " )"
    }

    UpdateLabels(dtPicker.Value)
    dtPicker.OnEvent("Change", (*) => UpdateLabels(dtPicker.Value))
}

; Formant a Human Time to an Unix Timestamp
GetUnixTime(date) {
    utcDate  := DateToUTC(date)
    epoch := "19700101000000"
    unixTime := DateDiff(utcDate, epoch, "Seconds")
    return unixTime
}

; Convert local time to UTC considering DST for specific date (AI code)
DateToUTC(localTime) {
    ; Create SYSTEMTIME structures for local and UTC time
    localST := Buffer(16, 0)
    utcST := Buffer(16, 0)

    ; Fill local SYSTEMTIME
    NumPut("UShort", SubStr(localTime, 1, 4), localST, 0)   ; year
    NumPut("UShort", SubStr(localTime, 5, 2), localST, 2)   ; month
    NumPut("UShort", 0, localST, 4)                         ; wDayOfWeek (ignored)
    NumPut("UShort", SubStr(localTime, 7, 2), localST, 6)   ; day
    NumPut("UShort", SubStr(localTime, 9, 2), localST, 8)   ; hour
    NumPut("UShort", SubStr(localTime, 11, 2), localST, 10) ; minute
    NumPut("UShort", SubStr(localTime, 13, 2), localST, 12) ; second
    NumPut("UShort", 0, localST, 14)                       ; milliseconds

    ; Convert local time to UTC
    DllCall("kernel32\TzSpecificLocalTimeToSystemTime", "Ptr", 0, "Ptr", localST, "Ptr", utcST)

    ; Read UTC SYSTEMTIME
    utcYear := Format("{:04}", NumGet(utcST, 0, "UShort"))
    utcMonth := Format("{:02}", NumGet(utcST, 2, "UShort"))
    utcDay := Format("{:02}", NumGet(utcST, 6, "UShort"))
    utcHour := Format("{:02}", NumGet(utcST, 8, "UShort"))
    utcMinute := Format("{:02}", NumGet(utcST, 10, "UShort"))
    utcSecond := Format("{:02}", NumGet(utcST, 12, "UShort"))

    ; Format UTC time as YYYYMMDDHHMMSS
    utcTimeStr := utcYear . utcMonth . utcDay . utcHour . utcMinute . utcSecond

    return utcTimeStr
}

; Format Preview Time into the Discord Relative Time Format
FormatRelativeTime(date) {
    now := A_Now
    text := 'Error'

    diff := DateDiff(date, now, 'Seconds')
    isFuture := diff > 0
    absSeconds := Abs(diff)

    if(absSeconds < 60){
        unit := Pluralize(absSeconds, 'second')
        text := FormatRelativeTimeHelper(absSeconds, isFuture, unit)
    } else if(absSeconds < 3600){
        minutes := Floor(absSeconds / 60)
        unit := Pluralize(minutes, 'minute')
        text := FormatRelativeTimeHelper(minutes, isFuture, unit)
    } else if(absSeconds < 86400){
        hours := Floor(absSeconds / 3600)
        unit := Pluralize(hours, 'hour')
        text := FormatRelativeTimeHelper(hours, isFuture, unit)
    } else {
        diffDays := Floor(absSeconds / 86400)
        if(diffDays == 1){
            if (isFuture){
                text := 'tomorrow'
            }else{
                text := 'yesterday'
            }
        }else if(diffDays < 30){
            text := FormatRelativeTimeHelper(diffDays, isFuture, 'days')
        }else{
            months := Floor(diffDays / 30)
            if(months < 12) {
                unit := Pluralize(months, 'month')
                text := FormatRelativeTimeHelper(months, isFuture, unit)
            }else{
                years := Floor(months / 12)
                unit := Pluralize(years, 'year')
                text := FormatRelativeTimeHelper(years, isFuture, unit)
            }
        }
    }
    return text
}

; Helper to pluralize words
Pluralize(count, word){
	return word . (count != 1 ? "s" : "")
}

; Helper to Format Relative Time Text
FormatRelativeTimeHelper(time, isFuture, unit){
    if(isFuture){
        text := 'in ' . time . ' ' . unit
    }else{
        text := time . ' ' . unit . ' ago'
    }
    return text
}
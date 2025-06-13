#Requires AutoHotkey v2.0

; GUI
; Formats a human time (YYYY-MM-DD HH:mm:ss) to unix time
; Formats a unix time to human time (YYYY-MM-DD HH:mm:ss)
; Buttons copy the result to clipboard
;
; Testing if the local date to UTC function is needed

!+t::ShowUi()  ; ALT+Shift+T

ShowUi() {
    utcTime := ""
    localTime := ""
    unixTime := ""
    inputTimer := 0

    ui := Gui("+AlwaysOnTop", "Timestamp Converter")
    ui.add("GroupBox", "w200 h44", "Input Time")
    input := ui.Add("Edit", "x20 y20 w180", "")
    utcToggle := ui.Add("CheckBox", "x165 y1 w40 h20", "UTC")
    ui.add("GroupBox", "w200 h44 x9", "Timestamp")
    unixButton := ui.Add("Button", "x20 y70 w180 h20", "Timestamp")
    ui.add("GroupBox", "w200 h44 x9", "UTC")
    utcButton := ui.Add("Button", "x20 y120 w180 h20", "UTC")
    ui.add("GroupBox", "w200 h44 x9", "Local")
    localButton := ui.Add("Button", "x20 y170 w180 h20", "Local")

    ui.Show()

    _ProcessInputHandler() {
        results := HandleUserInput(input.Value, utcToggle.Value)
        unixTime := results.unix
        utcTime := results.utc
        localTime := results.local
        unixButton.Text := results.unix
        utcButton.Text := results.utc
        localButton.Text := results.local
    }

    _HandleInputChange(*) {
        if (inputTimer) { 
            SetTimer(inputTimer, 0) 
        }
        inputTimer := SetTimer(_ProcessInputHandler, -500)
    }

    _handleToggleChange(*) {
        _ProcessInputHandler()
    }

    input.OnEvent("Change", _HandleInputChange)
    utcToggle.OnEvent("Click", _handleToggleChange)
    unixButton.OnEvent("Click", (*) => A_Clipboard := unixTime)
    utcButton.OnEvent("Click", (*) => A_Clipboard := utcTime)
    localButton.OnEvent("Click", (*) => A_Clipboard := localTime)
}


; Handles user input
HandleUserInput(input, isUtc := false) {
    if (input = "") {
        return {unix: "Timestamp", utc: "UTC", local: "Local"}
    }
    try {
        if RegExMatch(input, "^\d+$") {
            ahkTime := GetAhkTimeFromUnix(input)
            utcTime := FormatTime(ahkTime, "yyyy-MM-dd HH:mm:ss")
            localTime := FormatTime(UTCToLocal(ahkTime), "yyyy-MM-dd HH:mm:ss")
            return {unix: input, utc: utcTime, local: localTime}
        }else if RegExMatch(input, "^\d{4}-\d{2}-\d{2}(\s\d{2}:\d{2}(:\d{2})?)?$") {
            ahkTime := GetAhkTimeFromHuman(input)
            if(isUtc) {
                unixTime := GetUnixTimefromAhk(ahkTime)
                utcTime := FormatTime(ahkTime, "yyyy-MM-dd HH:mm:ss")
                localTime := FormatTime(UTCToLocal(ahkTime), "yyyy-MM-dd HH:mm:ss")
            } else {
                utcAhk := LocalToUTC(ahkTime)
                unixTime := GetUnixTimefromAhk(ahkTime)
                utcTime := FormatTime(utcAhk, "yyyy-MM-dd HH:mm:ss")
                localTime := FormatTime(ahkTime, "yyyy-MM-dd HH:mm:ss")
            }
            return {unix: unixTime, utc: utcTime, local: localTime}
        } else {
            return {unix: "Invalid", utc: "Invalid", local: "Invalid"}
        }
    } catch Error as e {
        return {unix: "Invalid", utc: "Invalid", local: "Invalid"} 
    }
}

; Formant a AhK to an Unix Timestamp
GetUnixTimefromAhk(date) {
    ; utcDate  := DateToUTC(date)
    utcDate := date
    epoch := "19700101000000"
    unixTime := DateDiff(utcDate, epoch, "Seconds")
    return unixTime
}

; Format Unix Timestamp to AHK (YYYYMMDDHH24MISS)
GetAhkTimeFromUnix(unixTime) {
    if (StrLen(unixTime) = 13) {
        unixTime := unixTime / 1000
    }
    
    epoc := "19700101000000"
    ahkTime := DateAdd(epoc, unixTime, "Seconds")
    return ahkTime
}

; Formant Human Time to AHK (YYYYMMDDHH24MISS)
GetAhkTimeFromHuman(human) {
   if REGEXMatch(human, "(\d{4})-(\d{2})-(\d{2})(\s(\d{2}):(\d{2})(:(\d{2}))?)?", &match) {
        year := match[1]
        month := match[2]
        day := match[3]
        hour := match[5] ? match[5] : "00"
        minutes := match[6] ? match[6] : "00"
        seconds := match[8] ? match[8] : "00"
        return year . month . day . hour . minutes . seconds
    }
}

; Convert local time to UTC considering DST for specific date (AI code)
LocalToUTC(localTime) {
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

; Convert UTC time to Local considering DST for specific date
UTCToLocal(utcTime) {
    utcST := Buffer(16, 0)
    localST := Buffer(16, 0)

    NumPut("UShort", SubStr(utcTime, 1, 4), utcST, 0)   ; year
    NumPut("UShort", SubStr(utcTime, 5, 2), utcST, 2)   ; month
    NumPut("UShort", 0, utcST, 4)                       ; wDayOfWeek (ignored)
    NumPut("UShort", SubStr(utcTime, 7, 2), utcST, 6)   ; day
    NumPut("UShort", SubStr(utcTime, 9, 2), utcST, 8)   ; hour
    NumPut("UShort", SubStr(utcTime, 11, 2), utcST, 10) ; minute
    NumPut("UShort", SubStr(utcTime, 13, 2), utcST, 12) ; second
    NumPut("UShort", 0, utcST, 14)                      ; milliseconds

    DllCall("kernel32\SystemTimeToTzSpecificLocalTime", "Ptr", 0, "Ptr", utcST, "Ptr", localST)

    localYear := Format("{:04}", NumGet(localST, 0, "UShort"))
    localMonth := Format("{:02}", NumGet(localST, 2, "UShort"))
    localDay := Format("{:02}", NumGet(localST, 6, "UShort"))
    localHour := Format("{:02}", NumGet(localST, 8, "UShort"))
    localMinute := Format("{:02}", NumGet(localST, 10, "UShort"))
    localSecond := Format("{:02}", NumGet(localST, 12, "UShour"))

    localTimeStr := localYear . localMonth . localDay . localHour . localMinute . localSecond

    return localTimeStr
}
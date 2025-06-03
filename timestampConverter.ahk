#Requires AutoHotkey v2.0

; GUI -> Text input, Button to copy unix, Button to copy human time
; Formats a human time (YYYY-MM-DD HH:mm:ss) to unix time -> handle unexpected formats
; Formats a unix time to human time (YYYY-MM-DD HH:mm:ss) -> handle unexpected formats
; Copies the result to clipboard

!+t::ShowUi()  ; ALT+Shift+T

ShowUi() {
    ui := Gui("+AlwaysOnTop", "Timestamp Converter")
    input := ui.Add("Edit", "w300 h30", "Enter date/time (YYYY-MM-DD HH:mm:ss or timestamp)")
    unixButton := ui.Add("Button", "w150 h30", "Unix Timestamp")
    humanButton := ui.Add("Button", "w150 h30", "Human Time")

    ui.Show()


}



; Handles user input
HandleUserInput(input) {
    ; input can be (YYYY-MM-DD HH:mm:ss) or a timestamp
    ; check type -> check expected format
    ; reforamt into both formats
    ; populate the buttons with the results ? global variables for later easy access?
}

; Formant a AhK to an Unix Timestamp
GetUnixTimefromAhk(date) {
    utcDate  := DateToUTC(date)
    epoch := "19700101000000"
    unixTime := DateDiff(utcDate, epoch, "Seconds")
    return unixTime
}

; Format Unix Timestamp to AHK (YYYYMMDDHH24MISS)
GetAhkTimeFromUnix(unixTime) {
    epoc := "19700101000000"
    akkTime := DateAdd(epoc, unixTime, "Seconds")
    return akkTime
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
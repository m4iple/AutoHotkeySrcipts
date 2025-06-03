#Requires AutoHotkey v2.0

; GUI
; Formats a human time (YYYY-MM-DD HH:mm:ss) to unix time
; Formats a unix time to human time (YYYY-MM-DD HH:mm:ss)
; Buttons copy the result to clipboard
;
; Testing if the local date to UTC function is needed

!+t::ShowUi()  ; ALT+Shift+T

ShowUi() {
    humanTime := ""
    unixTime := ""
    inputTimer := 0

    ui := Gui("+AlwaysOnTop", "Timestamp Converter")
    ui.add("GroupBox", "w200 h44", "Input Time")
    input := ui.Add("Edit", "x20 y20 w180", "")
    unixButton := ui.Add("Button", "x9 y50 w100 h30", "Unix")
    humanButton := ui.Add("Button", "x110 y50 w100 h30", "Human")

    ui.Show()

    _ProcessInputHandler() {
        results := HandleUserInput(input.Value)
        unixTime := results.unix
        humanTime := results.human
        unixButton.Text := results.unix
        humanButton.Text := results.human
    }

    _HandleInputChange(*) {
        if (inputTimer) { 
            SetTimer(inputTimer, 0) 
        }
        inputTimer := SetTimer(_ProcessInputHandler, -500)
    }

    input.OnEvent("Change", _HandleInputChange)
    unixButton.OnEvent("Click", (*) => A_Clipboard := unixTime)
    humanButton.OnEvent("Click", (*) => A_Clipboard := humanTime)
}


; Handles user input
HandleUserInput(input) {
    try {
        if RegExMatch(input, "^\d+$") {
            ahkTime := GetAhkTimeFromUnix(input)
            humanTime := FormatTime(ahkTime, "yyyy-MM-dd HH:mm:ss")
            return {unix: input, human: humanTime}
        }else if RegExMatch(input, "^\d{4}-\d{2}-\d{2}(\s\d{2}:\d{2}(:\d{2})?)?$") {
            ahkTime := GetAhkTimeFromHuman(input)
            unixTime := GetUnixTimefromAhk(ahkTime)
            return {unix: unixTime, human: input}
        } else {
            return {unix: "Invalid", human: "Invalid"}
        }
    } catch Error as e {
        return {unix: "Invalid", human: "Invalid"}
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
    epoc := "19700101000000"
    akkTime := DateAdd(epoc, unixTime, "Seconds")
    return akkTime
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
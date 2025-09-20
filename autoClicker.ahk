#Requires AutoHotkey v2.0

; Auto Clicker with GUI
; ALT+Shift+A to show/hide GUI

; Global variables
loopBool := false
delay := 50
guiObj := ""
statusText := ""
delayText := ""
startBtn := ""
stopBtn := ""

!+a::ToggleGui()  ; ALT+Shift+A

ToggleGui() {
    global guiObj, loopBool
    if (guiObj && guiObj.Hwnd) {
        guiObj.Destroy()
        guiObj := ""
    } else {
        ; Stop any active clicking when opening the GUI
        loopBool := false
        ShowAutoClickerGui()
    }
}

ShowAutoClickerGui() {
    global guiObj, statusText, delayText, startBtn, stopBtn, loopBool, delay
    
    guiObj := Gui("+AlwaysOnTop", "Auto Clicker longer Text So its wider/*  */")
    
    guiObj.Add("Text", "x10 y10", "Status:")
    statusText := guiObj.Add("Text", "x60 y10 w100", loopBool ? "Running" : "Stopped")
    
    guiObj.Add("Text", "x10 y35", "Delay:")
    delayText := guiObj.Add("Text", "x60 y35 w60", delay . "ms")
    
    decreaseBtn := guiObj.Add("Button", "x10 y55 w30 h25", "-10")
    increaseBtn := guiObj.Add("Button", "x45 y55 w30 h25", "+10")
    
    decreaseSlowBtn := guiObj.Add("Button", "x80 y55 w30 h25", "-100")
    increaseSlowBtn := guiObj.Add("Button", "x115 y55 w30 h25", "+100")

    startBtn := guiObj.Add("Button", "x10 y90 w60 h30", "Start")
    stopBtn := guiObj.Add("Button", "x75 y90 w60 h30", "Stop")

    startBtn.OnEvent("Click", (*) => StartClicking())
    stopBtn.OnEvent("Click", (*) => StopClicking())
    decreaseBtn.OnEvent("Click", (*) => AdjustDelay(-10))
    increaseBtn.OnEvent("Click", (*) => AdjustDelay(10))
    decreaseSlowBtn.OnEvent("Click", (*) => AdjustDelay(-100))
    increaseSlowBtn.OnEvent("Click", (*) => AdjustDelay(100))
    
    guiObj.Show()
    UpdateGuiStatus()
}

StartClicking() {
    global loopBool
    loopBool := true
    UpdateGuiStatus()
}

StopClicking() {
    global loopBool
    loopBool := false
    UpdateGuiStatus()
}

AdjustDelay(amount) {
    global delay
    delay += amount
    if (delay < 10) {
        delay := 10  ; Minimum delay
    }
    UpdateGuiStatus()
}

UpdateGuiStatus() {
    global statusText, delayText, loopBool, delay, guiObj
    if (guiObj && guiObj.Hwnd && statusText && delayText) {
        try {
            statusText.Text := loopBool ? "Running" : "Stopped"
            delayText.Text := delay . "ms"
        }
    }
}

while true{
	while loopBool
	{
		Click
		Sleep delay
		
		; Update GUI status if GUI exists
		UpdateGuiStatus()
	}
}
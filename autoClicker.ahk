#Requires AutoHotkey v2.0

; Press p to activate the Auto Clicker
; Press l to stop
; Press o to slow down the Clicker by 10 milliseconds
; Press i to speed up the Clicker by 10 milliseconds

loopBool := false
delay := 10

while true{
	if (GetKeyState("p"))
	{
		loopBool := true
	}

	while loopBool
	{
		Click
		Sleep delay
		if (GetKeyState("l"))
		{
			loopBool := false
		}
		if (GetKeyState("o"))
		{
			delay := delay + 10
		}
		if (GetKeyState("i"))
		{
			delay := delay - 10
		}
	}
}
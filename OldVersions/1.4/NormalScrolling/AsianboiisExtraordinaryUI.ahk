










































































































































































WheelDown::
	if (GetKeyState("CapsLock", "P"))
	{
		MoveBrightness(-1)
		isscrolled := 1
	}
	else
	{
		Send {WheelDown}
	}
return

WheelUp::
	if (GetKeyState("CapsLock", "P"))
	{
		MoveBrightness(-1)
		isscrolled := 0
	}
	else
	{
		Send {WheelUp}
	}
return


;================================================================================================================
;================================================================================================================
;	ASIANBOII'S EXTRAORDINARY KEYBOARD
;================================================================================================================
;================================================================================================================

; <COMPILER: v1.0.48.5>

#MaxHotkeysPerInterval 2147483647

SendMode Input

capsdown := 0
otherkeydown := 0

CapsLock::
	capsdown := 1
	otherkeydown := 0
return

isscrolled := 0

CapsLock Up::
	capsdown := 0
	;MsgBox, %otherkeydown%
	if (otherkeydown = 0 && !isscrolled) {
		if (GetKeyState("CapsLock", "T"))
			SetCapsLockState, On
		else
			SetCapsLockState, Off 
	}
	otherkeydown = 0
	isscrolled = 0
return


u::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Home}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "U" : "u"
	}
return
i::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Up}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "I" : "i"
	}
return
o::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {End}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "O" : "o"
	}
return

j::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Left}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "J" : "j"
	}
return
k::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Down}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "K" : "k"
	}
return
l::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Right}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "L" : "l"
	}
return

m::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Home}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "M" : "m"
	}
return
,::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {End}
	} else {
		SendInput, ","
	}
return


BackSpace::
	Suspend, Permit
	if (capsdown)
	{
		Send, {Blind}{Delete}
		otherkeydown := 1
	}
	else
	{
		Send, {Blind}{BackSpace}
	}
return

qwerty := 0

*Ctrl::
	Suspend, Permit
	if (GetKeyState("CapsLock", "T") && GetKeyState("Shift", "P")) {
		Winset, Alwaysontop, , A
		return
	}
	;Send {Blind}{Ctrl DownTemp}
	SetKeyDelay, -1
	Send {Blind}{Ctrl Down}
	Suspend On
	;MsgBox, ctrl down! %qwerty%
return

*Ctrl up::
	Suspend Off
	SetKeyDelay -1
	Send {Blind}{Ctrl Up}
	;MsgBox, ctrl up! %qwerty%
	if (qwerty = 1)
		Suspend On
return

*Alt::
	Suspend, Permit
	SetKeyDelay -1
	Send {Blind}{Alt Down}
	Suspend On
return

*Alt up::
	Suspend Off
	SetKeyDelay -1
	Send {Blind}{Alt Up}
	if (qwerty = 1)
		Suspend On
return

*LWin::
	Suspend, Permit
	SetKeyDelay -1
	Send {Blind}{LWin Down}
	Suspend On
return

*LWin up::
	Suspend Off
	SetKeyDelay -1
	Send {Blind}{LWin Up}
	if (qwerty = 1)
		Suspend On
return

*RWin::
	Suspend, Permit
	SetKeyDelay -1
	Send {Blind}{RWin Down}
	Suspend On
return

*RWin up::
	Suspend Off
	SetKeyDelay -1
	Send {Blind}{RWin Up}
	if (qwerty = 1)
		Suspend On
return

RShift Up::
	Suspend, Permit
	if (A_IsSuspended = 1)
	{
		if (barelySuspended != 0)
			barelySuspended := 0
		else
			Toggle()
	}
	SetKeyDelay -1
	Send {Blind}{LShift Up}
return

; THIS ONE BELOW CAUSES RIGHT-SHIFT TO TOGGLE only WHEN NO KEY IS PRESSED WHILE RIGHT-SHIFT
; IS PRESSED DOWN
RShift & SC029:: 
	Suspend, Permit
	SendInput ~
return

RShift::
	Suspend, Permit
	;MsgBox, RSHIFT!! %A_IsSuspended%
	if (A_IsSuspended = 0)
	{
		Toggle()
		barelySuspended := 1
	}
	else
	{
		Send {Blind}{LShift Down}
	}
	SetKeyDelay -1
	Send {Blind}{RShift Up}
return


*ScrollLock::
	Suspend, Permit
	Toggle()
return

Toggle() {
	if (A_IsSuspended = 0)
		qwerty := 1
	else
		qwerty := 0
	
	;MsgBox, %qwerty%
	
	Suspend, toggle
	
}






















































;================================================================================================================
;================================================================================================================
;	VOLUME MOUSE WHEEL
;================================================================================================================
;================================================================================================================


+WheelDown::
+WheelUp::
   ; get the current volume
   SoundGet, volval
   
   ; determine if we should add or subtract
   if (InStr(A_ThisHotkey, "down"))
      volval-=2
   Else
      volval+=2
   
   ; clamp the value between 0 and 100. Then set it.
   volval:=clamp(volval)
   SoundSet, volval
   
   ; display it and turn off the display
   MouseGetPos, mX, mY
   ToolTip % ASCIIBar(volval), %mX% + 30, %mY% - 50
   SetTimer, killtip, 1000
Return


killtip:
   ToolTip
   SetTimer, killtip, off
Return

Clamp(in, min=0, max=100)
{
   return ((in<min) ? min : (in>max) ? max : in)
}

ASCIIBar(Current, Max = 100, Length = 25, Empty = " ", Full = "!")
{
   ; Made by Bugz000 with assistance from tidbit, Chalamius and Bigvent
   ; modified by tidbit (Tue May 28, 2013)
   Loop % round((Current / Max) * Length, 0)
      Progress .= Full
   loop % round(Length - (Current / Max) * Length, 0)
      Progress .= Empty
   return "[" Progress "] " round(Current)
}











;############################################################################
; BRIGHTNESS
;############################################################################

MoveBrightness(IndexMove)
{

	VarSetCapacity(SupportedBrightness, 256, 0)
	VarSetCapacity(SupportedBrightnessSize, 4, 0)
	VarSetCapacity(BrightnessSize, 4, 0)
	VarSetCapacity(Brightness, 3, 0)
	
	hLCD := DllCall("CreateFile"
	, Str, "\\.\LCD"
	, UInt, 0x80000000 | 0x40000000 ;Read | Write
	, UInt, 0x1 | 0x2  ; File Read | File Write
	, UInt, 0
	, UInt, 0x3  ; open any existing file
	, UInt, 0
	  , UInt, 0)
	
	if hLCD != -1
	{
		
		DevVideo := 0x00000023, BuffMethod := 0, Fileacces := 0
		  NumPut(0x03, Brightness, 0, "UChar")   ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
		  NumPut(0x00, Brightness, 1, "UChar")      ; The AC brightness level
		  NumPut(0x00, Brightness, 2, "UChar")      ; The DC brightness level
		DllCall("DeviceIoControl"
		  , UInt, hLCD
		  , UInt, (DevVideo<<16 | 0x126<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS
		  , UInt, 0
		  , UInt, 0
		  , UInt, &Brightness
		  , UInt, 3
		  , UInt, &BrightnessSize
		  , UInt, 0)
		
		DllCall("DeviceIoControl"
		  , UInt, hLCD
		  , UInt, (DevVideo<<16 | 0x125<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS
		  , UInt, 0
		  , UInt, 0
		  , UInt, &SupportedBrightness
		  , UInt, 256
		  , UInt, &SupportedBrightnessSize
		  , UInt, 0)
		
		ACBrightness := NumGet(Brightness, 1, "UChar")
		ACIndex := 0
		DCBrightness := NumGet(Brightness, 2, "UChar")
		DCIndex := 0
		BufferSize := NumGet(SupportedBrightnessSize, 0, "UInt")
		MaxIndex := BufferSize-1

		Loop, %BufferSize%
		{
		ThisIndex := A_Index-1
		ThisBrightness := NumGet(SupportedBrightness, ThisIndex, "UChar")
		if ACBrightness = %ThisBrightness%
			ACIndex := ThisIndex
		if DCBrightness = %ThisBrightness%
			DCIndex := ThisIndex
		}
		
		if DCIndex >= %ACIndex%
		  BrightnessIndex := DCIndex
		else
		  BrightnessIndex := ACIndex

		BrightnessIndex += IndexMove
		
		if BrightnessIndex > %MaxIndex%
		   BrightnessIndex := MaxIndex
		   
		if BrightnessIndex < 0
		   BrightnessIndex := 0

		NewBrightness := NumGet(SupportedBrightness, BrightnessIndex, "UChar")
		
		NumPut(0x03, Brightness, 0, "UChar")   ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
        NumPut(NewBrightness, Brightness, 1, "UChar")      ; The AC brightness level
        NumPut(NewBrightness, Brightness, 2, "UChar")      ; The DC brightness level
		
		DllCall("DeviceIoControl"
			, UInt, hLCD
			, UInt, (DevVideo<<16 | 0x127<<2 | BuffMethod<<14 | Fileacces) ; IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS
			, UInt, &Brightness
			, UInt, 3
			, UInt, 0
			, UInt, 0
			, UInt, 0
			, Uint, 0)
		
		DllCall("CloseHandle", UInt, hLCD)
		
		; display it and turn off the display
		MouseGetPos, mX, mY
		ToolTip % ASCIIBar(BrightnessIndex, MaxIndex, MaxIndex), %mX% + 30, %mY% - 50
		SetTimer, killtip, 1000
	}

}


;================================================================================================================
;================================================================================================================
;	ADVANCED MOUSE WHEEL
;================================================================================================================
;================================================================================================================


/*
Limited SDownport, Documentation and Changelog: http://www.autohotkey.com/forum/viewtopic.php?t=83794

File structure

Settings
	-ahk script setting
	-save setings
	-reverse scroll settings
	-defaults method settings
	-app method settings
	-method counters
	-static system variables

External app settings retrieval

Suspend Hotkey
	-ScrollLock

SetDown HotKeys
	-WinKey + [Ctrl + Shift +]WheelDown
	-WinKey + [Ctrl + Shift +]WheelUp
	-WinKey + [Ctrl + Shift +]WheelRight
	-WinKey + [Ctrl + Shift +]WheelLeft

Main HotKeys
	-WheelDown
	-WheelUp
	-WheelRight
	-WheelLeft

Subs for the main hotkeys
	-Set_Method
	-Get_SBar_Info

Subs for the setDown hotkeys
	-TApp_Method_Settings
	-SAVEtoFILE
*/

#SingleInstance force
#NoEnv
#InstallMouseHook
#UseHook
Critical
SendMode Input
CoordMode, Mouse, Screen
SetScrollLockState, off
SetWorkingDir %A_ScriptDir%


;isScrolled := 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



WheelDown::
Suspend, Permit
SetKeyDelay, -1
;MsgBox, % isctrldown
;if (GetKeyState("Ctrl", "P") || GetKeyState("Alt", "P"))
;{
;	MsgBox, ctrl or alt down!
;	Send {Blind}{WheelDown}
;	return
;}
if (GetKeyState("Space", "P")) {
	Send {WheelLeft}
	Send {WheelLeft}
	isScrolled := 1
	return
}
if (capsdown = 1) {
	isScrolled := 1
	MoveBrightness(-1)
	return
}
   Critical
   MouseGetPos, x, y
   MouseGetPos,,,, Second_Try, 2
   MouseGetPos,,,, Third_Try, 3
   First_Try := DllCall("WindowFromPoint", "int", x, "int", y)
   Loop, 1
   {
      If(Second_Try = "")
         SendMessage, 0x20A, 120 << 17, (y << 16) | x,, ahk_id %First_Try%
      Else
      {
         SendMessage, 0x20A, 120 << 17, (y << 16) | x,, ahk_id %Second_Try%
         If(Second_Try != Third_Try)
            SendMessage, 0x20A, 120 << 17, (y << 16) | x,, ahk_id %Third_Try%
      }
   }
return

WheelUp::
Suspend, Permit
if (GetKeyState("Space", "P")) {
	Send  {WheelRight}
	Send  {WheelRight}
	isScrolled := 1
	return
}
if (capsdown = 1) {
	isScrolled := 1
	MoveBrightness(1)
	return
}
Critical
   MouseGetPos, x, y
   MouseGetPos,,,, Second_Try, 2
   MouseGetPos,,,, Third_Try, 3
   First_Try := DllCall("WindowFromPoint", "int", x, "int", y)
   Loop, 1
   {
      If(Second_Try = "")
         SendMessage, 0x20A, -120 << 17, (y << 16) | x,, ahk_id %First_Try%
      Else
      {
         SendMessage, 0x20A, -120 << 17, (y << 16) | x,, ahk_id %Second_Try%
         If(Second_Try != Third_Try)
            SendMessage, 0x20A, -120 << 17, (y << 16) | x,, ahk_id %Third_Try%
      }
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

global capsdown := 0
global otherkeydown := 0
global isctrldown := 0

CapsLock::
	capsdown := 1
	otherkeydown := 0
return

CapsLock Up::
	capsdown := 0
	if (otherkeydown == 0 && !isScrolled) {
		if (GetKeyState("CapsLock", "T") == 0)
			SetCapsLockState, On
		else
			SetCapsLockState, Off
	}
	isScrolled := 0
		
	;//// TESTING AREA ////
	
	;SoundBeep, 441, 1000
	
return

$space::
	if (!isScrolled)
		Send {Space}
	isScrolled := 0
return

1:: SendInput, % GetKeyState("CapsLock", "T") ? "1" : "<"
2:: SendInput, % GetKeyState("CapsLock", "T") ? "2" : ">"
3:: SendInput, % GetKeyState("CapsLock", "T") ? "3" : "{{}" 
4:: SendInput, % GetKeyState("CapsLock", "T") ? "4" : "{}}"
5:: SendInput, % GetKeyState("CapsLock", "T") ? "5" : "|"
6:: SendInput, % GetKeyState("CapsLock", "T") ? "6" : "{^}"
7:: SendInput, % GetKeyState("CapsLock", "T") ? "7" : "&"
8:: SendInput, % GetKeyState("CapsLock", "T") ? "8" : "*"
9:: SendInput, % GetKeyState("CapsLock", "T") ? "9" : "("
0:: SendInput, % GetKeyState("CapsLock", "T") ? "0" : ")"
-:: [
=:: ]
q:: '
w:: ,
e:: .
r:: p
t:: y
y:: f
u::
	if (capsdown == 1) {
		otherkeydown := 1
		Send ^{Left}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "G" : "g"
	}
return
i::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Up}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "C" : "c"
	}
return
o::
	if (capsdown == 1) {
		otherkeydown := 1
		Send ^{Right}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "R" : "r"
	}
return
p:: l
[:: /
]:: !
\:: @
a:: a
s:: o
d:: e
f:: u
g:: i
h:: d
j::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Left}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "H" : "h"
	}
return
k::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Down}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "T" : "t"
	}
return
l::
	if (capsdown == 1) {
		otherkeydown := 1
		Send {Right}
	} else {
		SendInput, % GetKeyState("CapsLock", "T") ? "N" : "n"
	}
return
SC027:: s
SC028:: SendInput, % GetKeyState("CapsLock", "T") ? "_" : "="
z:: SC027
x:: q
c:: j
v:: k
b:: x
n:: b
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
		SendInput, % GetKeyState("CapsLock", "T") ? "W" : "w"
	}
return
.:: v
/:: z

Space & SC029:: SendInput ~
Space & 1:: SendInput, % GetKeyState("CapsLock", "T") ? "<" : "1"
Space & 2:: SendInput, % GetKeyState("CapsLock", "T") ? ">" : "2"
Space & 3:: SendInput, % GetKeyState("CapsLock", "T") ? "{{}" : "3"
Space & 4:: SendInput, % GetKeyState("CapsLock", "T") ? "{}}" : "4"
Space & 5:: SendInput, % GetKeyState("CapsLock", "T") ? "|" : "5"
Space & 6:: SendInput, % GetKeyState("CapsLock", "T") ? "{^}" : "6"
Space & 7:: SendInput, % GetKeyState("CapsLock", "T") ? "&" : "7"
Space & 8:: SendInput, % GetKeyState("CapsLock", "T") ? "*" : "8"
Space & 9:: SendInput, % GetKeyState("CapsLock", "T") ? "(" : "9"
Space & 0:: SendInput, % GetKeyState("CapsLock", "T") ? ")" : "0"
Space & -:: SendInput `%
Space & =:: SendInput $
Space & q:: SendInput :
Space & w:: SendInput -
Space & e:: SendInput {+}
Space & r:: SendInput, % GetKeyState("CapsLock", "T") ? "p" : "P"
Space & t:: SendInput, % GetKeyState("CapsLock", "T") ? "y" : "Y"
Space & y:: SendInput, % GetKeyState("CapsLock", "T") ? "f" : "F"
Space & u:: SendInput, % GetKeyState("CapsLock", "T") ? "g" : "G"
Space & i:: SendInput, % GetKeyState("CapsLock", "T") ? "c" : "C"
Space & o:: SendInput, % GetKeyState("CapsLock", "T") ? "r" : "R"
Space & p:: SendInput, % GetKeyState("CapsLock", "T") ? "l" : "L"
Space & [:: SendInput \
Space & ]:: SendInput ?
Space & \:: SendInput {#}
Space & a:: SendInput, % GetKeyState("CapsLock", "T") ? "a" : "A"
Space & s:: SendInput, % GetKeyState("CapsLock", "T") ? "o" : "O"
Space & d:: SendInput, % GetKeyState("CapsLock", "T") ? "e" : "E"
Space & f:: SendInput, % GetKeyState("CapsLock", "T") ? "u" : "U"
Space & g:: SendInput, % GetKeyState("CapsLock", "T") ? "i" : "I"
Space & h:: SendInput, % GetKeyState("CapsLock", "T") ? "d" : "D"
Space & j:: SendInput, % GetKeyState("CapsLock", "T") ? "h" : "H"
Space & k:: SendInput, % GetKeyState("CapsLock", "T") ? "t" : "T"
Space & l:: SendInput, % GetKeyState("CapsLock", "T") ? "n" : "N"
Space & SC027:: SendInput, % GetKeyState("CapsLock", "T") ? "s" : "S"
Space & SC028:: SendInput, % GetKeyState("CapsLock", "T") ? "=" : "_"
Space & z:: SendInput " ;"
Space & x:: SendInput, % GetKeyState("CapsLock", "T") ? "q" : "Q"
Space & c:: SendInput, % GetKeyState("CapsLock", "T") ? "j" : "J"
Space & v:: SendInput, % GetKeyState("CapsLock", "T") ? "k" : "K"
Space & b:: SendInput, % GetKeyState("CapsLock", "T") ? "x" : "X"
Space & n:: SendInput, % GetKeyState("CapsLock", "T") ? "b" : "B"
Space & m:: SendInput, % GetKeyState("CapsLock", "T") ? "m" : "M"
Space & ,:: SendInput, % GetKeyState("CapsLock", "T") ? "w" : "W"
Space & .:: SendInput, % GetKeyState("CapsLock", "T") ? "v" : "V"
Space & /:: SendInput, % GetKeyState("CapsLock", "T") ? "z" : "Z"

+SC029:: SendInput ~
+1:: SendInput, % GetKeyState("CapsLock", "T") ? "<" : "1"
+2:: SendInput, % GetKeyState("CapsLock", "T") ? ">" : "2"
+3:: SendInput, % GetKeyState("CapsLock", "T") ? "{{}" : "3"
+4:: SendInput, % GetKeyState("CapsLock", "T") ? "{}}" : "4"
+5:: SendInput, % GetKeyState("CapsLock", "T") ? "|" : "5"
+6:: SendInput, % GetKeyState("CapsLock", "T") ? "{^}" : "6"
+7:: SendInput, % GetKeyState("CapsLock", "T") ? "&" : "7"
+8:: SendInput, % GetKeyState("CapsLock", "T") ? "*" : "8"
+9:: SendInput, % GetKeyState("CapsLock", "T") ? "(" : "9"
+0:: SendInput, % GetKeyState("CapsLock", "T") ? ")" : "0"
+-:: SendInput `%
+=:: SendInput $
+q:: SendInput :
+w:: SendInput -
+e:: SendInput {+}
+r:: SendInput, % GetKeyState("CapsLock", "T") ? "p" : "P"
+t:: SendInput, % GetKeyState("CapsLock", "T") ? "y" : "Y"
+y:: SendInput, % GetKeyState("CapsLock", "T") ? "f" : "F"
+u:: SendInput, % GetKeyState("CapsLock", "T") ? "g" : "G"
+i:: SendInput, % GetKeyState("CapsLock", "T") ? "c" : "C"
+o:: SendInput, % GetKeyState("CapsLock", "T") ? "r" : "R"
+p:: SendInput, % GetKeyState("CapsLock", "T") ? "l" : "L"
+[:: SendInput \
+]:: SendInput ?
+\:: SendInput {#}
+a:: SendInput, % GetKeyState("CapsLock", "T") ? "a" : "A"
+s:: SendInput, % GetKeyState("CapsLock", "T") ? "o" : "O"
+d:: SendInput, % GetKeyState("CapsLock", "T") ? "e" : "E"
+f:: SendInput, % GetKeyState("CapsLock", "T") ? "u" : "U"
+g:: SendInput, % GetKeyState("CapsLock", "T") ? "i" : "I"
+h:: SendInput, % GetKeyState("CapsLock", "T") ? "d" : "D"
+j:: SendInput, % GetKeyState("CapsLock", "T") ? "h" : "H"
+k:: SendInput, % GetKeyState("CapsLock", "T") ? "t" : "T"
+l:: SendInput, % GetKeyState("CapsLock", "T") ? "n" : "N"
+SC027:: SendInput, % GetKeyState("CapsLock", "T") ? "s" : "S"
+SC028:: SendInput, % GetKeyState("CapsLock", "T") ? "=" : "_"
+z:: SendInput " ;"
+x:: SendInput, % GetKeyState("CapsLock", "T") ? "q" : "Q"
+c:: SendInput, % GetKeyState("CapsLock", "T") ? "j" : "J"
+v:: SendInput, % GetKeyState("CapsLock", "T") ? "k" : "K"
+b:: SendInput, % GetKeyState("CapsLock", "T") ? "x" : "X"
+n:: SendInput, % GetKeyState("CapsLock", "T") ? "b" : "B"
+m:: SendInput, % GetKeyState("CapsLock", "T") ? "m" : "M"
+,:: SendInput, % GetKeyState("CapsLock", "T") ? "w" : "W"
+.:: SendInput, % GetKeyState("CapsLock", "T") ? "v" : "V"
+/:: SendInput, % GetKeyState("CapsLock", "T") ? "z" : "Z"

+Space:: SendInput, {Space}

global qwerty := 0
global isctrldown := 0

BackSpace::
	Suspend, Permit
	;MsgBox, backspace! %isctrldown%
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







*Ctrl::
	Suspend, Permit
	if (GetKeyState("CapsLock", "T") && GetKeyState("Shift", "P")) {
		Winset, Alwaysontop, , A
		return
	}
	;Send {Blind}{Ctrl DownTemp}
	isctrldown := 1
	SetKeyDelay, -1
	Send {Blind}{Ctrl Down}
	Suspend On
	;MsgBox, ctrl down! %qwerty%
return

*Ctrl Up::
	Suspend Off
	SetKeyDelay -1
	Send {Blind}{Ctrl Up}
	;MsgBox, ctrl up!
	isctrldown := 0
	if (qwerty = 1)
		Suspend On
return

*Alt::
	Suspend, Permit
	SetKeyDelay -1
	Send {Blind}{Alt Down}
	Suspend On
return

*Alt Up::
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

*LWin Up::
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

*RWin Up::
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
	{
		qwerty := 1
		
		;SoundBeep, 1661, 100
		;SoundBeep, 1245, 100
		;SoundBeep, 831, 100
		;SoundBeep, 932, 300
		
		ToolTip, OFF!, %mX% + 30, %mY% - 50
		SetTimer, killtip, 500
		
		SoundBeep, 698
		SoundBeep, 466
	}
	else
	{
		qwerty := 0
		
		;SoundBeep, 1245, 125
		;SoundBeep, 622, 41
		;SoundBeep, 932, 83
		;SoundBeep, 831, 166
		;SoundBeep, 1245, 83
		;SoundBeep, 932, 250
		
		ToolTip, ON!, %mX% + 30, %mY% - 50
		SetTimer, killtip, 500
		
		SoundBeep, 622
		SoundBeep, 932
	}
	;MsgBox, %qwerty%
	
	Suspend, Toggle
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

+MButton:: Send, {Volume_Mute}









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
		ToolTip % ASCIIBar(Round(BrightnessIndex * 100 / MaxIndex), 100, 25), %mX% + 30, %mY% - 50
		SetTimer, killtip, 1000
	}

}





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

useExternalAppSettings := 0
extSAVEfilename := "ScrollTrekAppSettings.ini"
SAVEdelay := -2000
isScrolled := 0

vReverse := 0
hReverse := 0
sReverse := 0		;use reverse settings above when using setting hotkeys too

vDefaultMethod := 1
hDefaultMethod := 1
fDefaultMethod := 1

/*
[AppMethodSettings]
*/
AppSettings_vMethod ={<SysTreeView>}{<SysListView>}{<DirectUIHWND>}
AppSettings_hMethod ={<SysTreeView>}{<SysListView>}{<DirectUIHWND(5)>}
AppSettings_fMethod =
/*
[Rest of Script]
*/

vMethodCount := 7
hMethodCount := 7
fMethodCount := 2

WM_MOUSEWHEEL := 0x20A
WM_MOUSEHWHEEL := 0x20E
WM_HSCROLL := 0x114
WM_VSCROLL := 0x115
EM_LINESCROLL := 0xB6
WM_LBUTTONUp := 0x201
WM_LBUTTONDown := 0x202
WM_KEYUp := 0x0100
WM_KEYDown := 0x0101
VK_LEFT := 0x25
VK_Down := 0x26
VK_RIGHT := 0x27
VK_Up := 0x28

if useExternalAppSettings
	{
	iniRead, AppSettings_vMethod, %extSAVEfilename%, AppMethodSettings, AppSettings_vMethod, %AppSettings_vMethod%
	iniRead, AppSettings_hMethod, %extSAVEfilename%, AppMethodSettings, AppSettings_hMethod, %AppSettings_hMethod%
	iniRead, AppSettings_fMethod, %extSAVEfilename%, AppMethodSettings, AppSettings_fMethod, %AppSettings_fMethod%
	StringReplace, AppSettings_vMethod, AppSettings_vMethod, ERROR,, All
	StringReplace, AppSettings_hMethod, AppSettings_hMethod, ERROR,, All
	StringReplace, AppSettings_fMethod, AppSettings_fMethod, ERROR,, All
	gosub, SAVEtoFILE
	}

;~ScrollLock::Suspend

#^+WheelDown::
axis := "v"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 2
gosub, TApp_Method_Settings
return

#^+WheelUp::
axis := "v"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 2
gosub, TApp_Method_Settings
return

#^+WheelRight::
axis := "h"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 2
gosub, TApp_Method_Settings
return

#^+WheelLeft::
axis := "h"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 2
gosub, TApp_Method_Settings
return

#^WheelDown::
axis := "v"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 1
gosub, TApp_Method_Settings
return

#^WheelUp::
axis := "v"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 1
gosub, TApp_Method_Settings
return

#^WheelRight::
axis := "h"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 1
gosub, TApp_Method_Settings
return

#^WheelLeft::
axis := "h"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 1
gosub, TApp_Method_Settings
return

#WheelDown::
axis := "v"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 0
gosub, TApp_Method_Settings
return

#WheelUp::
axis := "v"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 0
gosub, TApp_Method_Settings
return

#WheelRight::
axis := "h"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 0
gosub, TApp_Method_Settings
return

#WheelLeft::
axis := "h"
if (sReverse = 0) or (%axis%Reverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 0
gosub, TApp_Method_Settings
return

#+WheelDown::
axis := "f"
if (sReverse = 0) or (vReverse = 0)
	direction := 1
else
	direction := -1
SettingDeph := 0
gosub, TApp_Method_Settings
return

#+WheelUp::
axis := "f"
if (sReverse = 0) or (vReverse = 0)
	direction := -1
else
	direction := 1
SettingDeph := 0
gosub, TApp_Method_Settings
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WheelUp::
Suspend, Permit
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
MouseGetPos, mX, mY, TWinID, TCon
if (TWinID <> exWin4v) or (TCon <> exCon4v)
	{
	axis := "v"
	gosub, Set_Method
	}
if %axis%Reverse
	goto, ScrollUp
ScrollDown:
if (vMethod = "Off")
	Click, WheelDown
else if (vMethod = 1)
	PostMessage, WM_MOUSEWHEEL, 120 << 16, (mY << 16) | (mX & 0xFFFF), %TCon%, ahk_id%TWinID%
else if (vMethod = 2)
	ControlClick, %TCon%, ahk_id%TWinID%,, WheelDown, 1, NA
else if (vMethod = 3)
	PostMessage, WM_VSCROLL, 0, 0, %TCon%, ahk_id%TWinID%
else if (vMethod = 4)
	PostMessage, EM_LINESCROLL, 0, -1, %TCon%, ahk_id%TWinID%
else if (vMethod = 5) or (vMethod = 6)
	{
	if (mX <> exMx) or (mY <> exMy)
		{
		axis := "v"
		gosub, Get_SBar_Info
		}
	PostMessage, WM_LBUTTONUp,, (5 << 16) | 5, %VBarC%, ahk_id%TWinID%
	PostMessage, WM_LBUT ,, (5 << 16) | 5, %VBarC%, ahk_id%TWinID%
	}
else if (vMethod = 7) 
	{
	PostMessage, WM_KEYUp, VK_Down,, %TCon%, ahk_id%TWinID%
	}
	PostMessage, WM_KEYDown, VK_Down,, %TCon%, ahk_id%TWinID%
return

WheelDown::
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
MouseGetPos, mX, mY, TWinID, TCon
if (TWinID <> exWin4v) or (TCon <> exCon4v)
	{
	axis := "v"
	gosub, Set_Method
	}
if %axis%Reverse
	goto, ScrollDown
ScrollUp:
if (vMethod = "Off")
	Click, WheelUp
else if (vMethod = 1)
	PostMessage, WM_MOUSEWHEEL, -120 << 16, (mY << 16) | (mX & 0xFFFF), %TCon%, ahk_id%TWinID%
else if (vMethod = 2)
	ControlClick, %TCon%, ahk_id%TWinID%,, WheelUp, 1, NA
else if (vMethod = 3)
	PostMessage, WM_VSCROLL, 1, 0, %TCon%, ahk_id%TWinID%
else if (vMethod = 4)
	PostMessage, EM_LINESCROLL, 0, 1, %TCon%, ahk_id%TWinID%
else if (vMethod = 5) or (vMethod = 6)
	{
	if (mX <> exMx) or (mY <> exMy)
		{
		axis := "v"
		gosub, Get_SBar_Info
		}
	PostMessage, WM_LBUTTONUp,, ((VBarH - 5) << 16) | 5, %VBarC%, ahk_id%TWinID%
	PostMessage, WM_LBUTTONDown,, ((VBarH - 5) << 16) | 5, %VBarC%, ahk_id%TWinID%
	}
else if (vMethod = 7)
	{
	PostMessage, WM_KEYUp, VK_Up,, %TCon%, ahk_id%TWinID%
	PostMessage, WM_KEYDown, VK_Up,, %TCon%, ahk_id%TWinID%
	}
return

WheelLeft::
MouseGetPos, mX, mY, TWinID, TCon
if (TWinID <> exWin4h) or (TCon <> exCon4h)
	{
	axis := "h"
	gosub, Set_Method
	}
if %axis%Reverse
	goto, ScrollRight
ScrollLeft:
if (hMethod = "Off")
	Click, WheelLeft
else if (hMethod = 1)
	PostMessage, WM_MOUSEHWHEEL, -120 << 16, (mY << 16) | (mX & 0xFFFF), %TCon%, ahk_id%TWinID%
else if (hMethod = 2)
	ControlClick, %TCon%, ahk_id%TWinID%,, WheelLeft, 1, NA
else if (hMethod = 3)
	PostMessage, WM_HSCROLL, 0, 0, %TCon%, ahk_id%TWinID%
else if (hMethod = 4)
	PostMessage, EM_LINESCROLL, -1, 0, %TCon%, ahk_id%TWinID%
else if (hMethod = 5) or (hMethod = 6)
	{
	if (mX <> exMx) or (mY <> exMy)
		{
		axis := "h"
		gosub, Get_SBar_Info
		}
	PostMessage, WM_LBUTTONUp,, (5 << 16) | 5, %HBarC%, ahk_id%TWinID%
	PostMessage, WM_LBUTTONDown,, (5 << 16) | 5, %HBarC%, ahk_id%TWinID%
	}
else if (hMethod = 7)
	{
	PostMessage, WM_KEYUp, VK_LEFT,, %TCon%, ahk_id%TWinID%
	PostMessage, WM_KEYDown, VK_LEFT,, %TCon%, ahk_id%TWinID%
	}
return

WheelRight::
MouseGetPos, mX, mY, TWinID, TCon
if (TWinID <> exWin4h) or (TCon <> exCon4h)
	{
	axis := "h"
	gosub, Set_Method
	}
if %axis%Reverse
	goto, ScrollLeft
ScrollRight:
if (hMethod = "Off")
	Click, WheelRight
else if (hMethod = 1)
	PostMessage, WM_MOUSEHWHEEL, 120 << 16, (mY << 16) | (mX & 0xFFFF), %TCon%, ahk_id%TWinID%
else if (hMethod = 2)
	ControlClick, %TCon%, ahk_id%TWinID%,, WheelRight, 1, NA
else if (hMethod = 3)
	PostMessage, WM_HSCROLL, 1, 0, %TCon%, ahk_id%TWinID%
else if (hMethod = 4)
	PostMessage, EM_LINESCROLL, 1, 0, %TCon%, ahk_id%TWinID%
else if (hMethod = 5) or (hMethod = 6)
	{
	if (mX <> exMx) or (mY <> exMy)
		{
		axis := "h"
		gosub, Get_SBar_Info
		}
	PostMessage, WM_LBUTTONUp,, (5 << 16) | (HBarW - 5), %HBarC%, ahk_id%TWinID%
	PostMessage, WM_LBUTTONDown,, (5 << 16) | (HBarW - 5), %HBarC%, ahk_id%TWinID%
	}
else if (hMethod = 7)
	{
	PostMessage, WM_KEYUp, VK_RIGHT,, %TCon%, ahk_id%TWinID%
	PostMessage, WM_KEYDown, VK_RIGHT,, %TCon%, ahk_id%TWinID%
	}
return



Set_Method:

%axis%Method := %axis%DefaultMethod, fMethod := fDefaultMethod
, TConC := "", TConN := ""
, AppString := "", AppString_method := "", AppString_exceptions := ""
, ConCString := "", ConCString_method := "", ConCString_exceptions := ""
, ConNString := "", ConNString_method := ""

if (TCon <> "")
	RegExMatch(TCon, "(?P<C>.*\D)(?P<N>\d+)$", TCon)

WinGet, TApp, ProcessName, ahk_id%TWinID%

if (TApp <> "") and inStr(AppSettings_%axis%Method, "{" . TApp)
	{
	RegExMatch(AppSettings_%axis%Method, "i)\{" . TApp . "(\((?P<_method>[^\)]*)\))?(?P<_exceptions>[^\}]*)\}", AppString)

	if (AppString_method <> "")
		%axis%Method := AppString_method

	if inStr(AppSettings_%axis%Method, "{<" . TConC)
		{
		RegExMatch(AppSettings_%axis%Method, "i)\{\<" . TConC . "(\((?P<_method>[^\)]*)\))?\>\}", ConCString)

		if (ConCString_method <> "")
			%axis%Method := ConCString_method
		else %axis%Method := %axis%DefaultMethod
		}

	if inStr(AppString_Exceptions, "<" . TConC)
		{
		RegExMatch(AppString_Exceptions, "i)\<" . TConC . "(\((?P<_method>[^\)]*)\))?(?P<_exceptions>[^\>]*)\>", ConCString)

		if (ConCString_method <> "")
			%axis%Method := ConCString_method

		if inStr(ConCString_Exceptions, "[" . TConN)
			{
			RegExMatch(ConCString_Exceptions, "i)\[" . TConN . "\((?P<_method>[^\)]*)\)\]", ConNString)

			if (ConNString_method <> "")
				%axis%Method := ConNString_method
			}
		}
	}
else if (TCon <> "") and inStr(AppSettings_%axis%Method, "{<" . TConC)
	{
	RegExMatch(AppSettings_%axis%Method, "i)\{\<" . TConC . "(\((?P<_method>[^\)]*)\))?\>\}", ConCString)

	if (ConCString_method <> "")
		%axis%Method := ConCString_method
	}


if (%axis%Method = 5)
	{
	look4 := "ScrollBar"
	gosub, Get_SBar_Info
	}
else if (%axis%Method = 6)
	{
	look4 := "NetUIHWND"
	gosub, Get_SBar_Info
	}

if (TApp <> "") and inStr(AppSettings_fMethod, "{" . TApp)
	{
	RegExMatch(AppSettings_fMethod, "i)\{" . TApp . "(\((?P<_method>[^\)]*)\))?(?P<_exceptions>[^\}]*)\}", AppFocus)

	if (AppFocus_method <> "")
		fMethod := AppFocus_method
	}

if (fMethod = 1)
	PostMessage, 0x0006, 2,, %TCon%, ahk_id%TWinID%
else if (fMethod = 2)
	{
	PostMessage, 0x0006, 2,, %TCon%, ahk_id%TWinID%
	PostMessage, WM_LBUTTONUp,,, %TCon%, ahk_id%TWinID%
	PostMessage, WM_LBUTTONDown,,, %TCon%, ahk_id%TWinID%
	}

exWin4%axis% := exTWinID := TWinID, exCon4%axis% := exTCon := TCon
return


Get_SBar_Info:
%axis%BarC := "", exMx := mX, exMy := mY
if (look4 = "ScrollBar") and inStr(TCon, look4)
	{
	ControlGetPos, SBarX, SBarY, SBarW, SBarH, %TCon%, ahk_id%TWinID%
	if (axis = "v")
		and (SBarW < 20)
		and (SBarH > SBarW)
		{
		VBarC := TCon, VBarX := SBarX, VBarY := SBarY, VBarW := SBarW, VBarH := SBarH
		return
		}
	else if (axis = "h")
		and (SBarH < 20)
		and (SBarW > SBarH)
		{
		HBarC := TCon, HBarX := SBarX, HBarY := SBarY, HBarW := SBarW, HBarH := SBarH
		return
		}
	else TSBarH := SBarH, TSBarW := SBarW
	}
else  TSBarH := 0, TSBarW := 0
WinGetPos, TWinIDX, TWinIDY,,, ahk_id%TWinID%
WinGet, TWinIDConList, ControlList, ahk_id%TWinID%
loop, Parse, TWinIDConList, `n
	{
	if inStr(A_LoopField, look4)
		{
		ControlGet, vis, Visible,, %A_LoopField%, ahk_id%TWinID%
		if vis = 1
			{
			ControlGetPos, SBarX, SBarY, SBarW, SBarH,  %A_LoopField%, ahk_id%TWinID%
			if (axis = "v") 
				and (SBarW < 20)
				and (SBarH > SBarW)
				and (mX < (TWinIDX + SBarX + SBarW))
				and (mY < (TWinIDY + SBarY + SBarH + TSBarH))
				{
				if (VBarC = "")
					or (SBarX < VBarX)
					or ((TWinIDY + VBarY) > (TWinIDY + SBarY + SBarH))
					{
					VBarC := A_LoopField, VBarX := SBarX, VBarY := SBarY, VBarW := SBarW, VBarH := SBarH
					}
				}
			else if (axis = "h")
				and (SBarH < 20)
				and (SBarW > SBarH)
				and (mY < (TWinIDY + SBarY + SBarH))
				and (mX < (TWinIDX + SBarX + SBarW + TSBarW))
				{
				if (HBarC = "")
					or (SBarY < HBarY)
					or ((TWinIDX + HBarX) > (TWinIDX + SBarX + SBarW))
					{
					HBarC := A_LoopField, HBarX := SBarX, HBarY := SBarY, HBarW := SBarW, HBarH := SBarH
					}
				}
			}

		}
	}
return


TApp_Method_Settings:
MouseGetPos,,, TWinID, TCon
WinGet, TApp, ProcessName, ahk_id%TWinID%

if (TApp = "")
	return

if (TCon = "") and (SettingDeph > 0)
	return
else RegExMatch(TCon, "(?P<C>.*\D)(?P<N>\d+)$", TCon)

TApp_%axis%Method_ex := %axis%DefaultMethod, TApp_%axis%Method_new := ""
, AppString := "", AppString_method := "", AppString_exceptions := ""
, ConCString := "", ConCString_method := "", ConCString_exceptions := ""
, ConNString := "", ConNString_method := ""

if inStr(AppSettings_%axis%Method, "{" . TApp)
	{
	RegExMatch(AppSettings_%axis%Method, "i)\{" . TApp . "(\((?P<_method>[^\)]*)\))?(?P<_exceptions>[^\}]*)\}", AppString)
	StringReplace, AppSettings_%axis%Method, AppSettings_%axis%Method, %AppString%,, All

	if (AppString_method = "")
		AppString_method := %axis%DefaultMethod

	TApp_%axis%Method_ex := AppString_method

	if (SettingDeph > 0)
		and (AppString_exceptions <> "")
		and inStr(AppString_exceptions,  "<" . TConC)
		{
		RegExMatch(AppString_Exceptions, "i)\<" . TConC . "(\((?P<_method>[^\)]*)\))?(?P<_exceptions>[^\>]*)\>", ConCString)
		StringReplace, AppString_exceptions, AppString_exceptions, %ConCString%,, All

		if (ConCString_method = "")
			ConCString_method := AppString_method

		TApp_%axis%Method_ex := ConCString_method


		if (SettingDeph > 1)
			and (ConCString_exceptions <> "")
			and inStr(ConCString_exceptions, "[" . TConN)
			{
			RegExMatch(ConCString_Exceptions, "i)\[" . TConN . "\((?P<_method>[^\)]*)\)\]", ConNString)
			StringReplace, ConCString_exceptions, ConCString_exceptions, %ConNString%,, All

			if (ConNString_method = "")
				ConNString_method := ConCString_method

			TApp_%axis%Method_ex := ConNString_method
			}
		}
	}

ToolTip % TApp_%axis%Method_ex

if (TApp_%axis%Method_ex = 1) and (direction = -1)
	TApp_%axis%Method_new := "Off"
else if (TApp_%axis%Method_ex = %axis%MethodCount) and (direction = 1)
	TApp_%axis%Method_new := "Off"
else if (TApp_%axis%Method_ex = "Off")
	{
	if (direction = 1)
		TApp_%axis%Method_new := 1
	else if (direction = -1)
		TApp_%axis%Method_new := %axis%MethodCount
	}
else TApp_%axis%Method_new := TApp_%axis%Method_ex + direction

if (SettingDeph = 2)
	ConNString_method := TApp_%axis%Method_new
else if (SettingDeph = 1)
	ConCString_method := TApp_%axis%Method_new
else AppString_method := TApp_%axis%Method_new


if (SettingDeph > 1) and (ConNString_method <> ConCString_method)
	ConCString_exceptions := ConCString_exceptions . "[" . TConN . "(" . ConNString_method . ")]"

if (SettingDeph > 0)
	{
	if (ConCString_method <> AppString_method)
		AppString_exceptions := AppString_exceptions . "<" . TConC . "(" . ConCString_method . ")" . ConCString_exceptions . ">"
	else if (ConCString_exceptions <> "")
		AppString_exceptions := AppString_exceptions . "<" . TConC . ConCString_exceptions . ">"
	}

if (AppString_method <> %axis%DefaultMethod)
	AppSettings_%axis%Method := AppSettings_%axis%Method . "{" . TApp . "(" . AppString_method . ")" . AppString_exceptions . "}"
else if (AppString_exceptions <> "")
	AppSettings_%axis%Method := AppSettings_%axis%Method . "{" . TApp . AppString_exceptions . "}"

ToolTip, % TApp_%axis%Method_new

exWin4%axis% := "", exCon4%axis% := ""

setTimer, SAVEtoFILE, %SAVEdelay%

return

SAVEtoFILE:
iniWrite, %AppSettings_vMethod%, %A_ScriptName%, AppMethodSettings, AppSettings_vMethod
iniWrite, %AppSettings_hMethod%, %A_ScriptName%, AppMethodSettings, AppSettings_hMethod
iniWrite, %AppSettings_fMethod%, %A_ScriptName%, AppMethodSettings, AppSettings_fMethod
if useExternalAppSettings
	{
	iniWrite, %AppSettings_vMethod%, %extSAVEfilename%, AppMethodSettings, AppSettings_vMethod
	iniWrite, %AppSettings_hMethod%, %extSAVEfilename%, AppMethodSettings, AppSettings_hMethod
	iniWrite, %AppSettings_fMethod%, %extSAVEfilename%, AppMethodSettings, AppSettings_fMethod
	}
ToolTip
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




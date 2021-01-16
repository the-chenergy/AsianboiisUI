;####################################################################################################
;      CONFIGURATIONS
;{###################################################################################################

#NoEnv
#SingleInstance, Force
#MaxHotkeysPerInterval, 0x7FFFFFFF
#HotkeyInterval, 0x7FFFFFFF

SendMode, Input
CoordMode, Mouse, Screen
SetKeyDelay, -1
SetMouseDelay, -1
SetControlDelay, -1
SetWorkingDir, %A_ScriptDir%

; performance-wise
SetBatchLines, -1
ListLines, Off

; keyboard function initializations
SetCapsLockState, AlwaysOff
SetNumLockState, On
ResetModifiers()

;}###################################################################################################
;      GLOBALS
;{###################################################################################################

global IsFnDown := false
global IsShiftDown := false
global IsCtrlDown := false
global IsWinDown := false
global IsAltDown := false
global IsCapsLockOn := false
global IsNumLockOn := false
global IsFnLockOn := false
global IsToggled := false
; is it temporarily toggled (by capslock key)
global IsToggledByCapsLock := false
global IsInNormalScrolling := true
; is there any key/mouse action while shift(space) or fn(l-win) is down
global IsFnKeyComboUsed := false
global IsShiftKeyComboUsed := false
; is alt-tab(fn-tab) used while fn(l-win) is down
global IsFnTabUsed := false
; is shift(space)+bs(r-win, in mac version) used while shift(space) is down
global IsSpaceComboUsed := false
; special character inputting settings
global CurrentSpecChar := ""
global CurrentSpecIndex := 0
global SpecChars := {a: ["á", "ä", "à", "ã", "â", "å", "æ", "α"]
	,e: ["é", "ë", "è", "ê"]
	,i: ["í", "ï", "ì", "î"]
	,o: ["ó", "ö", "ò", "õ", "ô", "ø"]
	,u: ["ú", "ü", "ù", "û"]
	,y: ["ý", "ÿ"]
	,"$": ["¢", "€", "£", "¥"]
	,"^": ["¹", "²", "³"]
	,"*": ["×", "÷", "•", "°"]}
global CapSpecChars := {a: ["Á", "Ä", "À", "Ã", "Â", "Å", "Æ", "Α"]
	,e: ["É", "Ë", "È", "Ê"]
	,i: ["Í", "Ï", "Ì", ""]
	,o: ["Ó", "Ö", "Ò", "Õ", "Ô", "Ø"]
	,u: ["Ú", "Ü", "Ù", "Û"]
	,y: ["Ý", "Ÿ"]}

;}###################################################################################################
;      HELPERS
;{###################################################################################################

;{.... GUI/IconBox ..................................................................................

global GuiContent, GuiId
global GuiWidth = 150, GuiHeight = 150

global NumScreens
SysGet, NumScreens, MonitorCount ; get the number of monitor for later to determine the one
; that the mouse is currently on

global MainScreenLeft, MainScreenTop, MainScreenRight, MainScreenBottom
if (NumScreens = 1)
	SysGet, MainScreen, Monitor, 1 ; get the coordinate of the main screen, just in case
	; there is only one screen, so we don't have to get it everytime.

; create the gui instance
Gui, -Caption +ToolWindow +AlwaysOnTop +LastFound
GuiContent:= WinExist()
WinGet, GuiId, Id
Gui, Color, 202020
Gui, Margin, 0, 0

; green and red progress bars
Gui, %GuiId%:Add, Progress, X15 Y120 W120 H15 Background111111 C2ECC71 VGreenBar
Gui, %GuiId%:Add, Progress, X15 Y120 W120 H15 Background111111 CC0392B VRedBar

; the list of icon names
global GuiIcons := ["CapsLockOn"
	,"CapsLockOff"
	,"NumLockOn"
	,"NumLockOff"
	,"ToggleOn"
	,"ToggleOff"
	,"NormalScrollingOn"
	,"NormalScrollingOff"
	,"Brightness"
	,"MuteOn"
	,"VolumeOff"
	,"VolumeLow"
	,"VolumeMedium"
	,"VolumeHigh"
	,"FnLockOn"
	,"NeverSleepOn"
	,"NeverSleepOff"]

; load icons from local folder
For i, guiIcon in GuiIcons
	Gui, %GuiId%:Add, Picture, X0 Y0 V%guiIcon%, % "Icons/" guiIcon ".png"

Gui, Show, X-1000 Y-1000 Hide ; make the gui out of screen first to let play its annoying animation
ShowIconBox("Brightness", "", 0, true) ; let the gui finish its kickstart animation

/**
 * Shows the icon box GUI.
 * 
 * Params:
 *   string iconName - the name of the icon to display in the GUI.
 *   string progressBar - the progress bar to display in the GUI. empty for no progress bar.
 * (default = "")
 *   int progressValue - the value of progress bar, from 0 to 100. (default = 0)
 *   bool testingMode - if testing, the icon will be displayed outside the screen.
 * (default = false)
 */
ShowIconBox(iconName, progressBar := "", progressValue := 0, testingMode := false)
{
	SetTimer, HideIconBox, Off ; reset the timer if it's not reset
	
	; hide the rest of unrelated icons
	For i, guiIcon in GuiIcons
		if (guiIcon != %iconName%)
			GuiControl, %GuiId%:Hide, %guiIcon%
	
	GuiControl, %GuiId%:Show, %iconName%
	
	if (testingMode)
	{
		Gui, %GuiId%:Show, X-10000 Y-10000, Hide
		Gui, %GuiId%:Show, W%GuiWidth% H%GuiHeight% NoActivate
		
		SetTimer, HideIconBox, -500
		
		return
	}
	
	guiPosition := GetIconBoxPosition()
	guiX := guiPosition.x
	guiY := guiPosition.y
	
	Gui, %GuiId%:Show, X%guiX% Y%guiY% Hide
	Gui, %GuiId%:Show, W%GuiWidth% H%GuiHeight% NoActivate
	
	WinSet, AlwaysOnTop, Off, %GuiId%
	WinSet, AlwaysOnTop, On, %GuiId%
	
	if (progressBar = "Green")
	{
		GuiControl, %GuiId%:Show, GreenBar
		GuiControl, , GreenBar, %progressValue%
	}
	else if (progressBar = "Red")
	{
		GuiControl, %GuiId%:Show, RedBar
		GuiControl, , RedBar, %progressValue%
	}
	
	SetTimer, HideIconBox, -500 ; negative number means the timer should't loop.
}

/**
 * Forces the icon box GUI to hide. By default, it hides 500 milliseconds after it is shown.
 */
HideIconBox()
{
	DllCall("AnimateWindow", UInt, GuiId, Int, 200, UInt, 0x90000) ; play the fade-out amination
}

/**
 * Returns the position of where the icon box needs to pop up according to which screen
 * the mouse cursor is on.
 */
GetIconBoxPosition()
{
	if (NumScreens == 1)
		return {x: MainScreenRight - GuiWidth - 25
			,y: MainScreenTop + 25}
	
	; get the screen the cursor is currently on
	
	MouseGetPos, mouseX, mouseY
	
	Loop, %NumScreens%
	{
		SysGet, currentScreenCoord, Monitor, %A_Index%
		
		if (mouseX >= currentScreenCoordLeft && mouseX < currentScreenCoordRight
			&& mouseY >= currentScreenCoordTop && mouseY < currentScreenCoordBottom)
				break
	}
	
	return {x: currentScreenCoordRight - GuiWidth - 25
		,y: currentScreenCoordTop + 25}
}

;}
;{.... Default Configs (from ini) ...................................................................

global DefaultMagicScrolling, IsMacKeyboard

IniRead, DefaultMagicScrolling, % "Settings.ini", % "Config", % "UseMagicScrolling", 0
IniRead, IsMacKeyboard, % "Settings.ini", % "Config", % "IsMacKeyboard", 0

IsInNormalScrolling := (DefaultMagicScrolling = 0)

global FnKeyName := (IsMacKeyboard ? "LWin" : "LAlt")
global ToggleKeyName := (IsMacKeyboard ? "RAlt" : "RControl")

;}
;{.... Testing Area .................................................................................

/*

~Esc::
	;Test()
	;SendInput, {Shift Up}
	;MsgBox, % A_TickCount
	
	MsgBox, % SpecChars["a"][1]
return
*/

/**
 * Shows a message box containing the activity of each modifier key.
 */
Test()
{
	MsgBox, % "Toggled: " IsToggled "`nCapsLock: " IsCapsLockOn "`n`nFn: " IsFnDown n "`nCtrl: " IsCtrlDown "`nWin: " IsWinDown "`nAlt: " IsAltDown "`nShift: " IsShiftDown "`nPriorKey: " A_PriorKey
}

;#V:: MsgBox, Nice!

;}

;}###################################################################################################
;      MODIFIERS
;{###################################################################################################

;{.... Methods ......................................................................................

/**
 * Sends a modifier key press (it may hold down or release).
 * 
 * Params:
 *   string modifier - the name of the modifier to press.
 *   string state - either hold down ("Down") or release ("Up"). (default = "Down")
 */
PressMod(modifier, state := "Down")
{
	SendInput, {%modifier% %state%}
	
	if (modifier = "Shift")
		IsShiftDown := (state = "Down")
	else if (modifier = "Ctrl")
		IsCtrlDown := (state = "Down")
	else if (modifier = "LWin" || modifier = "RWin")
		IsWinDown := (state = "Down")
	else if (modifier = "Alt")
		IsAltDown := (state = "Down")
}

/**
 * Returns true if any of these modifiers is being held down:
 * (Fn, Alt, Ctrl, or Win).
 */
IsAnyHotkeyDown()
{
	return IsFnDown || IsCtrlDown || IsWinDown || IsAltDown
}

/**
 * Returns true if any of these modifiers is being held down:
 * (Alt, Ctrl, or Win).
 */
IsAnyControlKeyDown()
{
	return IsCtrlDown || IsWinDown || IsAltDown
}

/**
 * Returns true if CapsLock key is currently held down.
 */
IsCapsLockDown()
{
	return GetKeyState("CapsLock", "P")
}

/**
 * Sends an advanced backspace key-press. It simulates the following:
 *   BackSpace - normal backspace;
 *   CapsLock+BackSpace - delete current line;
 *   Ctrl+BackSpace - delete current word;
 *   Fn+BackSpace - forward delete.
 */
PressBackSpace()
{
	if (IsToggled)
	{
		if (IsCapsLockDown()) ; which means that caps-lock is held down
			SendInput, +{Home}{BackSpace}
		else
			SendInput, {BackSpace}
		
		return
	}
	
	if (IsCtrlDown)
	{
		SendInput, {Ctrl Up} ; blind ctrl key to prevent native ctrl+backspace
		SendInput, ^+{Left}{BackSpace}
		SendInput, {Ctrl Down}
	}
	else if (IsFnDown && !isFnLockOn)
		SendInput, {Delete}
	else
		SendInput, {BackSpace}
}

/**
 * Toggles the state of CapsLock key and shows a related icon in the icon box GUI.
 */
ToggleCapsLock()
{
	IsCapsLockOn := !IsCapsLockOn
	
	if (IsCapsLockOn)
	{
		SetCapsLockState, AlwaysOn
		
		ShowIconBox("CapsLockOn")
	}
	else
	{
		SetCapsLockState, AlwaysOff
		
		ShowIconBox("CapsLockOff")
	}
}

/**
 * Toggles the state of NumLock ky and shows a related icon in the icon box GUI.
 */
ToggleNumLock()
{
	IsNumLockOn := !IsNumLockOn
	
	; when system (on-keyboard) num-lock is on, the "programed" num-lock should be off
	; in other words, the "programed" num-lock should only be useful when
	;   system num-lock is off
	
	if (IsNumLockOn)
	{
		SetNumLockState, Off
		
		ShowIconBox("NumLockOn")
	}
	else
	{
		SendInput, {NumLock}
		
		ShowIconBox("NumLockOff")
	}
}

/**
 * Sends a customized hotkey avoiding the native ctrl hotkeys (blinding ctrl).
 * 
 * Params:
 *   string key - the key to send as a hotkey.
 *   bool useForcedKeyMode - whether it should send the autohotkey with the bracket
 * around the key.
 */
PressBlindCtrl(key, useForcedKeyMode := true)
{
	SendInput, {Ctrl Up}
	
	if (useForcedKeyMode)
		SendInput, {%key%}
	else
		SendInput, %key%
	
	if (IsCtrlDown)
		SendInput, {Ctrl Down}
}

/**
 * Turns off all modifiers temporarily in order to send some customized hotkeys
 * without triggering any native hotkeys.
 */
BlindModifiers()
{
	SendInput, {Shift Up}
	SendInput, {Ctrl Up}
	SendInput, {LWin Up}
	SendInput, {Alt Up}
}

/**
 * Turns the modifiers back on after using BlindModifiers() method to turn them off.
 */
UnblindModifiers()
{
	if (IsShiftDown)
		SendInput, {Shift Down}
	
	if (IsCtrlDown)
		SendInput, {Ctrl Down}
	
	if (IsWinDown)
		SendInput, {LWin Down}
	
	if (IsAltDown)
		SendInput, {Alt Down}
}

/**
 * Releases and resets all modifiers, regardless they are pressed/held or not.
 */
ResetModifiers()
{
	PressMod("Shift", "Up")
	PressMod("Ctrl", "Up")
	PressMod("LWin", "Up")
	PressMod("Alt", "Up")
	
	IsFnDown := IsFnLockOn := false
}

;}
;{.... Modifiers ....................................................................................
 
; shift => ctrl
$*LShift::
	if (IsCtrlDown)
		return
	
	PressMod("Ctrl")
return

$*LShift Up::
	PressMod("Ctrl", "Up")
	; ahk bug: shift key sometimes doesn't pop up after l-shift (mapped l-ctrl)
	;   releases
	if (!IsShiftDown)
		SendInput, {Shift Up}
return

$*RShift::
	if (IsCtrlDown)
		return
	
	PressMod("Ctrl")
return

$*RShift Up::
	PressMod("Ctrl", "Up")
	
	if (!IsShiftDown)
		SendInput, {Shift Up}
return

; ctrl => win
$*LCtrl:: PressMod("LWin")

$*LCtrl Up::
	PressMod("LWin", "Up")
	
	if (!IsCtrlDown)
		SendInput, {Ctrl Up}
return

; alt => alt (MAC VERSION)
#If (IsMacKeyboard)

$*~LAlt:: IsAltDown := true
$*~LAlt Up:: IsAltDown := false

; l-win => alt (PC VERSION)
#If (!IsMacKeyboard)

$*LWin::
	if (IsAltDown)
		return
	
	PressMod("Alt")
return

$*LWin Up::
	PressMod("Alt", "Up")
	
	if (!IsWinDown)
		SendInput, {LWin Up}
return

$*RWin::
	if (IsAltDown)
		return
	
	PressMod("Alt")
return

$*RWin Up::
	PressMod("Alt", "Up")
	
	if (!IsWinDown)
		SendInput, {RWin Up}
return

#If

;}
;{.... Dual Keys ....................................................................................

;{ space => shift/space

global SpaceDownTime := 0 ; used to determine what ctrl+space should send (enter or ctrl+shift)

$*Space::
	Suspend, Permit
	
	if (IsToggled)
	{
		if (IsCapsLockDown())
			SendInput, {Shift Down}
		else
			SendInput, {Space}
		
		return
	}
	
	if (IsShiftDown)
		return
	
	PressMod("Shift")
	
	if (IsCtrlDown)
		SpaceDownTime := A_TickCount
return

$*Space Up::
	Suspend, Permit
	
	if (IsToggled)
	{
		SendInput, {Shift Up}
		
		if (IsCapsLockDown() && A_PriorKey = "Space")
				SendInput, {Space}
		
		return
	}
	
	PressMod("Shift", "Up")
	
	; space => space
	; fn+space => bs
	; numlock(t)+space => 0
	if (A_PriorKey = "Space" && !IsShiftKeyComboUsed)
	{
		if (IsNumLockOn && !GetKeyState("CapsLock", "P"))
		{
			SendInput, 0
		}
		else if (IsCtrlDown)
		{
			if (A_TickCount - SpaceDownTime >= 1000)
				SendInput, ^{Shift}
			else
				PressBlindCtrl("Enter")
		}
		else if (!IsAnyHotkeyDown())
		{
			SendInput, {Space}
		}
	}
	
	IsShiftKeyComboUsed := false ; reset
return

;}
;{ l-win(MAC)/l-alt(PC) => fn/esc

FnDown()
{
	if (IsShiftDown || IsFnLockOn)
		if (IsFnLockOn := !IsFnLockOn)
			ShowIconBox("FnLockOn")
	
	IsFnDown := true
}

FnUp()
{
	if (!IsFnDown)
		return
	
	if (!IsFnLockOn)
		IsFnDown := false
	
	if (A_PriorKey = FnKeyName && !IsFnKeyComboUsed)
	{
		if (IsNumLockOn)
		{
			PressBackSpace()
		}
		else if (!IsFnLockOn)
		{
			if (IsCtrlDown)
			{
				SendInput, {Ctrl Up} ; blind ctrl to avoid native ctrl+backspace
				SendInput, {BackSpace}
				SendInput, {Ctrl Down}
			}
			else
			{
				SendInput, {Esc}
			}
		}
	}
	
	if (IsFnTabUsed)
	{
		if (!IsAltDown)
		{
			SendInput, {Alt Up}
			
			if (IsCapsLockOn)
				SendInput, {CapsLock}
			; for some reason this won't work properly when capslock is on
			;   and the script is without this line of code
		}
		
		IsFnTabUsed := false
	}
	
	IsFnKeyComboUsed := false ; reset
	CurrentSpecChar := ""
	CurrentSpecIndex := 0 ; reset special caracter inputting settings
}

#If (IsMacKeyboard)
$*LWin:: FnDown()
$*LWin Up:: FnUp()

#If (!IsMacKeyboard)
$*LAlt:: FnDown()
$*LAlt Up:: FnUp()

#If

;}
;{ r-alt(MAC)/r-ctrl(PC) => toggle/toggle-lock

global IsToggleDown := false

ToggleDown()
{
	if (IsToggleDown)
		return ; avoid the "toggling back and forth" while toggle is held down
	
	IsToggleDown := true
	
	Suspend, Toggle
	
	IsToggled := !IsToggled
}

ToggleUp()
{
	IsToggleDown := false
	
	if (A_PriorKey = ToggleKeyName)
	{
		if (IsToggled)
		{
			ShowIconBox("ToggleOn")
			
			SoundBeep, 698
			SoundBeep, 466
		}
		else
		{
			ShowIconBox("ToggleOff")
			
			IsCapsLockOn := GetKeyState("CapsLock", "T")
			IsNumLockOn := !GetKeyState("NumLock", "T")
			; update lock key states in case the user toggled them while script suspended
			
			SoundBeep, 622
			SoundBeep, 932
		}
		
		ResetModifiers()
	}
	else
	{
		Suspend, Toggle
		IsToggled := !IsToggled
	}
}

#If (IsMacKeyboard)

RAlt::
	Suspend, Permit
	
	ToggleDown()
return
RAlt Up::
	Suspend, Permit
	
	ToggleUp()
return

#If (!IsMacKeyboard)

RCtrl::
	Suspend, Permit
	
	ToggleDown()
return
RCtrl Up::
	Suspend, Permit
	
	ToggleUp()
return

#If

;}
;{ caps-lock => toggle/!?

CapsLock::
+CapsLock::
	Suspend, Permit
	
	if (IsFnDown || IsNumLockOn)
		return
	
	if (IsToggled)
	{
		if (!IsToggledByCapsLock)
			ToggleCapsLock()
		
		return
	}
	
	IsToggled := IsToggledByCapsLock := true
	
	Suspend, On
return

CapsLock Up::
+CapsLock Up::
	Suspend, Permit
	
	if (IsFnDown || IsNumLockOn)
	{
		if (A_PriorKey = "CapsLock")
			ToggleNumLock()
		
		return
	}
	
	if (!IsToggledByCapsLock)
		return
	
	IsToggled := IsToggledByCapsLock := false
	
	Suspend, Off
	
	IsCapsLockOn := GetKeyState("CapsLock", "T")
	IsNumLockOn := !GetKeyState("NumLock", "T")
	
	if (A_PriorKey = "CapsLock")
	{
		if (IsShiftDown)
			SendInput, {?}
		else
			SendInput, {!}
	}
	
	if (GetKeyState("Space", "P"))
		IsShiftKeyComboUsed := true ; avoid inserting a space afterwards
	
	if (GetKeyState(FnKeyName, "P"))
		IsFnKeyComboUsed := true ; avoid inserting an esc afterwards
return

;}

;}
;{.... Other Macros .................................................................................

; r-win(MAC)/r-alt(PC) => bs

BackSpaceDown()
{
	if (IsFnDown)
	{
		SendInput, {Delete}
		
		return
	}
	
	if (IsShiftDown)
	{
		SendInput, {Shift Up} ; blind to avoid shift+enter
		SendInput, {Enter}
		SendInput, {Shift Down}
		
		IsSpaceComboUsed := true
		
		return
	}
	
	if (!IsSpaceComboUsed)
		PressBackSpace()
}

BackSpaceUp()
{
	IsSpaceComboUsed := false ; avoid accidental backspaces when space is relased too early
}

#If (IsMacKeyboard)

$*RWin::
	Suspend, Permit
	
	BackSpaceDown()
return
$*~RWin Up:: BackSpaceUp()

#If (!IsMacKeyboard)

$*RAlt::
	Suspend, Permit
	
	BackSpaceDown()
return
$*~RAlt Up:: BackSpaceUp()

#If

; bs => advanced bs
$*BackSpace::
	Suspend, Permit
	
	PressBackSpace()
return

; \ => caps-lock
; shift+\ => num-lock
*\ Up::
	if (IsShiftDown || IsFnDown)
		ToggleNumLock()
	else
		ToggleCapsLock()
return

; num-lock: simply pop up the icon box
$*~NumLock::
	Suspend, Permit
	
	IsNumLockOn := !IsNumLockOn
	
	; num-lock controls are reversed (num-lock in program is on when system num-lock is off)
	if (IsNumLockOn)
		ShowIconBox("NumLockOn")
	else
		ShowIconBox("NumLockOff")
return

;}

;}###################################################################################################
;      MOUSE
;{###################################################################################################

;{.... Methods ......................................................................................

/**
 * Adjusts the manager volume by 2 units.
 * 
 * Params:
 *   bool isDown - true for adjusting down, or false for up.
 *   bool forceUnmute - whether it should unmute as adjusting the volume. (default = false)
 */
AdjustVolume(isDown, forceUnmute := false)
{
	if (forceUnmute)
	{
		; {vol_down} and {vol_up} always unmute first
		if (isDown)
			SendInput, {Volume_Down}
		else
			SendInput, {Volume_Up}
		
		ShowVolumeIconBox()
		
		return
	}
	
	SoundGet, isMuted, , Mute
	SoundGet, volume
	
	volume += isDown ? -2 : 2
	
	if (volume > 100)
		volume := 100
	else if (volume < 0)
		volume := 0
	
	SoundSet, volume
	
	ShowVolumeIconBox(volume)
}

/**
 * Shows the icon box with current system volume and muting setting.
 * 
 * Params:
 *   int volume - the volume as value to show in the progress bar. pass -1 to automatically
 * read current system volume.
 */
ShowVolumeIconBox(volume := -1)
{
	if (volume = -1)
		SoundGet, volume
	
	SoundGet, isMuted, , Mute
	
	if (isMuted = "On")
	{
		progressBar := "Red"
		iconName := "MuteOn"
	}
	else
	{
		progressBar := "Green"
		
		if (volume < 10)
			iconName := "VolumeOff"
		else if (volume < 30)
			iconName := "VolumeLow"
		else if (volume < 50)
			iconName := "VolumeMedium"
		else
			iconName := "VolumeHigh"
	}
	
	ShowIconBox(iconName, progressBar, volume)
}

/**
 * Toggles the muting setting.
 */
ToggleMute()
{
	SendInput, {Volume_Mute}
	
	ShowVolumeIconBox()
}

/**
 * Adjusts the system brightness by 2 units.
 * 
 * Params:
 *   bool isDown - true for adjusting down, or false for up.
 */
AdjustBrightness(isDown)
{
	units := isDown ? -2 : 2
	
	VarSetCapacity(supportedBrightness, 256, 0)
	VarSetCapacity(supportedBrightnessSize, 4, 0)
	VarSetCapacity(brightnessSize, 4, 0)
	VarSetCapacity(brightness, 3, 0)
	
	hLcd := DllCall("CreateFile"
		,Str, "\\.\LCD"
		,UInt, 0x80000000 | 0x40000000 ; Read      | Write
		,UInt, 0x1        | 0x2        ; File Read | File Write
		,UInt, 0
		,UInt, 0x3                     ; open any existing file
		,UInt, 0
		,UInt, 0)
	
	if (hLcd == -1)
		return
	
	devVideo := 0x00000023
	buffMethod := 0
	fileAccess := 0
	
	NumPut(0x03, brightness, 0, "UChar") ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
	NumPut(0x00, brightness, 1, "UChar") ; The AC brightness level
	NumPut(0x00, brightness, 2, "UChar") ; The DC brightness level
	
	DllCall("DeviceIoControl"
		,UInt, hLcd
		,UInt, (devVideo << 16 | 0x126 << 2 | buffMethod << 14 | fileAccess) ; IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS
		,UInt, 0
		,UInt, 0
		,UInt, &brightness
		,UInt, 3
		,UInt, &brightnessSize
		,UInt, 0)
	
	DllCall("DeviceIoControl"
		,UInt, hLcd
		,UInt, (devVideo << 16 | 0x125 << 2 | buffMethod << 14 | fileAccess) ; IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS
		,UInt, 0
		,UInt, 0
		,UInt, &supportedBrightness
		,UInt, 256
		,UInt, &supportedBrightnessSize
		,UInt, 0)
	
	acBrightness := NumGet(brightness, 1, "UChar")
	acIndex := 0
	dcBrightness := NumGet(brightness, 2, "UChar")
	dcIndex := 0
	bufferSize := NumGet(supportedBrightnessSize, 0, "UInt")
	maxIndex := bufferSize - 1
	
	Loop, %bufferSize%
	{
		thisIndex := A_Index - 1
		thisBrightness := NumGet(supportedBrightness, thisIndex, "UChar")
		
		if (acBrightness = thisBrightness)
			acIndex := thisIndex
		if (dcBrightness = thisBrightness)
			dcIndex := thisIndex
	}
	
	if (dcIndex >= acIndex)
		brightnessIndex := dcIndex
	else
		brightnessIndex := acIndex
	
	brightnessIndex += units
	
	if (brightnessIndex > maxIndex)
		brightnessIndex := maxIndex
	else if (brightnessIndex < 0)
		brightnessIndex := 0
	
	newBrightness := NumGet(supportedBrightness, brightnessIndex, "UChar")
	
	NumPut(0x03, brightness, 0, "UChar")	; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
	NumPut(newBrightness, brightness, 1, "UChar")		; The AC brightness level
	NumPut(newBrightness, brightness, 2, "UChar")		; The DC brightness level
	
	DllCall("DeviceIoControl"
		,UInt, hLcd
		,UInt, (devVideo << 16 | 0x127 << 2 | buffMethod << 14 | fileAccess) ; IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS
		,UInt, &brightness
		,UInt, 3
		,UInt, 0
		,UInt, 0
		,UInt, 0
		,UInt, 0)
	 
	DllCall("CloseHandle", UInt, hLcd)
	
	brightnessValue := Round(brightnessIndex * 100 / maxIndex)
	
	ShowIconBox("brightness", "Green", brightnessValue)
}

;}
;{.... Wheel Controls ...............................................................................

; fn+wheel => volume adjustment
; shift+fn+wheel => brightness adjustment
WheelUp::
WheelDown::
+WheelUp::
+WheelDown::
	Suspend, Permit
	
	if (IsShiftDown)
	IsShiftKeyComboUsed := true
	
	isScrollingDown := InStr(A_ThisHotkey, "Down")
	
	if (IsFnDown)
	{
		if (IsShiftDown)
			AdjustBrightness(isScrollingDown)
		else
			AdjustVolume(isScrollingDown)
		
		IsFnKeyComboUsed := true
		
		return
	}
	
	if (IsInNormalScrolling ^ IsToggled || IsShiftDown)
	{
		if (isScrollingDown)
			SendInput, {WheelDown}
		else
			SendInput, {WheelUp}
		
		return
	}
	
	; magic scrolling (inactive window scrolling, windows 10 already supports natively)
	
	scrollDist := isScrollingDown ? -60 : 60
	
	MouseGetPos, mouseX, mouseY
	MouseGetPos, , , , secondTry, 2
	MouseGetPos, , , , thirdTry, 3
	
	firstTry := DllCall("WindowFromPoint"
		,Int, mouseX
		,Int, mouseY)
	
	if (secondTry == "")
	{
		SendMessage, 0x20A, scrollDist << 17, (mouseY << 16) | mouseX, , ahk_id %firstTry%
	}
	else
	{
		SendMessage, 0x20A, scrollDist << 17, (mouseY << 16) | mouseX, , ahk_id %secondTry%
		
		if (secondTry != thirdTry)
			SendMessage, 0x20A, scrollDist << 17, (mouseY << 16) | mouseX, , ahk_id %thirdTry%
	}
return

;}
;{.... Button Controls ..............................................................................

; fn+m-button => mute/unmute
; shift+fn+m-button => toggle normal scrolling
*MButton::
	if (IsFnDown)
	{
		IsFnKeyComboUsed := true
		
		if (IsShiftDown)
		{
			IsShiftKeyComboUsed := true
			
			if (IsInNormalScrolling := !IsInNormalScrolling)
				ShowIconBox("NormalScrollingOn")
			else
				ShowIconBox("NormalScrollingOff")
		}
		else
		{
			ToggleMute()
		}
		
		return
	}
	
	if (IsShiftDown)
		IsShiftKeyComboUsed := true
	
	SendInput, {MButton Down}
return

*MButton Up:: SendInput, {MButton Up}

; update shift key combo state when l- or r- button is pressed

*~LButton::
	if (IsShiftDown)
		IsShiftKeyComboUsed := true
	
	if (IsFnDown)
		IsFnKeyComboUsed := true
return

*~RButton::
	if (IsShiftDown)
		IsShiftKeyComboUsed := true
	
	if (IsFnDown)
		IsFnKeyComboUsed := true
return

;}

;}###################################################################################################
;      KEYBOARD
;{###################################################################################################

;{.... Methods ......................................................................................

/**
 * Sends a normal key press.
 * 
 * Params:
 *   string key - the name of the key, or the string to be sent when the key is pressed.
 *   string shiftedKey - the string to be sent when shift+(this key) is pressed.
 *   bool capsLockShift - whether CapsLock should lock the key to shifted. (default = false)
 *   bool blindShift - whether the shift key should be blind when the key is normally pressed
 * (this is useful so the key may be represented with it's "unshifted" version when it's shifted
 * is not representable with ahk scripts, such as the double-quote character). (default = true)
 */
Press(key, shiftedKey, capsLockShift := false, blindShift := true)
{
	if (shiftedKey = "")
	{
		shiftedKey := key
		blindShift := false
	}
	
	if (IsCapsLockOn && capsLockShift)
	{
		; PressBlindShift the key when caps+shift is used
		if (IsShiftDown)
			PressBlindShift(key, true, true)
		else
			PressBlindShift(shiftedKey, blindShift, true)
	}
	else
	{
		if (IsShiftDown)
			PressBlindShift(shiftedKey, blindShift, true)
		else
			SendInput, {%key%}
	}
}

/**
 * Sends a shifted key press.
 * 
 * Params:
 *   string key - the key to send as a shifted key.
 *   bool blindshift - whether shift-blinding should be used when sending this shifted key.
 * (default = true)
 *   bool useForcedKeyMode - whether it should send the autohotkey with the bracket
 * around the key. (default = true)
 */
PressBlindShift(key, blindShift := true, useForcedKeyMode := true)
{
	if (!blindShift)
	{
		SendInput, +{%key%}
		return
	}
	
	SendInput, {Shift Up}
	
	if (useForcedKeyMode)
		SendInput, {%key%}
	else
		SendInput, %key%
	
	if (IsShiftDown || !IsCapsLockOn || IsNumLockOn)
		SendInput, {Shift Down}
}

/**
 * Sends a special latin letter.
 * 
 * Params:
 *   string specChar - the special character to send.
 *   bool hasShiftedKey - whether the special character has a shifted key. (default = true)
 */
PressSpecChar(specChar, hasShiftedKey := true)
{
	if (CurrentSpecChar = specChar)
	{
		SendInput, {BackSpace}
	}
	else
	{
		CurrentSpecChar := specChar
		CurrentSpecIndex := 0
	}
	
	if ((IsShiftDown ^ IsCapsLockOn) && hasShiftedKey)
		SendInput, % CapSpecChars[CurrentSpecChar][++CurrentSpecIndex]
	else
		SendInput, % SpecChars[CurrentSpecChar][++CurrentSpecIndex]
	
	CurrentSpecIndex := Mod(CurrentSpecIndex, SpecChars[CurrentSpecChar].Length())
}

/**
 * Runs a file/program blinding all held hotkeys/dual-keys.
 * 
 * Params:
 *   string target - the target to run.
 *   string arg - the argument(s) to pass after calling the target as a string.
 * (default = "")
 */
RunBlindHotkeys(target, arg := "")
{
	BlindModifiers()
	
	if (IsShiftDown)
		Run, "%target%" %arg%, , Maximize, WinProcessId
	else
		Run, "%target%" %arg%, , , WinProcessId
	
	UnblindModifiers()
	
	; wait for the program window to pop up in order to force-activate it
	
	WinWait, ahk_pid %WinProcessId%, , 0
	WinActivate, ahk_pid %WinProcessId%, , 0
}

/**
 * Runs a command blinding all held hotkeys/dual-keys.
 * 
 * Params:
 *   string command - the command to run via cmd.exe.
 */
RunCommandBlindHotkeys(command)
{
	BlindModifiers()
	
	if (IsShiftDown)
		Run, %ComSpec% /C start /Max "" %command%, , , WinProcessId
	else
		Run, %ComSpec% /C start "" %command%, , , WinProcessId
	
	UnblindModifiers()
	
	WinWait, ahk_pid %WinProcessId%, , 0
	WinActivate, ahk_pid %WinProcessId%, , 0
}

;}
;{.... Mapping ......................................................................................

#If (!IsAnyHotkeyDown() && !IsToggled && !IsNumLockOn)

*SC029:: Press("``", "~", true) ; dead key
*1:: Press("#"	, "1"	, true)
*2:: Press("<"	, "2"	, true)
*3:: Press("{"	, "3"	, true)
*4:: Press("}"	, "4"	, true)
*5:: Press(">"	, "5"	, true)
*6:: Press("`%"	, "6"	, true)
*7:: Press("*"	, "7"	, true)
*8:: Press("["	, "8"	, true)
*9:: Press("("	, "9"	, true)
*0:: Press(")"	, "0"	, true)
*-:: Press("]"	, "$"	, true)
*=:: Press("@"	, "^"	, true)
*Q:: Press("'"	, ":")
*W:: Press(","	, "+")
*E:: Press("."	, "-")
*R:: Press("p"	, ""	, true)
*T:: Press("y"	, ""	, true)
*Y:: Press("f"	, ""	, true)
*U:: Press("g"	, ""	, true)
*I:: Press("c"	, ""	, true)
*O:: Press("r"	, ""	, true)
*P:: Press("l"	, ""	, true)
*[:: Press("/"	, "`\")
*]:: Press("&"	, "|")
*A:: Press("a"	, ""	, true)
*S:: Press("o"	, ""	, true)
*D:: Press("e"	, ""	, true)
*F:: Press("i"	, ""	, true)
*G:: Press("u"	, ""	, true)
*H:: Press("d"	, ""	, true)
*J:: Press("h"	, ""	, true)
*K:: Press("t"	, ""	, true)
*L:: Press("n"	, ""	, true)
*SC027:: Press("s", ""  , true) ; semicolon
*SC028:: Press("=", "_" , true) ; single-quote
*Z:: Press("`;"	, "'"	, false, false) ; i don't find a way to input double-quote in an ahk script
*X:: Press("q"	, ""	, true)
*C:: Press("j"	, ""	, true)
*V:: Press("k"	, ""	, true)
*B:: Press("x"	, ""	, true)
*N:: Press("b"	, ""	, true)
*M:: Press("m"	, ""	, true)
*,:: Press("w"	, ""	, true)
*.:: Press("v"	, ""	, true)
*/:: Press("z"	, ""	, true)

;}
;{.... Macros .......................................................................................

;{ keyboard/mouse macros

#If (IsFnDown && !IsCtrlDown && !IsCapsLockDown())

; fn+tab => alt+tab simulation (the fn key is easier to reach than alt key :D)
$Tab::
	IsFnTabUsed := true
	
	if (IsCapsLockOn)
		SetCapsLockState, Off
	
	; for some weird reasons this won't work properly when capslock is on
	
	SendInput, {Alt Down}{Tab}
return

; arrow keys

*E:: SendInput, {Up}
*S:: SendInput, {Left}
*D:: SendInput, {Down}
*F:: SendInput, {Right}

*W:: SendInput, ^{Left}
*R:: SendInput, ^{Right}

*A:: SendInput, {Home}
*G:: SendInput, {End}
*C:: Send, {PGUP}
*V:: Send, {PGDN}

; program functions

SC029:: SendInput, !{F4} ; dead key

Z:: SendInput, !{Left}
X:: SendInput, !{Right}

; windows control

; fn+q => toggle 50% transparency of the current window
Q::
	WinGet, trans, Transparent, A
	WinSet, Transparent, % (trans = 0x7F) ? 0xFF : 0x7F, A
return

; fn+t => toggle the pinning mode of the current window
T:: WinSet, AlwaysOnTop, , A

global IsNeverSleepModeOn := false

; fn+b => make the monitor never sleep
B::
	if (IsNeverSleepModeOn := !IsNeverSleepModeOn)
	{
		SetTimer, ForceWakeUp, 30000
		
		ShowIconBox("NeverSleepOn")
	}
	else
	{
		SetTimer, ForceWakeUp, Off
		
		ShowIconBox("NeverSleepOff")
	}
return

/**
 * A function that makes the monitor never sleep. This should be called
 * by a timer periodically.
 */
ForceWakeUp()
{
	SendInput, {Pause}
}

; system functions

Up::
	,:: AdjustVolume(false, true)
Down::
	M:: AdjustVolume(true, true)
Left::
	.:: AdjustBrightness(true)
Right::
	/:: AdjustBrightness(false)
+Down::
	N:: ToggleMute()

*1:: SendInput, {F1}
*2:: SendInput, {F2}
*3:: SendInput, {F3}
*4:: SendInput, {F4}
*5:: SendInput, {F5}
*6:: SendInput, {F6}
*7:: SendInput, {F7}
*8:: SendInput, {F8}
*9:: SendInput, {F9}
*0:: SendInput, {F10}
*-:: SendInput, {F11}
*=:: SendInput, {F12}

; mouse simulation (FN+L CANNOT BE USED IN MAC VERSION
; BECAUSE OF THE NATIVE G.DARN WIN+L MAPPING)

#If (IsFnDown && !IsCapsLockDown())

*U:: SendInput, {LButton}
*O:: SendInput, {RButton}
O & U:: SendInput, {MButton}

*I::
	if (IsShiftDown || IsCtrlDown)
		MouseMove, 0, -15, 0, Relative
	else
		SendInput, {WheelUp}{WheelUp}
return
*J::
	if (IsShiftDown || IsCtrlDown)
		MouseMove, -15, 0, 0, Relative
	else
		SendInput, {WheelLeft}{WheelLeft}
return
*K::
	if (IsShiftDown || IsCtrlDown)
		MouseMove, 0, 15, 0, Relative
	else
		SendInput, {WheelDown}{WheelDown}
return
*L::
*SC027::
	if (IsShiftDown || IsCtrlDown)
		MouseMove, 15, 0, 0, Relative
	else
		SendInput, {WheelRight}{WheelRight}
return

#If

;}
;{ quick-run macros

; shortcuts to run frequenly used programs

#If (IsFnDown && IsCtrlDown)

*Q:: RunBlindHotkeys("D:/Projects/")
*W:: RunBlindHotkeys("chrome")
*E:: RunBlindHotkeys("chrome", "--incognito")
*R:: RunCommandBlindHotkeys("%onedrive%") ; TODO: test if this works on school computers
*T:: RunBlindHotkeys("putty")
*A:: RunBlindHotkeys("notepad")
*S:: RunBlindHotkeys("snippingtool")
*D:: RunBlindHotkeys("shell:downloads")
*F:: RunBlindHotkeys("shell:startup")
*Z:: RunBlindHotkeys("taskmgr")
*X:: RunBlindHotkeys("devmgmt.msc")
*C:: RunBlindHotkeys("cmd")
*V:: RunBlindHotkeys("SystemPropertiesAdvanced")
*B:: RunBlindHotkeys("D:/实用工具/BootCamp.bat")

;}
;{ special character macros

#If (IsFnDown)

CapsLock & R:: Press("π", "Π")
CapsLock & T:: PressSpecChar("y")
CapsLock & Y:: Press("φ", "Φ")
CapsLock & U:: Press("γ", "Γ")
CapsLock & I:: Press("ç", "Ç")
CapsLock & O:: Press("ρ", "P")
CapsLock & P:: Press("λ", "Λ")
CapsLock & A:: PressSpecChar("a")
CapsLock & S:: PressSpecChar("o")
CapsLock & D:: PressSpecChar("e")
CapsLock & F:: PressSpecChar("i")
CapsLock & G:: PressSpecChar("u")
CapsLock & H:: Press("δ", "Δ")
CapsLock & J:: Press("η", "H")
CapsLock & K:: Press("θ", "Θ")
CapsLock & L:: Press("ñ", "Ñ") ; use capslock+. instead on mac version
CapsLock & SC027:: Press("σ", "Σ")
CapsLock & SC028:: Press("¡", "¿")
CapsLock & B:: Press("χ", "X")
CapsLock & N:: Press("ß", "B")
CapsLock & M:: Press("µ", "M")
CapsLock & ,:: Press("ω", "Ω")
CapsLock & .:: Press("ñ", "Ñ") ; avoid native win+l

CapsLock & SC029:: SendInput, % "↊" ; digit dek (upside-down 2)
CapsLock & 1:: SendInput, % "↋" ; digit el (upside-down 3)
CapsLock & 2:: SendInput, % "½"
CapsLock & 3:: SendInput, % "¾"
CapsLock & 4:: SendInput, % "¼"
CapsLock & 5:: SendInput, % "√"
CapsLock & 6:: SendInput, % "‰"
CapsLock & 7:: PressSpecChar("*", false)
CapsLock & -:: PressSpecChar("$", false)
CapsLock & =:: PressSpecChar("^", false)
CapsLock & W:: SendInput, % "±"
CapsLock & E:: SendInput, % "—"
CapsLock & X:: SendInput, % "™"
CapsLock & C:: SendInput, % "©"
CapsLock & V:: SendInput, % "®"

;}

;}
;{.... NumPad .......................................................................................

#If (IsNumLockOn && IsShiftDown && !IsAnyHotkeyDown())

SC029:: SendInput, % "↊" ; digit dek (upside-down 2)
1:: SendInput, % "↋" ; digit el (upside-down 3)
2:: PressBlindShift("=", true, false)
3:: SendInput, <
4:: SendInput, >
5:: SendInput, {!}
Q:: PressBlindShift("sqrt", true, false)
W:: PressBlindShift("i", true, false)
E:: PressBlindShift("e", true, false)
R:: PressBlindShift("pi", true, false)
T:: PressBlindShift("tan", true, false)
A:: PressBlindShift("a", true, false)
S:: PressBlindShift("sin", true, false)
D:: PressBlindShift("dne", true, false)
F:: PressBlindShift("infinity", true, false)
G:: PressBlindShift("log", true, false)
Z:: SendInput, % "$"
X:: PressBlindShift("x", true, false)
C:: PressBlindShift("cos", true, false)
V:: PressBlindShift("abs", true, false)
B:: PressBlindShift("ln", true, false)

#If (IsNumLockOn && !IsAnyHotkeyDown())

*CapsLock:: ToggleNumLock()

SC029:: SendInput, % ","
1:: SendInput, [
2:: SendInput, ]
3:: SendInput, (
4:: SendInput, )
5:: SendInput, *
Q:: SendInput, {^}
W:: SendInput, 1
E:: SendInput, 2
R:: SendInput, 3
T:: SendInput, /
A:: SendInput, .
S:: SendInput, 4
D:: SendInput, 5
F:: SendInput, 6
G:: SendInput, {+}
Z:: SendInput, `%
X:: SendInput, 7
C:: SendInput, 8
V:: SendInput, 9
B:: SendInput, -

+SC029:: SendInput, % "↊" ; digit dek (upside-down 2)
+1:: SendInput, % "↋" ; digit el (upside-down 3)
+2:: PressBlindShift("=", true, false)
+3:: SendInput, <
+4:: SendInput, >
+5:: SendInput, {!}
+Q:: PressBlindShift("sqrt", true, false)
+W:: PressBlindShift("i", true, false)
+E:: PressBlindShift("e", true, false)
+R:: PressBlindShift("pi", true, false)
+T:: PressBlindShift("tan", true, false)
+A:: PressBlindShift("a", true, false)
+S:: PressBlindShift("sin", true, false)
+D:: PressBlindShift("dne", true, false)
+F:: PressBlindShift("infinity", true, false)
+G:: PressBlindShift("log", true, false)
+Z:: SendInput, % "$"
+X:: PressBlindShift("x", true, false)
+C:: PressBlindShift("cos", true, false)
+V:: PressBlindShift("abs", true, false)
+B:: PressBlindShift("ln", true, false)

#If

;}

;}


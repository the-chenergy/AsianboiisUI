;####################################################################################################
;      CONFIGURATIONS
;{###################################################################################################

global Version := "3.4 (Beta)"
global LatestDate := "W 07/10/19"

#NoEnv
#SingleInstance, Force
#WinActivateForce
#MaxHotkeysPerInterval, 0x7FFFFFFF
#HotkeyInterval, 0x7FFFFFFF

SendMode, Input
SetKeyDelay, -1
SetMouseDelay, -1
SetControlDelay, -1
SetWorkingDir, %A_ScriptDir%
DetectHiddenWindows, On
FileEncoding, UTF-8

; extensions for cursor and caret finding
CoordMode, Mouse, Screen
CoordMode, Caret, Screen
CoordMode, ToolTip, Screen

; performance-wise
ListLines, Off

; keyboard function initializations
SetCapsLockState, AlwaysOff
SetNumLockState, On
ResetModifiers(false)

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
global IsMirrored := false
global IsToggled := false
; is it temporarily toggled (by capslock key)
global IsToggledByCapsLock := false
global IsInNormalScrolling := true
; is there any key/mouse action while some modifiers are down
global IsFnKeyComboUsed := false
global IsShiftKeyComboUsed := false
global IsCapsLockKeyComboUsed := false ; records "if scrolled" only
; is key combos related to tab key used
global IsTabKeyComboUsed := false
; is alt-tab(fn-tab) used while fn(l-win) is down
global IsFnTabUsed := false
; is shift(space)+bs(r-win, in mac version) used while shift(space) is down
global IsSpaceComboUsed := false
; smart switch: the keyboard will only be in asianboii's layout when a caret (text-input point)
; is present; otherwise the keyboard will switch to qwerty automatically
global IsSmartSwitchOn := false
; special character inputting settings
global CurrentSpecChar := ""
global CurrentSpecIndex := 0
global SpecCharDict := {a: ["á", "ä", "à", "ã", "â", "å", "æ", "α"]
	,e: ["é", "ë", "è", "ê", "ε"]
	,i: ["í", "ï", "ì", "î"]
	,o: ["ó", "ö", "ò", "õ", "ô", "ø"]
	,u: ["ú", "ü", "ù", "û"]
	,y: ["ý", "ÿ"]
	,"$": ["¢", "€", "£", "¥"]
	,"^": ["¹", "²", "³"]
	,"*": ["×", "÷", "•", "°"]}
global CapSpecCharDict := {a: ["Á", "Ä", "À", "Ã", "Â", "Å", "Æ", "Α"]
	,e: ["É", "Ë", "È", "Ê", "Ɛ"]
	,i: ["Í", "Ï", "Ì", ""]
	,o: ["Ó", "Ö", "Ò", "Õ", "Ô", "Ø"]
	,u: ["Ú", "Ü", "Ù", "Û"]
	,y: ["Ý", "Ÿ"]}
; the list of titles of windows hidden by fn hotkeys
global HiddenWinIds := []
; the list of titles of windows transparent to cursor
global TransparentWinIds := []
; is the monitor currently not allowed to sleep
global IsNeverSleepModeOn := false
global ForceWakeUpTimeout := 119000
; is left-hand mouse currently enabled
global IsLeftyMouseOn := false
; the volumes used as the steps when adjusting the master volume
global VolumeSteps := [1, 2, 3, 4, 6, 8, 10, 12, 16, 20, 24, 28, 35, 42, 49, 56, 67, 78, 89, 100]
global NumVolumeSteps := VolumeSteps.Length()

; chinese shuangpin ime related

global HasImeDict := false
global MarkDict := {}
; some marks have two symmetric parts, this records its index of mark so that
; it gives the correct part of mark on each key-press
global MarkCurrentIndexDict := {}
global OneKeyCharDict := {}
global CharDict := {}
global BigramDict := {}
global TrigramDict := {}
global LongDict := {}
global SylAltDict := {} ; syllable alternative input codes
global SylScrCodeDict := {} ; syllable screen codes
global StrScrCodeDict := {} ; str screen codes

global IsImeOn := false
global ImeCode := ""
global ImeCodeLength := 0
; the code shown on the screen
; (formatted, such as "zhong'wen" is shown instead of "itpw")
global ImeScreenCode := ""
global ImeCandidates := [] ; the candidates displayed in the ime hint box
global IsImeTempOff := false ; use capslock to temporarily turn off shuangpin ime

;}###################################################################################################
;      HELPERS
;{###################################################################################################

;{.... Default Configs (from ini) ...................................................................

global DataPath, DefaultMagicScrolling, IsMacKeyboard, AlwaysMaxPerformance

IniRead, DataPath, % "Settings.ini", % "Config", % "DataPath", % "Data"
IniRead, AlwaysMaxPerformance, % "Settings.ini", % "Config", % "AlwaysMaxPerformance", 0
IniRead, DefaultMagicScrolling, % "Settings.ini", % "Config", % "UseMagicScrolling", 0
IniRead, IsLeftyMouseOn, % "Settings.ini", % "Config", % "UseLeftyMouse", 0
IniRead, IsMacKeyboard, % "Settings.ini", % "Config", % "IsMacKeyboard", 0
IniRead, IsNeverSleepModeOn, % "Settings.ini", % "Config", % "NeverSleep", 0

global QuickRun := {} ; the dictionary used to store quick-run paths for each key

; generate quick-run key list
for i, keyName in StrSplit("QWERTYUIOPASDFGHJKLZXCVBNM")
{
	QuickRun[keyName] := {}
	
	IniRead, quickRunStr, % "Settings.ini", % "QuickRun", %keyName%, ""
	
	params := StrSplit(quickRunStr, "|")
	QuickRun[keyName]["path"] := params[1]
	QuickRun[keyName]["param"] := params[2]
}

if (AlwaysMaxPerformance = 1) ; performance control
	SetBatchLines, -1

IsInNormalScrolling := (DefaultMagicScrolling = 0)
IsNeverSleepModeOn := (IsNeverSleepModeOn = 1)
IsLeftyMouseOn := (IsLeftyMouseOn = 1)

if (IsNeverSleepModeOn)
	SwitchNeverSleep(true, false)

if (IsMacKeyboard = -1) ; auto detect if it is mac keyboard
{
	; check if bootcamp manager exists somewhere
	IsMacKeyboard := (FileExist("C:/Program Files/Boot Camp") != "")
	IsMacKeyboard |= (FileExist("D:/Program Files/Boot Camp") != "")
	IsMacKeyboard |= (FileExist("E:/Program Files/Boot Camp") != "")
	IsMacKeyboard |= (FileExist("F:/Program Files/Boot Camp") != "")
}

global FnKeyName := (IsMacKeyboard ? "LWin" : "LAlt")
global ToggleKeyName := (IsMacKeyboard ? "RAlt" : "RControl")

;}
;{.... GUI/IconBox ..................................................................................

global IconBox, IconBoxWidth := 150, IconBoxHeight := 150
global IsIconBoxShowing := false, ShowingIconName := ""

global NumScreens
SysGet, NumScreens, MonitorCount ; get the number of monitor for later to determine the one
; that the mouse is currently on

global MainScreenLeft, MainScreenTop, MainScreenRight, MainScreenBottom
if (NumScreens = 1)
	SysGet, MainScreen, Monitor, 1 ; get the coordinate of the main screen, just in case
	; there is only one screen, so we don't have to get it every time.

; create the gui instance
Gui, New, -Caption +ToolWindow +LastFound +AlwaysOnTop
WinGet, IconBox, Id

Gui, %IconBox%:Color, 202020
Gui, %IconBox%:Margin, 0, 0

; green and red progress bars
Gui, %IconBox%:Add, Progress, X15 Y120 W120 H15 Background111111 C2ECC71 VGreenBar
Gui, %IconBox%:Add, Progress, X15 Y120 W120 H15 Background111111 CC0392B VRedBar

; the list of icon names
global IconBoxIcons := ["CapsLockOn"
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
	,"NeverSleepOff"
	,"SmartSwitchOn"
	,"SmartSwitchOff"
	,"ImeOn"
	,"ImeOff"
	,"PinOn"
	,"PinOff"
	,"Opacity"
	,"LeftyMouseOn"
	,"LeftyMouseOff"]

; load icons from local folder
for i, iconBoxIcon in IconBoxIcons
	Gui, %IconBox%:Add, Picture, X0 Y0 V%iconBoxIcon%, % DataPath . "/" . iconBoxIcon . ".png"

Gui, %IconBox%:Show, X-1000 Y-1000 Hide ; make the gui out of screen first to let play its annoying animation
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
	SetTimer, HideIconBox, Off ; reset the timer in case it's not reset
	
	; hide the rest of unrelated icons
	for i, iconBoxIcon in IconBoxIcons
		if (iconBoxIcon != %iconName%)
			GuiControl, %IconBox%:Hide, %iconBoxIcon%
	
	; only show the icon when it is not already showing
	if (iconName != %ShowingIconName%)
	{
		GuiControl, %IconBox%:Show, %iconName%
		
		ShowingIconName := iconName
	}
	
	; do not trigger other actions when using testing mode
	if (testingMode)
	{
		Gui, %IconBox%:Show, X-10000 Y-10000, Hide
		Gui, %IconBox%:Show, W%IconBoxWidth% H%IconBoxHeight% NoActivate
		
		SetTimer, HideIconBox, -500
		
		return
	}
	
	; only check for cursor position after gui is hidden
	if (!IsIconBoxShowing)
	{
		position := GetIconBoxPosition()
		x := position.x
		y := position.y
		
		Gui, %IconBox%:Show, X%x% Y%y% Hide
	}
	
	Gui, %IconBox%:Show, W%IconBoxWidth% H%IconBoxHeight% NoActivate
	
	WinSet, AlwaysOnTop, Off, ahk_id %IconBox%
	WinSet, AlwaysOnTop, On, ahk_id %IconBox%
	
	IsIconBoxShowing := true
	
	if (progressBar = "Green")
	{
		GuiControl, %IconBox%:Show, GreenBar
		GuiControl, %IconBox%:, GreenBar, %progressValue%
	}
	else if (progressBar = "Red")
	{
		GuiControl, %IconBox%:Show, RedBar
		GuiControl, %IconBox%:, RedBar, %progressValue%
	}
	
	SetTimer, HideIconBox, -500 ; negative number means the timer should't loop.
}

/**
 * Forces the icon box GUI to hide. By default, it hides 500 milliseconds after it is shown.
 */
HideIconBox()
{
	SetTimer, IconBoxOff, -400
	DllCall("AnimateWindow", UInt, IconBox, Int, 200, UInt, 0x90000) ; play the fade-out amination
}

/**
 * Turns off IconBox "on-mode".
 */
IconBoxOff()
{
	IsIconBoxShowing := false
}

/**
 * Returns the position of where the icon box needs to pop up according to which screen
 * the mouse cursor is on.
 */
GetIconBoxPosition()
{
	if (NumScreens = 1)
		return {x: MainScreenRight - IconBoxWidth - 25
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
	
	return {x: currentScreenCoordRight - IconBoxWidth - 25
		,y: currentScreenCoordTop + 25}
}

;}
;{.... Shuangpin IME ................................................................................

; initialize hint box

global ImeBox, ImeBoxWidth, ImeBoxHeight, ImeBoxX, ImeBoxY
global IsImeBoxShowing := false

Gui, New, -Caption +ToolWindow +LastFound +AlwaysOnTop
WinGet, ImeBox, Id

Gui, %ImeBox%:Color, 202020
Gui, %ImeBox%:Margin, 0, 0

Gui, %ImeBox%:Font, Normal S11 Q5, Microsoft YaHei
Gui, %ImeBox%:Add, Text, X4 Y1 C666666 VCodeText

Gui, %ImeBox%:Font, Bold S12
Gui, %ImeBox%:Add, Text, X4 Y24 CCCCCCC VFirstText

Gui, %ImeBox%:Font, Normal
Gui, %ImeBox%:Add, Text, X4 Y48 CCCCCCC VRestText

/**
 * Shows the IME hint box with the candidates.
 */
ShowImeBox()
{
	width := 120
	
	rest := "" ; the candidates except for the first one
	
	; find the longest candidate to determine the width of the hint box
	; meanwhile, generate the text to show in RestText
	for i, candidate in ImeCandidates
	{
		candidateWidth := (StrLen(candidate) + 1) * 18
		
		if (candidateWidth > width)
			width := candidateWidth
		
		if (i > 1)
			rest .= i . " " . candidate . "`n"
	}
	
	height := (ImeCandidates.Length() + 1) * 24
	
	position := GetImeBoxPosition(width, height)
	x := position.x
	y := position.y
	
	forceShowUp := false
	
	if (!IsImeBoxShowing || ImeBoxX != x || ImeBoxY != y)
	{
		Gui, %ImeBox%:Show, X%x% Y%y% Hide
		
		ImeBoxX := x
		ImeBoxY := y
		
		IsImeBoxShowing := forceShowUp := true
	}
	
	if (forceShowUp || ImeBoxWidth != width || ImeBoxHeight != height)
	{
		Gui, %ImeBox%:Show, W%width% H%height% NoActivate
		
		ImeBoxWidth := width
		ImeBoxHeight := height
	}
	
	WinSet, Bottom, , %ImeBox%
	WinSet, Top, , %ImeBox%
	
	GuiControl, %ImeBox%:Show, CodeText
	
	WinSet, AlwaysOnTop, Off, ahk_id %ImeBox%
	WinSet, AlwaysOnTop, On, ahk_id %ImeBox%
	
	if (ImeScreenCode = "") ; "empty code"
		GuiControl, %ImeBox%:, CodeText, % ImeCode
	else
		GuiControl, %ImeBox%:, CodeText, % ImeScreenCode
	
	GuiControl, %ImeBox%:Move, CodeText, W%width%
	
	if (ImeCandidates.Length() >= 1)
	{
		GuiControl, %ImeBox%:Show, FirstText
		GuiControl, %ImeBox%:, FirstText, % (ImeCandidates.Length() > 1 ? "1 " : "") . ImeCandidates[1]
		GuiControl, %ImeBox%:Move, FirstText, W%width%
		
		if (ImeCandidates.Length() >= 2)
		{
			GuiControl, %ImeBox%:Show, RestText
			GuiControl, %ImeBox%:, RestText, % rest
			GuiControl, %ImeBox%:Move, RestText, W%width% H%height%
		}
	}
}

/**
 * Returns the position of where the hint box needs to pop up according to which screen
 * is focused.
 * 
 * Params:
 *   int width - the width of the hint box used to calculate for position.
 *   int height - the height.
 */
GetImeBoxPosition(width, height)
{
	if (A_CaretX = "")
	{
		MouseGetPos, mouseX, mouseY
		
		candidateX := mouseX
		candidateY := mouseY
	}
	else
	{
		candidateX := A_CaretX
		candidateY := A_CaretY
	}
	
	if (NumScreens = 1)
	{
		if (candidateX + width + 50 > MainScreenRight)
			candidateX := MainScreenRight - width - 25
		else
			candidateX += 25
		
		if (candidateY + height + 50 > MainScreenBottom)
			candidateY -= height + 15
		else
			candidateY += 25
		
		return {x: candidateX, y: candidateY}
	}
	
	; get the screen the candidate position ("focus point") is currently on
	
	Loop, %NumScreens%
	{
		SysGet, currentScreenCoord, Monitor, %A_Index%
		
		if (candidateX >= currentScreenCoordLeft && candidateX < currentScreenCoordRight
			&& candidateY >= currentScreenCoordTop && candidateY < currentScreenCoordBottom)
				break
	}
	
	if (candidateX + width + 50 > currentScreenCoordRight)
		candidateX := currentScreenCoordRight - width - 25
	else
		candidateX += 25
	
	if (candidateY + height + 50 > currentScreenCoordBottom)
		candidateY -= height + 15
	else
		candidateY += 25
	
	return {x: candidateX, y: candidateY}
}

/**
 * Hides the ime hint box.
 */
HideImeBox()
{
	Gui, %ImeBox%:Hide
	
	IsImeBoxShowing := false
}

/**
 * Sends the nth item in the IME candidate list.
 * 
 * Params:
 *   int index - the index of the item in the list to send. the raw typed-in code is sent
 * when this argument is set to 0 (default = 1).
 */
SendImeCandidate(index := 1)
{
	if (index > ImeCandidates.Length()) ; can't send beyond the maximum index
		index := ImeCandidates.Length()
	
	if (index = 0) ; no candidates are found
		SendInput, % ImeCode
	else
		SendInput, % ImeCandidates[index]
	
	; clear candidates and code typed in
	
	ImeCode := ""
	ImeCodeLength := 0
	
	ClearImeCandidates()
	
	HideImeBox()
}

/**
 * Removes everything in the IME candidate list and resets the screen code.
 */
ClearImeCandidates()
{
	while (ImeCandidates.Length())
		ImeCandidates.Pop()
	
	ImeScreenCode := ""
}

; load dictionaries

LoadIMECodeDicts(DataPath . "/IME.txt") ; this can only work in a function call for some reason

/**
 * Reads the code dictionaries of the Chinese Shuangpin IME from a file.
 * 
 * Params:
 *   string file - the path to the text file to read the dictionary from.
 */
LoadIMECodeDicts(file)
{
	if (!FileExist(file))
		return
	
	Loop, Read, %file%
	{
		line := A_LoopReadLine
		
		if (line = "")
			continue
		
		data := StrSplit(line, A_Space)
		
		if (data.Length() = 1)
		{
			currentDict := line
			
			continue
		}
		
		key := data.RemoveAt(1) ; the first element is the key and the rest are values
		
		if (currentDict = "[Marks]")
		{
			MarkDict.Insert(key, data)
			MarkCurrentIndexDict.Insert(key, 0)
		}
		else if (currentDict = "[1Keys]")
		{
			OneKeyCharDict.Insert(key, data[1])
		}
		else if (currentDict = "[Chars]")
		{
			if (CharDict.HasKey(key))
				CharDict[key].Push(data[1])
			else
				CharDict.Insert(key, [data[1]])
		}
		else if (currentDict = "[Bigrams]")
		{
			if (BigramDict.HasKey(key))
				BigramDict[key].Push(data[1])
			else
				BigramDict.Insert(key, [data[1]])
		}
		else if (currentDict = "[Trigrams]")
		{
			if (TrigramDict.HasKey(key))
				TrigramDict[key].Push(data[1])
			else
				TrigramDict.Insert(key, [data[1]])
		}
		else if (currentDict = "[Long]")
		{
			if (LongDict.HasKey(key))
				LongDict[key].Push(data[1])
			else
				LongDict.Insert(key, [data[1]])
		}
		else if (currentDict = "[SylAlts]")
		{
			SylAltDict.Insert(key, data[1])
		}
		else if (currentDict = "[SylScrCodes]")
		{
			SylScrCodeDict.Insert(key, data[1])
		}
		else if (currentDict = "[StrScrCodes]")
		{
			StrScrCodeDict.Insert(key, data[1])
		}
	}
	
	HasImeDict := true
}

;}
;{.... Tray Icon Controls ...........................................................................

/**
 * Sets the tooltip text of the icon shown in the system tray.
 * 
 * Params:
 *   string tipText - the text to show in the tooltip.
 */
SetTrayTipText(tipText)
{
	Menu, Tray, Tip, % "Programming Asianboii's UI`n" . (tipText = "" ? "" : "(" . tipText . ")`n") . "`n" . LatestDate . " v" . Version . "`nby Qianlang Chen`nqianlangchen@gmail.com"
}

/**
 * Sets the icon shown in the system tray.
 * 
 * Params:
 *   string iconName - the name of the icon to show (not including ".ico").
 */
SetTrayIcon(iconName)
{
	path := DataPath . "/" . iconName . ".ico"
	
	if (FileExist(path))
		Menu, Tray, Icon, % path, 1, 1
}

;}
;{.... Other Initializations .......................................................................................

; get the id of taskbar for ensuring the taskbar is always on top
; (in toggle-up)
global TaskBar
WinGet, TaskBar, Id, ahk_class Shell_TrayWnd

; ensure that the taskbar is always on top
WinSet, AlwaysOnTop, On, ahk_id %TaskBar%

; initalize system tray icon and text
SetTrayIcon("Default")
SetTrayTipText("")

;}
;{.... Testing Area .................................................................................

/*


Esc::
	
return*/

/*

Test()
{
	MsgBox, % "Toggled: " IsToggled "`nCapsLock: " IsCapsLockOn "`n`nFn: " IsFnDown n "`nCtrl: " IsCtrlDown "`nWin: " IsWinDown "`nAlt: " IsAltDown "`nShift: " IsShiftDown "`nPriorKey: " A_PriorKey
}
*/

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
 * Returns true if any of these modifiers is held down:
 * Fn, Alt, Ctrl, or Win.
 */
IsAnyHotkeyDown()
{
	if (IsToggled)
		return GetKeyState("Control", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P") || GetKeyState("Shift", "P")
	
	return IsFnDown || IsCtrlDown || IsWinDown || IsAltDown
}

/**
 * Returns true if any of these modifiers is held down:
 * Alt, Ctrl, or Win.
 */
IsAnyControlKeyDown()
{
	if (IsToggled)
		return GetKeyState("Control", "P") || GetKeyState("Alt", "P") || GetKeyState("LWin", "P") || GetKeyState("RWin", "P") || GetKeyState("Shift", "P")
	
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
 * Returns true if Tab key is currently held down.
 */
IsTabDown()
{
	return GetKeyState("Tab", "P")
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
	if (IsImeOn && ImeCodeLength > 0)
	{
		if (IsCtrlDown || IsImeTempOff) ; IsImeTempOff => capslock down
		{
			ImeCode := ""
			ImeCodeLength := 0
		}
		else
		{
			ImeCode := SubStr(ImeCode, 1, --ImeCodeLength)
		}
		
		if (ImeCodeLength > 0)
		{
			PressImeKey("")
		}
		else
		{
			ClearImeCandidates()
			
			HideImeBox()
		}
		
		return
	}
	
	if (IsToggled || IsImeTempOff)
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
	{
		SendInput, {Delete}
	}
	else
	{
		SendInput, {BackSpace}
	}
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
	; 
	; in other words, the "programed" num-lock should only be useful when
	; system num-lock is off
	
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
 * 
 * Params:
 *   bool mouseButtons - resets the left and right mouse buttons as well. (default = true)
 */
ResetModifiers(mouseButtons := true)
{
	PressMod("Shift", "Up")
	PressMod("Ctrl", "Up")
	PressMod("LWin", "Up")
	PressMod("Alt", "Up")
	
	IsFnDown := IsFnLockOn := false
	
	SendInput, {Space Up}
	SendInput, {Tab Up}
	
	IsMirrored := false
}

;}
;{.... Modifiers ....................................................................................
 
; shift => ctrl
$*LShift::
	if (IsCtrlDown)
		return
	
	PressMod("Ctrl")
	
	KeyWait, LShift
return

$*LShift Up::
	PressMod("Ctrl", "Up")
	
	; ahk bug: shift key sometimes doesn't pop up after l-shift (mapped l-ctrl)
	; releases
	if (!IsShiftDown)
		SendInput, {Shift Up}
return

$*RShift::
	if (IsCtrlDown)
		return
	
	PressMod("Ctrl")
	
	KeyWait, RShift
return

$*RShift Up::
	PressMod("Ctrl", "Up")
	
	if (!IsShiftDown)
		SendInput, {Shift Up}
return

; ctrl => win
$*LCtrl::
	PressMod("LWin")
	
	KeyWait, LCtrl
return

$*LCtrl Up::
	PressMod("LWin", "Up")
	
	if (!IsCtrlDown)
		SendInput, {Ctrl Up}
return

; alt => alt (MAC VERSION)
#If (IsMacKeyboard)

$*~LAlt::
	IsAltDown := true
	
	KeyWait, LAlt
return

$*~LAlt Up:: IsAltDown := false

; l-win => alt (PC VERSION)
#If (!IsMacKeyboard)

$*LWin::
	if (IsAltDown)
		return
	
	PressMod("Alt")
	
	KeyWait, LWin
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
	
	KeyWait, RWin
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

$*Space::
	Suspend, Permit
	
	if (IsMirrored)
	{
		SendInput, {Space Down}
		
		return
	}
	
	if (IsToggled)
	{
		if (IsToggledByCapsLock)
			SendInput, {Shift Down}
		else
			SendInput, {Space Down}
		
		return
	}
	
	if (IsShiftDown)
		return
	
	PressMod("Shift")
	
	KeyWait, Space
return

$*Space Up::
	Suspend, Permit
	
	if (IsMirrored || GetKeyState("Space", "P"))
	{
		SendInput, {Space Up}
		
		if (IsShiftDown)
			PressMod("Shift", "Up")
		
		return
	}
	
	if (IsToggled)
	{
		if (IsToggledByCapsLock)
		{
			SendInput, {Shift Up}
			
			if (A_PriorKey = "Space")
			{
				if (IsNumLockOn)
					SendInput, {Space}
				else
					SendInput, {Enter}
			}
		}
		else
		{
			SendInput, {Space Up}
			
			if (IsShiftDown)
				PressMod("Shift", "Up")
		}
		
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
			SendInput, ^{Shift}
		}
		else if (IsFnDown) ; toggle Chinese Shuangpin IME on/off
		{
			if (!IsFnKeyComboUsed) ; only toggle when there are no prior fn-hotkeys used
			{
				if (IsImeOn := !IsImeOn)
				{
					if (HasImeDict)
					{
						ShowIconBox("ImeOn")
						SetTrayIcon("Ime")
						SetTrayTipText("Chinese Shuangpin IME Activated")
					}
					else
					{
						IsImeOn := false
						
						MsgBox, % "The Shuangpin (双拼) IME dictionary could not be found. Please contact Asianboii for the dictionary file!!`n`nFile path: """ . DataPath . "/Ime.txt"""
					}
				}
				else
				{
					if (ImeCodeLength > 0)
						SendImeCandidate(0) ; clear candidates before switching IME off
					
					ShowIconBox("ImeOff")
					SetTrayIcon("Default")
					SetTrayTipText("")
				}
			}
		}
		else if (!IsAnyHotkeyDown())
		{
			if (IsImeOn && ImeCodeLength > 0)
				SendImeCandidate()
			else
				SendInput, {Space}
			
			if (IsNeverSleepModeOn) ; reset user's "inactive" clock
			{
				SetTimer, ForceWakeUp, Off
				SetTimer, ForceWakeUp, % ForceWakeUpTimeout
			}
		}
	}
	
	IsShiftKeyComboUsed := false ; reset
return

;}
;{ l-win(MAC)/l-alt(PC) => fn/esc

FnDown()
{
	if (IsMirrored)
	{
		PressBackSpace()
		
		return
	}
	
	if (IsShiftDown || IsFnLockOn)
	{
		if (IsFnLockOn := !IsFnLockOn)
			ShowIconBox("FnLockOn")
		
		IsFnKeyComboUsed := true
	}
	
	IsFnDown := true
	
	SetCapsLockState, AlwaysOff ; turn off capslock temporarily, because some hotkeys
	; (such as alt+tab) won't work with capslock on (autohotkey bug!)
}

FnUp()
{
	if (!IsFnDown || IsMirrored)
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
			if (IsCapsLockDown())
			{
				if (IsImeOn && ImeCodeLength > 0)
					PressBackSpace() ; delete the input code instead
				else
					SendInput, {BackSpace}
			}
			else if (IsImeOn && ImeCodeLength > 0)
			{
				SendImeCandidate(2)
			}
			else
			{
				SendInput, {Esc}
			}
		}
	}
	
	if (IsTabDown() && !IsTabKeyComboUsed) ; the user pressed fn+tab and released fn first
	; (sort of by mistake)
	{
		SendInput, !{Tab}
		
		IsTabKeyComboUsed := true ; prevent sending a "tab" character when tab releases
	}
	else if (IsFnTabUsed)
	{
		SendInput, {Alt Up}
		
		IsTabKeyComboUsed := false
	}
	
	IsFnTabUsed := false
	IsFnKeyComboUsed := false ; reset
	CurrentSpecChar := ""
	CurrentSpecIndex := 0 ; reset special caracter inputting settings
	
	if (IsCapsLockOn)
		SetCapsLockState, AlwaysOn ; reset capslock state
}

;{ mac keyboard layout definitions

#If (IsMacKeyboard)

$*LWin::
	Suspend, Permit
	
	if (IsToggled)
	{
		if (IsToggledByCapsLock)
			SendInput, {BackSpace}
		else
			SendInput, {LWin Down}
		
		return
	}
	
	FnDown()
	
	KeyWait, LWin
return

$*LWin Up::
	Suspend, Permit
	
	if (IsToggled)
	{
		if (!IsToggledByCapsLock)
			SendInput, {LWin Up}
		
		return
	}
	
	FnUp()
return

#If (!IsMacKeyboard)

$*LAlt::
	Suspend, Permit
	
	if (IsToggled)
	{
		if (IsToggledByCapsLock)
			SendInput, {BackSpace}
		else
			SendInput, {LAlt Down}
		
		return
	}
	
	FnDown()
	
	KeyWait, LAlt
return

$*LAlt Up::
	Suspend, Permit
	
	if (IsToggled)
	{
		if (!IsToggledByCapsLock)
			SendInput, {LAlt Up}
		
		return
	}
	
	FnUp()
return

#If

;}

;}
;{ r-alt(MAC)/r-ctrl(PC) => toggle/toggle-lock

global IsToggleDown := false

ToggleDown()
{
	if (IsToggleDown)
		return ; avoid the "toggling back and forth" while toggle is held down
	
	if (IsImeOn && ImeCodeLength > 0)
		SendImeCandidate(0) ; clear ime candidates before toggling
	
	IsToggleDown := true
	
	Suspend, Toggle
	
	IsToggled := !IsToggled
}

ToggleUp()
{
	; some key combo with toggle is used (such as shift+toggle: smart switch)
	if (!IsToggleDown)
		return
	
	IsToggleDown := false
	
	if (A_PriorKey = ToggleKeyName)
	{
		if (IsToggled)
		{
			SetTrayIcon("Toggle")
			SetTrayTipText("Toggled Off")
			
			ShowIconBox("ToggleOn")
			
			SoundBeep, 698
			SoundBeep, 466
		}
		else
		{
			if (IsImeOn)
			{
				SetTrayIcon("Ime")
				SetTrayTipText("Chinese Shuangpin IME Activated")
			}
			else
			{
				SetTrayIcon("Default")
				SetTrayTipText("")
			}
			
			ShowIconBox("ToggleOff")
			
			; update lock key states in case the user toggled them while script suspended
			IsCapsLockOn := GetKeyState("CapsLock", "T")
			IsNumLockOn := !GetKeyState("NumLock", "T")
			
			SoundBeep, 622
			SoundBeep, 932
		}
		
		ResetModifiers()
		
		; ensure that the taskbar, icon box, and ime box are on top
		
		WinSet, AlwaysOnTop, Off, ahk_id %IconBox%
		WinSet, AlwaysOnTop, On, ahk_id %IconBox%
		
		WinSet, AlwaysOnTop, Off, ahk_id %ImeBox%
		WinSet, AlwaysOnTop, On, ahk_id %ImeBox%
		
		WinSet, AlwaysOnTop, Off, ahk_id %TaskBar%
		WinSet, AlwaysOnTop, On, ahk_id %TaskBar%
	}
	else
	{
		Suspend, Toggle
		
		IsToggled := !IsToggled
	}
}

#If (IsMacKeyboard)

*RAlt::
	Suspend, Permit
	
	ToggleDown()
	
	KeyWait, RAlt
return

*RAlt Up::
	Suspend, Permit
	
	ToggleUp()
return

#If (!IsMacKeyboard)

*RCtrl::
	Suspend, Permit
	
	ToggleDown()
	
	KeyWait, RCtrl
return

*RCtrl Up::
	Suspend, Permit
	
	ToggleUp()
return

#If

;}
;{ caps-lock => toggle/!?

CapsLock::
+CapsLock::
	Suspend, Permit
	
	if (IsFnDown)
		return
	
	if (IsToggled)
	{
		if (!IsToggledByCapsLock)
			ToggleCapsLock()
		
		return
	}
	
	if (IsMirrored)
	{
		Press("=", "_", true, true, "'")
		
		IsCapsLockComboUsed := true
		
		return
	}
	
	if (IsImeOn)
	{
		if (!IsNumLockOn)
			IsImeTempOff := true
		
		return
	}
	
	IsToggled := IsToggledByCapsLock := true
	
	Suspend, On
	
	KeyWait, CapsLock
return

CapsLock Up::
+CapsLock Up::
	Suspend, Permit
	
	if (IsFnDown || IsNumLockOn)
	{
		if (A_PriorKey = "CapsLock")
		{
			ToggleNumLock()
			
			IsToggled := IsToggledByCapsLock := false
			IsCapsLockKeyComboUsed := false
			
			Suspend, Off
			
			return
		}
	}
	
	if (IsImeOn)
	{	
		IsImeTempOff := false
	}
	else if (!IsToggledByCapsLock || IsMirrored)
	{
		IsCapsLockKeyComboUsed := false
		
		return
	}
	
	IsToggled := IsToggledByCapsLock := false
	
	Suspend, Off
	
	IsCapsLockOn := GetKeyState("CapsLock", "T")
	IsNumLockOn := !GetKeyState("NumLock", "T")
	
	if (A_PriorKey = "CapsLock" && !IsCapsLockKeyComboUsed && !IsMirrored)
	{
		if (IsImeOn && ImeCodeLength > 0 && !IsShiftDown)
		{
			SendImeCandidate(3)
		}
		else
		{
			if (IsShiftDown)
				Press("?", "", true, true)
			else
				Press("!", "", true, true)
		}
	}
	
	IsCapsLockKeyComboUsed := false
	
	if (GetKeyState("Space", "P"))
		IsShiftKeyComboUsed := true ; avoid inserting a space afterwards
	
	if (GetKeyState(FnKeyName, "P"))
		IsFnKeyComboUsed := true ; avoid inserting an esc afterwards
return

;}
;{ tab => mirror/tab

$*Tab::
	Suspend, Permit
	
	if (IsFnDown)
	{
		if (IsFnTabUsed)
			SendInput, {Blind}{Tab}
		
		return
	}
	
	if (IsToggledByCapsLock || IsAnyControlKeyDown())
	{
		SendInput, {Blind}{Tab}
		
		IsTabKeyComboUsed := true
		
		return
	}
	
	IsMirrored := true
	
	KeyWait, Tab
return

$*Tab Up::
	Suspend, Permit
	
	if (IsFnDown)
	{
		if (!IsFnTabUsed)
		{
			IsFnTabUsed := true
			
			SendInput, {Alt Down}{Tab}
		}
		
		IsTabKeyComboUsed := true
		
		return
	}
	
	IsMirrored := false
	
	if (IsTabDown() && !IsFnTabUsed)
		SendInput, {Tab Up}
	
	if (A_PriorKey = "Tab" && !IsTabKeyComboUsed)
	{
		if (IsImeOn && ImeCodeLength > 0)
			SendImeCandidate(4)
		else
			SendInput, {Tab}
	}
	
	IsTabKeyComboUsed := false
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
		PressEnter()
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
*\::
	if (IsShiftDown || IsFnDown)
		ToggleNumLock()
	else
		ToggleCapsLock()
	
	KeyWait, \
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
	
	KeyWait, NumLock
return

; enter: send raw (typed-in) code when Shuangpin IME is on
PressEnter()
{
	if (IsImeOn && ImeCodeLength > 0)
		SendImeCandidate(0)
	else
		SendInput, {Enter}
}

Enter:: PressEnter()

;}

;}###################################################################################################
;      MOUSE
;{###################################################################################################

;{.... Methods ......................................................................................

/**
 * Adjusts the master volume by a "volume-step" (in the 1-2-4-7-11 scale).
 * 
 * Params:
 *   bool isDown - true for adjusting down, or false for up.
 *   bool forceUnmute - whether it should unmute as adjusting the volume. (default = false)
 */
AdjustVolume(isDown, forceUnmute := false)
{
	SoundGet, isMuted, , Mute
	isMuted := (isMuted = "On")
	
	SoundGet, volume
	volume := Round(volume)
	volumeStep := GetVolumeStep(volume)
	
	if (isDown)
	{
		if (volumeStep > 0)
			volumeStep--
	}
	else
	{
		if (volumeStep < NumVolumeSteps)
			volumeStep++
	}
	volume := VolumeSteps[volumeStep]
	
	if (forceUnmute && isMuted)
	{
		SoundSet, 0, , Mute
		isMuted := false
	}
	
	SoundSet, volume
	
	ShowVolumeIconBox(volumeStep / NumVolumeSteps, isMuted)
}

/**
 * Calculates and returns the volume step for a specific volume.
 * 
 * Params:
 *   double volume - the volume to calculate step.
 */
GetVolumeStep(volume)
{
	Loop, % NumVolumeSteps
	{
		if (VolumeSteps[A_Index] > volume)
			return A_Index - 1
	}
	
	return NumVolumeSteps
}

/**
 * Shows the icon box with current system volume and muting setting.
 * 
 * Params:
 *   int volume - the volume as value to show in the progress bar. pass -1 to automatically
 * read current system volume.
 *   bool isMuted - whether or not the volume is muted. (default = false)
 */
ShowVolumeIconBox(volume, isMuted := false)
{
	if (isMuted)
	{
		progressBar := "Red"
		iconName := "MuteOn"
	}
	else
	{
		progressBar := "Green"
		
		if (volume < .25)
			iconName := "VolumeOff"
		else if (volume < .50)
			iconName := "VolumeLow"
		else if (volume < .75)
			iconName := "VolumeMedium"
		else
			iconName := "VolumeHigh"
	}
	
	ShowIconBox(iconName, progressBar, volume * 100)
}

/**
 * Toggles the muting setting.
 */
ToggleMute()
{
	SoundGet, volume
	SoundGet, isMuted, , Mute
	ShowVolumeIconBox(GetVolumeStep(volume) / NumVolumeSteps, isMuted = "Off")
	
	SoundSet, -1, , Mute
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
	
	if (hLcd = -1)
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
	
	ShowIconBox("Brightness", "Green", brightnessValue)
}

;}
;{.... Wheel Controls ...............................................................................

/**
 * Performs a magic scrolling (inactive window scrolling).
 * 
 * Params:
 *   bool isDown - true for scrolling down, false otherwise.
 */
MagicScroll(isDown)
{
	scrollDist := (isDown ? -60 : 60) * (IsMirrored ? 5 : 1)
	
	MouseGetPos, mouseX, mouseY
	MouseGetPos, , , , secondTry, 2
	MouseGetPos, , , , thirdTry, 3
	
	firstTry := DllCall("WindowFromPoint"
		,Int, mouseX
		,Int, mouseY)
	
	if (secondTry = "")
	{
		SendMessage, 0x20A, scrollDist << 17, (mouseY << 16) | mouseX, , ahk_id %firstTry%
	}
	else
	{
		SendMessage, 0x20A, scrollDist << 17, (mouseY << 16) | mouseX, , ahk_id %secondTry%
		
		if (secondTry != thirdTry)
			SendMessage, 0x20A, scrollDist << 17, (mouseY << 16) | mouseX, , ahk_id %thirdTry%
	}
}

; fn+wheel => volume adjustment
; shift+fn+wheel => brightness adjustment
WheelUp::
WheelDown::
+WheelUp::
+WheelDown::
	Suspend, Permit
	
	if (IsMirrored)
		IsTabKeyComboUsed := true
	
	if (IsShiftDown)
		IsShiftKeyComboUsed := true
	
	if (IsToggledByCapsLock)
		IsCapsLockKeyComboUsed := true
	
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
	
	if (IsInNormalScrolling ^ IsMirrored || IsShiftDown)
	{
		Loop, % IsToggledByCapsLock ? 4 : 1
		{
			if (isScrollingDown)
				SendInput, {WheelDown}
			else
				SendInput, {WheelUp}
		}
		
		return
	}
	
	; magic scrolling (inactive window scrolling, windows 10 already supports natively)
	
	MagicScroll(isScrollingDown)
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

; update shift key combo state when l- or r-button is pressed

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

#If (IsLeftyMouseOn)

*LButton::
	SendInput, {RButton Down}
	
	KeyWait, LButton
return

*LButton Up:: SendInput, {RButton Up}

*RButton::
	SendInput, {LButton Down}
	
	KeyWait, RBUtton
return

*RButton Up:: SendInput, {LButton Up}

#If

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
 *   string smartSwitchKey - the (normal) key to send instead when smart-switch is on and there
 * is no caret detected; if set to empty string, this functionality is off. (default = "")
 */
Press(key, shiftedKey, capsLockShift := false, blindShift := true, smartSwitchKey := "")
{
	if (smartSwitchKey != "")
	{
		if (IsSmartSwitchOn && A_CaretX = "") ; no caret on screen
		{
			SendInput, {%smartSwitchKey%}
			
			return
		}
	}
	
	if (shiftedKey = "")
	{
		shiftedKey := key
		blindShift := false
	}
	
	if (IsCapsLockOn && capsLockShift)
	{
		; PressBlindShift the key when caps+shift is used
		if (IsShiftDown)
			PressBlindShift(key, true)
		else
			PressBlindShift(shiftedKey, blindShift)
	}
	else
	{
		if (IsImeOn && !IsImeTempOff)
		{
			if (IsShiftDown)
			{
				if (blindShift)
				{
					PressImeKey(shiftedKey)
				}
				else ; it's an upper-case letter
				{
					StringUpper, key, key
					
					PressImeKey(key)
				}
			}
			else
			{
				PressImeKey(key)
			}
		}
		else
		{
			if (IsShiftDown)
				PressBlindShift(shiftedKey, blindShift)
			else
				SendInput, {%key%}
		}
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
 * Sends a key to the Chinese Shupangpin IME.
 * 
 * Params:
 *   string key - the key to send to the IME.
 */
PressImeKey(key)
{
	if (ImeCodeLength = 0 || ImeCodeLength = 4)
	{
		if (ImeCodeLength = 4) ; push the first candidate onto screen
			SendImeCandidate(1)
		
		if (!OneKeyCharDict.HasKey(key))
		{
			if (MarkDict.HasKey(key)) ; "chinese" punctuation marks
			{
				SendInput, % MarkDict[key][++MarkCurrentIndexDict[key]]
				
				MarkCurrentIndexDict[key] := Mod(MarkCurrentIndexDict[key], MarkDict[key].Length())
			}
			else
			{
				PressBlindShift(key)
			}
			
			return
		}
	}
	
	if (key != "") ; a blank key only means to update
	{
		ImeCode .= key
		ImeCodeLength++
	}
	
	ClearImeCandidates()
	
	if (ImeCodeLength = 1)
	{
		ImeCandidates.Push(OneKeyCharDict[ImeCode])
		ImeScreenCode := SylScrCodeDict[ImeCode]
	}
	else if (ImeCodeLength = 2)
	{
		if (SylAltDict.HasKey(ImeCode)) ; add alternative syllable input first
		{
			altSyl := SylAltDict[ImeCode]
			
			ImeCandidates.Push(CharDict[altSyl][1])
			ImeScreenCode := SylScrCodeDict[altSyl]
		}
		
		if (CharDict.HasKey(ImeCode))
		{
			ImeCandidates.Push(CharDict[ImeCode][1])
			
			if (ImeScreenCode = "") ; the screen code always belongs to the first candidate only
				ImeScreenCode := SylScrCodeDict[ImeCode]
		}
	}
	else if (ImeCodeLength = 3)
	{
		strCode := SubStr(ImeCode, 3, 1)
		
		if (CharDict.HasKey(ImeCode)) ; non-alternative inputs have a higher priority this time
		{
			for i, char in CharDict[ImeCode]
				ImeCandidates.Push(char)
			
			ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 2)] . " [" . StrScrCodeDict[strCode] . "]"
		}
		
		altSyl := SubStr(ImeCode, 1, 2)
		
		if (SylAltDict.HasKey(altSyl))
		{
			altSyl := SylAltDict[altSyl]
			
			if (CharDict.HasKey(altSyl . strCode))
			{
				for i, char in CharDict[altSyl . strCode]
					ImeCandidates.Push(char)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[altSyl] . " [" . StrScrCodeDict[strCode] . "]"
			}
		}
	}
	else ; if (length = 4)
	{
		firstSyl := SubStr(ImeCode, 1, 2)
		secondSyl := SubStr(ImeCode, 3, 2)
		
		altFirstSyl := SylAltDict.HasKey(firstSyl) ? SylAltDict[firstSyl] : ""
		altSecondSyl := SylAltDict.HasKey(secondSyl) ? SylAltDict[secondSyl] : ""
		
		; bigrams have the highest priority in this case
		
		if (BigramDict.HasKey(ImeCode)) ; first . second
		{
			for i, bigram in BigramDict[ImeCode]
				ImeCandidates.Push(bigram)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[firstSyl] . "'" . SylScrCodeDict[secondSyl]
		}
		
		if (altSecondSyl != "" && BigramDict.HasKey(firstSyl . altSecondSyl))
		{
			for i, bigram in BigramDict[firstSyl . altSecondSyl]
				ImeCandidates.Push(bigram)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[firstSyl] . "'" . SylScrCodeDict[altSecondSyl]
		}
		
		if (altFirstSyl != "" && BigramDict.HasKey(altFirstSyl . secondSyl))
		{
			for i, bigram in BigramDict[altFirstSyl . secondSyl]
				ImeCandidates.Push(bigram)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[altFirstSyl] . "'" . SylScrCodeDict[secondSyl]
		}
		
		if (altFirstSyl != "" && altSecondSyl != "" && BigramDict.HasKey(altFirstSyl . altSecondSyl))
		{
			for i, bigram in BigramDict[altFirstSyl . altSecondSyl]
				ImeCandidates.Push(bigram)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[altFirstSyl] . "'" . SylScrCodeDict[altSecondSyl]
		}
		
		; trigrams come second in proirity
		
		if (TrigramDict.HasKey(ImeCode))
		{
			for i, trigram in TrigramDict[ImeCode]
				ImeCandidates.Push(trigram)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 1)] . "'" . SylScrCodeDict[SubStr(ImeCode, 2, 1)] . "'" . SylScrCodeDict[secondSyl]
		}
		
		if (altSecondSyl != "" && TrigramDict.HasKey(firstSyl . altSecondSyl))
		{
			for i, trigram in TrigramDict[firstSyl . altSecondSyl] ; "firstSyl" here is not really a syllable, it's two initials
				ImeCandidates.Push(trigram)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 1)] . "'" . SylScrCodeDict[SubStr(ImeCode, 2, 1)] . "'" . SylScrCodeDict[altSecondSyl]
		}
		
		; then all long phrases
		
		if (LongDict.HasKey(ImeCode))
		{
			for i, long in LongDict[ImeCode]
				ImeCandidates.Push(long)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 1)] . "'" . SylScrCodeDict[SubStr(ImeCode, 2, 1)] . "'" . SylScrCodeDict[SubStr(ImeCode, 3, 1)] . "'" . SylScrCodeDict[SubStr(ImeCode, 4, 1)]
		}
		
		; finally all full-coded characters
		
		if (CharDict.HasKey(ImeCode))
		{
			for i, char in CharDict[ImeCode]
				ImeCandidates.Push(char)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[firstSyl] . " [" . StrScrCodeDict[SubStr(secondSyl, 1, 1)] . "," . StrScrCodeDict[SubStr(secondSyl, 2, 1)] . "]"
		}
		
		if (altFirstSyl != "" && CharDict.HasKey(altFirstSyl . secondSyl))
		{
			for i, char in CharDict[altFirstSyl . secondSyl] ; secondSyl is not a syllable here, it's two str codes
				ImeCandidates.Push(char)
			
			if (ImeScreenCode = "")
				ImeScreenCode := SylScrCodeDict[altFirstSyl] . " [" . StrScrCodeDict[SubStr(secondSyl, 1, 1)] . "," . StrScrCodeDict[SubStr(secondSyl, 2, 1)] . "]"
		}
	}
	
	if (ImeScreenCode = "") ; "empty code"
		ImeScreenCode := ImeCode
	
	ShowImeBox()
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
		Press(CapSpecCharDict[CurrentSpecChar][++CurrentSpecIndex], "")
	else
		Press(SpecCharDict[CurrentSpecChar][++CurrentSpecIndex], "")
	
	CurrentSpecIndex := Mod(CurrentSpecIndex, SpecCharDict[CurrentSpecChar].Length())
}

/**
 * Runs a file/program blinding all held hotkeys/dual-keys.
 * 
 * Params:
 *   string key - the QuickRun key pressed. (default = "")
 */
RunBlindHotkeys(key)
{
	IsTabKeyComboUsed := true ; since quick-runs are now triggered by fn+tab
	
	target := QuickRun[key]["path"]
	
	if (target = "")
		return
	
	param := QuickRun[key]["param"]
	
	if (param = "(cmd)")
	{
		RunCommandBlindHotkeys(target)
		
		return
	}
	
	BlindModifiers()
	
	if (IsShiftDown)
		Run, "%target%" %param%, , Maximize, WinProcessId
	else
		Run, "%target%" %param%, , , WinProcessId
	
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
		Run, %ComSpec% /C start /Max "" %command%, , Hide, WinProcessId
	else
		Run, %ComSpec% /C start "" %command%, , Hide, WinProcessId
	
	UnblindModifiers()
	
	WinWait, ahk_pid %WinProcessId%, , 0
	WinActivate, ahk_pid %WinProcessId%, , 0
}

;}
;{.... Mapping ......................................................................................

;{ normal

#If (!IsAnyHotkeyDown() && !IsToggled && !IsNumLockOn && !IsMirrored)

$*SC029:: Press("``", "~", true) ; dead key
$*1:: Press("#"	, "1"	, true,  true, "1")
$*2:: Press("<"	, "2"	, true,  true, "2")
$*3:: Press("{"	, "3"	, true,  true, "3")
$*4:: Press("}"	, "4"	, true,  true, "4")
$*5:: Press(">"	, "5"	, true,  true, "5")
$*6:: Press("`%", "6"	, true,  true, "6")
$*7:: Press("*"	, "7"	, true,  true, "7")
$*8:: Press("["	, "8"	, true,  true, "8")
$*9:: Press("("	, "9"	, true,  true, "9")
$*0:: Press(")"	, "0"	, true,  true, "0")
$*-:: Press("]"	, "$"	, true,  true, "-")
$*=:: Press("@"	, "^"	, true,  true, "=")
$*Q:: Press("'"	, ":"	, false, true, "q")
$*W:: Press(","	, "+"	, false, true, "w")
$*E:: Press("."	, "-"	, false, true, "e")
$*R:: Press("p"	, ""	, true,  true, "r")
$*T:: Press("y"	, ""	, true,  true, "t")
$*Y:: Press("f"	, ""	, true,  true, "y")
$*U:: Press("g"	, ""	, true,  true, "u")
$*I:: Press("c"	, ""	, true,  true, "i")
$*O:: Press("r"	, ""	, true,  true, "o")
$*P:: Press("l"	, ""	, true,  true, "p")
$*[:: Press("/"	, "`\"	, false, true, "[")
$*]:: Press("&"	, "|"	, false, true, "]")
$*A:: Press("a"	, ""	, true,  true, "a")
$*S:: Press("o"	, ""	, true,  true, "s")
$*D:: Press("e"	, ""	, true,  true, "d")
$*F:: Press("i"	, ""	, true,  true, "f")
$*G:: Press("u"	, ""	, true,  true, "g")
$*H:: Press("d"	, ""	, true,  true, "h")
$*J:: Press("h"	, ""	, true,  true, "j")
$*K:: Press("t"	, ""	, true,  true, "k")
$*L:: Press("n"	, ""	, true,  true, "l")
$*SC027:: Press("s", ""  , true, true, "`;") ; semicolon
$*SC028:: Press("=", "_" , true, true, "'") ; single-quote
$*Z:: Press("`;", """"	, false, true, "z") ; double double-quotes escape a double-quote. good to know
$*X:: Press("q"	, ""	, true,  true, "x")
$*C:: Press("j"	, ""	, true,  true, "c")
$*V:: Press("k"	, ""	, true,  true, "v")
$*B:: Press("x"	, ""	, true,  true, "b")
$*N:: Press("b"	, ""	, true,  true, "n")
$*M:: Press("m"	, ""	, true,  true, "m")
$*,:: Press("w"	, ""	, true,  true, ",")
$*.:: Press("v"	, ""	, true,  true, ".")
$*/:: Press("z"	, ""	, true,  true, "/")

;}
;{ mirrored

#If (!IsNumLockOn && IsMirrored)

;{ number row

*SC029:: ; dead key
	Suspend, Permit
	
	SendInput, {Delete}
return

*1::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {=}
	else
		Press("@"	, "^"	, true, true, "=")
return

*2::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {-}
	else
		Press("["	, "$"	, true, true, "-")
return

*3::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {0}
	else
		Press("("	, "0"	, true, true, "0")
return

*4::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {9}
	else
		Press(")"	, "9"	, true, true, "9")
return

*5::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {8}
	else
		Press("]"	, "8"	, true, true, "8")
return

*6::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {7}
	else
		Press("*"	, "7"	, true, true, "7")
return

;}
;{ top row

*Q::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, p
	else
		Press("l"	, ""	, true, true, "p")
return

*W::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, o
	else
		Press("r"	, ""	, true, true, "o")
return

*E::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, i
	else
		Press("c"	, ""	, true, true, "i")
return

*R::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, u
	else
		Press("g"	, ""	, true, true, "u")
return

*T::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, y
	else
		Press("f"	, ""	, true, true, "y")
return

;}
;{ home row

*A::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, SC027 ; semicolon
	else
		Press("s"	, ""	, true, true, "`;")
return

*S::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, l
	else
		Press("n"	, ""	, true, true, "l")
return

*D::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, k
	else
		Press("t"	, ""	, true, true, "k")
return

*F::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, j
	else
		Press("h"	, ""	, true, true, "j")
return

*G::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, h
	else
		Press("d"	, ""	, true, true, "h")
return

;}
;{ bottom row

*Z::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {/}
	else
		Press("z"	, ""	, true, true, "/")
return

*X::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {.}
	else
		Press("v"	, ""	, true, true, ".")
return

*C::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, {,}
	else
		Press("w"	, ""	, true, true, ",")
return

*V::
	Suspend, Permit
	
	Press("m"	, ""	, true)
return

*B::
	Suspend, Permit
	
	if (IsToggled || IsAnyControlKeyDown())
		SendInput, n
	else
		Press("b"	, ""	, true, true, "n")
return

;}

#If

;}

;}
;{.... Macros .......................................................................................

;{ keyboard/mouse macros (fn+**)

#If (IsFnDown && !IsAltDown && !IsCapsLockDown() && !IsMirrored)

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

; fn+q => minimize current window
Q:: WinMinimize, A

; fn+t => toggle the pinning mode of the current window
T::
	WinSet, AlwaysOnTop, , A
	
	; ensure that the taskbar is always on top
	
	WinSet, AlwaysOnTop, Off, ahk_id %TaskBar%
	WinSet, AlwaysOnTop, On, ahk_id %TaskBar%
	
	WinGet, isPinned, ExStyle, A
	
	if (isPinned & 0x8) ; ws_ex_topmost
		ShowIconBox("PinOn")
	else
		ShowIconBox("PinOff")
return

; fn+y => toggle 25%/50%/75% transparency of the current window
Y::
	WinGet, trans, Transparent, A
	
	trans := (trans = "") ? 0x3F : Mod((trans + 0x40), 0x100)
	
	WinSet, Transparent, % trans, A
	
	ShowIconBox("Opacity", "Green", trans / 0x100 * 100)
return

; fn+h => hide the window and its icon in the taskbar
; without killing the process
H::
	; record the title of the window for later to unhide it
	; (there is no convient way to focus it since it's hidden)

	HiddenWinIds.Push(WinExist("A"))
	
	WinHide, A
	; apply tool-window style to force hide taskbar icon
	WinSet, ExStyle, +0x80, A
return

; fn+n => toggle "smart switch"
; (switch keyboard layout to PADV when there is focus, or qwerty otherwise)
N::
	if (IsSmartSwitchOn := !IsSmartSwitchOn)
		ShowIconBox("SmartSwitchOn")
	else
		ShowIconBox("SmartSwitchOff")
	
return

; fn+m => make the current window transparent to mouse
M::
	; record the title of the window for later to un-transparent it
	; (there is no convient way to focus it since it's transparent)
	
	TransparentWinIds.Push(WinExist("A"))
	
	WinSet, AlwaysOnTop, On, A
	WinSet, ExStyle, +0x80020, A
	WinSet, Transparent, 0x7F, A
return

; fn+' => undo making all windows transparent to mouse
; and unhide all hidden windows
SC028::
	while (TransparentWinIds.Length())
	{
		winId := TransparentWinIds.Pop()
		
		WinSet, AlwaysOnTop, Off, ahk_id %winId%
		WinSet, ExStyle, -0x80020, ahk_id %winId%
		WinSet, Transparent, 0xFF, ahk_id %winId%
	}
	
	while (HiddenWinIds.Length())
	{
		winId := HiddenWinIds.Pop()
		
		WinShow, ahk_id %winId%
		; turn off tool window styles
		WinSet, ExStyle, -0x80, ahk_id %winId%
	}
	
	; focus the last un-tranparent-ized window
	WinActivate, ahk_id %winId%
return

; fn+b => make the monitor never sleep
B::
	SwitchNeverSleep(IsNeverSleepModeOn := !IsNeverSleepModeOn)
return

/**
 * Turns the never-sleep mode on or off.
 * 
 * params:
 *   bool state - on (true) or off (false).
 *   bool showIcon - show the icon box (true) or not (false). (default = true)
 */
SwitchNeverSleep(state, showIcon := true)
{
	if (state)
	{
		SetTimer, ForceWakeUp, % ForceWakeUpTimeout
		
		if (showIcon)
			ShowIconBox("NeverSleepOn")
	}
	else
	{
		SetTimer, ForceWakeUp, Off
		
		if (showIcon)
			ShowIconBox("NeverSleepOff")
	}
}

/**
 * A function that makes the monitor never sleep. This should be called
 * by a timer periodically.
 */
ForceWakeUp()
{
	SendInput, {ScrollLock}
	SendInput, {ScrollLock}
}

; system functions

Up::
	.:: AdjustVolume(false, true)
Down::
	,:: AdjustVolume(true, true)
Left::
	+,:: AdjustBrightness(true)
Right::
	+.:: AdjustBrightness(false)
+Down::
	/:: ToggleMute()

*1:: SendInput, {Blind}{F1}
*2:: SendInput, {Blind}{F2}
*3:: SendInput, {Blind}{F3}
*4:: SendInput, {Blind}{F4}
*5:: SendInput, {Blind}{F5}
*6:: SendInput, {Blind}{F6}
*7:: SendInput, {Blind}{F7}
*8:: SendInput, {Blind}{F8}
*9:: SendInput, {Blind}{F9}
*0:: SendInput, {Blind}{F10}
*-:: SendInput, {Blind}{F11}
*=:: SendInput, {Blind}{F12}
*[:: SendInput, {PrintScreen}
*]:: SendInput, !{PrintScreen}

; fn+shift+(r-button)+(l+button) => toggle left-hand mouse / swap mouse buttons
RButton & LButton::
LButton & RButton::
	if (IsLeftyMouseOn := !IsLeftyMouseOn)
		ShowIconBox("LeftyMouseOn")
	else
		ShowIconBox("LeftyMouseOff")
	
	SendInput, {LButton Up}
	SendInput, {RButton Up}
return

; mouse simulation (FN+L CANNOT BE USED IN MAC VERSION
; BECAUSE OF THE STUPID NATIVE WIN+L MAPPING)

#If (IsFnDown && !IsCapsLockDown() && !IsMirrored)

*U:: SendInput, {Blind}{LButton}
*O:: SendInput, {Blind}{RButton}
*P:: SendInput, {Blind}{MButton}

*I::
	if (IsShiftDown || IsCtrlDown)
	{
		MouseMove, 0, -15, 0, Relative
		
		IsFnKeyComboUsed := true
	}
	else
	{
		if (IsInNormalScrolling)
		{
			SendInput, {WheelUp}{WheelUp}
			
			return
		}
		
		MagicScroll(false)
		MagicScroll(false)
	}
return

*J::
	if (IsShiftDown || IsCtrlDown)
	{
		MouseMove, -15, 0, 0, Relative
		
		IsFnKeyComboUsed := true
	}
	else
	{
		SendInput, {WheelLeft}
	}
return

*K::
	if (IsShiftDown || IsCtrlDown)
	{
		MouseMove, 0, 15, 0, Relative
		
		IsFnKeyComboUsed := true
	}
	else
	{
		if (IsInNormalScrolling)
		{
			SendInput, {WheelDown}{WheelDown}
			
			return
		}
		
		MagicScroll(true)
		MagicScroll(true)
	}
return

*L::
*SC027:: ; semicolon
	if (IsShiftDown || IsCtrlDown)
	{
		MouseMove, 15, 0, 0, Relative
		
		IsFnKeyComboUsed := true
	}
	else
	{
		SendInput, {WheelRight}
	}
return

#If

;}
;{ quick-run macros (ft+tab+**)

; shortcuts to run frequenly used programs

#If (IsFnDown && !IsFnTabUsed && !IsTabComboUsed && !IsCtrlDown && !IsAltDown && !IsCapsLockDown())

Tab & Q:: RunBlindHotkeys("Q")
Tab & W:: RunBlindHotkeys("W")
Tab & E:: RunBlindHotkeys("E")
Tab & R:: RunBlindHotkeys("R")
Tab & T:: RunBlindHotkeys("T")
Tab & Y:: RunBlindHotkeys("Y")
Tab & U:: RunBlindHotkeys("U")
Tab & I:: RunBlindHotkeys("I")
Tab & O:: RunBlindHotkeys("O")
Tab & P:: RunBlindHotkeys("P")
Tab & A:: RunBlindHotkeys("A")
Tab & S:: RunBlindHotkeys("S")
Tab & D:: RunBlindHotkeys("D")
Tab & F:: RunBlindHotkeys("F")
Tab & G:: RunBlindHotkeys("G")
Tab & H:: RunBlindHotkeys("H")
Tab & J:: RunBlindHotkeys("J")
Tab & K:: RunBlindHotkeys("K")
Tab & L:: RunBlindHotkeys("L")
Tab & Z:: RunBlindHotkeys("Z")
Tab & X:: RunBlindHotkeys("X")
Tab & C:: RunBlindHotkeys("C")
Tab & V:: RunBlindHotkeys("V")
Tab & B:: RunBlindHotkeys("B")
Tab & N:: RunBlindHotkeys("N")
Tab & M:: RunBlindHotkeys("M")

;}
;{ special character macros (fn+capslock+**)

#If (IsFnDown && !IsMirrored)

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
CapsLock & L:: Press("ñ", "Ñ") ; use "." key instead on mac version
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
CapsLock & Q:: SendInput, % "√"
CapsLock & W:: SendInput, % "±"
CapsLock & E:: SendInput, % "—"
CapsLock & X:: SendInput, % "™"
CapsLock & C:: SendInput, % "©"
CapsLock & V:: SendInput, % "®"

;}

;}
;{.... NumPad .......................................................................................

#If (IsNumLockOn && IsShiftDown && !IsAnyHotkeyDown() && !IsMirrored)

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


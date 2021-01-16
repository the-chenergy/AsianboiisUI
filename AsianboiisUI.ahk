;{ configurations
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
	;ListLines, Off
	
	; keyboard function initializations
	SetCapsLockState,  Off
	SetScrollLockState, Off
;}
;{ constants
	global Version := "v4.1 Beta F 01/15/21"
	
	global DefaultSettingsFileName := "Settings.ini"
	global UserSettingsFileName := Format("Settings_{}.ini", A_UserName)
	global DefaultSettingsSection := "configs" ; the name of the section in the ini file to read by default
	
	global ModList := ["Control", "Alt", "Win", "Shift"]
	global ModDict := {Toggle: "~", Fn: "$", Control: "^", Alt: "!", Win: "#", Shift: "+"}
	global ToggleBit := 32 ; bit encoding used for vars ModsDown and StickyModsDown
	global FnBit := 16
	global ControlBit := 8
	global AltBit := 4
	global WinBit := 2
	global ShiftBit := 1
	
	global InvisibleKeys := "{Space}{Tab}{Escape}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Delete}{Insert}{Backspace}{CapsLock}{NumLock}{PrintScreen}{Pause}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}``1234567890-=qwertyuiop[]\asdfghjkl`;'zxcvbnm,./"
	
	global ShiftedKeyDict := {"``": "~", 1: "!", 2: "@", 3: "#", 4: "$", 5: "`%", 6: "^"
		,7: "&", 8: "*", 9: "(", 0: ")", "-": "_", "=": "+"
		,"[": "{", "]": "}", "\": "|", "`;": ":", "'": """", ",": "<", ".": ">", "/": "?"}
	
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
	
	; the volume levels used as the steps when adjusting the master volume
	global VolumeSteps := [.70, 1.6, 2.8, 4.4, 6.3, 8.5, 11, 14, 17, 21, 25, 29, 33, 38, 43, 49, 54, 60, 66, 73, 79, 86, 93, 100]
	
	global GestureIconDict := {n: "⭡", ns: "⮏", nw: "⮢", ne: "⮣"
		,s: "⭣", sn: "⮍", sw: "↲", se: "↳"
		,w: "⭠", we: "⮎", wn: "⮤", ws: "⮦"
		,e: "⭢", ew: "⮌", en: "⮥", es: "⮧"}
	
	; the minimum time for a settimer command to start a function in a new thread
	global ThreadStartWaitTime := 64
;}
;{ settings
	global DataPath
	
	global BrightnessStep
	global FnScrollingUpdateDelay ; ms per update on fn scrolling
	global FnMouseMovingUpdateDelay
	global NeverSleepWakingDelay ; ms per "force waking" command sent when never sleep mode is on
	global MaxAccelScrollInterval ; maximum interval between scrolls for accel to activate
	global ScrollSpeedupFactor
	
	global MaxDualKeyTimeout ; the maximum wait time (in ms) before a dual-key expires its press function
	global MaxFnMouseKeyTimeout ; the maximum wait time (in ms) before fn+u be considered holding the mouse button
	global MaxStickyKeyTimeout ; the maximum wait time (in secs) before an activated sticky key expires
	global StickyKeyMask ; key mask: the key to send to prevent a sticky key's hold function from firing when expired
	
	global FunctionMacroDict
	global QuickRunDict
	
	global GestureDict
	global GestureWhiteList
	
	global SwapLAltAndLWinKeyPositions
	global ThumbBackspaceKeyPosition
	global UseRControl
	global RFnKeyPosition
	global LeftKeyPosition
	global RToggleKeyPosition
	global IsSmallLayout ; the physical layout is 65% or less where there is no function row (and is very stupid)
	
	global UseTerminalFuncs ; whether fn+(key) should automatically optimize for putty (eg, ^left becomes !left)
	global UseMaxPerformance ; whether the script should always run at maximum speed (never sleeps)
	global UseSmartSwitch ; smart switch: auto switch back to qwerty when input caret doesn't exist (meaning no text focus)
	global UseLeftHandedMouse
	global UseMouseGestures
	global UseReversedScrolling
	global UseMagicScrolling
	global UseAccelScrolling
	global UseNeverSleep
	global UseToggleBeeps
	global ScrollAltTabMenu
	global SwapMButtonAndXButton2
	
	global AutoToggleSystemColorTheme
	global ATColorThemeDarkTime
	global ATColorThemeLightTime
	global ATColorThemeTaskBarStaysDark
	global ATColorThemeDarkExtraCommands
	global ATColorThemeLightExtraCommands
	
	global UseLogger
	global LoggerDataFileName
	
	global ProgramsAlwaysUseAccelScrolling
;}
;{ global variables
	global IsFnDown := false
	global IsLFnDown := false
	global IsRFnDown := false
	
	global IsControlDown := false
	global IsLControlDown := false
	global IsRControlDown := false
	global IsStickyControlDown := false
	
	global IsAltDown := false
	global IsLAltDown := false
	global IsRAltDown := false
	global IsStickyAltDown := false
	
	global IsWinDown := false
	global IsLWinDown := false
	global IsRWinDown := false
	global IsStickyWinDown := false
	
	global IsShiftDown := false
	global IsLShiftDown := false
	global IsRShiftDown := false
	global IsStickyShiftDown := false
	
	global IsCustomComboUsed := false ; whether a mouse button or a custom press function is pressed while a mod is held down (to avoid triggering sticky key)
	global ModsDown := 0 ; the modifiers currently down: toggle | fn | control | alt | win | shift
	global StickyModsDown := 0 ; the number of sticky modifier currently activated: toggle | -- | control | alt | win | shift
	global ModDescription := "" ; the symbols of the modifiers current activated
	global SendModPressKey := false ; whether it should send the press function of a dual-mod key upon release
	
	global IsCapsLockOn := false
	
	global IsToggleDown := false
	global IsLToggleDown := false
	global IsRToggleDown := false
	global IsStickyToggleDown := false
	global IsLControlTempDown := false ; true when fn+tab is used (which temporarily holds down lcontrol)
	
	global IsLButtonTempDown := false ; true when fn+u is used, holding down lbutton
	global FnMouseMovingSpeedX := 0
	global FnMouseMovingSpeedY := 0
	
	global IsLButtonDown := false
	global IsMButtonDown := false
	global IsRButtonDown := false
	global IsXButton1Down := false
	global IsXButton2Down := false
	
	global IsDrawingGesture := false
	global PrevScrollSpeedup := 0
	
	global CurrSpecChar := ""
	global CurrSpecCharListIndex := 0
	
	global IsAltTabMenuShowing := false
	
	; typing-test mode: send only space when space is pressed; no shift or sticky shift
	global IsTypingTestModeOn := false
;}
;{ helper functions
	; no op ;)
	Noop()
	{
	}
	
	; attempts restarting the script and run as admin
	AttemptRestartAsAdmin()
	{
		if (A_IsAdmin || RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)"))
			return ; already running as admin or already tried
		
		try
			Run, *RunAs "%A_ScriptFullPath%" /restart
		catch
			return
		
		ExitApp
	}
	
	; returns the settings file name to use
	GetSettingsFileName()
	{
		if (FileExist(UserSettingsFileName))
			return UserSettingsFileName
		
		return DefaultSettingsFileName
	}
	
	; returns the opposite direction (L <> R, Up <> Down)
	GetOppDir(dir)
	{
		if (dir = "R")
			return "L"
		if (dir = "L")
			return "R"
		
		if (dir = "Down")
			return "Up"
		if (dir = "Up")
			return "Down"
		
		return dir ; "M", etc.
	}
	
	; returns whether a key position represents a modifier
	IsModPosition(keyPos)
	{
		dir := SubStr(keyPos, 1, 1)
		key := SubStr(keyPos, 2)
		
		return (dir = "L" || dir = "R") && ArrayContains(ModList, keyPos)
	}
	
	; returns the program currently active
	GetActiveProgramName()
	{
		WinGet, temp, ProcessName, A
		SplitPath, temp, , , , temp
		
		return temp
	}
	
	; returns true if the program name contains any of the given keywords
	ActiveProgramNameContains(targets)
	{
		WinGetTitle, temp, A
		
		for i, target in targets
			if (InStr(temp, target))
				return true
		
		return false
	}
	
	; returns true if putty is running and currently active
	IsPuttyActive()
	{
		return UseTerminalFuncs && GetActiveProgramName() = "putty"
	}
	
	; sets the taskbar to be always on top and returns the app-id of the task bar
	PinTaskBar()
	{
		WinGet, temp, Id, ahk_class Shell_TrayWnd
		
		WinSet, AlwaysOnTop, Off, ahk_id %temp%
		WinSet, AlwaysOnTop, On, ahk_id %temp%
		
		return temp
	}
	
	; resets all modifiers in case of a bug
	ResetAll()
	{
		for i, modName in ModList
			SendInput, {L%modName% Up}{R%modName% Up}
		
		SendInput, {Space Up}
		SendInput, {Tab Up}
		SendInput, {Enter Up}
		SendInput, {LButton Up}
		
		IsFnDown := IsLFnDown := IsRFnDown := false
		IsControlDown := IsLControlDown := IsRControlDown := IsStickyControlDown := false
		IsAltDown := IsLAltDown := IsRAltDown := IsStickyAltDown := false
		IsWinDown := IsLWinDown := IsRWinDown := IsStickyWinDown := false
		IsShiftDown := IsLShiftDown := IsRShiftDown := IsStickyShiftDown := false
		
		IsCustomComboUsed := SendModPressKey := false
		ModsDown := StickyModsDown := 0
		
		IsCapsLockOn := GetKeyState("CapsLock", "T")
		
		IsToggleDown := IsLToggleDown := IsRToggleDown := IsStickyToggleDown := IsLControlTempDown := false
		FnMouseMovingSpeedX := FnMouseMovingSpeedY := 0
		
		IsLButtonTempDown := IsLButtonDown := IsMButtonDown := IsRButtonDown := IsXButton1Down := IsXButton2Down := false
		
		IsAltTabMenuShowing := false
		
		PinTaskBar()
		
		TTln("") ; hide tooltip
	}
	
	; flips a boolean variable and shows the corresponding icon
	FlipAndShowIcon(ByRef toToggle, iconIfTrue, descriptionIfTrue, iconIfFalse, descriptionIfFalse, trayItem)
	{
		if (toToggle := !toToggle)
		{
			ShowIconBox(iconIfTrue, "", 0, false, descriptionIfTrue, descriptionIfTrue ? "Green" : "")
			
			if (trayItem)
				Menu, %AddonTrayItem%, Check, %trayItem%
		}
		else
		{
			ShowIconBox(iconIfFalse, "", 0, false, descriptionIfFalse, descriptionIfFalse ? "Red" : "")
			
			if (trayItem)
				Menu, %AddonTrayItem%, UnCheck, %trayItem%
		}
		
		WaitForKeyUp()
		
		return toToggle
	}
	
	WaitForKeyUp()
	{
		KeyWait, % SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
	}
	
	Println(firstStr, rest*)
	{
		SendInput, %firstStr%
		for i, str in rest
			SendInput, % ", " str
		
		SendInput, `n
	}
	
	Msgln(firstStr, rest*)
	{
		temp := firstStr
		for i, str in rest
			temp .= ", " str
		
		MsgBox, %temp%
	}
	
	TTln(firstStr, rest*)
	{
		temp := firstStr
		for i, str in rest
			temp .= ", " str
		
		ToolTip, %temp%
	}
	
	ArrayToString(arr, dim)
	{
		temp := "["
		for i, item in arr
		{
			if (i > 1)
				temp .= ", "
			
			if (dim > 1)
				temp .= " " ArrayToString(item, dim - 1) " "
			else
				temp .= item
		}
		
		return temp "]"
	}
	
	ArrayContains(arr, target)
	{
		for i, str in arr
			if (str = target)
				return true
		
		return false
	}
	
	; returns the time of the day in seconds (3600=1am, 7200=2am, ... 86399=11:59:59pm)
	GetCurrTime()
	{
		return A_Hour * 3600 + A_Min * 60 + A_Sec
	}
	
	; atTime: the time of the day in seconds to execute
	ExecuteAtTime(atTime, funcToExecute)
	{
		currTime := GetCurrTime()
		if (atTime < currTime)
			atTime += 86400
		
		SetTimer, %funcToExecute%, % (currTime - atTime) * 1000
	}
	
	; returns the time of the day in seconds that `str` represents
	ParseTime(str)
	{
		args := StrSplit(str, ":")
		
		if (args.Length() == 2) ; hh:mm
			return args[1] // 1 * 3600 + args[2] // 1 * 60
		
		return args[1] // 1 * 3600 + args[2] // 1 * 60 + args[3] // 1 ; hh:mm:ss
	}
;}

;{ tray icon and menu
	if (InStr(Version, "Beta"))
		Menu, Tray, Add
	else
		Menu, Tray, NoStandard
	
	SetTrayTipText(tipText)
	{
		Menu, Tray, Tip, % "Asianboii's UI`n" (tipText = "" ? "" : "("  tipText  ")`n") "`n" Version "`nby Qianlang Chen`nqianlangchen@gmail.com"
	}
	
	SetTrayIcon(iconName)
	{
		path := DataPath "/" iconName ".ico"
		if (FileExist(path))
			Menu, Tray, Icon, %path%, 1, 1
	}
	
	global AboutMsgBoxTitle := "About Asianboii's UI"
	Menu, Tray, Add, % AboutMsgBoxTitle "`tFn+F1", TrayItemAbout
	TrayItemAbout()
	{
		SetTimer, SetAboutMsgBoxButtons, 11
		MsgBox, 0x101, %AboutMsgBoxTitle%, % "Asianboii's UI`n`n" Version "`nby Qianlang Chen`nqianlangchen@gmail.com"
		IfMsgBox, Ok
			TrayItemViewDoc()
	}
	
	Menu, Tray, Add, % "View documentation", TrayItemViewDoc
	TrayItemViewDoc()
	{
		Run, % "https://github.com/asianboii-chen/AsianboiisUI"
	}
	
	SetAboutMsgBoxButtons()
	{
		IfWinNotExist, %AboutMsgBoxTitle%
			return ; keep waiting
		
		SetTimer, SetAboutMsgBoxButtons, Off 
		
		WinActivate, A
		ControlSetText, Button1, % "&View doc"
		ControlSetText, Button2, % "&Close"
	}
	
	Menu, Tray, Add
	
	global AddonTrayItem := "Addons"
	
	global TypingTestModeTrayItem := "Typing-Test Mode (no shift; space only)`tWin+k"
	Menu, %AddonTrayItem%, Add, %TypingTestModeTrayItem%, TrayItemTypingTestMode
	TrayItemTypingTestMode()
	{
		FlipAndShowIcon(IsTypingTestModeOn, "SmartSwitchOn", "Typing Test On", "SmartSwitchOff", "Typing Test Off", TypingTestModeTrayItem)
		
		if (IsTypingTestModeOn)
		{
			SetTrayIcon("ime")
			SetTrayTipText("Typing-Test Mode On")
		}
		else
		{
			SetTrayIcon("default")
			SetTrayTipText("")
		}
	}
	
	Menu, %AddonTrayItem%, Add
	
	global GestureTrayItem := "Use mouse gestures`tWin+m"
	Menu, %AddonTrayItem%, Add, %GestureTrayItem%, TrayItemGesture
	TrayItemGesture()
	{
		FlipAndShowIcon(UseMouseGestures, "LeftyMouseOn", "Mouse Gestures", "LeftyMouseOff", "No Gestures", GestureTrayItem)
	}
	
	global MaxPerformanceTrayItem := "Force maximum performance`tWin+y"
	Menu, %AddonTrayItem%, Add, %MaxPerformanceTrayItem%, TrayItemMaxPerformance
	TrayItemMaxPerformance()
	{
		ToggleMaxPerformance(!UseMaxPerformance, true)
	}
	
	global SmartSwitchTrayItem := "Auto QWERTY while not inputting`tWin+i"
	Menu, %AddonTrayItem%, Add, %SmartSwitchTrayItem%, TrayItemSmartSwitch
	TrayItemSmartSwitch()
	{
		FlipAndShowIcon(UseSmartSwitch, "SmartSwitchOn", "", "SmartSwitchOff", "", SmartSwitchTrayItem)
	}
	
	global ToggleBeepTrayItem := "Beeps on suspension`tWin+u"
	Menu, %AddonTrayItem%, Add, %ToggleBeepTrayItem%, TrayItemToggleBeep
	TrayItemToggleBeep()
	{
		FlipAndShowIcon(UseToggleBeeps, "VolumeMedium", "Toggle Beeps", "MuteOn", "No Beeps", ToggleBeepTrayItem)
	}
	
	global TerminalFuncTrayItem := "Auto convert Putty (terminal) hotkeys`tWin+j"
	Menu, %AddonTrayItem%, Add, %TerminalFuncTrayItem%, TrayItemTerminalFuncs
	TrayItemTerminalFuncs()
	{
		FlipAndShowIcon(UseTerminalFuncs, "SmartSwitchOn", "Putty Friendly", "SmartSwitchOff", "No Putty Friendly", TerminalFuncTrayItem)
	}
	
	global NeverSleepTrayItem := "Monitor never sleeps`tWin+n"
	Menu, %AddonTrayItem%, Add, %NeverSleepTrayItem%, TrayItemNeverSleep
	TrayItemNeverSleep()
	{
		ToggleNeverSleep(!UseNeverSleep, true)
	}
	
	global MagicScrollTrayItem := "Use magic (inactive window) scrolling`tWin+'"
	Menu, %AddonTrayItem%, Add, %MagicScrollTrayItem%, TrayItemMagicScroll
	TrayItemMagicScroll()
	{
		FlipAndShowIcon(UseMagicScrolling, "NormalScrollingOff", "", "NormalScrollingOn", "", MagicScrollTrayItem)
	}
	
	global ReversedScrollingTrayItem := "Use reversed scrolling`tWin+,"
	Menu, %AddonTrayItem%, Add, %ReversedScrollingTrayItem%, TrayItemReversedScrolling
	TrayItemReversedScrolling()
	{
		FlipAndShowIcon(UseReversedScrolling, "NormalScrollingOff", "Reversed Scroll", "NormalScrollingOn", "No Rev. Scroll", ReversedScrollingTrayItem)
	}
	
	global AccelScrollingTrayItem := "Use scroll-acceleration`tWin+."
	Menu, %AddonTrayItem%, Add, %AccelScrollingTrayItem%, TrayItemAccelScrolling
	TrayItemAccelScrolling()
	{
		FlipAndShowIcon(UseAccelScrolling, "NormalScrollingOff", "Scroll Accel.", "NormalScrollingOn", "No Scroll Accel.", AccelScrollingTrayItem)
	}
	
	global LeftyMouseTrayItem := "Use left-handed Mouse`tWin+h"
	Menu, %AddonTrayItem%, Add, %LeftyMouseTrayItem%, TrayItemLeftyMouse
	TrayItemLeftyMouse()
	{
		FlipAndShowIcon(UseLeftHandedMouse, "LeftyMouseOn", "", "LeftyMouseOff", "", LeftyMouseTrayItem)
	}
	
	global ScrollAltTabMenuTrayItem := "Scroll through alt-tab menu"
	Menu, %AddonTrayItem%, Add, %ScrollAltTabMenuTrayItem%, TrayItemScrollAltTabMenu
	TrayItemScrollAltTabMenu()
	{
		FlipAndShowIcon(ScrollAltTabMenu, "NormalScrollingOff", "Scroll Alt-Tab", "NormalScrollingOn", "No Scroll Alt-Tab", ScrollAltTabMenuTrayItem)
	}
	
	global SwapMButtonAndXButton2TrayItem := "Swap middle and forward mouse-buttons"
	Menu, %AddonTrayItem%, Add, %SwapMButtonAndXButton2TrayItem%, TrayItemSwapMButtonAndXButton2
	TrayItemSwapMButtonAndXButton2()
	{
		FlipAndShowIcon(SwapMButtonAndXButton2, "NormalScrollingOff", "Swap M&X2 Buttons", "NormalScrollingOn", "No Swap M&X2", SwapMButtonAndXButton2TrayItem)
	}
	
	global AddonTrayItems := [GestureTrayItem, SmartSwitchTrayItem, TerminalFuncTrayItem
		,NeverSleepTrayItem, MagicScrollTrayItem, ReversedScrollingTrayItem, AccelScrollingTrayItem, LeftyMouseTrayItem
		,ScrollAltTabMenuTrayItem]
	
	Menu, Tray, Add, % "Customize add-ons", % ":" AddonTrayItem
	
	Menu, Tray, Add, % "View key position settings", TrayItemKeyPositions
	TrayItemKeyPositions()
	{
		strData := "(key) @ (located at)`n`n"
		strData .= "LControl @ LShift`n"
		
		if (SwapLAltAndLWinKeyPositions)
		{
			strData .= "LAlt @ LWin`n"
			strData .= "LWin @ LAlt`n"
		}
		else
		{
			strData .= "LAlt @ LAlt`n"
			strData .= "LWin @ LWin`n"
		}
		
		strData .= "LFn @ LControl`n"
		strData .= "Shift @ Space`n"
		strData .= "Thumb backspace @ " ThumbBackspaceKeyPosition "`n"
		strData .= "Left arrow @ " LeftKeyPosition "`n"
		
		if (UseRControl)
			strData .= "RControl @ RShift`n"
		else
			strData .= "RControl @`n" ; unassigned
		
		strData .= "RFn @ " RFnKeyPosition "`n"
		strData .= "Suspend (Toggle) @ " RToggleKeyPosition "`n"
		
		MsgBox, 0, % "Key Positions", %strData%
	}
	
	Menu, Tray, Add, % "Edit settings file", TrayItemEditSettings
	TrayItemEditSettings()
	{
		Run, % GetSettingsFileName()
	}
	
	Menu, Tray, Add, % "Reload settings`tWin+o", TrayItemReloadSettings
	TrayItemReloadSettings()
	{
		ShowIconBox("", "", 0, false, "Reload...", "Green")
		SetTimer, ReloadSettings, -%ThreadStartWaitTime%
	}
	
	ReloadSettings()
	{
		LoadBasicSettings(false)
	}
	
	Menu, Tray, Add
	
	global DebugTrayItem := "DebugTools"
	
	Menu, %DebugTrayItem%, Add, % "View major variables`tFn+F12", TrayItemDebug
	TrayItemDebug()
	{
		strData := ""
		
		if (UseSmartSwitch)
			strData .= "UseSmartSwitch: " UseSmartSwitch "`n"
		if (UseLeftHandedMouse)
			strData .= "UseLeftHandedMouse: " UseLeftHandedMouse "`n"
		if (UseReversedScrolling)
			strData .= "UseReversedScrolling: " UseReversedScrolling "`n"
		if (UseMagicScrolling)
			strData .= "UseMagicScrolling: " UseMagicScrolling "`n"
		if (UseNeverSleep)
			strData .= "UseNeverSleep: " UseNeverSleep "`n"
		if (IsFnDown)
			strData .= "IsFnDown: " IsFnDown "`n"
		if (IsLFnDown)
			strData .= "IsLFnDown: " IsLFnDown "`n"
		if (IsRFnDown)
			strData .= "IsRFnDown: " IsRFnDown "`n"
		if (IsControlDown)
			strData .= "IsControlDown: " IsControlDown "`n"
		if (IsLControlDown)
			strData .= "IsLControlDown: " IsLControlDown "`n"
		if (IsRControlDown)
			strData .= "IsRControlDown: " IsRControlDown "`n"
		if (IsStickyControlDown)
			strData .= "IsStickyControlDown: " IsStickyControlDown "`n"
		if (IsAltDown)
			strData .= "IsAltDown: " IsAltDown "`n"
		if (IsLAltDown)
			strData .= "IsLAltDown: " IsLAltDown "`n"
		if (IsRAltDown)
			strData .= "IsRAltDown: " IsRAltDown "`n"
		if (IsStickyAltDown)
			strData .= "IsStickyAltDown: " IsStickyAltDown "`n"
		if (IsWinDown)
			strData .= "IsWinDown: " IsWinDown "`n"
		if (IsLWinDown)
			strData .= "IsLWinDown: " IsLWinDown "`n"
		if (IsRWinDown)
			strData .= "IsRWinDown: " IsRWinDown "`n"
		if (IsStickyWinDown)
			strData .= "IsStickyWinDown: " IsStickyWinDown "`n"
		if (IsShiftDown)
			strData .= "IsShiftDown: " IsShiftDown "`n"
		if (IsLShiftDown)
			strData .= "IsLShiftDown: " IsLShiftDown "`n"
		if (IsRShiftDown)
			strData .= "IsRShiftDown: " IsRShiftDown "`n"
		if (IsStickyShiftDown)
			strData .= "IsStickyShiftDown: " IsStickyShiftDown "`n"
		if (IsCustomComboUsed)
			strData .= "IsCustomComboUsed: " IsCustomComboUsed "`n"
		if (ModsDown)
			strData .= "ModsDown: " ModsDown "`n"
		if (StickyModsDown)
			strData .= "StickyModsDown: " StickyModsDown "`n"
		if (SendModPressKey)
			strData .= "SendModPressKey: " SendModPressKey "`n"
		if (IsCapsLockOn)
			strData .= "IsCapsLockOn: " IsCapsLockOn "`n"
		if (IsToggleDown)
			strData .= "IsToggleDown: " IsToggleDown "`n"
		if (IsLToggleDown)
			strData .= "IsLToggleDown: " IsLToggleDown "`n"
		if (IsRToggleDown)
			strData .= "IsRToggleDown: " IsRToggleDown "`n"
		if (IsStickyToggleDown)
			strData .= "IsStickyToggleDown: " IsStickyToggleDown "`n"
		if (IsLControlTempDown)
			strData .= "IsLControlTempDown: " IsLControlTempDown "`n"
		if (IsLButtonTempDown)
			strData .= "IsLButtonTempDown: " IsLButtonTempDown "`n"
		if (FnMouseMovingSpeedX)
			strData .= "FnMouseMovingSpeedX: " FnMouseMovingSpeedX "`n"
		if (FnMouseMovingSpeedY)
			strData .= "FnMouseMovingSpeedY: " FnMouseMovingSpeedY "`n"
		if (IsLButtonDown)
			strData .= "IsLButtonDown: " IsLButtonDown "`n"
		if (IsMButtonDown)
			strData .= "IsMButtonDown: " IsMButtonDown "`n"
		if (IsRButtonDown)
			strData .= "IsRButtonDown: " IsRButtonDown "`n"
		if (IsXButton1Down)
			strData .= "IsXButton1Down: " IsXButton1Down "`n"
		if (IsXButton2Down)
			strData .= "IsXButton2Down: " IsXButton2Down "`n"
		
		if (strData = "")
			strData := "(all variables = false)"
		
		MsgBox, 0, % GetActiveProgramName(), %strData%
	}
	
	Menu, %DebugTrayItem%, Add, % "Reset all modifiers`tEscape *2", ResetAll
	
	Menu, %DebugTrayItem%, Add, % "Open Working Directory", TrayItemOpenWorkingDir
	TrayItemOpenWorkingDir()
	{
		Run, %A_WorkingDir%
	}
	
	Menu, %DebugTrayItem%, Add, % "Restart Asianboii's UI", TrayItemReload
	TrayItemReload()
	{
		Reload
	}
	
	Menu, Tray, Add, % "Debugging tools", % ":" DebugTrayItem
	
	Menu, Tray, Add
	
	global SuspendTrayItem := "Suspend Asianboii's UI`t" RToggleKeyPosition
	Menu, Tray, Add, %SuspendTrayItem%, TrayItemSuspend
	Menu, Tray, Default, %SuspendTrayItem%
	Menu, Tray, Click, 1
	TrayItemSuspend()
	{
		ToggleSuspend(A_IsSuspended)
	}
	
	Menu, Tray, Add, % "Exit Asianboii's UI", TrayItemExit
	TrayItemExit()
	{
		ExitApp
	}
;}
;{ other initializations
	LoadBasicSettings(true)
	
	if (LoadSetting("AttemptAdmin", false))
		AttemptRestartAsAdmin()
	
	if (LoadSetting("AutoToggleSystemColorTheme", false))
	{
		LoadSetting("ATColorThemeDarkTime", "20:00")
		LoadSetting("ATColorThemeLightTime", "06:00")
		LoadSetting("ATColorThemeTaskBarStaysDark", false)
		LoadSetting("ATColorThemeDarkExtraCommands", "")
		ATColorThemeDarkExtraCommands := StrSplit(ATColorThemeDarkExtraCommands, ";;")
		LoadSetting("ATColorThemeLightExtraCommands", "")
		ATColorThemeLightExtraCommands := StrSplit(ATColorThemeLightExtraCommands, ";;")
		
		InitATColorTheme()
	}
	
	if (LoadSetting("UseLogger", false))
	{
		LoadSetting("LoggerDataFileName", "KeyLogs.txt")
		InitLogger()
	}
	
	SetTrayIcon("Default")
	SetTrayTipText("")
;}
;{ icon box
	global IconBox, IconBoxWidth := 150, IconBoxHeight := 150
	global IsIconBoxShowing := false, ShowingIconName := ""
	global IconBoxShownTime := 0
	
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
	
	; controls
	Gui, %IconBox%:Add, Progress, X15 Y120 W120 H15 Background101010 C2ECC71 VGreenBar
	Gui, %IconBox%:Add, Progress, X15 Y120 W120 H15 Background101010 CC0392B VRedBar
	
	Gui, %IconBox%:Font, Bold S10
	Gui, %IconBox%:Add, Text, X15 Y120 W120 H15 C2ECC71 VDescriptionText +Center
	
	Gui, %IconBox%:Font, Bold S10
	Gui, %IconBox%:Add, Text, X15 Y120 W120 H15 CC0392B VDescriptionRedText +Center
	
	Gui, %IconBox%:Font, Bold S108
	Gui, %IconBox%:Add, Text, X0 Y-24 W150 H150 C2ECC71 VAsciiIconText +Center
	
	Gui, %IconBox%:Font, Bold S20, % "Consolas"
	Gui, %IconBox%:Add, Text, X24 Y18 W72 H30 C2ECC71 VSymbolText
	
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
		Gui, %IconBox%:Add, Picture, X0 Y0 V%iconBoxIcon%, % DataPath "/" iconBoxIcon ".png"
	
	Gui, %IconBox%:Show, X-3456 Y-3456 Hide ; make the gui out of screen first to let play its annoying animation
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
	ShowIconBox(iconName, progressBar := "", progressValue := 0, testingMode := false, description := "", descriptionColor := "")
	{
		SetTimer, HideIconBox, Off ; reset the timer in case it's not reset
		IconBoxShownTime := A_TickCount
		
		; hide the rest of unrelated controls
		for i, iconBoxIcon in IconBoxIcons
			if (iconBoxIcon != iconName)
				GuiControl, %IconBox%:Hide, %iconBoxIcon%
		
		ShowOrHideIconBoxControl("GreenBar", progressBar = "Green", false)
		ShowOrHideIconBoxControl("RedBar", progressBar = "Red", false)
		ShowOrHideIconBoxControl("AsciiIconText", false, false)
		ShowOrHideIconBoxControl("DescriptionText", descriptionColor = "Green", false)
		ShowOrHideIconBoxControl("DescriptionRedText", descriptionColor = "Red", false)
		ShowOrHideIconBoxControl("SymbolText", false, false)
		
		; only show the icon when it is not already showing
		if (iconName != ShowingIconName)
		{
			GuiControl, %IconBox%:Show, %iconName%
			ShowingIconName := iconName
		}
		
		; do not trigger other actions when using testing mode
		if (testingMode)
		{
			Gui, %IconBox%:Show, X-3456 Y-3456, Hide
			Gui, %IconBox%:Show, W%IconBoxWidth% H%IconBoxHeight% NoActivate
			
			SetTimer, HideIconBox, -521
			
			return
		}
		
		; only check for cursor position after gui is hidden
		if (!IsIconBoxShowing)
		{
			GetIconBoxPosition(x, y)
			Gui, %IconBox%:Show, X%x% Y%y% Hide
		}
		
		Gui, %IconBox%:Show, W%IconBoxWidth% H%IconBoxHeight% NoActivate
		
		WinSet, AlwaysOnTop, Off, ahk_id %IconBox%
		WinSet, AlwaysOnTop, On, ahk_id %IconBox%
		
		IsIconBoxShowing := true
		
		if (progressBar = "Green")
			GuiControl, %IconBox%:, GreenBar, %progressValue%
		else if (progressBar = "Red")
			GuiControl, %IconBox%:, RedBar, %progressValue%
		
		if (descriptionColor = "Green")
			GuiControl, %IconBox%:, DescriptionText, %description%
		else if (descriptionColor = "Red")
			GuiControl, %IconBox%:, DescriptionRedText, %description%
		
		SetTimer, HideIconBox, -521 ; negative number means the timer should't loop.
	}
	
	ShowSustainedIconBox(iconName, asciiIcon, description, symbols)
	{
		SetTimer, HideIconBox, Off ; reset the timer in case it's not reset
		
		; hide the rest of unrelated controls
		for i, iconBoxIcon in IconBoxIcons
			if (iconBoxIcon != iconName)
				GuiControl, %IconBox%:Hide, %iconBoxIcon%
		
		ShowOrHideIconBoxControl("GreenBar", false, false)
		ShowOrHideIconBoxControl("RedBar", false, false)
		ShowOrHideIconBoxControl("AsciiIconText", asciiIcon, true)
		ShowOrHideIconBoxControl("DescriptionText", description, true)
		ShowOrHideIconBoxControl("DescriptionRedText", false, true)
		ShowOrHideIconBoxControl("SymbolText", symbols, true)
		
		; only show the icon when it is not already showing
		if (iconName != ShowingIconName)
		{
			GuiControl, %IconBox%:Show, %iconName%
			ShowingIconName := iconName
		}
		
		; only check for cursor position after gui is hidden
		if (!IsIconBoxShowing)
		{
			GetIconBoxPosition(x, y)
			Gui, %IconBox%:Show, X%x% Y%y% Hide
		}
		
		Gui, %IconBox%:Show, W%IconBoxWidth% H%IconBoxHeight% NoActivate
		
		WinSet, AlwaysOnTop, Off, ahk_id %IconBox%
		WinSet, AlwaysOnTop, On, ahk_id %IconBox%
		
		IsIconBoxShowing := true
		
		GuiControl, %IconBox%:, AsciiIconText, %asciiIcon%
		GuiControl, %IconBox%:, DescriptionText, %description%
		GuiControl, %IconBox%:, SymbolText, %symbols%
	}
	
	ShowOrHideIconBoxControl(controlName, trueForShow, forceReset)
	{
		GuiControl, % IconBox ":" (trueForShow ? "Show" : "Hide"), %controlName%
		
		if (forceReset)
			GuiControl, %IconBox%:, %controlName%, % ""
	}
	
	; Forces the icon box GUI to hide. By default, it hides 500 milliseconds after it is shown.
	HideIconBox()
	{
		SetTimer, IconBoxOff, -260
		DllCall("AnimateWindow", UInt, IconBox, Int, 130, UInt, 0x90000) ; play the fade-out amination
	}
	
	; Turns off IconBox "on-mode".
	IconBoxOff()
	{
		IsIconBoxShowing := false
	}
	
	; returns the position of where the icon box needs to pop up according to which screen the mouse cursor is on.
	GetIconBoxPosition(ByRef x, ByRef y)
	{
		if (NumScreens = 1)
		{
			x := MainScreenRight - IconBoxWidth - 25
			y := MainScreenTop + 25
			
			return
		}
		
		; get the screen the cursor is currently on
		
		MouseGetPos, mouseX, mouseY
		
		Loop, %NumScreens%
		{
			SysGet, currentScreenCoord, Monitor, %A_Index%
			
			if (mouseX >= currentScreenCoordLeft && mouseX < currentScreenCoordRight
				&& mouseY >= currentScreenCoordTop && mouseY < currentScreenCoordBottom)
					break
		}
		
		x := currentScreenCoordRight - IconBoxWidth - 25
		y := currentScreenCoordTop + 25
	}
;}
;{ loading
	LoadBasicSettings(isFirstLoad)
	{
		LoadSetting("DataPath", "./Data")
		
		LoadSetting("BrightnessStep", 2)
		LoadSetting("FnScrollingUpdateDelay", 86.8)
		LoadSetting("FnMouseMovingUpdateDelay", 21.7)
		LoadSetting("NeverSleepWakingDelay", 100000)
		LoadSetting("MaxDualKeyTimeout", 130.2)
		LoadSetting("MaxFnMouseKeyTimeout", 260.4)
		LoadSetting("MaxStickyKeyTimeout", 1.042)
		LoadSetting("MaxAccelScrollInterval", 57.9)
		LoadSetting("ScrollSpeedupFactor", 3)
		LoadSetting("StickyKeyMask", "RControl")
		LoadSetting("ProgramsAlwaysUseAccelScrolling", "")
		ProgramsAlwaysUseAccelScrolling := StrSplit(ProgramsAlwaysUseAccelScrolling, "*")
		
		LoadSettingAndCheckTrayItem("UseMouseGestures", true, GestureTrayItem)
		
		if (isFirstLoad)
		{
			LoadSettingAndCheckTrayItem("UseTerminalFuncs", true, TerminalFuncTrayItem)
			LoadSettingAndCheckTrayItem("UseSmartSwitch", false, SmartSwitchTrayItem)
			LoadSettingAndCheckTrayItem("UseLeftHandedMouse", false, LeftyMouseTrayItem)
			LoadSettingAndCheckTrayItem("UseReversedScrolling", false, ReversedScrollingTrayItem)
			LoadSettingAndCheckTrayItem("UseMagicScrolling", false, MagicScrollTrayItem)
			LoadSettingAndCheckTrayItem("UseAccelScrolling", true, AccelScrollingTrayItem)
			LoadSettingAndCheckTrayItem("UseToggleBeeps", true, ToggleBeepTrayItem)
			LoadSettingAndCheckTrayItem("ScrollAltTabMenu", true, ScrollAltTabMenuTrayItem)
			LoadSettingAndCheckTrayItem("SwapMButtonAndXButton2", false, SwapMButtonAndXButton2TrayItem)
			
			ToggleMaxPerformance(LoadSetting("UseMaxPerformance", false), false)
			ToggleNeverSleep(LoadSetting("UseNeverSleep", false), false)
		}
		
		if (LoadSetting("AutoDetectMacKeyboard", true))
		{
			; check if bootcamp manager exists somewhere
			if (FileExist("C:/Program Files/Boot Camp") || FileExist("D:/Program Files/Boot Camp")
				|| FileExist("E:/Program Files/Boot Camp") || FileExist("F:/Program Files/Boot Camp"))
			{
				SwapLAltAndLWinKeyPositions := true
				LoadOrSetKeyPosition("ThumbBackSpace", "RWin", false, true)
				UseRControl := false
				LoadOrSetKeyPosition("RFn", "RAlt", false, false)
				LoadOrSetKeyPosition("Left", "Left", false, true)
				LoadOrSetKeyPosition("RToggle", "RShift", false, false)
				IsSmallLayout := false
			}
			else ; assume a tkl or full-size layout
			{
				SwapLAltAndLWinKeyPositions := false
				ThumbBackspaceKeyPosition := "RAlt"
				LoadOrSetKeyPosition("ThumbBackSpace", "RAlt", false, true)
				UseRControl := true
				LoadOrSetKeyPosition("RFn", "AppsKey", false, false)
				LoadOrSetKeyPosition("Left", "Left", false, true)
				LoadOrSetKeyPosition("RToggle", "RControl", false, false)
				IsSmallLayout := false
			}
		}
		else
		{
			LoadSetting("SwapLAltAndLWinKeyPositions", false)
			LoadOrSetKeyPosition("ThumbBackspace", "RAlt", true, true)
			LoadSetting("UseRControl", true)
			LoadOrSetKeyPosition("RFn", "AppsKey", true, false)
			LoadOrSetKeyPosition("Left", "Left", true, true)
			LoadOrSetKeyPosition("RToggle", "RControl", true, false)
			LoadSetting("IsSmallLayout", false)
			
			temp := "Suspend Asianboii's UI`t" RToggleKeyPosition
			if (temp != SuspendTrayItem)
			{
				Menu, Tray, Rename, %SuspendTrayItem%, %temp%
				SuspendTrayItem := temp
			}
		}
		
		GestureDict := {}
		FunctionMacroDict := {}
		QuickRunDict := {}
		
		; mouse gestures
		for dir in GestureIconDict
			LoadGestureSetting(dir)
		
		LoadSetting("GestureWhiteList", "")
		GestureWhiteList := StrSplit(GestureWhiteList, "*")
		
		; function key macros
		Loop, 12
			LoadFunctionKeyMacroSetting("F" A_Index)
		
		; quick runs
		for i, key in StrSplit("QWTASDFGZXCB")
			LoadQuickRunSetting(key)
	}
	
	LoadSetting(setting, defaultValue)
	{
		IniRead, %setting%, % GetSettingsFileName(), %DefaultSettingsSection%, %setting%, %defaultValue%
		temp := %setting%
		
		return temp
	}
	
	LoadSettingAndCheckTrayItem(setting, defaultValue, trayItem)
	{
		if (LoadSetting(setting, defaultValue))
			Menu, %AddonTrayItem%, Check, %trayItem%
		else
			Menu, %AddonTrayItem%, UnCheck, %trayItem%
	}
	
	LoadGestureSetting(dir)
	{
		args := StrSplit(LoadSetting("Gesture" dir, ""), "|")
		
		GestureDict[dir] := {title: args[1], defaultCommand: args[2], programs: [], commands: []}
		Loop, % (args.Length() - 2) / 2
		{
			GestureDict[dir].programs[A_Index] := StrSplit(args[A_Index * 2 + 1], "*")
			GestureDict[dir].commands[A_Index] := args[A_Index * 2 + 2]
		}
	}
	
	LoadFunctionKeyMacroSetting(key)
	{
		args := StrSplit(LoadSetting("Custom" key, ""), "|")
		
		FunctionMacroDict[key] := {programs: [], commands: []}
		Loop, % args.Length() / 2
		{
			FunctionMacroDict[key].programs[A_Index] := StrSplit(args[A_Index * 2 - 1], "*")
			FunctionMacroDict[key].commands[A_Index] := args[A_Index * 2]
		}
	}
	
	LoadQuickRunSetting(key)
	{
		command := LoadSetting("QuickRun" key, "")
		if (command = "")
		{
			QuickRunDict[key] := {path: "", args: ""}
			return
		}
		
		args := StrSplit(command, "|")
		
		QuickRunDict[key] := {path: args[1], args: args[2]}
	}
	
	; hasUp: whether the key has both a down- and an up-part
	LoadOrSetKeyPosition(key, newOrDefaultPos, loadFromSettings, hasUp)
	{
		keyPosVar := key "KeyPosition"
		keyLabel := "Dynamic" key
		onStickyKeyLabel := keyLabel "OnSticky"
		
		if (%keyPosVar%)
		{
			Hotkey, % "*" %keyPosVar%, %keyLabel%, Off
			
			if (hasUp)
				Hotkey, % "*" %keyPosVar% " Up", % keyLabel "Up", Off
		}
		
		if (loadFromSettings)
			IniRead, %keyPosVar%, % GetSettingsFileName(), %DefaultSettingsSection%, %keyPosVar%, %newOrDefaultPos%
		else
			%keyPosVar% := newOrDefaultPos
		
		Hotkey, % "*" %keyPosVar%, %keyLabel%, On
		if (hasUp)
			Hotkey, % "*" %keyPosVar% " Up", % keyLabel "Up", On
	}
;}

;{ auto toggle system color theme
	global ATColorThemeRegPath
	
	InitATColorTheme()
	{
		ATColorThemeRegPath := "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
		ATColorThemeDarkTime := ParseTime(ATColorThemeDarkTime)
		ATColorThemeLightTime := ParseTime(ATColorThemeLightTime)
		
		currColorTheme := ATColorThemeGet()
		if (currColorTheme = -1)
		{
			Msgln("This system does not support dynamically changing the color-theme!")
			return
		}
		
		currTime := GetCurrTime()
		if (currTime >= ATColorThemeLightTime && currTime < ATColorThemeDarkTime) ; light hours
		{
			if (currColorTheme != 1)
				ATColorThemeSet(1)
			ExecuteAtTime(ATColorThemeDarkTime, "ATColorThemeSetDark")
		}
		else ; dark hours
		{
			if (currColorTheme != 0)
				ATColorThemeSet(0)
			ExecuteAtTime(ATColorThemeLightTime, "ATColorThemeSetLight")
		}
	}
	
	; 0=dark, 1=light, 2=mixed, -1=error
	ATColorThemeGet()
	{
		RegRead, areAppsLight, %ATColorThemeRegPath%, % "AppsUseLightTheme"
		RegRead, isSystemLight, %ATColorThemeRegPath%, % "SystemUsesLightTheme"
		
		if (areAppsLight = "" || isSystemLight = "")
			return -1
		
		if (ATColorThemeTaskBarStaysDark)
			return isSystemLight ? 2 : areAppsLight
		
		return (areAppsLight != isSystemLight) ? 2 : areAppsLight
	}
	
	; don't call if it couldn't successfully get in the first place
	ATColorThemeSet(isLight)
	{
		RegWrite, REG_DWORD, %ATColorThemeRegPath%, % "AppsUseLightTheme", %isLight%
		RegWrite, REG_DWORD, %ATColorThemeRegPath%, % "SystemUsesLightTheme", % !ATColorThemeTaskBarStaysDark && isLight
		
		ATColorThemeRunExtraCommands(isLight ? ATColorThemeLightExtraCommands : ATColorThemeDarkExtraCommands)
	}
	
	ATColorThemeSetDark()
	{
		ATColorThemeSet(0)
		ExecuteAtTime(ATColorThemeLightTime, "ATColorThemeSetLight")
	}
	
	ATColorThemeSetLight()
	{
		ATColorThemeSet(1)
		ExecuteAtTime(ATColorThemeDarkTime, "ATColorThemeSetDark")
	}
	
	ATColorThemeRunExtraCommands(commands)
	{
		for i, command in commands
			Run, %command%, , Hide
	}
;}
;{ key logger
	global LoggerKeyNames, LoggerKeyTexts, LoggerKeyCount, LoggerKeyFreqCount
	global LoggerData, LoggerHasChanged
	
	InitLogger()
	{
		; LoggerKeyNames := StrSplit("esc f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 gra n1 n2 n3 n4 n5 n6 n7 n8 n9 n0 min equ bsp tab q w e r t y u i o p lsq rsq bsl cap a s d f g h j k l sem apo ent lsh z x c v b n m com dot fsl rsh lco lwi lal spa ral app rco psc del ins hom end pup pdn lar rar uar dar", " ")
		LoggerKeyNames := StrSplit("dol amp ast equ lbr rbr lth gth lpa rpa lsq rsq pou apo com dot lp ly lf lg lc lr ll fsl das la lo le li lu ld lh lt ln ls und sem lq lj lk lx lb lm lw lv lz bsl n1 n2 n3 n4 n5 n6 n7 n8 n9 n0 car til gra quo que exc up uy uf ug uc ur ul per plu ua uo ue ui uu ud uh ut un us pip col uq uj uk ux ub um uw uv uz at", " ")
		LoggerKeyCount := LoggerKeyNames.Length()
		
		; the number of types of frequencies the logger is in change of counting, which includes no-mod, every mod, every mod with
		; shift key activated, and a total.
		; LoggerKeyFreqCount := 6 * 2 + 1
		LoggerKeyFreqCount := 1
		
		LoggerData := []
		if (FileExist(LoggerDataFileName))
		{
			keyCode := -1
			Loop, Read, %LoggerDataFileName%
			{
				line := A_LoopReadLine
				if (line = "")
					continue
				
				keyCode++
				if (keyCode = 0)
					continue ; skip the first line (table header)
				
				args := StrSplit(line, "`t")
				LoggerData[keyCode] := []
				Loop, %LoggerKeyFreqCount%
					LoggerData[keyCode][A_Index] := args[A_Index + 1] // 1 ; +1 to skip the key's name
			}
		}
		else
		{
			Loop, % LoggerKeyCount
			{
				keyCode := A_Index
				
				LoggerData[keyCode] := []
				Loop, %LoggerKeyFreqCount%
					LoggerData[keyCode][A_Index] := 0
			}
		}
		
		Menu, Tray, Add
		LoggerTrayItem := "LoggerOptions"
		Menu, %LoggerTrayItem%, Add, % "Open Key Log Data`tWin+/", LoggerOpenRecords
		Menu, %LoggerTrayItem%, Add, % "Save Key Log Data", LoggerSaveRecords
		Menu, Tray, Add, % "Key Logger Options", % ":" LoggerTrayItem
		
		LoggerHasChanged := false
		SetTimer, LoggerSaveRecords, % LoadSetting("LoggerSaveInterval", 1800000)
		
		OnExit("LoggerOnScriptExit")
	}
	
	LoggerOnScriptExit(reason, code)
	{
		LoggerSaveRecords()
	}
	
	LoggerSaveRecords()
	{
		if (!UseLogger || !LoggerHasChanged)
			return
		
		if (FileExist(LoggerDataFileName))
			FileMove, %LoggerDataFileName%, % LoggerDataFileName "~", true ; create an emacs-style file backup
		
		; data := "key`ttotal`tnorm`t+`t#`t!`t^`t$`t~`t#+`t!+`t^+`t$+`t~+`n"
		data := "key`treleases`n"
		for keyCode, freqs in LoggerData
		{
			data .= LoggerKeyNames[keyCode]
			for i, freq in freqs
				data .= "`t" freq
			
			data .= "`n"
		}
		
		FileAppend, %data%, %LoggerDataFileName%
		
		LoggerHasChanged := false
	}
	
	LoggerOpenRecords()
	{
		LoggerSaveRecords()
		Run, %LoggerDataFileName%
	}
	
	LoggerRecord(keyCode)
	{
		mods := 2
		; if (IsShiftDown)
		; {
		; 	mods |= ((ModsDown & 62) << 8)
		; 	if (mods = 2)
		; 		mods |= 8
		; }
		; else
		; {
		; 	mods |= ((ModsDown & 62) << 3)
		; 	if (mods = 2)
		; 		mods |= 4
		; }
		
		Loop, %LoggerKeyFreqCount%
			if (mods & 1 << A_Index)
				LoggerData[keyCode][A_Index]++
		
		LoggerHasChanged := true
	}
;}

; end of init code
return

;{ normal keyboard layout
	#If (IsSmallLayout && (ModsDown & ~ShiftBit = 0) && (!UseSmartSwitch || A_CaretX))
	{
		*Escape:: HoldNormal("3", "``", true, false, false)
	}
	#If ((ModsDown & ~ShiftBit = 0) && (!UseSmartSwitch || A_CaretX)) ; no modifier other than shift is held
	{
		*SC029:: HoldNormal("3", "``", true, false, false) ; tilde
		*1:: HoldNormal("4", "1", true, false, true)
		*2:: HoldNormal("7", "2", true, false, true)
		*3:: HoldNormal("8", "3", true, false, true)
		*4:: HoldNormal("=", "4", false, false, true)
		*5:: HoldNormal("[", "5", true, false, true)
		*6:: HoldNormal("]", "6", true, false, true)
		*7:: HoldNormal(",", "7", true, false, true)
		*8:: HoldNormal(".", "8", true, false, true)
		*9:: HoldNormal("9", "9", true, false, true)
		*0:: HoldNormal("0", "0", true, false, true)
		*-:: HoldNormal("[", "6", false, true, false)
		*=:: HoldNormal("]", "``", false, true, false)
		*q:: HoldNormal("'", "'", false, true, false)
		*w:: HoldNormal(",", "/", false, true, false)
		*e:: HoldNormal(".", "1", false, true, false)
		*r:: HoldNormal("p", "p", false, true, true)
		*t:: HoldNormal("y", "y", false, true, true)
		*y:: HoldNormal("f", "f", false, true, true)
		*u:: HoldNormal("g", "g", false, true, true)
		*i:: HoldNormal("c", "c", false, true, true)
		*o:: HoldNormal("r", "r", false, true, true)
		*p:: HoldNormal("l", "l", false, true, true)
		*[:: HoldNormal("/", "5", false, true, false)
		*]:: HoldNormal("\", "2", false, true, false)
		*CapsLock:: HoldNormal("-", "=", false, true, false)
		*a:: HoldNormal("a", "a", false, true, true)
		*s:: HoldNormal("o", "o", false, true, true)
		*d:: HoldNormal("e", "e", false, true, true)
		*f:: HoldNormal("i", "i", false, true, true)
		*g:: HoldNormal("u", "u", false, true, true)
		*h:: HoldNormal("d", "d", false, true, true)
		*j:: HoldNormal("h", "h", false, true, true)
		*k:: HoldNormal("t", "t", false, true, true)
		*l:: HoldNormal("n", "n", false, true, true)
		*SC027:: HoldNormal("s", "s", false, true, true) ; semicolon
		*SC028:: HoldNormal("-", "\", true, true, false) ; apostrophe
		*z:: HoldNormal(";", ";", false, true, false)
		*x:: HoldNormal("q", "q", false, true, true)
		*c:: HoldNormal("j", "j", false, true, true)
		*v:: HoldNormal("k", "k", false, true, true)
		*b:: HoldNormal("x", "x", false, true, true)
		*n:: HoldNormal("b", "b", false, true, true)
		*m:: HoldNormal("m", "m", false, true, true)
		*,:: HoldNormal("w", "w", false, true, true)
		*.:: HoldNormal("v", "v", false, true, true)
		*SC035:: HoldNormal("z", "z", false, true, true) ; slash
		
		*SC029 Up:: ReleaseNormal("3", "``", false, 13)
		*1 Up:: ReleaseNormal("4", "1", true, 1)
		*2 Up:: ReleaseNormal("7", "2", true, 2)
		*3 Up:: ReleaseNormal("8", "3", true, 3)
		*4 Up:: ReleaseNormal("=", "4", true, 4)
		*5 Up:: ReleaseNormal("[", "5", true, 5)
		*6 Up:: ReleaseNormal("]", "6", true, 6)
		*7 Up:: ReleaseNormal(",", "7", true, 7)
		*8 Up:: ReleaseNormal(".", "8", true, 8)
		*9 Up:: ReleaseNormal("9", "9", true, 9)
		*0 Up:: ReleaseNormal("0", "0", true, 10)
		*- Up:: ReleaseNormal("[", "6", false, 11)
		*= Up:: ReleaseNormal("]", "``", false, 12)
		*q Up:: ReleaseNormal("'", "'", false, 14)
		*w Up:: ReleaseNormal(",", "/", false, 15)
		*e Up:: ReleaseNormal(".", "1", false, 16)
		*r Up:: ReleaseNormal("p", "p", true, 17)
		*t Up:: ReleaseNormal("y", "y", true, 18)
		*y Up:: ReleaseNormal("f", "f", true, 19)
		*u Up:: ReleaseNormal("g", "g", true, 20)
		*i Up:: ReleaseNormal("c", "c", true, 21)
		*o Up:: ReleaseNormal("r", "r", true, 22)
		*p Up:: ReleaseNormal("l", "l", true, 23)
		*[ Up:: ReleaseNormal("/", "5", false, 24)
		*] Up:: ReleaseNormal("\", "2", false, 47)
		*CapsLock Up:: ReleaseNormal("-", "=", false, 25)
		*a Up:: ReleaseNormal("a", "a", true, 26)
		*s Up:: ReleaseNormal("o", "o", true, 27)
		*d Up:: ReleaseNormal("e", "e", true, 28)
		*f Up:: ReleaseNormal("i", "i", true, 29)
		*g Up:: ReleaseNormal("u", "u", true, 30)
		*h Up:: ReleaseNormal("d", "d", true, 31)
		*j Up:: ReleaseNormal("h", "h", true, 32)
		*k Up:: ReleaseNormal("t", "t", true, 33)
		*l Up:: ReleaseNormal("n", "n", true, 34)
		*SC027 Up:: ReleaseNormal("s", "s", true, 35)
		*SC028 Up:: ReleaseNormal("-", "\", false, 36)
		*z Up:: ReleaseNormal(";", ";", false, 37)
		*x Up:: ReleaseNormal("q", "q", true, 38)
		*c Up:: ReleaseNormal("j", "j", true, 39)
		*v Up:: ReleaseNormal("k", "k", true, 40)
		*b Up:: ReleaseNormal("x", "x", true, 41)
		*n Up:: ReleaseNormal("b", "b", true, 42)
		*m Up:: ReleaseNormal("m", "m", true, 43)
		*, Up:: ReleaseNormal("w", "w", true, 44)
		*. Up:: ReleaseNormal("v", "v", true, 45)
		*SC035 Up:: ReleaseNormal("z", "z", true, 46)
	}
	#If
	
	; holds down a normal key
	; isShiftedKeyShifted: whether the shifted version of the key is the shifted version of the "shiftedKey"
	HoldNormal(key, shiftedKey, isKeyShifted, isShiftedKeyShifted, useCapsLock)
	{
		if ((IsCapsLockOn && useCapsLock) ^ IsShiftDown)
			HoldNormalBlindShift(shiftedKey, isShiftedKeyShifted)
		else
			HoldNormalBlindShift(key, isKeyShifted)
		
		if (StickyModsDown)
			AbortStickyKey(false, true)
	}
	
	GetShiftedKey(key)
	{
		if (!ShiftedKeyDict[key])
		{
			StringUpper, key, key
			return key
		}
		
		return ShiftedKeyDict[key]
	}
	
	HoldNormalBlindShift(key, isShifted)
	{
		if (isShifted)
		{
			if (!IsShiftDown)
			{
				SendInput, {Blind}{LShift Down}
				SendInput, {Blind}{%key% Down}
				SendInput, {Blind}{LShift Up}
				
				return
			}
		}
		else
		{
			if (IsShiftDown)
			{
				if (IsLShiftDown)
				{
					SendInput, {Blind}{LShift Up}
					SendInput, {Blind}{%key% Down}
					SendInput, {Blind}{LShift Down}
				}
				else
				{
					SendInput, {Blind}{RShift Up}
					SendInput, {Blind}{%key% Down}
					SendInput, {Blind}{RShift Down}
				}
				
				return
			}
		}
		
		SendInput, {Blind}{%key% Down}
	}
	
	; keyCodes: for key logger
	ReleaseNormal(key, shiftedKey, useCapsLock, keyCode)
	{
		if ((IsCapsLockOn && useCapsLock) ^ IsShiftDown)
		{
			SendInput, {Blind}{%shiftedKey% Up}
			if (UseLogger)
				LoggerRecord(keyCode + 47) ; 47 "type-able" keys
		}
		else
		{
			SendInput, {Blind}{%key% Up}
			if (UseLogger)
				LoggerRecord(keyCode)
		}
	}
;}
;{ advanced deletion
	HoldBackSpace()
	{
		if (IsToggleDown) ; tab+backspace = delete
		{
			HoldDelete()
			return
		}
		
		if (IsPuttyActive())
		{
			if (IsControlDown)
			{
				PressCombo("BackSpace", false, true, false, false)
				return
			}
			
			if (IsFnDown)
			{
				PressCombo("0", false, true, false, false)
				PressCombo("k", true, false, false, false)
				return
			}
		}
		
		if (IsFnDown)
			SendInput, {Blind}+{Home}{BackSpace}
		else
			SendEvent, {Blind}{BackSpace Down}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	ReleaseBackSpace()
	{
		if (IsToggleDown)
		{
			ReleaseDelete()
			return
		}
		
		SendEvent, {Blind}{BackSpace Up}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	HoldDelete()
	{
		if (IsPuttyActive())
		{
			if (IsControlDown)
			{
				PressCombo("d", false, true, false, false)
				return
			}
			
			if (IsFnDown)
			{
				PressCombo("k", true, false, false, false)
				return
			}
		}
		
		if (IsFnDown)
			SendInput, {Blind}+{End}{BackSpace}{Right}
		else
			SendEvent, {Blind}{Delete Down}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	ReleaseDelete()
	{
		SendEvent, {Blind}{Delete Up}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	*BackSpace:: HoldBackSpace()
	*BackSpace Up:: ReleaseBackSpace()
	
	*Delete:: HoldDelete()
	*Delete Up:: ReleaseDelete()
;}
;{ advanced enter
	HoldEnter()
	{
		if (IsPuttyActive())
		{
			if (IsFnDown)
			{
				PressCombo("a", true, false, false, false) ; home in terminal
				SendInput, {Bilnd}{Enter}{Up}
				
				return
			}
		}
		
		if (IsFnDown)
			SendInput, {Blind}{Home}{Enter}{Up}
		else
			SendEvent, {Blind}{Enter Down}
	}
	
	ReleaseEnter()
	{
		SendEvent, {Blind}{Enter Up}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	PressEnter()
	{
		HoldEnter()
		if (!IsFnDown)
			ReleaseEnter()
	}
	
	*Enter:: HoldEnter()
	*Enter Up:: ReleaseEnter()
;}
;{ (custom): thumb backspace
	DynamicThumbBackspace()
	{
		HoldBackSpace()
	}
	
	DynamicThumbBackspaceUp()
	{
		ReleaseBackSpace()
	}
;}
;{ backslash: capslock / ime
	#If ((!UseSmartSwitch || A_CaretX) && (ModsDown & ~ShiftBit = 0))
	{
		*SC02B::
		{
			if (IsShiftDown)
				Msgln("todo: an optional numpad feature!")
			else
				ToggleCapsLock()
			
			return
		}
	}
	#If
	
	ToggleCapsLock()
	{
		if (FlipAndShowIcon(IsCapsLockOn, "CapsLockOn", "", "CapsLockOff", "", ""))
			SetCapsLockState, On
		else
			SetCapsLockState, Off
	}
;}
;{ (custom): left (as compensation when rfn takes over left arrow)
	DynamicLeft()
	{
		if (LeftKeyPosition != "RShift")
			SendInput, {Blind}{Left Down}
	}
	
	DynamicLeftUp()
	{
		if (LeftKeyPosition != "RShift")
			SendInput, {Blind}{Left Up}
	}
;}
;{ escape: escape and resets all
	; useTerminal: send control+g instead of escape
	PressEscape(useTerminal)
	{
		if (A_PriorKey = "Escape" || A_PriorHotkey = "*LShift")
			ResetAll()
		
		if (useTerminal && IsPuttyActive())
			PressCombo("g", true, false, false, false)
		else
			SendEvent, {Blind}{Escape}
		
		KeyWait, % SubStr(A_ThisHotkey, 2)
	}
	
	#If (!IsSmallLayout)
		*Escape:: PressEscape(false)
	#If
;}

;{ keyboard macros
	#If (ModsDown = 0)
	{
		F1:: SendFunctionKeyMacro("F1")
		F2:: SendFunctionKeyMacro("F2")
		F3:: SendFunctionKeyMacro("F3")
		F4:: SendFunctionKeyMacro("F4")
		F5:: SendFunctionKeyMacro("F5")
		F6:: SendFunctionKeyMacro("F6")
		F7:: SendFunctionKeyMacro("F7")
		F8:: SendFunctionKeyMacro("F8")
		F9:: SendFunctionKeyMacro("F9")
		F10:: SendFunctionKeyMacro("F10")
		F11:: SendFunctionKeyMacro("F11")
		F12:: SendFunctionKeyMacro("F12")
	}
	#If (IsFnDown && !IsToggleDown)
	{
		*SC029:: SendInput, {Escape}
		*1:: SendFunctionKeyMacro("F1")
		*2:: SendFunctionKeyMacro("F2")
		*3:: SendFunctionKeyMacro("F3")
		*4:: SendFunctionKeyMacro("F4")
		*5:: SendFunctionKeyMacro("F5")
		*6:: SendFunctionKeyMacro("F6")
		*7:: SendFunctionKeyMacro("F7")
		*8:: SendFunctionKeyMacro("F8")
		*9:: SendFunctionKeyMacro("F9")
		*0:: SendFunctionKeyMacro("F10")
		*-:: SendFunctionKeyMacro("F11")
		*=:: SendFunctionKeyMacro("F12")
		*q::
		{
			WinGet, opacity, Transparent, A
			
			opacity := (opacity = "") ? 0x3F : Mod((opacity + 0x40), 0x100)
			WinSet, Transparent, %opacity%, A
			
			ShowIconBox("Opacity", "Green", opacity / 0x100 * 100)
			
			WaitForKeyUp()
			
			return
		}
		*w:: PressTerminal("^{Left}", "b", true, true, false, true, false, false)
		*e:: PressTerminal("{Up}", "{Up}", true, false, false, false, false, false)
		*r:: PressTerminal("^{Right}", "f", true, true, false, true, false, false)
		*t::
		{
			WinSet, AlwaysOnTop, , A
			
			PinTaskBar() ; the taskbar should be always on top no matter what
			
			WinGet, isPinned, ExStyle, A
			if (isPinned & 0x8) ; ws_ex_topmost
				ShowIconBox("PinOn")
			else
				ShowIconBox("PinOff")
			
			WaitForKeyUp()
			
			return
		}
		*y::
		{
			SendInput, {Blind}{XButton2}
			WaitForKeyUp()
			
			return
		}
		*u::
		{
			if (IsLButtonDown)
			{
				SendInput, {Blind}{LButton Up}
				return
			}
			
			IsLButtonDown := true
			SendInput, {Blind}{LButton Down}
			WaitForKeyUp()
			if (A_TimeSinceThisHotkey <= MaxFnMouseKeyTimeout)
			{
				SendInput, {Blind}{LButton Up}
				IsLButtonDown := false
			}
			
			return
		}
		*i::
		{
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			MoveFnMouse(FnMouseMovingSpeedY, -1, currHotkey)
			
			return
		}
		*o::
		{
			SendInput, {Blind}{RButton}
			WaitForKeyUp()
			
			return
		}
		*p::
		{
			if (IsShiftDown)
				PressCombo("PrintScreen", false, false, false, false)
			else
				SendInput, !{PrintScreen}
			
			return
		}
		*[:: ToggleMaxPerformance(!UseMaxPerformance, true)
		*]::
		{
			TrayItemReloadSettings()
			WaitForKeyUp()
			
			return
		}
		*CapsLock:: TrayItemSmartSwitch()
		*a:: PressTerminal("{Home}", "a", true, true, true, false, false, false)
		*s:: PressTerminal("{Left}", "{Left}", true, false, false, false, false, false)
		*d:: PressTerminal("{Down}", "{Down}", true, false, false, false, false, false)
		*f:: PressTerminal("{Right}", "{Right}", true, false, false, false, false, false)
		*g:: PressTerminal("{End}", "e", true, true, true, false, false, false)
		*h::
		{
			IsAltTabMenuShowing := true
			SendInput, {LAlt Down}{Tab}
			WaitForKeyUp()
			SendInput, {LAlt Up}
			IsAltTabMenuShowing := false
			
			return
		}
		*j::
		{
			if (IsAltTabMenuShowing)
			{
				SendInput, {Blind}+{Tab}
				return
			}
			
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			MoveFnMouse(FnMouseMovingSpeedX, -1, currHotkey)
			
			return
		}
		*k::
		{
			if (IsAltTabMenuShowing)
			{
				SendInput, {Blind}{Tab}
				return
			}
			
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			MoveFnMouse(FnMouseMovingSpeedY, 1, currHotkey)
			
			return
		}
		*l::
		{
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			MoveFnMouse(FnMouseMovingSpeedX, 1, currHotkey)
			
			return
		}
		*SC027::
		{
			SendInput, {Blind}{MButton}
			WaitForKeyUp()
			
			return
		}
		*z::
		{
			if (IsShiftDown)
				WinClose, A
			else
				WinMinimize, A
			
			WaitForKeyUp()
			
			return
		}
		*x:: SendInput, {Blind}!{Left}
		*c:: SendInput, {PgDn}
		*v:: SendInput, {PgUp}
		*b:: SendInput, {Blind}!{Right}
		*n::
		{
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			FnNormalScroll("{WheelLeft}", currHotkey)
			
			return
		}
		*m::
		{
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			if (IsPuttyActive())
				FnNormalScroll("{WheelDown}", currHotkey)
			else
				FnMagicScroll("Down", currHotkey)
			
			return
		}
		*,::
		{
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			if (IsPuttyActive())
				FnNormalScroll("{WheelUp}", currHotkey)
			else
				FnMagicScroll("Up", currHotkey)
			
			return
		}
		*.::
		{
			currHotkey := SubStr(A_ThisHotkey, StrLen(A_ThisHotkey))
			FnNormalScroll("{WheelRight}", currHotkey)
			
			return
		}
		*SC035:: TrayItemLeftyMouse()
		*Home:: SendInput, {Blind}^{Home}
		*End:: SendInput, {Blind}^{End}
		*Up:: AdjustVolume(1, true)
		*Down::
		{
			if (IsShiftDown)
				ToggleMute()
			else
				AdjustVolume(-1, true)
			
			return
		}
		*Left::
		{
			if (RFnKeyPosition = "Left")
			{
				PressRFn()
				return
			}
			
			if (IsShiftDown)
				AdjustBrightness(-0xFF)
			else
				AdjustBrightness(-BrightnessStep)
			
			return
		}
		*Right::
		{
			if (IsShiftDown)
				AdjustBrightness(0xFF)
			else
				AdjustBrightness(BrightnessStep)
			
			return
		}
	}
	#If
	
	SendFunctionKeyMacro(key)
	{
		; if (UseLogger)
			; LoggerRecord(SubStr(key, 2) + 1)
		
		args := FunctionMacroDict[key]
		if (args)
			SendProgramSpecificMacro("{" A_ThisHotkey "}", args.programs, args.commands)
		else
			SendInput, {%A_ThisHotkey%}
	}
	
	SendProgramSpecificMacro(defaultCommand, programs, commands)
	{
		toSend := defaultCommand
		for i in programs
		{
			if (ArrayContains(programs[i], GetActiveProgramName()))
			{
				toSend := commands[i]
				break
			}
		}
		
		if (toSend = "*max")
		{
			WinGetPos, x, y, , , A
			if (x == -8 && y == -8) ; secret code for maximized windows
				WinRestore, A
			else
				WinMaximize, A
		}
		else if (toSend = "*min")
		{
			WinMinimize, A
		}
		else
		{
			SendInput, {Blind}%toSend%
		}
	}
	
	; sends a keyboard shortcut compatible to terminal (putty)
	; key: the normal (non-terminal) shortcut to send (with {})
	; terminalKey: the shortcut to send when putty is active (without {} when usePressCombo)
	; autoMarkSet: when putty is active and it is the first fn key-combo sent, press control+space before sending the shortcut
	; usePressCombo: true to call PressCombo() method when in terminal, false to use simple SendInput
	; use(key): the arguments to pass into PressCombo() call
	PressTerminal(key, terminalKey, autoMarkSet, usePressCombo, useControl, useAlt, useWin, useShift)
	{
		if (IsPuttyActive())
		{
			if (autoMarkSet && IsShiftDown && !IsCustomComboUsed)
				PressCombo("Space", true, false, false, false)
			
			if (usePressCombo)
				PressCombo(terminalKey, useControl, useAlt, useWin, useShift)
			else
				SendInput, {Blind}%terminalKey%
			
			IsCustomComboUsed := true
			
			return
		}
		
		SendInput, {Blind}%key%
	}
	
	MoveFnMouse(ByRef speedVar, accel, keyToWait)
	{
		speedVar := accel
		while (GetKeyState(keyToWait, "P"))
		{
			MouseMove, %FnMouseMovingSpeedX%, %FnMouseMovingSpeedY%, 0, Relative
			Sleep, %FnMouseMovingUpdateDelay%
			speedVar += accel
		}
		speedVar := 0
	}
	
	FnNormalScroll(key, keyToWait)
	{
		while (GetKeyState(keyToWait, "P"))
		{
			SendInput, %key%
			Sleep, %FnScrollingUpdateDelay%
		}
	}
	
	FnMagicScroll(dir, keyToWait)
	{
		delay := FnScrollingUpdateDelay
		while (GetKeyState(keyToWait, "P"))
		{
			MagicScroll(dir, 1)
			Sleep, %delay%
			if (delay > 1)
				delay *= 0.875
		}
	}
	
	ToggleNeverSleep(state, showIcon)
	{
		if (UseNeverSleep := state)
		{
			SetTimer, ForceWakeUp, -%NeverSleepWakingDelay%
			Menu, %AddonTrayItem%, Check, %NeverSleepTrayItem%
			
			if (showIcon)
				ShowIconBox("NeverSleepOn")
		}
		else
		{
			SetTimer, ForceWakeUp, Off
			Menu, %AddonTrayItem%, UnCheck, %NeverSleepTrayItem%
			
			if (showIcon)
				ShowIconBox("NeverSleepOff")
		}
		
		KeyWait, % SubStr(A_ThisHotkey, 2)
	}
	
	ForceWakeUp()
	{
		if (A_TimeIdle >= 0 && A_TimeIdle < NeverSleepWakingDelay)
		{
			SetTimer, ForceWakeUp, % -NeverSleepWakingDelay + A_TimeIdle
			return
		}
		
		SendInput, {ScrollLock}
		SendInput, {ScrollLock}
		
		SetTimer, ForceWakeUp, -%NeverSleepWakingDelay%
	}
	
	ToggleMaxPerformance(state, showIcon)
	{
		if (UseMaxPerformance := state)
		{
			SetBatchLines, -1
			Process, Priority, , High
			Menu, %AddonTrayItem%, Check, %MaxPerformanceTrayItem%
			
			if (showIcon)
				ShowIconBox("NeverSleepOn", "", 0, false, "Max Performance", "Green")
		}
		else
		{
			SetBatchLines, 11ms
			Process, Priority, , Normal
			Menu, %AddonTrayItem%, UnCheck, %MaxPerformanceTrayItem%
			
			if (showIcon)
				ShowIconBox("NeverSleepOff", "", 0, false, "No Max Perf.", "Red")
		}
	}
	
	; adjusts the master volume by a "volume-step"
	AdjustVolume(units, forceUnmute)
	{
		SoundGet, isMuted, , Mute
		isMuted := (isMuted = "On")
		
		SoundGet, volume
		volumeStep := GetVolumeStep(Round(volume, 2)) + units
		
		if (volumeStep > VolumeSteps.Length())
			volumeStep := VolumeSteps.Length()
		else if (volumeStep < 0)
			volumeStep := 0
		
		volume := VolumeSteps[volumeStep]
		
		if (forceUnmute && isMuted)
		{
			SoundSet, 0, , Mute
			isMuted := false
		}
		
		SoundSet, % volume
		
		ShowVolumeIconBox(volumeStep / VolumeSteps.Length(), isMuted)
	}
	
	GetVolumeStep(volume)
	{
		Loop, % VolumeSteps.Length()
			if (VolumeSteps[A_Index] > volume)
				return A_Index - 1
		
		return VolumeSteps.Length()
	}
	
	ShowVolumeIconBox(volume, isMuted)
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
	
	ToggleMute()
	{
		SoundGet, volume
		SoundGet, isMuted, , Mute
		ShowVolumeIconBox(GetVolumeStep(volume) / VolumeSteps.Length(), isMuted = "Off")
		
		SoundSet, -1, , Mute
	}
	
	AdjustBrightness(units)
	{
		VarSetCapacity(supportedBrightness, 256, 0)
		VarSetCapacity(supportedBrightnessSize, 4, 0)
		VarSetCapacity(brightnessSize, 4, 0)
		VarSetCapacity(brightness, 3, 0)
		
		hLcd := DllCall("CreateFile"
			,Str, "\\.\LCD"
			,UInt, 0x80000000 | 0x40000000 ; Read | Write
			,UInt, 0x1 | 0x2 ; File Read | File Write
			,UInt, 0
			,UInt, 0x3 ; open any existing file
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
;{ special character macros
	#If (IsFnDown && IsToggleDown)
	{
		*SC029:: PressCombo("↊", false, false, false, false)
		*1:: PressCombo("↋", false, false, false, false)
		*2:: PressCombo("½", false, false, false, false)
		*3:: PressCombo("¾", false, false, false, false)
		*4:: PressCombo("¼", false, false, false, false)
		*5:: PressCombo("‰", false, false, false, false)
		*6:: PressCombo("√", false, false, false, false)
		*0:: PressSpecCharList("*", false)
		*-:: PressSpecCharList("^", false)
		*=:: PressSpecCharList("$", false)
		*q:: PressCombo("√", false, false, false, false)
		*w:: PressSpecChar("–", "¡")
		*e:: PressSpecChar("—", "¿")
		*r:: PressSpecChar("π", "Π")
		*t:: PressSpecCharList("y", true)
		*y:: PressSpecChar("φ", "Φ")
		*u:: PressSpecChar("γ", "Γ")
		*i:: PressSpecChar("ç", "Ç")
		*o:: PressSpecChar("ρ", "P")
		*p:: PressSpecChar("λ", "Λ")
		*a:: PressSpecCharList("a", true)
		*s:: PressSpecCharList("o", true)
		*d:: PressSpecCharList("e", true)
		*f:: PressSpecCharList("i", true)
		*g:: PressSpecCharList("u", true)
		*h:: PressSpecChar("δ", "Δ")
		*j:: PressSpecChar("η", "H")
		*k:: PressSpecChar("θ", "Θ")
		*l:: PressSpecChar("ñ", "Ñ")
		*SC027:: PressSpecChar("σ", "Σ")
		*z:: PressSpecChar("±", "")
		*x:: PressCombo("™", false, false, false, false)
		*c:: PressCombo("©", false, false, false, false)
		*v:: PressCombo("®", false, false, false, false)
		*b:: PressSpecChar("χ", "X")
		*n:: PressSpecChar("ß", "B")
		*m:: PressSpecChar("µ", "M")
		*,:: PressSpecChar("ω", "Ω")
	}
	#If
	
	PressSpecChar(char, shiftedChar)
	{
		if (IsShiftDown ^ IsCapsLockOn)
			PressCombo(shiftedChar, false, false, false, false)
		else
			PressCombo(char, false, false, false, false)
	}
	
	PressSpecCharList(char, hasShiftedKey)
	{
		if (CurrSpecChar = char)
		{
			SendInput, {Blind}{BackSpace}
		}
		else
		{
			CurrSpecChar := char
			CurrSpecCharListIndex := 0
		}
		
		if ((IsShiftDown ^ IsCapsLockOn) && hasShiftedKey)
			PressCombo(CapSpecCharDict[CurrSpecChar][++CurrSpecCharListIndex], false, false, false, false)
		else
			PressCombo(SpecCharDict[CurrSpecChar][++CurrSpecCharListIndex], false, false, false, false)
		
		CurrSpecCharListIndex := Mod(CurrSpecCharListIndex, SpecCharDict[CurrSpecChar].Length())
	}
;}
;{ quick-run macros
	*#q:: QuickRun("Q")
	*#w:: QuickRun("W")
	*#t:: QuickRun("T")
	*#a:: QuickRun("A")
	*#s:: QuickRun("S")
	*#d:: QuickRun("D")
	*#f:: QuickRun("F")
	*#g:: QuickRun("G")
	*#z:: QuickRun("Z")
	*#x:: QuickRun("X")
	*#c:: QuickRun("C")
	*#b:: QuickRun("B")
	
	QuickRun(key)
	{
		if (IsStickyWinDown)
			AbortStickyKey(false, true)
		else
			SendInput, {Blind}{%StickyKeyMask%}
		
		target := QuickRunDict[key].path
		if (target = "") ; send the original win shortcut
		{
			StringLower, temp, key
			SendInput, {Blind}#%temp%
			
			return
		}
		
		if (target = "*screenshot")
		{
			SendInput, {Blind}#+s
			return
		}
		
		args := QuickRunDict[key].args
		if (args = "*cmd")
		{
			QuickRunCommand(target)
			return
		}
		
		if (IsShiftDown)
			Run, "%target%" %args%, , Maximize, QuickRunProcessId
		else
			Run, "%target%" %args%, , , QuickRunProcessId
		
		SetTimer, QuickRunForceActivate, -%ThreadStartWaitTime%
	}
	
	QuickRunCommand(command)
	{
		if (IsShiftDown)
			Run, %ComSpec% /C start /Max "" %command%, , Hide, QuickRunProcessId
		else
			Run, %ComSpec% /C start "" %command%, , Hide, QuickRunProcessId
		
		SetTimer, QuickRunForceActivate, -%ThreadStartWaitTime%
	}
	
	; stupid autohotkey!!
	global QuickRunProcessId
	QuickRunForceActivate()
	{
		WinWait, ahk_pid %QuickRunProcessId%
		WinActivate, ahk_pid %QuickRunProcessId%
		
		return
	}
;}
;{ toggle setting macros
	*#y:: ToggleMaxPerformance(!UseMaxPerformance, true)
	*#u:: TrayItemToggleBeep()
	*#i:: TrayItemSmartSwitch()
	*#o::
	{
		TrayItemReloadSettings()
		WaitForKeyUp()
		
		return
	}
	*#h:: TrayItemLeftyMouse()
	*#j:: TrayItemTerminalFuncs()
	*#k:: TrayItemTypingTestMode()
	*#SC028:: TrayItemMagicScroll()
	*#n:: ToggleNeverSleep(!UseNeverSleep, true)
	*#m:: TrayItemGesture()
	*#,:: TrayItemReversedScrolling()
	*#.:: TrayItemAccelScrolling()
	*#SC035:: LoggerOpenRecords()
;}

;{ mouse button methods
	HoldOrReleaseMouseButton(buttonName, dir)
	{
		isDownVar := "Is" buttonName "Down"
		%isDownVar% := dir = "Down"
		
		SendInput, {Blind}{%buttonName% %dir%}
		AbortStickyKey(downOrUp = "Down", true)
	}
;}
;{ lbutton
	HoldLButton()
	{
		HoldOrReleaseMouseButton("LButton", "Down")
	}
	
	ReleaseLButton()
	{
		HoldOrReleaseMouseButton("LButton", "Up")
	}
	
	*LButton::
	{
		if (UseLeftHandedMouse)
			HoldRButton()
		else
			HoldLButton()
		
		return
	}
	
	*LButton Up::
	{
		if (UseLeftHandedMouse)
			ReleaseRButton()
		else
			ReleaseLButton()
		
		return
	}
;}
;{ mbutton
	HoldMButton()
	{
		if (IsFnDown) ; fn+mbutton = toggle mute
		{
			ToggleMute()
			AbortStickyKey(true, true)
		}
		else if (IsToggleDown) ; tab+mbutton = toggle mouse gestures
		{
			TrayItemGesture()
			AbortStickyKey(true, true)
		}
		else ; normal rbutton
		{
			HoldOrReleaseMouseButton("MButton", "Down")
		}
	}
	
	ReleaseMButton()
	{
		if (!IsFnDown && !IsToggleDown)
			HoldOrReleaseMouseButton("MButton", "Up")
		
		return
	}
	
	#If (SwapMButtonAndXButton2)
	{
		*MButton:: HoldOrReleaseXButton2("Down")
		*MButton Up:: HoldOrReleaseXButton2("Up")
	}
	#If (!SwapMButtonAndXButton2)
	{
		*MButton:: HoldMButton()
		*MButton Up:: ReleaseMButton()
	}
	#If
;}
;{ rbutton
	HoldRButton()
	{
		if (IsLButtonDown) ; drag+rbutton press = copy dragged content
		{
			SendInput, {LControl Down}
			IsLControlDown := IsLControlTempDown := true
			
			KeyWait, RButton
			if (IsLButtonDown)
			{
				SendInput, {LButton Up}
				SendInput, {LButton Down}
			}
			
			SendInput, {LControl Up}
			IsLControlDown := IsLControlTempDown := true
			
			return
		}
		
		if (IsFnDown) ; fn+rbutton = copy/paste line
			PressRButtonCopyAndPasteFuncs("{LButton 3}")
		else if (IsToggleDown) ; tab+rbutton = copy/paste word
			PressRButtonCopyAndPasteFuncs("{LButton 2}")
		else ; normal rbutton
			StartGesture()
	}
	
	ReleaseRButton()
	{
		if (IsRButtonDown)
			StopGesture()
	}
	
	PressRButtonCopyAndPasteFuncs(key)
	{
		MouseGetPos, oldX, oldY
		
		SendInput, %key%^c
		AbortStickyKey(true, true)
		
		MouseGetPos, newX, newY
		if (Abs(newX - oldX) > 6 || Abs(newY - oldY) > 6)
			SendInput, %key%^v
	}
	
	global GestureDrawn
	
	StartGesture()
	{
		IsRButtonDown := true
		
		GestureDrawn := ""
		if (!UseMouseGestures || ActiveProgramNameContains(GestureWhiteList))
		{
			SendInput, {Blind}{RButton Down}
			return
		}
		
		IsDrawingGesture := true
		
		MouseGetPos, startX, startY
		prevDir := ""
		
		while (IsRButtonDown)
		{
			MouseGetPos, endX, endY
			if (Abs(endX - startX) > 12 || Abs(endY - startY) > 12)
			{
				currDir := GetDir(startX, startY, endX, endY)
				if (currDir && currDir != prevDir)
				{
					GestureDrawn .= currDir
					if (StrLen(GestureDrawn) > 2)
						break ; too many turns, report unrecognizable gesture
					
					prevDir := currDir
					
					args := GestureDict[GestureDrawn]
					if (args)
						ShowSustainedIconBox("", GestureIconDict[GestureDrawn], GestureDict[GestureDrawn].title, "")
				}
			}
			
			startX := endX
			startY := endY
			
			Sleep, %FnMouseMovingUpdateDelay%
		}
		
		HideIconBox()
		IsDrawingGesture := false
	}
	
	; returns the code of the direction between two points, with an empty string meaning undefined (from === to)
	GetDir(fromX, fromY, toX, toY)
	{
		x := toX - fromX
		y := toY - fromY
		if (x = 0) ; avoid divided by zero when later y/x
		{
			if (y = 0)
				return ""
			
			return y > 0 ? "s" : "n"
		}
		
		angle := ATan(y / x) * 144 / 3.1415926535897932384626
		if (x < 0) ; compute atan2
			angle += (y >= 0) * 288 - 144
		
		if (angle > 108)
			return "w"
		
		if (angle > 36)
			return "s"
		
		if (angle > -36)
			return "e"
		
		if (angle > -108)
			return "n"
		
		return "w"
	}
	
	StopGesture()
	{
		IsRButtonDown := false
		
		if (ModsDown)
			IsCustomComboUsed := true
		
		if (!GestureDrawn)
		{
			if (UseMouseGestures && !ActiveProgramNameContains(GestureWhiteList))
				SendInput, {Blind}{RButton}
			else
				SendInput, {Blind}{RButton Up}
			
			return
		}
		
		args := GestureDict[GestureDrawn]
		if (args)
			SendProgramSpecificMacro(args.defaultCommand, args.programs, args.commands)
	}
	
	*RButton::
	{
		if (UseLeftHandedMouse)
			HoldLButton()
		else
			HoldRButton()
		
		return
	}
	
	*RButton Up::
	{
		if (UseLeftHandedMouse)
			ReleaseLButton()
		else
			ReleaseRButton()
		
		return
	}
;}
;{ button4
	*XButton1::
	{
		AbortStickyKey(false, true)
		
		if (IsFnDown) ; fn+button4 = control+tab
		{
			temp := "Control"
			IsControlDown := IsLControlDown := IsLControlTempDown := true
		}
		else if (IsToggleDown) ; tab+button4 = win+tab
		{
			temp := "Win"
		}
		else ; button4 = alt+tab
		{
			temp := "Alt"
			IsAltTabMenuShowing := true
		}
		
		SendInput, {L%temp% Down}{Tab}
		KeyWait, XButton1
		SendInput, {L%temp% Up}
		
		if (IsAltTabMenuShowing)
			IsAltTabMenuShowing := false
		
		return
	}
;}
;{ button5
	HoldOrReleaseXButton2(dir)
	{
		if (IsFnDown)
		{
			if (dir = "Down")
			{
				SendInput, {Blind}{F5}
				AbortStickyKey(false, true)
			}
		}
		else if (IsToggleDown)
		{
			HoldOrReleaseMouseButton("XButton2", dir)
		}
		else
		{
			HoldOrReleaseMouseButton("XButton1", dir)
		}
	}
	
	#If (SwapMButtonAndXButton2)
	{
		*XButton2:: HoldMButton()
		*XButton2 Up:: ReleaseMButton()
	}
	#If (!SwapMButtonAndXButton2)
	{
		*XButton2:: HoldOrReleaseXButton2("Down")
		*XButton2 Up:: HoldOrReleaseXButton2("Up")
	}
	#If
;}
;{ mouse wheel
	*WheelUp:: Scroll("Up", true, true, true)
	*WheelDown:: Scroll("Down", true, true, true)
	
	; scrolls the mouse wheel
	; allowFnScrolling: whether it should allow fn+wheel(up|down) to trigger master volume or brightness scrolling
	; allowAccel: whether it should calcelate the speedup factor
	Scroll(dir, allowFn, allowReversed, allowAccel)
	{
		if (IsAltTabMenuShowing)
		{
			if (ScrollAltTabMenu)
			{
				if (dir = "Down")
					SendEvent, {Blind}{Tab}
				else
					SendInput, {Blind}+{Tab}
			}
			
			return
		}
		
		if (allowFn && IsFnDown)
		{
			unit := dir = "Down" ? -1 : 1
			
			if (IsShiftDown) ; fn+shift+wheel(up|down) = brightness scrolling
				AdjustBrightness(BrightnessStep * units)
			else ; volume scrolling
				AdjustVolume(unit, false)
			
			AbortStickyKey(false, true)
			
			return
		}
		
		if (allowReversed && UseReversedScrolling)
			dir := GetOppDir(dir)
		
		timeout := A_TimeSincePriorHotkey
		speedUp := 1
		
		if (allowAccel)
		{
			if (IsToggleDown && ModsDown & ~ToggleBit = 0)
				speedUp := ScrollSpeedupFactor
			
			if (ActiveProgramNameContains(ProgramsAlwaysUseAccelScrolling))
				speedUp := speedUp = 1 ? ScrollSpeedupFactor : 1
			
			if (UseAccelScrolling)
			{
				if (A_PriorHotkey = A_ThisHotkey && timeout < 521)
				{
					if (timeout < MaxAccelScrollInterval)
						PrevScrollSpeedup := Round((PrevScrollSpeedup + (1 - A_TimeSincePriorHotkey / MaxAccelScrollInterval) * ScrollSpeedupFactor) / 2)
					
					if (PrevScrollSpeedup > 1)
						speedUp *= PrevScrollSpeedup
				}
				else
				{
					PrevScrollSpeedup := 0
				}
			}
		}
		
		if ((IsToggleDown || UseMagicScrolling) && ModsDown & ~ToggleBit = 0) ; using magic scrolling while speeding up fixes a stupid windows 10 bug ("lagging and beeping")
			MagicScroll(dir, speedUp)
		else
			SendInput, {Wheel%dir% %speedUp%}
		
		AbortStickyKey(false, true)
		
		return
	}
	
	; scrolls on inactive window
	MagicScroll(dir, speedUp)
	{
		scrollDist := (dir = "Down" ? -60 : 60) * speedUp
		
		MouseGetPos, mouseX, mouseY
		MouseGetPos, , , , secondTry, 2
		MouseGetPos, , , , thirdTry, 3
		
		firstTry := DllCall("WindowFromPoint", Int, mouseX, Int, mouseY)
		
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
;}

;{ modifier methods
	global HasWowied := false
	Wowie()
	{
		Msgln("win key was pressed and released but the end of press_mod() wasn't reached! detected!")
		HasWowied := true
	}
	
	; presses a modifier
	; isActualMod: whether the modifier should be physically held down during the process (eg, fn is not a physical mod)
	; isSticky: whether the modifier still functions for the next key press after it is released
	; usePressKey: whether the sticky key has a press function (pass 2 to run a function)
	; pressKeyToSend: the key to press when calceling the sticky key (effective when usePressKey is true); or the function to run if uPK was 2
	; args*: the arguments to pass to the function (when uPK was 2)
	PressMod(key, isActualMod, isSticky, usePressKey, pressKeyToSend, args*)
	{
		keyName := SubStr(key, 2)
		keyBitVar := keyName "Bit"
		isDownVar := "Is" keyName "Down"
		isStickyVar := "IsSticky" keyName "Down"
		isDirDownVar := "Is" key "Down"
		isOppDownVar := "Is" GetOppDir(SubStr(key, 1, 1)) keyName "Down"
		currHotkey := SubStr(A_ThisHotkey, 2)
		
		%isDownVar% := %isDirDownVar% := true
		ModsDown |= %keyBitVar%
		ModDescription .= ModDict[keyName]
		if (isActualMod)
			SendEvent, {Blind}{%key% Down}
		
		if (keyName = "Win")
		{
			HasWowied := false
			SetTimer, Wowie, -2083
		}
		
		KeyWait, %currHotkey%
		
		if (keyName = "Win")
		{
			if (HasWowied)
				Msgln("nevermind! it was just a lag and win got released as usual!")
			
			SetTimer, Wowie, Off
		}
		
		if (keyName = "Alt" && IsAltTabMenuShowing)
			IsAltTabMenuShowing := false
		
		if (A_PriorKey = currHotkey && !IsCustomComboUsed)
		{
			if (A_TimeSinceThisHotkey <= MaxDualKeyTimeout)
			{
				SendModPressKey := true
			}
			else if (isSticky)
			{
				%isStickyVar% := true
				StickyModsDown |= %keyBitVar%
				ShowSustainedIconBox("FnLockOn", "", "", ModDescription)
				temp := IconBoxShownTime := A_TickCount
				
				Input, keyData, L1 M V T%MaxStickyKeyTimeout%, {%StickyKeyMask%}%InvisibleKeys%
				
				if (ErrorLevel = "Timeout") ; prevent firing actual key (such as win)
					SendEvent, {Blind}{%StickyKeyMask%}
				
				%isStickyVar% := false
				StickyModsDown &= ~%keyBitVar%
				if (IconBoxShownTime = temp)
					HideIconBox() ; only hide when no other actions triggered to show it while the sticky key was pressed down
			}
		}
		
		if (!%isOppDownVar%)
		{
			%isDownVar% := false
			ModsDown &= ~%keyBitVar%
		}
		
		%isDirDownVar% := false
		ModDescription := SubStr(ModDescription, 1, StrLen(ModDescription) - 1)
		if (isActualMod)
			SendEvent, {Blind}{%key% Up}
		
		if (usePressKey && SendModPressKey && !IsCustomComboUsed)
		{
			if (usePressKey = 2) ; run a custom function instead
				%pressKeyToSend%(args*)
			else
				SendInput, {Blind}%pressKeyToSend%
			
			if (StickyModsDown)
				IsCustomComboUsed := true ; for some reason ahk doesn't detect a custom send-input as an interruption to A_PriorKey
		}
		
		SendModPressKey := false
		IsCustomComboUsed := false
	}
	
	; aborts and masks activated sticky keys
	; useKeyWait: whether it should still allow the sticky key to be sent for the last time
	; isCustomCombo: whether the caller sent a custom combo and needs the sticky key to know (to not fire press function)
	AbortStickyKey(useKeyWait, isCustomCombo)
	{
		if (StickyModsDown)
			SendEvent, {Blind}{%StickyKeyMask%}
		
		if (isCustomCombo && ModsDown)
			IsCustomComboUsed := true
		
		if (!useKeyWait)
			return
		
		currHotkey := SubStr(A_ThisHotkey, 2)
		KeyWait, %currHotkey% ; still allow the sticky mod to be sent for the last moment (until it is released)
		
		if (A_PriorKey = currHotkey && !IsCustomComboUsed && A_TimeSinceThisHotkey <= MaxDualKeyTimeout)
			if (StickyModsDown)
				SendModPressKey := true ; let the other thread know to send the press key
	}
	
	; sends a key combo with the correct modifiers
	; -1 to any use(key) argument: ignore such key, neither hold or release it
	PressCombo(key, useControl, useAlt, useWin, useShift)
	{
		BlindModifiers("Up", useControl, useAlt, useWin, useShift)
		SendInput, {Blind}{%key%}
		BlindModifiers("Down", useControl, useAlt, useWin, useShift)
	}
	
	; sets all modifiers to down or up temporarily according to the corresponding argument; should be called in pair (set dir to
	; "Up", then "Down" after whatever action is finished)
	; use(key): true to force hold down, false, to force release, -1 to have no effect
	BlindModifiers(dir, useControl, useAlt, useWin, useShift)
	{
		oppDir := GetOppDir(dir)
		
		for i, modName in ModList
		{
			useModVar := "use" modName
			if (%useModVar% = -1)
				continue
			
			isDownVar := "Is" modName "Down"
			isLDownVar := "IsL" modName "Down"
			isRDownVar := "IsR" modName "Down"
			
			if (%useModVar%)
			{
				if (!%isDownVar%)
					SendInput, {Blind}{L%modName% %oppDir%}
			}
			else
			{
				if (%isDownVar%)
				{
					if (%isLDownVar%)
						SendInput, {Blind}{L%modName% %dir%}
					if (%isRDownVar%)
						SendInput, {Blind}{R%modName% %dir%}
				}
			}
		}
	}
;}
;{ tab: ltoggle/tab
	PressTab()
	{
		SendEvent, {Blind}{Tab}
	}
	
	#If (!IsStickyToggleDown && (ModsDown & ~ShiftBit & ~FnBit) = 0) ; no modifier other than shift or fn is down
	{
		*Tab::
		{
			if (IsFnDown)
			{
				PressMod("LToggle", false, true, true, "{LControl Down}{Tab}")
				IsControlDown := IsLControlDown := IsLControlTempDown := true
			}
			else
			{
				PressMod("LToggle", false, true, 2, "PressTab")
			}
			
			return
		}
	}
	#If (IsStickyToggleDown && (ModsDown & ~ShiftBit & ~FnBit) = 0)
	{
		*Tab:: AbortStickyKey(true, false)
	}
	#If ((ModsDown & ~ShiftBit & ~FnBit) > 0)
	{
		$*Tab:: ; stupid ahk bug: tab KEEPS on firing randomly when held
		{
			if (IsControlDown || IsAltDown || IsWinDown)
			{
				SendEvent, {Blind}{Tab}
				if (IsAltDown)
					IsAltTabMenuShowing := true
			}
			
			IsCustomComboUsed := true
			KeyWait, Tab
			
			return
		}
	}
	#If
;}
;{ lshift: lcontrol/escape
	#If (!IsStickyControlDown)
		*LShift:: PressMod("LControl", true, true, 2, "PressEscape", true)
	#If (IsStickyControlDown)
		*LShift:: AbortStickyKey(true, false)
	#If
;}
;{ lcontrol: lfn/tab
	*LControl::
	{
		PressMod("LFn", false, false, 2, "PressTab")
		
		if (IsLControlTempDown) ; fn+tab was used
		{
			SendInput, {Blind}{LControl Up}
			IsControlDown := IsLControlDown := IsLControlTempDown := false
		}
		if (IsLButtonTempDown) ; fn+u was used
		{
			SendInput, {LButton Up}
			IsLButtonTempDown := false
		}
		
		CurrSpecChar := ""
		CurrSpecCharListIndex := 0
		
		return
	}
;}
;{ lwin or lalt: lwin
	#If (!SwapLAltAndLWinKeyPositions && !IsStickyWinDown)
		*LWin:: PressMod("LWin", true, true, false, "")
	#If (!SwapLAltAndLWinKeyPositions && IsStickyWinDown)
		*LWin:: AbortStickyKey(true, false)
	#If

	#If (SwapLAltAndLWinKeyPositions && !IsStickyWinDown)
		*LAlt:: PressMod("LWin", true, true, false, "")
	#If (SwapLAltAndLWinKeyPositions && IsStickyWinDown)
		*LAlt:: AbortStickyKey(true, false)
	#If
;}
;{ lalt or lwin: lalt
	#If (!SwapLAltAndLWinKeyPositions && !IsStickyAltDown)
		*LAlt:: PressLAlt()
	#If (!SwapLAltAndLWinKeyPositions && IsStickyAltDown)
		*LAlt:: AbortStickyKey(true, false)
	#If
	
	#If (SwapLAltAndLWinKeyPositions && !IsStickyAltDown)
		*LWin:: PressLAlt()
	#If (SwapLAltAndLWinKeyPositions && IsStickyAltDown)
		*LWin:: AbortStickyKey(true, false)
	#If
	
	PressLAlt()
	{
		if (IsToggleDown) ; tab+lalt = backspace (easier to reach for left hand to reach)
			SendEvent, {Blind}{BackSpace}
		else
			PressMod("LAlt", true, true, false, "")
	}
;}
;{ space: lshift/space
	#If (!IsTypingTestModeOn && !IsStickyShiftDown)
	{
		*Space::
		{
			if (IsToggleDown) ; tab+space = enter (easier for left hand to reach)
				PressMod("LShift", true, true, 2, "PressEnter")
			else
				PressMod("LShift", true, true, true, "{Space}")
			
			return
		}
	}
	#If (!IsTypingTestModeOn && IsStickyShiftDown)
	{
		*Space:: AbortStickyKey(true, false)
	}
	#If
;}
;{ appskey, rcontrol, ralt, or left: rfn/enter
	PressRFn()
	{
		PressMod("RFn", false, false, 2, "PressEnter")
		
		if (IsLControlTempDown) ; fn+tab was used
		{
			SendInput, {Blind}{LControl Up}
			IsControlDown := IsLControlDown := IsLControlTempDown := false
		}
		
		CurrSpecChar := ""
		CurrSpecCharListIndex := 0
	}
	
	DynamicRFn()
	{
		PressRFn()
	}
;}
;{ rshift: rcontrol
	#If (UseRControl && !IsStickyControlDown)
		*RShift:: PressRControl()
	#If (UseRControl && IsStickyControlDown)
		*RShift:: AbortStickyKey(true, false)
	#If
	
	PressRControl()
	{
		if (LeftKeyPosition = "RShift")
			PressMod("RControl", true, false, true, "{Left}")
		else
			PressMod("RControl", true, true, 2, "ToggleCapsLock", true)
	}
;}
;{ (custom): rtoggle/togglelock
	DynamicRToggle:
	Suspend, Permit
	{
		if (A_IsSuspended)
		{
			currHotkey := SubStr(A_ThisHotkey, 2)
			
			isPosMod := IsModPosition(RToggleKeyPosition)
			if (isPosMod)
				SendInput, {%currHotkey% Down}
			KeyWait, %currHotkey%
			if (isPosMod)
				SendInput, {%currHotkey% Up}
			
			if (A_PriorKey = currHotkey)
			{
				if (A_TimeSinceThisHotkey <= MaxDualKeyTimeout)
					ToggleSuspend(true)
				else if (!isPosMod)
					SendInput, {%currHotkey%}
			}
			
			return
		}
		
		PressMod("RToggle", false, true, 2, "ToggleSuspend", false)
		
		return
	}
	
	; true=padv, false=qwerty
	ToggleSuspend(state)
	{
		if (state)
		{
			Suspend, Off
			ShowIconBox("ToggleOff")
			
			SetTrayIcon("Default")
			SetTrayTipText("")
			
			if (UseToggleBeeps)
			{
				SoundBeep, 586.50, 174
				SoundBeep, 878.76, 174
			}
			
			Menu, Tray, UnCheck, %SuspendTrayItem%
			
			for i, trayItem in AddonTrayItems
				Menu, %AddonTrayItem%, Enable, %trayItem%
		}
		else
		{
			Suspend, On
			SetTrayIcon("Toggle")
			SetTrayTipText("Suspended")
			ShowIconBox("ToggleOn")
			IsTypingTestModeOn := false
			
			if (UseToggleBeeps)
			{
				SoundBeep, 658.33, 174
				SoundBeep, 439.38, 174
			}
			
			Menu, Tray, Check, %SuspendTrayItem%
			
			for i, trayItem in AddonTrayItems
				Menu, %AddonTrayItem%, Disable, %trayItem%
		}
		
		ResetAll()
	}
;}

;{ other debugging tools
	#If (IsFnDown)
	{
		*F1:: TrayItemAbout()
		
		*F12:: ;  print all (non-empty) variables
		Suspend, Permit
		{
			TrayItemDebug()
			return
		}
	}
	#If
;}


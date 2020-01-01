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
	ListLines, Off
	
	; keyboard function initializations
	SetCapsLockState,  Off
	SetNumLockState, On
	SetScrollLockState, Off
;}
;{ constants
	global Version := "v4.0 T 12/31/19"
	
	global SettingsFileName := "Settings-4.0.ini"
	global DefaultSettingsSection := "config" ; the name of the section in the ini file to read by default
	
	global ModList := ["Control", "Alt", "Win", "Shift"]
	global ModDict := {Toggle: "~", Fn: "$", Control: "^", Alt: "!", Win: "#", Shift: "+"}
	global ToggleBit := 32 ; bit encoding used for vars ModsDown and StickyModsDown
	global FnBit := 16
	global ControlBit := 8
	global AltBit := 4
	global WinBit := 2
	global ShiftBit := 1
	
	global InvisibleKeys := "{Space}{Tab}{Escape}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Delete}{Insert}{Backspace}{CapsLock}{NumLock}{PrintScreen}{Pause}"
	InvisibleKeys .= "{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{F13}{F14}{F15}{F16}{F17}{F18}{F19}{F20}{F21}{F22}{F23}{F24}"
	
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
;}
;{ settings
	global DataPath
	
	global BrightnessStep
	global FnScrollingUpdateDelay ; ms per update on fn scrolling
	global FnMouseMovingUpdateDelay
	global NeverSleepWakingDelay ; ms per "force waking" command sent when never sleep mode is on
	global MaxAccelScrollInterval ; maximum interval between scrolls for accel to activate
	
	global MaxDualKeyTimeout ; the maximum wait time (in ms) before a dual-key expires its press function
	global MaxFnMouseKeyTimeout ; the maximum wait time (in ms) before fn+u be considered holding the mouse button
	global MaxStickyKeyTimeout ; the maximum wait time (in secs) before an activated sticky key expires
	global StickyKeyMask ; key mask: the key to send to prevent a sticky key's hold function from firing when expired
	
	global GestureDict
	global QuickRunDict
	
	global SwapLAltAndLWinKeyPositions
	global ThumbBackspaceKeyPosition
	global UseRControl
	global RFnKeyPosition
	global LeftKeyPosition
	global RToggleKeyPosition
	
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
	
	global CurrSpecChar := ""
	global CurrSpecCharListIndex := 0
;}
;{ helper functions
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
	
	; returns the program currently active
	GetActiveProgramName()
	{
		WinGet, temp, ProcessName, A
		SplitPath, temp, , , , temp
		
		return temp
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
		{
			SendInput, {L%modName% Up}
			SendInput, {R%modName% Up}
		}
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
		
		PinTaskBar()
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
		
		KeyWait, % SubStr(A_ThisHotkey, 2)
		
		return toToggle
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
;}

;{ tray icon and menu
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
	
	Menu, Tray, NoStandard
	
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
	
	global ImeTrayItem := "Chinese Shuangpin IME`tFn+\ , Shift+\"
	Menu, %AddonTrayItem%, Add, %ImeTrayItem%, TrayItemIme
	TrayItemIme()
	{
		ToggleIme()
	}
	
	Menu, %AddonTrayItem%, Add

	global GestureTrayItem := "Use mouse gestures"
	Menu, %AddonTrayItem%, Add, %GestureTrayItem%, TrayItemGesture
	TrayItemGesture()
	{
		if (UseMouseGestures := !UseMouseGestures)
			Menu, %AddonTrayItem%, Check, %GestureTrayItem%
		else
			Menu, %AddonTrayItem%, UnCheck, %GestureTrayItem%
	}
	
	global MaxPerformanceTrayItem := "Force maximum performance`tFn+["
	Menu, %AddonTrayItem%, Add, %MaxPerformanceTrayItem%, TrayItemMaxPerformance
	TrayItemMaxPerformance()
	{
		ToggleMaxPerformance(!UseMaxPerformance, true)
	}
	
	global SmartSwitchTrayItem := "Auto QWERTY while not inputting`tFn+CapsLock"
	Menu, %AddonTrayItem%, Add, %SmartSwitchTrayItem%, TrayItemSmartSwitch
	TrayItemSmartSwitch()
	{
		FlipAndShowIcon(UseSmartSwitch, "SmartSwitchOn", "", "SmartSwitchOff", "", SmartSwitchTrayItem)
	}
	
	global ToggleBeepTrayItem := "Beeps on suspension`tFn+'"
	Menu, %AddonTrayItem%, Add, %ToggleBeepTrayItem%, TrayItemToggleBeep
	TrayItemToggleBeep()
	{
		FlipAndShowIcon(UseToggleBeeps, "VolumeMedium", "Toggle Beeps", "MuteOn", "No Beeps", ToggleBeepTrayItem)
	}
	
	global TerminalFuncTrayItem := "Auto convert Putty (terminal) hotkeys`tFn+b"
	Menu, %AddonTrayItem%, Add, %TerminalFuncTrayItem%, TrayItemTerminalFuncs
	TrayItemTerminalFuncs()
	{
		FlipAndShowIcon(UseTerminalFuncs, "SmartSwitchOn", "Putty Friendly", "SmartSwitchOff", "No Putty Friendly", TerminalFuncTrayItem)
	}
	
	global NeverSleepTrayItem := "Monitor never sleeps`tFn+n"
	Menu, %AddonTrayItem%, Add, %NeverSleepTrayItem%, TrayItemNeverSleep
	TrayItemNeverSleep()
	{
		ToggleNeverSleep(!UseNeverSleep, true)
	}
	
	global MagicScrollTrayItem := "Use magic (inactive window) scrolling`tFn+m"
	Menu, %AddonTrayItem%, Add, %MagicScrollTrayItem%, TrayItemMagicScroll
	TrayItemMagicScroll()
	{
		FlipAndShowIcon(UseMagicScrolling, "NormalScrollingOff", "", "NormalScrollingOn", "", MagicScrollTrayItem)
	}
	
	global ReversedScrollingTrayItem := "Use reversed scrolling`tFn+,"
	Menu, %AddonTrayItem%, Add, %ReversedScrollingTrayItem%, TrayItemReversedScrolling
	TrayItemReversedScrolling()
	{
		FlipAndShowIcon(UseReversedScrolling, "NormalScrollingOff", "Reversed Scroll", "NormalScrollingOn", "No Rev. Scroll", ReversedScrollingTrayItem)
	}
	
	global AccelScrollingTrayItem := "Use scroll-acceleration`tFn+."
	Menu, %AddonTrayItem%, Add, %AccelScrollingTrayItem%, TrayItemAccelScrolling
	TrayItemAccelScrolling()
	{
		FlipAndShowIcon(UseAccelScrolling, "NormalScrollingOff", "Scroll Accel.", "NormalScrollingOn", "No Scroll Accel.", AccelScrollingTrayItem)
	}
	
	global LeftyMouseTrayItem := "Use left-handed Mouse`tFn+/"
	Menu, %AddonTrayItem%, Add, %LeftyMouseTrayItem%, TrayItemLeftyMouse
	TrayItemLeftyMouse()
	{
		FlipAndShowIcon(UseLeftHandedMouse, "LeftyMouseOn", "", "LeftyMouseOff", "", LeftyMouseTrayItem)
	}
	
	global AddonTrayItems := [ImeTrayItem, GestureTrayItem, SmartSwitchTrayItem, TerminalFuncTrayItem
		,NeverSleepTrayItem, MagicScrollTrayItem, ReversedScrollingTrayItem, AccelScrollingTrayItem, LeftyMouseTrayItem]
	
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
		Run, %SettingsFileName%
	}
	
	Menu, Tray, Add, % "Reload settings`tFn+]", TrayItemReloadSettings
	TrayItemReloadSettings()
	{
		ShowIconBox("", "", 0, false, "Reload...", "Green")
		SetTimer, ReloadSettings, -260 ; force the process to be done in a different thread
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
	
	Menu, %DebugTrayItem%, Add, % "Reset all modifiers`tEscape", ResetAll
	
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
	LoadSettings(true)
	SetTrayIcon("Default")
	SetTrayTipText("")
	
	if (LoadSetting("AttemptAdmin", false))
		AttemptRestartAsAdmin()
	
	ResetAll()
;}
;{ icon box
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
;{ ime
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
	
	; shows the IME hint box with the candidates
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
				rest .= i " " candidate "`n"
		}
		
		height := (ImeCandidates.Length() + 1) * 24
		
		GetImeBoxPosition(width, height, x, y)
		
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
			GuiControl, %ImeBox%:, FirstText, % (ImeCandidates.Length() > 1 ? "1 " : "") ImeCandidates[1]
			GuiControl, %ImeBox%:Move, FirstText, W%width%
			
			if (ImeCandidates.Length() >= 2)
			{
				GuiControl, %ImeBox%:Show, RestText
				GuiControl, %ImeBox%:, RestText, % rest
				GuiControl, %ImeBox%:Move, RestText, W%width% H%height%
			}
		}
	}
	
	; gets the position of where the hint box needs to pop up according to which screen is focused
	GetImeBoxPosition(width, height, ByRef x, ByRef y)
	{
		if (A_CaretX = "")
		{
			MouseGetPos, mouseX, mouseY
			x := mouseX
			y := mouseY
		}
		else
		{
			x := A_CaretX
			y := A_CaretY
		}
		
		if (NumScreens = 1)
		{
			if (x + width + 50 > MainScreenRight)
				x := MainScreenRight - width - 25
			else
				x += 25
			
			if (y + height + 50 > MainScreenBottom)
				y -= height + 15
			else
				y += 25
			
			return
		}
		
		; get the screen the candidate position ("focus point") is currently on
		Loop, %NumScreens%
		{
			SysGet, currentScreenCoord, Monitor, %A_Index%
			
			if (x >= currentScreenCoordLeft && x < currentScreenCoordRight
				&& y >= currentScreenCoordTop && y < currentScreenCoordBottom)
					break
		}
		
		if (x + width + 50 > currentScreenCoordRight)
			x := currentScreenCoordRight - width - 25
		else
			x += 25
		
		if (y + height + 50 > currentScreenCoordBottom)
			y -= height + 15
		else
			y += 25
	}
	
	HideImeBox()
	{
		Gui, %ImeBox%:Hide
		
		IsImeBoxShowing := false
	}
	
	; sends the nth item in the ime candidate list
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
	
	; removes everything in the IME candidate list and resets the screen code
	ClearImeCandidates()
	{
		while (ImeCandidates.Length())
			ImeCandidates.Pop()
		
		ImeScreenCode := ""
	}
	
	ClearImeCode()
	{
		ImeCode := ""
		ImeCodeLength := 0
		ClearImeCandidates()
		HideImeBox()
	}
	
	; sends a key to the chinese shuangpin ime
	PressImeKey(key)
	{
		if (ImeCodeLength = 4)
		{
			if (key = "*")
			{
				SendImeCandidate(1)
				return
			}
			if (key = "," || key = "<")
			{
				SendImeCandidate(2)
				return
			}
			if (key = "." || key = ">")
			{
				SendImeCandidate(3)
				return
			}
			if (key = "{")
			{
				SendImeCandidate(4)
				return
			}
			
			SendImeCandidate(1) ; "push" onto screen
		}
		
		if (ImeCodeLength = 0 || ImeCodeLength = 4)
		{
			if (!OneKeyCharDict.HasKey(key))
			{
				if (MarkDict.HasKey(key)) ; "chinese" punctuation marks
				{
					PressCombo(MarkDict[key][++MarkCurrentIndexDict[key]], false, false, false, false)
					MarkCurrentIndexDict[key] := Mod(MarkCurrentIndexDict[key], MarkDict[key].Length())
				}
				else
				{
					PressCombo(key, false, false, false, false)
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
		
		StringLower, temp, ImeCode
		if (!(temp == ImeCode)) ; the code contains uppercase letters (stupid ahk syntax!)
		{
			ShowImeBox()
			return
		}
		
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
				
				ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 2)] " [" StrScrCodeDict[strCode] "]"
			}
			
			altSyl := SubStr(ImeCode, 1, 2)
			
			if (SylAltDict.HasKey(altSyl))
			{
				altSyl := SylAltDict[altSyl]
				
				if (CharDict.HasKey(altSyl strCode))
				{
					for i, char in CharDict[altSyl strCode]
						ImeCandidates.Push(char)
					
					if (ImeScreenCode = "")
						ImeScreenCode := SylScrCodeDict[altSyl] " [" StrScrCodeDict[strCode] "]"
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
			
			if (BigramDict.HasKey(ImeCode)) ; first second
			{
				for i, bigram in BigramDict[ImeCode]
				{
					ImeCandidates.Push(bigram)
				}
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[firstSyl] "'" SylScrCodeDict[secondSyl]
			}
			
			if (altSecondSyl != "" && BigramDict.HasKey(firstSyl altSecondSyl))
			{
				for i, bigram in BigramDict[firstSyl altSecondSyl]
					ImeCandidates.Push(bigram)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[firstSyl] "'" SylScrCodeDict[altSecondSyl]
			}
			
			if (altFirstSyl != "" && BigramDict.HasKey(altFirstSyl secondSyl))
			{
				for i, bigram in BigramDict[altFirstSyl secondSyl]
					ImeCandidates.Push(bigram)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[altFirstSyl] "'" SylScrCodeDict[secondSyl]
			}
			
			if (altFirstSyl != "" && altSecondSyl != "" && BigramDict.HasKey(altFirstSyl altSecondSyl))
			{
				for i, bigram in BigramDict[altFirstSyl altSecondSyl]
					ImeCandidates.Push(bigram)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[altFirstSyl] "'" SylScrCodeDict[altSecondSyl]
			}
			
			; trigrams come second in proirity
			
			if (TrigramDict.HasKey(ImeCode))
			{
				for i, trigram in TrigramDict[ImeCode]
					ImeCandidates.Push(trigram)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 1)] "'" SylScrCodeDict[SubStr(ImeCode, 2, 1)] "'" SylScrCodeDict[secondSyl]
			}
			
			if (altSecondSyl != "" && TrigramDict.HasKey(firstSyl altSecondSyl))
			{
				for i, trigram in TrigramDict[firstSyl altSecondSyl] ; "firstSyl" here is not really a syllable, it's two initials
					ImeCandidates.Push(trigram)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 1)] "'" SylScrCodeDict[SubStr(ImeCode, 2, 1)] "'" SylScrCodeDict[altSecondSyl]
			}
			
			; then all long phrases
			
			if (LongDict.HasKey(ImeCode))
			{
				for i, long in LongDict[ImeCode]
					ImeCandidates.Push(long)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[SubStr(ImeCode, 1, 1)] "'" SylScrCodeDict[SubStr(ImeCode, 2, 1)] "'" SylScrCodeDict[SubStr(ImeCode, 3, 1)] "'" SylScrCodeDict[SubStr(ImeCode, 4, 1)]
			}
			
			; finally all full-coded characters
			
			if (CharDict.HasKey(ImeCode))
			{
				for i, char in CharDict[ImeCode]
					ImeCandidates.Push(char)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[firstSyl] " [" StrScrCodeDict[SubStr(secondSyl, 1, 1)] "," StrScrCodeDict[SubStr(secondSyl, 2, 1)] "]"
			}
			
			if (altFirstSyl != "" && CharDict.HasKey(altFirstSyl secondSyl))
			{
				for i, char in CharDict[altFirstSyl secondSyl] ; secondSyl is not a syllable here, it's two str codes
					ImeCandidates.Push(char)
				
				if (ImeScreenCode = "")
					ImeScreenCode := SylScrCodeDict[altFirstSyl] " [" StrScrCodeDict[SubStr(secondSyl, 1, 1)] "," StrScrCodeDict[SubStr(secondSyl, 2, 1)] "]"
			}
		}
		
		if (ImeScreenCode = "") ; "empty code"
			ImeScreenCode := ImeCode
		
		ShowImeBox()
	}
;}
;{ loading
	LoadSettings(isFirstLoad)
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
		LoadSetting("StickyKeyMask", "RControl")
		
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
				ThumbBackspaceKeyPosition := "RWin"
				UseRControl := false
				RFnKeyPosition := "RAlt"
				LeftKeyPosition := "Left"
				RToggleKeyPosition := "RShift"
			}
			else
			{
				SwapLAltAndLWinKeyPositions := false
				ThumbBackspaceKeyPosition := "RAlt"
				UseRControl := true
				RFnKeyPosition := "AppsKey"
				LeftKeyPosition := "Left"
				RToggleKeyPosition := "RControl"
			}
		}
		else
		{
			LoadSetting("SwapLAltAndLWinKeyPositions", false)
			LoadSetting("ThumbBackspaceKeyPosition", "RAlt")
			LoadSetting("UseRControl", true)
			LoadSetting("RFnKeyPosition", "AppsKey")
			LoadSetting("LeftKeyPosition", "Left")
			LoadSetting("RToggleKeyPosition", "RControl")
			
			temp := "Suspend Asianboii's UI`t" RToggleKeyPosition
			if (temp != SuspendTrayItem)
			{
				Menu, Tray, Rename, %SuspendTrayItem%, %temp%
				SuspendTrayItem := temp
			}
		}
		
		GestureDict := {}
		QuickRunDict := {}
		
		; mouse gestures
		for dir in GestureIconDict
			LoadGestureSetting(dir)
		
		; quick runs
		LoadQuickRunSetting("Tilde")
		LoadQuickRunSetting("Minus")
		LoadQuickRunSetting("Equals")
		Loop, 10
			LoadQuickRunSetting(A_Index - 1) ; number keys
		
		; ime dictionary
		LoadImeCodeDicts(DataPath "/Ime.txt")
	}
	
	LoadSetting(setting, defaultValue)
	{
		IniRead, %setting%, %SettingsFileName%, %DefaultSettingsSection%, %setting%, %defaultValue%
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
		StringUpper, temp, dir
		args := StrSplit(LoadSetting("Gesture" temp, ""), "|")
		
		GestureDict[dir] := {toSend: args[1], title: args[2]}
	}
	
	LoadQuickRunSetting(key)
	{
		args := StrSplit(LoadSetting("QuickRun" key, ""), "|")
		
		QuickRunDict[key] := {path: args[1], args: args[2]}
	}
	
	LoadImeCodeDicts(file)
	{
		MarkDict := {}
		OneKeyCharDict := {}
		CharDict := {}
		BigramDict := {}
		TrigramDict := {}
		LongDict := {}
		SylAltDict := {}
		SylScrCodeDict := {}
		StrScrCodeDict := {}
		
		if (!FileExist(file))
		{
			HasImeDict := false
			return
		}
		
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

;{ normal keyboard layout
	#If ((ModsDown & ~ShiftBit = 0) && (!UseSmartSwitch || A_CaretX)) ; no modifer other than shift is held
	{
		*SC029:: HoldNormal("``", "``", false, true, false) ; tilde
		*1:: HoldNormal("8", "1", true, false, true)
		*2:: HoldNormal(",", "2", true, false, true)
		*3:: HoldNormal(".", "3", true, false, true)
		*4:: HoldNormal("[", "4", true, false, true)
		*5:: HoldNormal("]", "5", true, false, true)
		*6:: HoldNormal("5", "6", true, false, true)
		*7:: HoldNormal("[", "7", false, false, true)
		*8:: HoldNormal("]", "8", false, false, true)
		*9:: HoldNormal("9", "9", true, false, true)
		*0:: HoldNormal("0", "0", true, false, true)
		*-:: HoldNormal("7", "\", true, true, false)
		*=:: HoldNormal("2", "6", true, true, false)
		*q:: HoldNormal("'", "'", false, true, false)
		*w:: HoldNormal(",", "1", false, true, false)
		*e:: HoldNormal(".", "/", false, true, false)
		*r:: HoldNormal("p", "p", false, true, false)
		*t:: HoldNormal("y", "y", false, true, false)
		*y:: HoldNormal("f", "f", false, true, false)
		*u:: HoldNormal("g", "g", false, true, false)
		*i:: HoldNormal("c", "c", false, true, false)
		*o:: HoldNormal("r", "r", false, true, false)
		*p:: HoldNormal("l", "l", false, true, false)
		*[:: HoldNormal("/", "\", false, false, false)
		*]:: HoldNormal("3", "4", true, true, false)
		*CapsLock:: HoldNormal("-", "=", false, true, false)
		*a:: HoldNormal("a", "a", false, true, false)
		*s:: HoldNormal("o", "o", false, true, false)
		*d:: HoldNormal("e", "e", false, true, false)
		*f:: HoldNormal("i", "i", false, true, false)
		*g:: HoldNormal("u", "u", false, true, false)
		*h:: HoldNormal("d", "d", false, true, false)
		*j:: HoldNormal("h", "h", false, true, false)
		*k:: HoldNormal("t", "t", false, true, false)
		*l:: HoldNormal("n", "n", false, true, false)
		*SC027:: HoldNormal("s", "s", false, true, false) ; semicolon
		*SC028:: HoldNormal("=", "-", false, true, false) ; apostrophe
		*z:: HoldNormal("`;", "`;", false, true, false)
		*x:: HoldNormal("q", "q", false, true, false)
		*c:: HoldNormal("j", "j", false, true, false)
		*v:: HoldNormal("k", "k", false, true, false)
		*b:: HoldNormal("x", "x", false, true, false)
		*n:: HoldNormal("b", "b", false, true, false)
		*m:: HoldNormal("m", "m", false, true, false)
		*,:: HoldNormal("w", "w", false, true, false)
		*.:: HoldNormal("v", "v", false, true, false)
		*SC035:: HoldNormal("z", "z", false, true, false) ; slash
		
		*SC029 Up:: ReleaseNormal("``", "``", false) ; tilde
		*1 Up:: ReleaseNormal("8", "1", true)
		*2 Up:: ReleaseNormal(",", "2", true)
		*3 Up:: ReleaseNormal(".", "3", true)
		*4 Up:: ReleaseNormal("[", "4", true)
		*5 Up:: ReleaseNormal("]", "5", true)
		*6 Up:: ReleaseNormal("5", "6", true)
		*7 Up:: ReleaseNormal("[", "7", true)
		*8 Up:: ReleaseNormal("]", "8", true)
		*9 Up:: ReleaseNormal("9", "9", true)
		*0 Up:: ReleaseNormal("0", "0", true)
		*- Up:: ReleaseNormal("7", "\", false)
		*= Up:: ReleaseNormal("2", "6", false)
		*q Up:: ReleaseNormal("'", "'", false)
		*w Up:: ReleaseNormal(",", "1", false)
		*e Up:: ReleaseNormal(".", "/", false)
		*r Up:: ReleaseNormal("p", "p", false)
		*t Up:: ReleaseNormal("y", "y", false)
		*y Up:: ReleaseNormal("f", "f", false)
		*u Up:: ReleaseNormal("g", "g", false)
		*i Up:: ReleaseNormal("c", "c", false)
		*o Up:: ReleaseNormal("r", "r", false)
		*p Up:: ReleaseNormal("l", "l", false)
		*[ Up:: ReleaseNormal("/", "\", false)
		*] Up:: ReleaseNormal("3", "4", false)
		*CapsLock Up:: ReleaseNormal("-", "=", false)
		*a Up:: ReleaseNormal("a", "a", false)
		*s Up:: ReleaseNormal("o", "o", false)
		*d Up:: ReleaseNormal("e", "e", false)
		*f Up:: ReleaseNormal("i", "i", false)
		*g Up:: ReleaseNormal("u", "u", false)
		*h Up:: ReleaseNormal("d", "d", false)
		*j Up:: ReleaseNormal("h", "h", false)
		*k Up:: ReleaseNormal("t", "t", false)
		*l Up:: ReleaseNormal("n", "n", false)
		*SC027 Up:: ReleaseNormal("s", "s", false) ; semicolon
		*SC028 Up:: ReleaseNormal("=", "-", false) ; apostrophe
		*z Up:: ReleaseNormal("`;", "`;", false)
		*x Up:: ReleaseNormal("q", "q", false)
		*c Up:: ReleaseNormal("j", "j", false)
		*v Up:: ReleaseNormal("k", "k", false)
		*b Up:: ReleaseNormal("x", "x", false)
		*n Up:: ReleaseNormal("b", "b", false)
		*m Up:: ReleaseNormal("m", "m", false)
		*, Up:: ReleaseNormal("w", "w", false)
		*. Up:: ReleaseNormal("v", "v", false)
		*SC035 Up:: ReleaseNormal("z", "z", false) ; slash
	}
	#If
	
	; holds down a normal key
	; isShiftedKeyShifted: whether the shifted version of the key is the shifted version of the "shiftedKey"
	HoldNormal(key, shiftedKey, isKeyShifted, isShiftedKeyShifted, useCapsLock)
	{
		if (ModsDown)
			IsCustomComboUsed := true
		
		if (IsImeOn && !IsImeTempOff)
		{
			if ((IsCapsLockOn && useCapsLock) ^ IsShiftDown)
			{
				if (isShiftedKeyShifted)
					PressImeKey(GetShiftedKey(shiftedKey))
				else
					PressImeKey(shiftedKey)
			}
			else
			{
				if (isKeyShifted)
					PressImeKey(GetShiftedKey(key))
				else
					PressImeKey(key)
			}
			
			return
		}
		
		if ((IsCapsLockOn && useCapsLock) ^ IsShiftDown)
			HoldNormalBlindShift(shiftedKey, isShiftedKeyShifted)
		else
			HoldNormalBlindShift(key, isKeyShifted)
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
	
	ReleaseNormal(key, shiftedKey, useCapsLock)
	{
		if ((IsCapsLockOn && useCapsLock) ^ IsShiftDown)
			SendInput, {Blind}{%shiftedKey% Up}
		else
			SendInput, {Blind}{%key% Up}
	}
;}
;{ advanced deletion
	HoldBackSpace()
	{
		if (IsImeOn && ImeCodeLength > 0)
		{
			if (IsFnDown || IsControlDown || IsToggleDown)
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
			SendInput, {Blind}{BackSpace Down}
		
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
		
		SendInput, {Blind}{BackSpace Up}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	HoldDelete()
	{
		if (IsImeOn && ImeCodeLength > 0)
		{
			ClearImeCode()
			return
		}
		
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
			SendInput, {Blind}{Delete Down}
		
		if (ModsDown)
			IsCustomComboUsed := true
	}
	
	ReleaseDelete()
	{
		SendInput, {Blind}{Delete Up}
		
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
		if (IsImeOn && ImeCodeLength > 0)
		{
			SendImeCandidate(0)
			return
		}
		
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
			SendInput, {Blind}{Enter Down}
	}
	
	ReleaseEnter()
	{
		SendInput, {Blind}{Enter Up}
		
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
;{ ralt or rwin: backspace
	#If (ThumbBackspaceKeyPosition = "RAlt")
	{
		*RAlt:: HoldBackSpace()
		*RAlt Up:: ReleaseBackSpace()
	}
	#If (ThumbBackspaceKeyPosition = "RWin")
	{
		*RWin:: HoldBackSpace()
		*RWin Up:: ReleaseBackSpace()
	}
	#If
;}
;{ backslash: capslock / ime
	#If (!IsToggleDown && !IsAltDown && !IsWinDown && (!UseSmartSwitch || IsFnDown && !IsShiftDown))
	{
		*SC02B:: ; backslash
		{
			if (IsFnDown || IsShiftDown)
			{
				ToggleIme()
				KeyWait, SC02B
			}
			else
			{
				if (FlipAndShowIcon(IsCapsLockOn, "CapsLockOn", "", "CapsLockOff", "", ""))
					SetCapsLockState, On
				else
					SetCapsLockState, Off
			}
			
			return
		}
	}
	#If
	
	ToggleIme()
	{
		if (IsImeOn := !IsImeOn)
		{
			if (HasImeDict)
			{
				ShowIconBox("ImeOn")
				SetTrayIcon("Ime")
				SetTrayTipText("Chinese Shuangpin IME Activated")
				
				Menu, %AddonTrayItem%, Check, %ImeTrayItem%
			}
			else
			{
				IsImeOn := false
				MsgBox, % "The Shuangpin (双拼) IME dictionary could not be found. Please contact Asianboii for the dictionary file!!`n`nFile path: """ DataPath "/Ime.txt"""
			}
		}
		else
		{
			if (ImeCodeLength > 0)
				SendImeCandidate(0) ; clear candidates before switching IME off
			
			ShowIconBox("ImeOff")
			SetTrayIcon("Default")
			SetTrayTipText("")
			
			Menu, %AddonTrayItem%, UnCheck, %ImeTrayItem%
		}
	}
;}
;{ rshift, rcontrol, or ralt: left (as compensation when rfn takes over left arrow)
	#If (LeftKeyPosition = "RShift")
	{
		*RShift:: SendInput, {Blind}{Left Down}
		*RShift Up:: SendInput, {Blind}{Left Up}
	}
	#If (LeftKeyPosition = "RControl")
	{
		*RControl:: SendInput, {Blind}{Left Down}
		*RControl Up:: SendInput, {Blind}{Left Up}
	}
	#If (LeftKeyPosition = "RAlt")
	{
		*RAlt:: SendInput, {Blind}{Left Down}
		*RAlt Up:: SendInput, {Blind}{Left Up}
	}
	#If
;}
;{ escape: escape and resets all
	; useTerminal: send control+g instead of escape
	PressEscape(useTerminal)
	{
		if (IsImeOn && ImeCodeLength > 0)
		{
			ClearImeCode()
			return
		}
		
		ResetAll()
		
		if (useTerminal && IsPuttyActive())
			PressCombo("g", true, false, false, false)
		else
			SendInput, {Blind}{Escape}
		
		KeyWait, % SubStr(A_ThisHotkey, 2)
	}
	
	*Esc:: PressEscape(false)
;}
;{ keyboard macros
	#If (IsFnDown && !IsToggleDown)
	{
		*SC029:: QuickRun("Tilde")
		*1:: QuickRun("1")
		*2:: QuickRun("2")
		*3:: QuickRun("3")
		*4:: QuickRun("4")
		*5:: QuickRun("5")
		*6:: QuickRun("6")
		*7:: QuickRun("7")
		*8:: QuickRun("8")
		*9:: QuickRun("9")
		*0:: QuickRun("0")
		*-:: QuickRun("Minus")
		*=:: QuickRun("Equals")
		*q::
		{
			if (IsShiftDown)
				WinClose, A
			else
				WinMinimize, A
			
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
			
			return
		}
		*y::
		{
			WinGet, opacity, Transparent, A
			
			opacity := (opacity = "") ? 0x3F : Mod((opacity + 0x40), 0x100)
			WinSet, Transparent, %opacity%, A
			
			ShowIconBox("Opacity", "Green", opacity / 0x100 * 100)
			
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
			KeyWait, u
			if (A_TimeSinceThisHotkey <= MaxFnMouseKeyTimeout)
			{
				SendInput, {Blind}{LButton Up}
				IsLButtonDown := false
			}
			
			return
		}
		*i::
		{
			currHotKey := SubStr(A_ThisHotkey, 2)
			
			if (IsShiftDown)
				MoveFnMouse(FnMouseMovingSpeedY, -1, currHotKey)
			else if (IsPuttyActive())
				FnNormalScroll("{WheelUp}", currHotKey)
			else
				FnMagicScroll("Up", currHotKey)
			
			return
		}
		*o::
		{
			SendInput, {Blind}{RButton}
			KeyWait, o
			
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
			KeyWait, ]
			
			return
		}
		*CapsLock:: TrayItemSmartSwitch()
		*a:: PressTerminal("{Home}", "a", true, true, true, false, false, false)
		*s:: PressTerminal("{Left}", "{Left}", true, false, false, false, false, false)
		*d:: PressTerminal("{Down}", "{Down}", true, false, false, false, false, false)
		*f:: PressTerminal("{Right}", "{Right}", true, false, false, false, false, false)
		*g:: PressTerminal("{End}", "e", true, true, true, false, false, false)
		*h:: PressTerminal("{PgUp}", "v", true, true, false, true, false, false)
		*j::
		{
			currHotKey := SubStr(A_ThisHotkey, 2)
			
			if (IsShiftDown)
				MoveFnMouse(FnMouseMovingSpeedX, -1, currHotKey)
			else
				FnNormalScroll("{WheelLeft}", currHotKey)
			
			return
		}
		*k::
		{
			currHotKey := SubStr(A_ThisHotkey, 2)
			
			if (IsShiftDown)
				MoveFnMouse(FnMouseMovingSpeedY, 1, currHotKey)
			else if (IsPuttyActive())
				FnNormalScroll("{WheelDown}", currHotKey)
			else
				FnMagicScroll("Down", currHotKey)
			
			return
		}
		*l::
		{
			currHotKey := SubStr(A_ThisHotkey, 2)
			
			if (IsShiftDown)
				MoveFnMouse(FnMouseMovingSpeedX, 1, currHotKey)
			else
				FnNormalScroll("{WheelRight}", currHotKey)
			
			return
		}
		*SC027:: PressTerminal("{PgDn}", "v", true, true, true, false, false, false)
		*SC028:: TrayItemToggleBeep()
		*z:: SendInput, {Blind}!{Left}
		*x:: SendInput, {Blind}!{Right}
		*c:: SendInput, {Blind}!{Down}
		*v:: SendInput, {Blind}!{Up}
		*b:: TrayItemTerminalFuncs()
		*n:: ToggleNeverSleep(!UseNeverSleep, true)
		*m:: TrayItemMagicScroll()
		*,:: TrayItemReversedScrolling()
		*.:: TrayItemAccelScrolling()
		*SC035:: TrayItemLeftyMouse()
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
	
	; runs a file/program blinding all held hotkeys/dual-keys.
	QuickRun(key)
	{
		target := QuickRunDict[key]["path"]
		if (target = "")
			return
		
		args := QuickRunDict[key]["args"]
		if (args = "(cmd)")
		{
			QuickRunCommand(target)
			return
		}
		
		BlindModifiers("Up", false, false, false, false)
		if (IsShiftDown)
			Run, "%target%" %args%, , Maximize, temp
		else
			Run, "%target%" %args%, , , temp
		BlindModifiers("Down", false, false, false, false)
		
		; wait for the program window to pop up in order to force-activate it
		WinWait, ahk_pid %temp%, , 0
		WinActivate, ahk_pid %temp%, , 0
	}

	; runs a command blinding all held hotkeys/dual-keys.
	QuickRunCommand(command)
	{
		BlindModifiers("Up", false, false, false, false)
		if (IsShiftDown)
			Run, %ComSpec% /C start /Max "" %command%, , Hide, temp
		else
			Run, %ComSpec% /C start "" %command%, , Hide, temp
		BlindModifiers("Down", false, false, false, false)
		
		WinWait, ahk_pid %temp%, , 0
		WinActivate, ahk_pid %temp%, , 0
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
			SetTimer, ForceWakeUp, % NeverSleepWakingDelay
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
		SendInput, {ScrollLock}
		SendInput, {ScrollLock}
	}
	
	ReloadSettings()
	{
		LoadSettings(false)
	}
	
	ToggleMaxPerformance(state, showIcon)
	{
		if (UseMaxPerformance := state)
		{
			SetBatchLines, -1
			Menu, %AddonTrayItem%, Check, %MaxPerformanceTrayItem%
			
			if (showIcon)
				ShowIconBox("NeverSleepOn", "", 0, false, "Max Performance", "Green")
		}
		else
		{
			SetBatchLines, 11ms
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
		*5:: PressCombo("√", false, false, false, false)
		*6:: PressCombo("‰", false, false, false, false)
		*7:: PressSpecCharList("*", false)
		*=:: PressSpecCharList("^", false)
		*q:: PressCombo("√", false, false, false, false)
		*w:: PressSpecChar("±", "¡")
		*e:: PressSpecChar("—", "¿")
		*r:: PressSpecChar("π", "Π")
		*t:: PressSpecCharList("y", true)
		*y:: PressSpecChar("φ", "Φ")
		*u:: PressSpecChar("γ", "Γ")
		*i:: PressSpecChar("ç", "Ç")
		*o:: PressSpecChar("ρ", "P")
		*p:: PressSpecChar("λ", "Λ")
		*]:: PressSpecCharList("$", false)
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
	*MButton::
	{
		if (IsFnDown) ; fn+mbutton = toggle mute
		{
			ToggleMute()
			AbortStickyKey(true, true)
		}
		else if (IsToggleDown) ; tab+rbutton = toggle magic scrolling
		{
			FlipAndShowIcon(UseMagicScrolling, "NormalScrollingOff", "", "NormalScrollingOn", "", MagicScrollTrayItem)
			AbortStickyKey(true, true)
		}
		else ; normal rbutton
		{
			HoldOrReleaseMouseButton("MButton", "Down")
		}
		
		return
	}
	
	*MButton Up::
	{
		if (!IsFnDown && !IsToggleDown)
			HoldOrReleaseMouseButton("MButton", "Up")
		
		return
	}
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
		if (!UseMouseGestures)
		{
			SendInput, {RButton Down}
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
			if (UseMouseGestures)
				SendInput, {Blind}{RButton}
			else
				SendInput, {Blind}{RButton Up}
			
			return
		}
		
		args := GestureDict[GestureDrawn]
		if (args)
		{
			toSend := args.toSend
			if (toSend = "``new")
			{
				if (GetActiveProgramName() = "chrome")
					SendInput, ^t
				else
					SendInput, ^n
			}
			else if (toSend = "``copy")
			{
				if (GetActiveProgramName() = "explorer")
					SendInput, ^c
				else
					SendInput, ^c^x^v ; allows and "undo" command to delete
			}
			else if (toSend = "``max")
			{
				WinGetPos, x, y, , , A
				if (x == -8 && y == -8) ; secret code for maximumized windows
					WinRestore, A
				else
					WinMaximize, A
			}
			else if (toSend = "``min")
			{
				WinMinimize, A
			}
			else
			{
				SendInput, %toSend%
			}
		}
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
			IsControlDown := IsLControlDown := IsLControlTempDown := true
			temp := "Control"
		}
		else if (IsToggleDown) ; tab+button4 = win+tab
		{
			temp := "Win"
		}
		else ; button4 = alt+tab
		{
			temp := "Alt"
		}
		
		SendInput, {L%temp% Down}{Tab}
		KeyWait, XButton1
		SendInput, {L%temp% Up}
		
		return
	}
;}
;{ button5
	*XButton2:: HoldOrReleaseXButton2("Down")
	*XButton2 Up:: HoldOrReleaseXButton2("Up")
	
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
;}
;{ mouse wheel
	*WheelUp:: Scroll("Up", true, true, true)
	*WheelDown:: Scroll("Down", true, true, true)
	
	; scrolls the mouse wheel
	; allowFnScrolling: whether it should allow fn+wheel(up|down) to trigger master volume or brightness scrolling
	; allowAccel: whether it should calcelate the speedup factor
	Scroll(dir, allowFn, allowReversed, allowAccel)
	{
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
				speedUp := 4
			
			if (UseAccelScrolling)
			{
				if (A_PriorHotkey = A_ThisHotkey && timeout < 521)
				{
					if (timeout < MaxAccelScrollInterval)
						PrevScrollSpeedup := Round((PrevScrollSpeedup + (1 - A_TimeSincePriorHotkey / MaxAccelScrollInterval) * 4) / 2)
					
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
		currHotKey := SubStr(A_ThisHotkey, 2)
		
		%isDownVar% := %isDirDownVar% := true
		ModsDown |= %keyBitVar%
		ModDescription .= ModDict[keyName]
		if (isActualMod)
			SendInput, {Blind}{%key% Down}
		
		KeyWait, %currHotKey%
		
		if (A_PriorKey = currHotKey && !IsCustomComboUsed)
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
				
				Input, keyData, L1 M V T%MaxStickyKeyTimeout%, {%StickyKeyMask%}%InvisibleKeys%
				
				if (ErrorLevel = "Timeout") ; prevent firing actual key (such as win)
					SendInput, {Blind}{%StickyKeyMask%}
				
				%isStickyVar% := false
				StickyModsDown &= ~%keyBitVar%
				HideIconBox()
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
			SendInput, {Blind}{%key% Up}
		
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
			SendInput, {Blind}{%StickyKeyMask%}
		
		if (isCustomCombo && ModsDown)
			IsCustomComboUsed := true
		
		if (!useKeyWait)
			return
		
		currHotKey := SubStr(A_ThisHotkey, 2)
		KeyWait, %currHotKey% ; still allow the sticky mod to be sent for the last moment (until it is released)
		
		if (A_PriorKey = currHotKey && !IsCustomComboUsed && A_TimeSinceThisHotkey <= MaxDualKeyTimeout)
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
		if (IsImeOn && ImeCodeLength > 0)
		{
			SendImeCandidate(4)
			return
		}
		
		SendInput, {Blind}{Tab}
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
				SendInput, {Blind}{Tab}
			
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
			SendInput, {Blind}{BackSpace}
		else
			PressMod("LAlt", true, true, false, "")
	}
;}
;{ space: lshift/space
	#If (!IsStickyShiftDown)
	{
		*Space::
		{
			if (IsImeOn && ImeCodeLength > 0) ; top priority while using the ime
			{
				SendImeCandidate(1)
				KeyWait, Space
				
				return
			}
			
			if (IsToggleDown) ; tab+space = enter (easier for left hand to reach)
				PressMod("LShift", true, true, 2, "PressEnter")
			else
				PressMod("LShift", true, true, true, "{Space}")
			
			if (UseNeverSleep) ; reset user's "inactive" clock
			{
				SetTimer, ForceWakeUp, Off
				SetTimer, ForceWakeUp, % NeverSleepWakingDelay
			}
			
			return
		}
	}
	#If (IsStickyShiftDown)
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
	
	#If (RFnKeyPosition = "AppsKey") ; aka menu key
		*AppsKey:: PressRFn()
	#If (RFnKeyPosition = "RControl")
		*RControl:: PressRFn()
	#If (RFnKeyPosition = "RAlt")
		*RAlt:: PressRFn()
	#If (RFnKeyPosition = "Left") ; left arrow
		*Left:: PressRFn()
	#If
;}
;{ rshift: rcontrol
	#If (UseRControl && !IsStickyControlDown)
		*RShift:: PressMod("RControl", true, true, 2, "PressEscape", true)
	#If (UseRControl && IsStickyControlDown)
		*RShift:: AbortStickyKey(true, false)
	#If
;}
;{ rcontrol, ralt, or rshift: rtoggle/togglelock
	PressRToggle()
	{
		currHotKey := SubStr(A_ThisHotkey, 2)
		
		if (A_IsSuspended)
		{
			SendInput, {%currHotKey% Down}
			KeyWait, %currHotKey%
			SendInput, {%currHotKey% Up}
			
			if (A_PriorKey = currHotKey && A_TimeSinceThisHotkey <= MaxDualKeyTimeout)
				ToggleSuspend(true)
			
			return
		}
		
		IsToggleDown := IsRToggleDown := true
		ModsDown |= ToggleBit
		
		KeyWait, %currHotKey%
		
		IsRToggleDown := false
		if (!IsLToggleDown)
		{
			IsToggleDown := false
			ModsDown &= !ToggleBit
		}
		
		if (A_PriorKey = currHotKey && !IsCustomComboUsed && !IsLToggleDown && A_TimeSinceThisHotkey <= MaxDualKeyTimeout)
		{
			if (IsImeOn && ImeCodeLength > 0)
				SendImeCandidate(0) ; clear ime imputs before toggling
			
			ToggleSuspend(false)
		}
	}
	
	; true=padv, false=qwerty
	ToggleSuspend(state)
	{
		if (state)
		{
			Suspend, Off
			ShowIconBox("ToggleOff")
			
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
			
			if (UseToggleBeeps)
			{
				SoundBeep, 587.33, 174
				SoundBeep, 880, 174
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
			
			if (UseToggleBeeps)
			{
				SoundBeep, 659.25, 174
				SoundBeep, 440, 174
			}
			
			Menu, Tray, Check, %SuspendTrayItem%
			
			for i, trayItem in AddonTrayItems
				Menu, %AddonTrayItem%, Disable, %trayItem%
		}
		
		ResetAll()
	}
	
	#If (RToggleKeyPosition = "RControl")
	{
		*RControl::
		Suspend, Permit
		{
			PressRToggle()
			return
		}
	}
	#If (RToggleKeyPosition = "RAlt")
	{
		*RAlt::
		Suspend, Permit
		{
			PressRToggle()
			return
		}
	}
	#If (RToggleKeyPosition = "RShift")
	{
		*RShift::
		Suspend, Permit
		{
			PressRToggle()
			return
		}
	}
	#If
;}

;{ testing area
	#If (InStr(Version, "Beta") || IsFnDown)
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



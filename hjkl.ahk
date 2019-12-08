#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;************光标移动**********
!j::  	;;光标下移
    Send , {Down}
    Return
!l::	;;光标右移
    Send , {Right}
    Return
!k::	;;光标左移
    Send , {Up}
    Return
!h::	;;光标上移
    Send , {Left}
    Return
!a::	;;光标移动到行首
	Send , {Home}
	Return
!e::	;;光标移动到行尾
	Send , {End}
	Return
!+$h::	;;光标移动到上一个单词
	Send , ^{Left}
	Return
!+$l::	;;光标移动到下一个单词
	Send , ^{Right}
	Return

;;*********删除************
!+$j::	;;向左删除单词
	Send , ^{Backspace}
	Return
!+$K::	;;向右删除单词
	Send , ^{Del}
	Return
!n::	;;向左删除
	Send , {Backspace}
	Return
!m::	;;向右删除
	Send , {Del}
	Return

;;**********替换*************
!u::	;;撤销
	Send , ^{z}
	Return
!i::	;;反撤销
	Send , ^{y}
	Return
!+$a::	;;全选
	Send , ^{a}
	Return
!s::	;;保存
	Send , ^{s}
	Return
!f::	;;搜索
	Send , ^{f}
	Return

CapsLock::`		;;将Caps替换为 `
$+CapsLock::    ;用shift+caps替代原来的caps
    SetCapsLockState % getkeystate("CapsLock", "t") ? "off" : "on"
    return

;*******************Windows 10 虚拟桌面自动切换*********************

#Persistent
$ctrl::
if ctrl_presses > 0 ; SetTimer 已经启动，所以我们记录按键。
{
ctrl_presses += 1
return
}
;否则，这是新一系列按键的首次按键。将计数设为 1 并启动定时器：
ctrl_presses = 1
SetTimer, Keyctrl, 500 ;在 500 毫秒内等待更多的按键。
return
Keyctrl:
SetTimer, Keyctrl, off
if ctrl_presses = 1 ;该键已按过一次。
{
Gosub singleClick
}
else if ctrl_presses = 2 ;该键已按过两次。
{
Gosub doubleClick
}
else if ctrl_presses = 3
{
Gosub trebleClick
}
;不论上面哪个动作被触发，将计数复位以备下一系列的按键：

ctrl_presses = 0
return
singleClick:
send {ctrl}
return

doubleClick:
send #^{left}
return

trebleClick:
send #^{right}
return

;不论上面哪个动作被触发，将计数复位以备下一系列的按键：**这个好像没用上**
SPACE_presses = 0
return
singleClick2:
send {SPACE}
return

doubleClick2:
send {enter}
return

;***********关闭应用*************
!q:: send !{F4}

;***********最大化，最小化**********
!enter:: ;; alt-enter
#enter::
    WinGet,S,MinMax,A
    if S=0
        WinMaximize,A
    else if S=1
        WinRestore,A
    else if S=-1
        WinRestore,A
    return


;*************调节亮度*****************
$F12::
if F12_presses > 0 ; SetTimer 已经启动，所以我们记录按键。
{
F12_presses += 1
return
}
;否则，这是新一系列按键的首次按键。将计数设为 1 并启动定时器：
F12_presses = 1
SetTimer, Keyf12, 250 ;在 500 毫秒内等待更多的按键。
return
Keyf12:
SetTimer, Keyf12, off
if F12_presses = 1 ;该键已按过一次。
{
Gosub singleClickf12
}
else if F12_presses >= 2 ;该键已按过两次。
{
Gosub moreClickf12
}
;不论上面哪个动作被触发，将计数复位以备下一系列的按键：

F12_presses = 0
return
singleClickf12:
send {F12}
return

moreClickf12:
	MoveBRightness(5)
return

$F11::
if F11_presses > 0 ; SetTimer 已经启动，所以我们记录按键。
{
F11_presses += 1
return
}
;否则，这是新一系列按键的首次按键。将计数设为 1 并启动定时器：
F11_presses = 1
SetTimer, Keyf11, 250 ;在 500 毫秒内等待更多的按键。
return
Keyf11:
SetTimer, Keyf11, off
if F11_presses = 1 ;该键已按过一次。
{
Gosub singleClickf11
}
else if F11_presses >= 2 ;该键已按过两次。
{
Gosub moreClickf11
}
;不论上面哪个动作被触发，将计数复位以备下一系列的按键：

F11_presses = 0
return
singleClickf11:
send {F11}
return

moreClickf11:
	MoveBRightness(-5)
return

MoveBrightness(IndexMove)
{

	VarSetCapacity(SupportedBRightness, 256, 0)
	VarSetCapacity(SupportedBRightnessSize, 4, 0)
	VarSetCapacity(BRightnessSize, 4, 0)
	VarSetCapacity(BRightness, 3, 0)

	hLCD := DllCall("CreateFile"
		, Str, "\\.\LCD"
		, UInt, 0x80000000 | 0x40000000 ;Read | Write
		, UInt, 0x1 | 0x2  ; File Read | File Write
		, UInt, 0
		, UInt, 0x3        ; open any existing file
		, UInt, 0
		, UInt, 0)

	if hLCD != -1
	{
		DevVideo := 0x00000023, BuffMethod := 0, Fileacces := 0
		NumPut(0x03, BRightness, 0, "UChar")      ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
		NumPut(0x00, BRightness, 1, "UChar")      ; The AC bRightness level
		NumPut(0x00, BRightness, 2, "UChar")      ; The DC bRightness level
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

		ACBRightness := NumGet(BRightness, 1, "UChar")
		ACIndex := 0
		DCBRightness := NumGet(BRightness, 2, "UChar")
		DCIndex := 0
		BufferSize := NumGet(SupportedBRightnessSize, 0, "UInt")
		MaxIndex := BufferSize-1

		loop, %BufferSize%
		{
			ThisIndex := A_Index-1
			ThisBRightness := NumGet(SupportedBRightness, ThisIndex, "UChar")
			if ACBRightness = %ThisBRightness%
				ACIndex := ThisIndex
			if DCBRightness = %ThisBRightness%
				DCIndex := ThisIndex
		}

		if DCIndex >= %ACIndex%
			BRightnessIndex := DCIndex
		else
			BRightnessIndex := ACIndex

		BRightnessIndex += IndexMove

		if BRightnessIndex > %MaxIndex%
			BRightnessIndex := MaxIndex

		if BRightnessIndex < 0
			BRightnessIndex := 0

		NewBRightness := NumGet(SupportedBRightness, BRightnessIndex, "UChar")

		NumPut(0x03, BRightness, 0, "UChar")               ; 0x01 = Set AC, 0x02 = Set DC, 0x03 = Set both
		NumPut(NewBRightness, BRightness, 1, "UChar")      ; The AC bRightness level
		NumPut(NewBRightness, BRightness, 2, "UChar")      ; The DC bRightness level

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

	}

}
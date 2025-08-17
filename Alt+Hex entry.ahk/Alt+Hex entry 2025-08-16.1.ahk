#Requires AutoHotkey v2.0.19
; Name:        Alt+Hex entry.ahk
; Version:     2025-08-16.1
; Description: Use AutoHotkey to isolate the Alt,Numpad+ combo to enter a Unicode 4-digit HEX code or Alt,Shift,Numpad+ to enter a 5-digit HEX code
; Author:      Jeremy Gagliardi
; License:     GPL v3
; URL:         https://github.com/jjg8/AutoHotkey-Scripts/tree/main/Alt%2BHex%20entry.ahk

;———————————————————————————————————————————————
; Globals
hexActive := false
hexDigits := 4
hexBuffer := ""

;———————————————————————————————————————————————
; Kick off 4-digit HEX code entry on Alt + NumpadAdd (“+” on numeric keypad)
!NumpadAdd:: {
    global hexActive, hexDigits, hexBuffer
    hexActive := true
	hexDigits := 4
    hexBuffer := ""
    ShowTip("▗▞▚▖ Alt,Numpad+ pressed, waiting for 4-digit HEX input (Esc=cancel) . . .")
    return
}

;———————————————————————————————————————————————
; Kick off 5-digit HEX code entry on Alt + Shift + NumpadAdd (“+” on numeric keypad)
!+NumpadAdd:: {
    global hexActive, hexDigits, hexBuffer
    hexActive := true
	hexDigits := 5
    hexBuffer := ""
    ShowTip("▗▞▚▖ Alt,Shift,Numpad+ pressed, waiting for 5-digit HEX input (Esc=cancel) . . .")
    return
}

;———————————————————————————————————————————————
; While hexActive, capture exactly 4 or 5 HEX digits

#HotIf hexActive

; Top-row Digits
*0:: AppendHex("0")
*1:: AppendHex("1")
*2:: AppendHex("2")
*3:: AppendHex("3")
*4:: AppendHex("4")
*5:: AppendHex("5")
*6:: AppendHex("6")
*7:: AppendHex("7")
*8:: AppendHex("8")
*9:: AppendHex("9")

; Numpad Digits
*Numpad0:: AppendHex("0")
*Numpad1:: AppendHex("1")
*Numpad2:: AppendHex("2")
*Numpad3:: AppendHex("3")
*Numpad4:: AppendHex("4")
*Numpad5:: AppendHex("5")
*Numpad6:: AppendHex("6")
*Numpad7:: AppendHex("7")
*Numpad8:: AppendHex("8")
*Numpad9:: AppendHex("9")

; Letters A–F (either case)
*A:: AppendHex("A")
*B:: AppendHex("B")
*C:: AppendHex("C")
*D:: AppendHex("D")
*E:: AppendHex("E")
*F:: AppendHex("F")

; Press Escape to cancel
*Esc:: {
    global hexActive, hexDigits, hexBuffer

    ; reset entry state
    hexActive := false
    hexDigits := 4
    hexBuffer := ""

    ; brief feedback
	base_tooltip := "▗▞▚▖ HEX Code Entry CANCELED ▗▞▚▖ THIS TOOLTIP WILL SELF-DESTRUCT IN 3…"
    ShowTip(base_tooltip)
	sleep 1000
    ShowTip(base_tooltip "2…")
	sleep 1000
	ShowTip(base_tooltip "2…💥💥💥")
	SetTimer(() => ShowTip(), -1000)

    ; clear the tip after 2 seconds
    ; ShowTip("▗▞▚▖ Hex entry CANCELED ▗▞▚▖")
    ; SetTimer(() => ShowTip(), -2000)

    ; return to swallow the Escape keystroke
    Return
}

#HotIf  ; end context-sensitive hotkeys

;———————————————————————————————————————————————
; AppendHex(d) – helper to build buffer, show tooltip, send at 4 or 5 HEX digits
AppendHex(d) {
    global hexActive, hexDigits, hexBuffer
 
    hexBuffer .= d
    ShowTip("▗▞▚▖ HEX Code Entered:  " hexBuffer " (Esc=cancel) ▗▞▚▖")

    if (StrLen(hexBuffer) = hexDigits) {
        ; inject the real Unicode character
        SendUnicode(hexBuffer)

        ; reset state
        hexActive := false
		hexDigits := 4
        hexBuffer := ""
    }
}

;———————————————————————————————————————————————
; SendUnicode(hex) accepts 4 or 5 HEX digits as input and outputs the Unicode character
SendUnicode(hex) {
    ; Strip optional “U+” prefix and parse
    hex  := RegExReplace(hex, "i)^(?:U\+)?")
    code := ("0x" hex) + 0

    ; Build actual UTF-16 char(s)
    if (code <= 0xFFFF) {
        text := Chr(code)
    }
    else if (code <= 0x10FFFF) {
        cp   := code - 0x10000
        high := ((cp >> 10) & 0x3FF) + 0xD800
        low  := ( cp  & 0x3FF) + 0xDC00
        text := Chr(high) . Chr(low)
    }
    else {
        Throw Format("Unicode code point out of range: 0x{:X}", code)
    }

    ; Send the raw Unicode string
    Send(text)

    base_tooltip := "▗▞▚▖ Sent Unicode {U+" hex "} ⫷" text "⫸ THIS TOOLTIP WILL SELF-DESTRUCT IN 3…"
    ShowTip(base_tooltip)
	sleep 1000
    ShowTip(base_tooltip "2…")
	sleep 1000
	ShowTip(base_tooltip "2…💥💥︎💥︎")
    SetTimer(() => ShowTip(), -1000)
        
    ; clear tooltip after a moment
    ; SetTimer(() => ShowTip(), -3000)
}


;———————————————————————————————————————————————
; Show tooltip helper
ShowTip(text := "") {
  ; v2’s built-in ToolTip command shows text when non-empty, hides it when empty
  Tooltip(text, 20, 80)
}



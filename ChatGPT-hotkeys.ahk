; ChatGPT — Fenêtre FIXE (AHK v2)
; Alt+X : ouvrir/activer + imposer taille/position
; Alt+W : minimiser
#SingleInstance Force
DetectHiddenWindows True
SetTitleMatchMode 2

; --- Géométrie voulue (1920×1080) ---
gX := 16
gY := 48
gW := 680
gH := 1032    ; 48 + 1032 = 1080
gHWND := 0

!x::OpenOrFocusChatGPT()
!w::MinimizeChatGPT()

; Bloque redimensionnement / déplacement / maximisation
OnMessage(0x0112, WM_SYSCOMMAND)     ; SC_*
OnMessage(0x00A1, WM_NCLBUTTONDOWN)  ; clic barre de titre

OpenOrFocusChatGPT() {
    global gX,gY,gW,gH,gHWND
    exe := "C:\Program Files\ChatGPT\ChatGPT.exe"

    hwnd := GetMainChatGPTHwnd()
    if (!hwnd) {
        if FileExist(exe) {
            Run(exe)
            WinWait("ahk_exe ChatGPT.exe", , 5000)
            hwnd := GetMainChatGPTHwnd()
            if (!hwnd)
                return
        } else return
    }

    gHWND := hwnd
    ApplyFixedStyle(hwnd)                 ; enlève la bordure redimensionnable + bouton Max
    WinShow("ahk_id " hwnd), WinRestore("ahk_id " hwnd)
    WinMove(gX, gY, gW, gH, "ahk_id " hwnd)
    WinActivate("ahk_id " hwnd)
    SetTimer(EnforceGeometry, 500)        ; garde la fenêtre collée si quelque chose essaie de la bouger
}

MinimizeChatGPT() {
    global gHWND
    if (gHWND && WinExist("ahk_id " gHWND))
        WinMinimize("ahk_id " gHWND)
}

EnforceGeometry(*) {
    global gX,gY,gW,gH,gHWND
    if (!gHWND || !WinExist("ahk_id " gHWND))
        return
    if (WinGetMinMax("ahk_id " gHWND) != 0)   ; minimisée/maximisée → ne rien faire
        return
    pos := WinGetPos("ahk_id " gHWND)         ; [x,y,w,h]
    if (pos[1]!=gX || pos[2]!=gY || pos[3]!=gW || pos[4]!=gH)
        WinMove(gX, gY, gW, gH, "ahk_id " gHWND)
}

ApplyFixedStyle(hwnd) {
    ; supprime redimensionnement (WS_THICKFRAME) et bouton Max (WS_MAXIMIZEBOX)
    GWL_STYLE := -16
    WS_MAXIMIZEBOX := 0x00010000
    WS_THICKFRAME  := 0x00040000
    style := DllCall("GetWindowLongPtr", "ptr", hwnd, "int", GWL_STYLE, "ptr")
    style := style & ~WS_MAXIMIZEBOX & ~WS_THICKFRAME
    DllCall("SetWindowLongPtr", "ptr", hwnd, "int", GWL_STYLE, "ptr", style, "ptr")
    SWP_NOMOVE := 0x0002, SWP_NOSIZE := 0x0001, SWP_NOZORDER := 0x0004, SWP_FRAMECHANGED := 0x0020
    DllCall("SetWindowPos", "ptr", hwnd, "ptr", 0, "int", 0, "int", 0, "int", 0, "int", 0
        , "uint", SWP_NOMOVE|SWP_NOSIZE|SWP_NOZORDER|SWP_FRAMECHANGED)
}

WM_SYSCOMMAND(wParam, lParam, msg, hwnd) {
    global gHWND
    if (hwnd != gHWND)          ; ne bloque que la fenêtre ChatGPT ciblée
        return
    cmd := wParam & 0xFFF0
    if (cmd=0xF010 || cmd=0xF000 || cmd=0xF030)  ; MOVE, SIZE, MAXIMIZE
        return 0
}

WM_NCLBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global gHWND
    if (hwnd = gHWND && wParam = 2)  ; HTCAPTION = 2 → empêcher le drag par la barre de titre
        return 0
}

GetMainChatGPTHwnd() {
    ids := WinGetList("ahk_exe ChatGPT.exe")
    if (ids.Length = 0) return 0
    best := 0, bestArea := -1
    for id in ids {
        pos := WinGetPos("ahk_id " id)
        if (pos.Length >= 4) {
            area := pos[3]*pos[4]
            if (area > bestArea)
                best := id, bestArea := area
        }
    }
    return best
}

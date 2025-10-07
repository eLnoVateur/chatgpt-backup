# Chemins
$dir     = "$env:USERPROFILE\.chatgpt"
$old     = Join-Path $dir "ChatGPT-hotkey.ahk"
$new     = Join-Path $dir "ChatGPT-hotkeys.ahk"
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ChatGPT-hotkeys.lnk"
$ahkExe  = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"

# 1) Stopper AHK et nettoyer anciens fichiers/raccourcis
Stop-Process -Name "AutoHotkey64","AutoHotkey" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\ChatGPT-hotkey.lnk" -ErrorAction SilentlyContinue
Remove-Item $old -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $dir -Force | Out-Null

# 2) Écrire le script FINAL (Alt+X focus/restore, Alt+W minimize, focus sur la fenêtre principale)
@'
#SingleInstance Force
DetectHiddenWindows True
SetTitleMatchMode 2
#Warn

!x::OpenOrFocusChatGPT()   ; Alt + X
!w::MinimizeChatGPT()      ; Alt + W

OpenOrFocusChatGPT() {
    exe := "C:\Program Files\ChatGPT\ChatGPT.exe"
    hwnd := GetMainChatGPTHwnd()
    if (hwnd) {
        WinShow("ahk_id " hwnd)
        WinRestore("ahk_id " hwnd)
        WinActivate("ahk_id " hwnd)
        return
    }
    if FileExist(exe) {
        Run(exe)
        WinWait("ahk_exe ChatGPT.exe", , 5000)
        hwnd := GetMainChatGPTHwnd()
        if (hwnd) {
            WinShow("ahk_id " hwnd)
            WinRestore("ahk_id " hwnd)
            WinActivate("ahk_id " hwnd)
        }
    } else {
        MsgBox("MANQUANT : " exe)
    }
}

MinimizeChatGPT() {
    hwnd := GetMainChatGPTHwnd()
    if (hwnd) {
        WinMinimize("ahk_id " hwnd)
    }
}

GetMainChatGPTHwnd() {
    ids := WinGetList("ahk_exe ChatGPT.exe")
    if (ids.Length = 0)
        return 0
    best := 0, bestArea := -1
    for id in ids {
        pos := WinGetPos("ahk_id " id)  ; [x,y,w,h]
        if (pos.Length >= 4) {
            area := pos[3] * pos[4]
            if (area > bestArea) {
                best := id
                bestArea := area
            }
        }
    }
    return best
}
'@ | Out-File -Encoding UTF8 $new -Force

# 3) Raccourci de démarrage → nouveau script
$w = New-Object -ComObject WScript.Shell
$s = $w.CreateShortcut($startup)
$s.TargetPath = $ahkExe
$s.Arguments  = "`"$new`""
$s.Save()

# 4) Lancer maintenant
& $ahkExe "$new"

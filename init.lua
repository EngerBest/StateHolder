local KEY_F5 = 62
local KEY_F9 = 66

local function create_powershell_script()
    local script_content = [[
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $mode = $args
    $user = $env:USERNAME
    $src = "C:\Users\$user\AppData\LocalLow\Nolla_Games_Noita\save00"
    $dst = "C:\Users\$user\AppData\LocalLow\Nolla_Games_Noita\state_holder_data"

    if ($mode -eq "save") {
        $proc = Get-Process -Name "noita" -ErrorAction SilentlyContinue
        if ($proc) { $proc | Wait-Process }
        Start-Sleep -Milliseconds 1200
        
        if (Test-Path $dst) { Remove-Item -Path $dst -Recurse -Force }
        Copy-Item -Path $src -Destination $dst -Recurse -Force
    } else {
        Stop-Process -Name "noita" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
        
        if (Test-Path $src) { Remove-Item -Path $src -Recurse -Force }
        Copy-Item -Path $dst -Destination $src -Recurse -Force
    }

    Stop-Process -Name "noita" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500

    Start-Process "noita.exe"
    
    for ($i = 0; $i -lt 60; $i++) {
        $g = Get-Process -Name "noita" -ErrorAction SilentlyContinue
        if ($g -and $g.MainWindowHandle -ne [IntPtr]::Zero) {
            Start-Sleep -Seconds 3 
            
            $wshell = New-Object -ComObject WScript.Shell
            $sig = '[DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);'
            $win32 = Add-Type -MemberDefinition $sig -Name "Win32Focus" -Namespace "Win32" -PassThru
            
            [void]$win32::SetForegroundWindow($g.MainWindowHandle)
            Start-Sleep -Milliseconds 200
            
            # $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
            # $X = [int]($screen.Width / 2)
            # $Y = [int]($screen.Height / 2)
            # [System.Windows.Forms.Cursor]::Position = [System.Drawing.Point]::new($X, $Y)
            # Start-Sleep -Milliseconds 200
            
            # [System.Windows.Forms.SendKeys]::SendWait('^{ESC}')
            # Start-Sleep -Milliseconds 300
            # [System.Windows.Forms.SendKeys]::SendWait('^{ESC}')
            # Start-Sleep -Milliseconds 200
            
            [void]$win32::SetForegroundWindow($g.MainWindowHandle)
            break;
        }
        Start-Sleep -Seconds 1
    }
    ]]

    local file = io.open("noita_quicksave_helper.ps1", "w")
    if file then
        file:write(script_content)
        file:close()
    end
end

create_powershell_script()

function OnWorldPreUpdate()
    if InputIsKeyJustDown(KEY_F5) then 
        GamePrint("Saving...")
        os.execute('start powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File noita_quicksave_helper.ps1 save')
        os.execute('taskkill /IM noita.exe')
    end

    if InputIsKeyJustDown(KEY_F9) then 
        GamePrint("Loading...")
        os.execute('start powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File noita_quicksave_helper.ps1 load')
    end
end

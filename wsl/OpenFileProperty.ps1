# C# code to be compiled
$cSharpCode = @'
using System;
using System.Runtime.InteropServices;

public class FileProperties
{
    [DllImport("shell32.dll", CharSet = CharSet.Auto)]
    public static extern bool ShellExecuteEx(ref SHELLEXECUTEINFO lpExecInfo);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
    public struct SHELLEXECUTEINFO
    {
        public int cbSize;
        public uint fMask;
        public IntPtr hwnd;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string lpVerb;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string lpFile;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string lpParameters;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string lpDirectory;
        public int nShow;
        public IntPtr hInstApp;
        public IntPtr lpIDList;
        [MarshalAs(UnmanagedType.LPTStr)]
        public string lpClass;
        public IntPtr hkeyClass;
        public uint dwHotKey;
        public IntPtr hIcon;
        public IntPtr hProcess;
    }

    public static void ShowFileProperties(string filename)
    {
        SHELLEXECUTEINFO info = new SHELLEXECUTEINFO();
        info.cbSize = System.Runtime.InteropServices.Marshal.SizeOf(info);
        info.lpVerb = "properties";
        info.lpFile = filename;
        info.nShow = 1;
        info.fMask = 0x0000000C;
        info.hwnd = IntPtr.Zero;
        ShellExecuteEx(ref info);
    }
}
'@

# Compile the C# code and create the .NET type
Add-Type -TypeDefinition $cSharpCode -Language CSharp
# Import UI Automation assemblies
Add-Type -AssemblyName "UIAutomationClient"
Add-Type -AssemblyName "UIAutomationTypes"


# Define the PowerShell function
function Open-FileProperty {
    param (
        [string]$path
    )
    $logPath = "C:\temp\openfile.txt"

    $executingUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $loggedInUser = "$([System.Environment]::UserDomainName)\$([System.Environment]::UserName)"
    # $processInfo = Get-Process -Id $PID
    # "Debug: Path is $path" | Out-File -FilePath $logPath -Append
    # "Debug: Executing user is $executingUser" | Out-File -FilePath $logPath -Append
    # "Debug: Logged in user is $loggedInUser" | Out-File -FilePath $logPath -Append
    # "Debug: PowerShell Session ID is $($processInfo.SessionId)" | Out-File -FilePath $logPath -Append

    if ($executingUser -eq $loggedInUser) {
        if (Test-Path -Path $path) {
            "Debug: Path exists." | Out-File -FilePath $logPath -Append
            try {
                $result = [FileProperties]::ShowFileProperties($path)
                "Debug: ShowFileProperties result: $result" | Out-File -FilePath $logPath -Append
                #TODO : Handle this better ? 
                Start-Sleep -Seconds 500  # Sleep for 10 seconds
            }
            catch {
                $errorMessage = $_.Exception.Message
                "Error: Unable to show file properties. Error message: $errorMessage" | Out-File -FilePath $logPath -Append
                "Error: Unable to show file properties. Error message: $errorMessage"
            }
        } else {
            "Debug: Path does not exist." | Out-File -FilePath $logPath -Append
        }
    } else {
        "Error: Mismatch between executing user and logged-in user. Cannot proceed." | Out-File -FilePath $logPath -Append
    }
}

# Function to automate clicking on the "Advanced" button
function Open-AdvancedSecurityTab {
    param (
        [string]$path
    )
    
    # Run Open-FileProperty asynchronously as a background job
    Start-Job -ScriptBlock {
        # Replace with your Open-FileProperty function call
        Open-FileProperty -path $using:path
    }

    # Wait a bit to ensure the Properties window is open
    Start-Sleep -Seconds 2

    $fileName = [System.IO.Path]::GetFileName($path)
    $root = [System.Windows.Automation.AutomationElement]::RootElement

    # Find the Properties window by its title
    $propWindow = $root.FindFirst(
        [System.Windows.Automation.TreeScope]::Children, 
        [System.Windows.Automation.AutomationElement]::NameProperty.ConditionFor($fileName + " Properties")
    )

    if ($propWindow -eq $null) {
        Write-Host "Properties window not found."
        return
    }

    # Find the "Security" or "Sécurité" tab
    $securityTab = $propWindow.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants, 
        [System.Windows.Automation.AutomationElement]::NameProperty.ConditionFor("Security")
    )
    if ($securityTab -eq $null) {
        $securityTab = $propWindow.FindFirst(
            [System.Windows.Automation.TreeScope]::Descendants, 
            [System.Windows.Automation.AutomationElement]::NameProperty.ConditionFor("Sécurité")
        )
    }

    if ($securityTab -eq $null) {
        Write-Host "Security tab not found."
        return
    }

    # Click the "Security" or "Sécurité" tab
    $invokePattern = $securityTab.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $invokePattern.Invoke()

    Start-Sleep -Seconds 2  # Wait for the tab to load

    # Find the "Advanced" or "Avancé" button
    $advancedButton = $propWindow.FindFirst(
        [System.Windows.Automation.TreeScope]::Descendants, 
        [System.Windows.Automation.AutomationElement]::NameProperty.ConditionFor("Advanced")
    )
    if ($advancedButton -eq $null) {
        $advancedButton = $propWindow.FindFirst(
            [System.Windows.Automation.TreeScope]::Descendants, 
            [System.Windows.Automation.AutomationElement]::NameProperty.ConditionFor("Avancé")
        )
    }

    if ($advancedButton -eq $null) {
        Write-Host "Advanced button not found."
        return
    }

    # Get the "Invoke" pattern and invoke (click) the button
    $invokePattern = $advancedButton.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
    $invokePattern.Invoke()
}


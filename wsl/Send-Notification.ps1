# Define mandatory parameters
param (
    [Parameter(Mandatory=$true)]
    [string]$Title,
  
    [Parameter(Mandatory=$true)]
    [string]$Message
)

# Import the BurntToast module
# BurnToast need to be installed globally to work 
Import-Module BurntToast

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Custom image path relative to script path
$ImagePath = Join-Path $ScriptPath "nnnlogo-128x128.ico"

# Create and show the toast notification
New-BurntToastNotification -Text $Title, $Message -AppLogo $ImagePath -Silent


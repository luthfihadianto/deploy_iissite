Param(    [Parameter(Mandatory=$true)]    [string]$ApplicationName,    [Parameter(Mandatory=$true)]
    [string]$Username,
    [Parameter(Mandatory=$true)]
    [string]$Password
 #   [Parameter(Mandatory=$true)]
 #   [string]$CertTumbPrint,
 #   [Parameter(Mandatory=$true)]
 #   [string]$Domain
)#Create virtual directories$Path = "C:\inetpub\apps\"+$ApplicationName.ToLower() md $Path$FileName = "C:\inetpub\apps\"+$ApplicationName.ToLower()+"\index.htm"$ContentFile = "<body>"+$ApplicationName.ToLower()+"</body>"#New-Item $FileName -type file -force -value $ContentFile Write-Host "Virtual Directories $Path has been created" -ForegroundColor WhiteWrite-Host "Extracting Template App to Path $Path..." -ForegroundColor YellowExpand-Archive -Path appinfra.zip -DestinationPath $Path$FileAppSetting = $Path+"\appsettings.json"((Get-Content -Path $FileAppSetting -Raw) -replace '###HOSTNAME###',$ApplicationName.ToLower()) | Set-Content -Path $FileAppSettingImport-Module iisadministration
#Create IIS Application Pool
$AppPoolName = $ApplicationName 
if(Test-Path ("IIS:\AppPools\" + $AppPoolName)) 
{
    Write-Host "The App Pool $AppPoolName already exists" -ForegroundColor Yellow
}
else
{
    New-WebAppPool -Name $AppPoolName
}
Set-ItemProperty IIS:\AppPools\$($AppPoolName) -name processModel -value @{userName="$($Username)";password="$($Password)";identitytype=3}

#Create IIS Web Application
$Path = "C:\inetpub\apps\" + $ApplicationName.ToLower()

$WebAppName = $ApplicationName 
$HostHeader = $ApplicationName

New-WebSite -Name $WebAppName -Port 80 -HostHeader $HostHeader -PhysicalPath $Path -ApplicationPool $AppPoolName

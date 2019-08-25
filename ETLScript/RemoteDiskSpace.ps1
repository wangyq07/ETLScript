$flag=$TRUE
$ips=(ipconfig|findstr "IPv4")
foreach($ip in $ips)
{
  $tempip=$ip.split(":")[1].trim() 
  if($tempip -ceq $args[2])
  {
    $flag=$FALSE
    break
  }
}
$hostname=hostname
if( (($flag)  -and( $args[2] -ceq $hostname)) -or($args[2] -ceq "127.0.0.1") -or ($args[2] -ceq "."))
{
 $flag=$FALSE
}
if($flag)
{
$pwd = ConvertTo-SecureString $args[0] -AsPlainText -Force
$c = New-Object System.Management.Automation.PSCredential ($args[1], $pwd)
Invoke-Command -ComputerName $args[2] -Credential $c -FilePath .\CheckDiskSpace.ps1 -ArgumentList $args[2],$args[3],$args[4]
$mySession = new-PSSession -ComputerName $args[2] -Credential $c
$FileName=$args[4]
$RemotePath=(-Join($args[3] , "\$FileName"+"DiskSpaceResult.csv"))
$LocalPath=".\$FileName"+"DiskSpaceResult.csv"
Copy-Item -Path $RemotePath -Destination $LocalPath -FromSession $mySession
}
else
{
  .\CheckDiskSpace.ps1  $args[2] ./ $args[4]
}

#Copy-Item -Path C:\PowerShell -Destination F:\temp -FromSession $mySession -Recurse
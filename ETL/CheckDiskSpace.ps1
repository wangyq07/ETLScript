$levelname=$args[0] 
$FileName=$args[2]
$resultfile = (-Join($args[1] , "\$FileName"+"DiskSpaceResult.csv"));
Out-File $resultfile -InputObject 'DISK_NAME,FREE_SPACE,LEVEL_NAME' -Encoding UTF8
$DiskCount = ((Get-WmiObject -Class Win32_DiskDrive).Caption).count
 #获取磁盘分区大小
$DiskInfo = Get-WmiObject -Class Win32_LogicalDisk     
foreach ($Drivers in $DiskInfo) 
  {
    $PartitionID =$Drivers.DeviceID -Replace ":", " DISK"
    $TotalSize=$Drivers.Size 
    $FreeSize=$Drivers.FreeSpace
     #Write-Host $TotalSize
    if(!$TotalSize)
    {
     continue
     }
      $f = [System.Math]::Round($FreeSize/$TotalSize*100,2)
      $m = $PartitionID+','+$f + ',' + $FileName
	  Out-File -append $resultfile -InputObject  $m -Encoding UTF8
     
  }
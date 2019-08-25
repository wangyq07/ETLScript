$location = $PSScriptRoot
#$resultfile = (-Join($location , "\CheckPerformanceResult.csv"));
$FileName=$args[2]
 function Get-CpuUtil
 { 
   param( 
        $Server =$env:computername,
        $resultfile=$env:string	
       ) 
       $os = gwmi win32_perfformatteddata_perfos_processor -computername $Server | ? {$_.name -eq "_total"} | select -ExpandProperty PercentProcessorTime  -ea silentlycontinue 
	   $m = 'CPU,'+$os + ',' + $FileName
	   Out-File -append $resultfile -InputObject  $m -Encoding UTF8
 } 

function Get-MemoryUtil
 { 
   param( 
        $Server =$env:computername,
		$resultfile=$env:string
       ) 
       $mem = Get-WmiObject win32_operatingsystem -computername $Server | Foreach {"{0:N2}" -f ((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory)*100)/ $_.TotalVisibleMemorySize)}
	   $m = 'MEMORY,'+$mem + ',' + $FileName
	   Out-File -append $resultfile -InputObject  $m -Encoding UTF8
 }  
 
#######################cpu function end#################  
$server=$args[0]  

$resultfile=(-Join($args[1]  , "\$FileName"+"PerformanceResult.csv"))
Out-File $resultfile -InputObject 'NAME,UTILIZATION,LEVEL_NAME' -Encoding UTF8
Get-CpuUtil  $server $resultfile
Get-MemoryUtil  $server $resultfile

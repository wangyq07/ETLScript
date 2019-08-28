cd C:\ETL\data-integration
Kitchen.bat /norep /file c:\ETL\ETLScript\ETLScript\PerfermanceCheck.kjb   >> PerfermanceCheck_%date:~0,4%%date:~5,2%%date:~8,2%%h%%time:~3,2%%time:~6,2%.txt
Kitchen.bat /norep /file c:\ETL\ETLScript\ETLScript\DBCheckConnection.kjb   >> DBCheckConnection_%date:~0,4%%date:~5,2%%date:~8,2%%h%%time:~3,2%%time:~6,2%.txt
exit
 
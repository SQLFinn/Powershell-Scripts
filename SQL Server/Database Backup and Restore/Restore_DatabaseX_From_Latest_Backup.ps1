<#
.SYNOPSIS
   Script for restoring last backupfile from directory.
.DESCRIPTION
   This script will search for the latest .BAK file from the
   given directory and restore it to current SQL Server instance.
.PARAMETER <paramName>
   N/A
.EXAMPLE
   powershell.exe -file .\Path_To_PS_files\Restore_DatabaseX_From_Latest_Backup.ps1
#>

# First we need to load the SMO assemblies for managing SQL Server.
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

# Next step is to set the variables for the restore command
# Change the server name, backup filepath, database name to restore and where
# to place the data- and logfiles.
$dbServerName = 'SERVERNAME1'
$dbBackupFilePath = '\\SERVERNAME1\BackupShare$\FULL\'
$dbBackupFileName = Get-ChildItem $dbBackupFilePath | Select-Object Name | Where-Object { $_.Name -Like "*.BAK" }| SORT LastWriteTime | SELECT -Last 1
$dbRestoreFile = $dbBackupFilePath+$dbBackupFileName.Name
$dbRestoreName = 'DatabaseNameHere'
$dbDataFile = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile('DBDataFile', 'X:\DBDataFileLoc\RestoredDataFile.MDF')
$dbLogFile = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile('DBLogFile', 'X:\DBLogFileLoc\RestoredLogFile.LDF')

# Executing the restore.
Restore-SqlDatabase -ServerInstance $dbServerName -Database $dbRestoreName -BackupFile $dbRestoreFile -RelocateFile @($dbDataFile,$dbLogFile) -NoRecovery
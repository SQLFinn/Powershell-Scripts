<#
.SYNOPSIS
   Script for initializing log shipping.
.DESCRIPTION
   This script will search for the latest .BAK file from the
   given directory and restore it to current SQL Server instance.
   It'll be left in norecovery mode for restoring logs.
.PARAMETER <paramName>
   N/A
.EXAMPLE
    powershell.exe -file .\Path_To_PS_files\Initialize_LogShipping_DatabaseX.ps1
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
$dbCopyFile = $dbBackupFilePath+$dbBackupFileName.Name
$dbRestoreName = 'DATABASENAME1'
$dbDataFile = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile('DBDataFile', 'X:\DBDataFileLoc\RestoredDataFile.MDF')
$dbLogFile = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile('DBLogFile', 'X:\DBLogFileLoc\RestoredLogFile.LDF')

# Copy the backup file to local server.
Copy-Item $dbCopyFile X:\DBBackupFolder\
$dbRestoreFile = 'X:\DBBackupFolder\'+$dbBackupFileName.Name

# Executing the restore.
Restore-SqlDatabase -ServerInstance $dbServerName -Database $dbRestoreName -BackupFile $dbRestoreFile -RelocateFile @($dbDataFile,$dbLogFile) -NoRecovery

# Cleaning up backups after restore.
Remove-Item 'X:\DBBackupFolder\*.BAK'
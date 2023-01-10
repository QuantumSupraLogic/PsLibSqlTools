#region documentation

#endregion

#region scriptheader
#requires -version 3.0
Import-Module ($(Get-Item $PSScriptRoot).Parent.FullName + "\SqlTools\SqlTools.Execute.psm1")
#endregion

#region code
function New-BackupDatabaseSqlQuery {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $srcDatabaseName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $backupLocation,
        [switch]
        $withCompression,
        [switch]
        $copyOnly
    )
        
    $backupName = $srcDatabaseName + '-Full Database Backup'
    $sqlQuery = "BACKUP DATABASE $srcDatabaseName TO  DISK = N'$backupLocation' WITH "
    if ($copyOnly) {
        $sqlQuery += "COPY_ONLY, "
    }
    if ($withCompression) {
        $sqlQuery += "COMPRESSION, "
    }
    $sqlQuery += "NOFORMAT, NOINIT,  NAME = N'$backupName', SKIP, NOREWIND, NOUNLOAD,  STATS = 10"

    return $sqlQuery
}

function New-RestoreDatabaseSqlWithOverwriteQuery {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dstDataSource,
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string] 
        $dstDatabaseName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $backupLocation
    )

    $QueryToCreateRestoreQuery = "
        USE $dstDatabaseName
        SELECT name as LogicalName, physical_name as PhysicalName FROM sys.database_files"

    $queryResult = Invoke-SQL -databaseName $dstDatabaseName -dataSource $dstDataSource -sqlQuery $QueryToCreateRestoreQuery 
    $dbFiles = $queryResult
        
    $sqlQuery = "
        USE [master]
        ALTER DATABASE $dstDatabaseName SET SINGLE_USER WITH ROLLBACK IMMEDIATE
        RESTORE DATABASE $dstDatabaseName FROM  DISK = N'$backupLocation' WITH  FILE = 1"

    foreach ($dbFile in $dbFiles) {
        $logicalName = $dbFile.LogicalName
        $physicalName = $dbFile.PhysicalName
        $sqlQuery = $sqlQuery + ",MOVE  N'$logicalName' TO N'$physicalName'"
    }

    $sqlQuery = $sqlQuery + ", NOUNLOAD, REPLACE, STATS = 5
        ALTER DATABASE $dstDatabaseName SET MULTI_USER"
    
    return $sqlQuery
}

function New-ChangeDatabaseRecoveryModelSqlQuery{
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [string] 
        $databaseName,
        [Parameter(Mandatory=$true)]
        [ValidateSet('Full', 'Bulk-Logged', 'Simple')]
        [string]
        $recoveryModel
    )

    $sqlQuery = "
        USE [master]
        ALTER DATABASE $databaseName SET RECOVERY $recoveryModel"
        
    return $sqlQuery
}
#endregion
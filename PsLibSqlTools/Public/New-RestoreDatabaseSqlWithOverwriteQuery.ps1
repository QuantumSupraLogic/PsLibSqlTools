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
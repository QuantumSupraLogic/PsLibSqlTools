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